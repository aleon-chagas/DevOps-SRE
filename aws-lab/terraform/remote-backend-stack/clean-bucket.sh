#!/bin/bash

BUCKET="devops-sre-aleon"

echo "Removing current versions..."
aws s3api list-object-versions \
    --bucket $BUCKET \
    --output json \
    --query 'Versions[].{Key:Key,VersionId:VersionId}' \
    | jq -c '.[]' \
    | while read -r version; do
        key=$(echo $version | jq -r '.Key')
        versionId=$(echo $version | jq -r '.VersionId')
        echo "Deleting $key version $versionId"
        aws s3api delete-object \
            --bucket $BUCKET \
            --key "$key" \
            --version-id "$versionId"
    done

echo "Removing delete markers..."
aws s3api list-object-versions \
    --bucket $BUCKET \
    --output json \
    --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' \
    | jq -c '.[]' \
    | while read -r marker; do
        key=$(echo $marker | jq -r '.Key')
        versionId=$(echo $marker | jq -r '.VersionId')
        echo "Deleting marker $key version $versionId"
        aws s3api delete-object \
            --bucket $BUCKET \
            --key "$key" \
            --version-id "$versionId"
    done

echo "Bucket should be empty now"
