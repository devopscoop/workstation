FROM alpine:3.13.5

# Adding Cloud Service Provider (CSP) argument to build separate images for AWS and GCP.
ARG CSP

RUN apk add --no-cache curl
