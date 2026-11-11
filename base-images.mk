# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := wodby/php
BASE_IMAGE_VERSION_SUFFIX :=

BASE_IMAGE_DIGEST_8.4-apache := sha256:1640b58c44ce13519da473f2ddbab223d82513f28c314d0054038fd206d1b250
BASE_IMAGE_DIGEST_8.4-apache-r14 := sha256:fa21a4a7f348a5e8f50ebb8759188ce7b760d6a9e3ad2d466b61a5d1d05e3d4a

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
