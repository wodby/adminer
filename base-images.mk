# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := wodby/php
BASE_IMAGE_VERSION_SUFFIX :=

BASE_IMAGE_DIGEST_8.4-apache := sha256:21d688a1b314017d5ad34a8bba27ace3d9fb4b9c4c175a8aa7f59bd71fa3aac0
BASE_IMAGE_DIGEST_8.4-apache-r13 := sha256:9ac5f59e62270b8641ec7077d9da03977bcab4000daef37cbc5a0c82f7f4fd83

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
