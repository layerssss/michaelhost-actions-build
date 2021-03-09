#!/bin/sh -e

export DOCKER_BUILDKIT=$INPUT_DOCKER_BUILDKIT
IMAGE=$INPUT_REGISTRY/$INPUT_IMAGE_NAME:$INPUT_IMAGE_TAG

echo $INPUT_REGISTRY_PASSWORD | docker login -u "$INPUT_REGISTRY_USERNAME" --password-stdin "$INPUT_REGISTRY"

docker pull \
  $IMAGE \
  || true
docker build \
  -t $IMAGE \
  --cache-from $IMAGE \
  --file $INPUT_BUILD_CONTEXT/$INPUT_BUILD_FILE \
  $INPUT_BUILD_FLAGS \
  $INPUT_BUILD_CONTEXT

docker push \
  $IMAGE

url=${INPUT_MICHAELHOST_WEBHOOK_URL}/image\?repoName\=${INPUT_REGISTRY}/${INPUT_IMAGE_NAME}\&tag\=${INPUT_IMAGE_TAG}
echo "POST $url"
curl \
  --fail \
  -H "Authorization: Bearer ${INPUT_MICHAELHOST_SECRET}" \
  -X POST \
  $url
