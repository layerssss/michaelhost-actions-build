#!/bin/sh -e

IMAGE=$INPUT_REGISTRY/$INPUT_IMAGE_NAME:$INPUT_IMAGE_TAG

echo $INPUT_REGISTRY_PASSWORD | docker login -u "$INPUT_REGISTRY_USERNAME" --password-stdin "$INPUT_REGISTRY"

docker pull \
  $IMAGE \
  || true
docker build \
  -t $IMAGE \
  --cache-from $IMAGE \
  --file $INPUT_BUILD_CONTEXT/$INPUT_BUILD_FILE \
  $INPUT_BUILD_CONTEXT

docker push \
  $IMAGE

curl \
  --fail \
  -H "Authorization: Bearer ${INPUT_MICHAELHOST_SECRET}" \
  -X POST ${INPUT_MICHAELHOST_WEBHOOK_URL}/image\?repoName\=${INPUT_IMAGE_NAME}\&tag\=${INPUT_IMAGE_TAG}