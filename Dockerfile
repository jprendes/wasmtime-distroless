# syntax=docker/dockerfile:1.13-labs
FROM --platform=$BUILDPLATFORM ghcr.io/cross-rs/aarch64-unknown-linux-musl:edge AS cross-arm64
ENV CARGO_BUILD_TARGET=aarch64-unknown-linux-musl

FROM --platform=$BUILDPLATFORM ghcr.io/cross-rs/x86_64-unknown-linux-musl:edge AS cross-amd64
ENV CARGO_BUILD_TARGET=x86_64-unknown-linux-musl

FROM --platform=$BUILDPLATFORM rust AS rust

ARG TARGETARCH
FROM cross-$TARGETARCH AS cross
COPY --from=rust /usr/local/cargo /usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
RUN rustup default stable
RUN rustup target add $CARGO_BUILD_TARGET

FROM cross AS build
ARG VERSION=latest
RUN /usr/local/cargo/bin/cargo install \
    $(echo $VERSION | sed -E 's/^latest$//;s/.+/--version=\0/') \
    --profile='fastest-runtime' \
    --config='profile.fastest-runtime.strip="symbols"' \
    --config='profile.fastest-runtime.panic="abort"' \
    wasmtime-cli
RUN cp $CARGO_HOME/bin/wasmtime /wasmtime

FROM scratch
COPY --from=build /wasmtime /wasmtime