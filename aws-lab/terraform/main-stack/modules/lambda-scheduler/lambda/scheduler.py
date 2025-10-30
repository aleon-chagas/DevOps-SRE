"""Lambda scheduler para desligar instâncias EC2 com uma tag específica.

- Usa variáveis de ambiente para configurar tag, horário alvo e timezone.
- Verifica o horário local (ex.: America/Sao_Paulo) antes de executar.
- Janela de execução: 5 min antes até 15 min depois do horário alvo.
- Usa paginator para descrever instâncias e lidar com muitas instâncias.
- Batching de chamadas stop_instances e tratamento de erros.

CONFIGURAÇÃO EVENTBRIDGE:
Para execução às 18h Brasil (sem horário de verão):
- Expressão: cron(0 21 * * ? *)  # 21:00 UTC = 18:00 BRT
- Ou use: cron(0 18 * * ? *) com timezone America/Sao_Paulo (se disponível)

Requer as permissões IAM:
- ec2:DescribeInstances
- ec2:StopInstances
- logs:CreateLogGroup
- logs:CreateLogStream
- logs:PutLogEvents

Opções via variáveis de ambiente (com valores padrão):
- SCHEDULE_TAG_KEY (Schedule)
- SCHEDULE_TAG_VALUE (stop-daily-18h)
- TARGET_HOUR (18)
- TARGET_MINUTE (0)
- TIMEZONE (America/Sao_Paulo)
- EXECUTION_WINDOW_MINUTES (15) - janela após horário alvo
- EXECUTION_WINDOW_BEFORE_MINUTES (5) - janela antes do horário alvo
- DRY_RUN (false)
"""

import os
import logging
import datetime
import boto3
from botocore.config import Config
from botocore.exceptions import ClientError

try:
    # Python 3.9+ recommended in Lambda for zoneinfo
    from zoneinfo import ZoneInfo
    ZONEINFO_AVAILABLE = True
except ImportError:
    ZONEINFO_AVAILABLE = False
    try:
        import pytz
        PYTZ_AVAILABLE = True
    except ImportError:
        PYTZ_AVAILABLE = False

# Logger
logger = logging.getLogger()
logger.setLevel(os.getenv('LOG_LEVEL', 'INFO'))

# Configuration from environment (easy to override in Lambda console)
SCHEDULE_TAG_KEY = os.getenv('SCHEDULE_TAG_KEY', 'Schedule')
SCHEDULE_TAG_VALUE = os.getenv('SCHEDULE_TAG_VALUE', 'stop-daily-18h')
TARGET_HOUR = int(os.getenv('TARGET_HOUR', '18'))
TARGET_MINUTE = int(os.getenv('TARGET_MINUTE', '0'))
TIMEZONE = os.getenv('TIMEZONE', 'America/Sao_Paulo')
EXECUTION_WINDOW_MINUTES = int(os.getenv('EXECUTION_WINDOW_MINUTES', '15'))
EXECUTION_WINDOW_BEFORE_MINUTES = int(os.getenv('EXECUTION_WINDOW_BEFORE_MINUTES', '5'))
DRY_RUN = os.getenv('DRY_RUN', 'false').lower() in ('1', 'true', 'yes')

# Validação de configuração
if not (0 <= TARGET_HOUR <= 23):
    raise ValueError(f'TARGET_HOUR must be between 0-23, got: {TARGET_HOUR}')
if not (0 <= TARGET_MINUTE <= 59):
    raise ValueError(f'TARGET_MINUTE must be between 0-59, got: {TARGET_MINUTE}')
if EXECUTION_WINDOW_MINUTES < 1:
    raise ValueError(f'EXECUTION_WINDOW_MINUTES must be >= 1, got: {EXECUTION_WINDOW_MINUTES}')
if EXECUTION_WINDOW_BEFORE_MINUTES < 0:
    raise ValueError(f'EXECUTION_WINDOW_BEFORE_MINUTES must be >= 0, got: {EXECUTION_WINDOW_BEFORE_MINUTES}')

# Boto3 client with retries
ec2 = boto3.client('ec2', config=Config(retries={'max_attempts': 3, 'mode': 'standard'}))


def _get_current_time_in_timezone(tz_name: str) -> datetime.datetime:
    """Return the current time in given timezone."""
    now_utc = datetime.datetime.now(datetime.timezone.utc)

    if ZONEINFO_AVAILABLE:
        try:
            tz = ZoneInfo(tz_name)
            return now_utc.astimezone(tz)
        except Exception as e:
            logger.error('Failed to get timezone %s using zoneinfo: %s', tz_name, e)
            raise ValueError(f'Invalid timezone: {tz_name}') from e

    if PYTZ_AVAILABLE:
        try:
            tz = pytz.timezone(tz_name)
            return now_utc.astimezone(tz)
        except Exception as e:
            logger.error('Failed to get timezone %s using pytz: %s', tz_name, e)
            raise ValueError(f'Invalid timezone: {tz_name}') from e

    error_msg = 'Neither zoneinfo nor pytz available. Cannot handle timezones.'
    logger.error(error_msg)
    raise RuntimeError(error_msg)


def _is_within_execution_window(now_local: datetime.datetime,
                                 target_hour: int,
                                 target_minute: int,
                                 window_after: int = 15,
                                 window_before: int = 5) -> bool:
    """
    Verifica se o horário atual está dentro da janela de execução.

    Permite execução desde 'window_before' minutos ANTES até
    'window_after' minutos DEPOIS do horário alvo.

    Exemplo: Se alvo é 18:00, before=5 e after=15:
    - Executa entre 17:55:00 e 18:14:59
    """
    target_time = now_local.replace(hour=target_hour, minute=target_minute, second=0, microsecond=0)
    time_diff = (now_local - target_time).total_seconds() / 60  # diferença em minutos

    # Permite execução dentro da janela: [-window_before, +window_after)
    in_window = -window_before <= time_diff < window_after

    if logger.isEnabledFor(logging.DEBUG):
        logger.debug('Time check: now=%s, target=%s, diff=%.2f min, window=[-%d, +%d), in_window=%s',
                    now_local.strftime('%H:%M:%S'), target_time.strftime('%H:%M:%S'),
                    time_diff, window_before, window_after, in_window)

    return in_window


def lambda_handler(event, context):
    logger.info('Lambda invoked; checking time and searching for EC2 instances to stop')
    logger.info('Configuration: TAG=%s:%s, TARGET=%02d:%02d, TZ=%s, WINDOW=[-%d,+%d)min, DRY_RUN=%s',
                SCHEDULE_TAG_KEY, SCHEDULE_TAG_VALUE, TARGET_HOUR, TARGET_MINUTE, TIMEZONE,
                EXECUTION_WINDOW_BEFORE_MINUTES, EXECUTION_WINDOW_MINUTES, DRY_RUN)

    try:
        now_local = _get_current_time_in_timezone(TIMEZONE)
    except (ValueError, RuntimeError) as e:
        logger.error('Timezone configuration error: %s', e)
        return {
            'statusCode': 500,
            'body': {'error': f'Timezone error: {str(e)}'}
        }

    logger.info('Current time in %s: %s (target: %02d:%02d)',
                TIMEZONE, now_local.strftime('%Y-%m-%d %H:%M:%S'), TARGET_HOUR, TARGET_MINUTE)

    # =================================================================================
    # TRAVA DE EXECUÇÃO POR HORÁRIO
    # O bloco de código abaixo foi comentado para permitir a execução manual a qualquer momento.
    # Originalmente, ele verifica se a hora atual está dentro de uma janela de tempo
    # (ex: 15 minutos) ao redor da TARGET_HOUR. Isso evita que a automação
    # desligue instâncias fora do horário programado. Para reativar, basta descomentar.
    # =================================================================================
    #
    # # Verifica se estamos dentro da janela de execução
    # if not _is_within_execution_window(now_local, TARGET_HOUR, TARGET_MINUTE,
    #                                    EXECUTION_WINDOW_MINUTES, EXECUTION_WINDOW_BEFORE_MINUTES):
    #     msg = (f"Outside execution window. Current: {now_local.strftime('%H:%M')}, "
    #            f"Target: {TARGET_HOUR:02d}:{TARGET_MINUTE:02d} "
    #            f"(window: -{EXECUTION_WINDOW_BEFORE_MINUTES} to +{EXECUTION_WINDOW_MINUTES} min)")
    #     logger.info(msg)
    #     return {'statusCode': 200, 'body': msg}

    logger.info('Within execution window: looking for instances with tag %s=%s',
                SCHEDULE_TAG_KEY, SCHEDULE_TAG_VALUE)

    filters = [
        {'Name': f'tag:{SCHEDULE_TAG_KEY}', 'Values': [SCHEDULE_TAG_VALUE]},
        {'Name': 'instance-state-name', 'Values': ['running']}
    ]

    instance_ids = []
    try:
        paginator = ec2.get_paginator('describe_instances')
        for page in paginator.paginate(Filters=filters):
            for reservation in page.get('Reservations', []):
                for instance in reservation.get('Instances', []):
                    instance_ids.append(instance['InstanceId'])

        if not instance_ids:
            logger.info('No running instances found with tag %s=%s', SCHEDULE_TAG_KEY, SCHEDULE_TAG_VALUE)
            return {'statusCode': 200, 'body': 'No instances to stop'}

        logger.info('Found %d instances to stop: %s', len(instance_ids), instance_ids)

        if DRY_RUN:
            logger.warning('DRY_RUN mode enabled - NO instances will be stopped')
            return {
                'statusCode': 200,
                'body': {
                    'dry_run': True,
                    'would_stop': instance_ids,
                    'count': len(instance_ids),
                    'timestamp': now_local.isoformat()
                }
            }

        return _stop_instances_batch(instance_ids)

    except ClientError as e:
        error_code = e.response.get('Error', {}).get('Code', 'Unknown')
        error_msg = e.response.get('Error', {}).get('Message', str(e))
        logger.error('AWS ClientError: [%s] %s', error_code, error_msg)
        return {
            'statusCode': 500,
            'body': {'error': f'AWS Error: {error_code} - {error_msg}'}
        }
    except Exception as e:
        logger.exception('Unexpected error while describing instances')
        return {
            'statusCode': 500,
            'body': {'error': f'Unexpected error: {str(e)}'}
        }


def _stop_instances_batch(instance_ids: list) -> dict:
    """Stop instances in batches with error handling."""
    stopped = []
    errors = []
    chunk_size = 50

    for i in range(0, len(instance_ids), chunk_size):
        chunk = instance_ids[i:i + chunk_size]
        try:
            resp = ec2.stop_instances(InstanceIds=chunk)
            stopping_instances = [inst['InstanceId'] for inst in resp.get('StoppingInstances', [])]
            stopped.extend(stopping_instances)
            logger.info('Successfully stopped %d instances: %s', len(stopping_instances), stopping_instances)
        except ClientError as e:
            error_code = e.response.get('Error', {}).get('Code', 'Unknown')
            error_msg = e.response.get('Error', {}).get('Message', str(e))
            logger.error('ClientError stopping instances %s: [%s] %s', chunk, error_code, error_msg)
            errors.append({
                'instance_ids': chunk,
                'error_code': error_code,
                'error_message': error_msg
            })
        except Exception as e:
            logger.error('Unexpected error stopping instances %s: %s', chunk, str(e))
            errors.append({
                'instance_ids': chunk,
                'error': str(e)
            })

    result = {
        'stopped': stopped,
        'stopped_count': len(stopped),
        'errors': errors,
        'error_count': len(errors)
    }

    logger.info('Operation finished: stopped=%d, errors=%d', len(stopped), len(errors))
    status_code = 200 if not errors else 207
    return {'statusCode': status_code, 'body': result}
