VERSION ?= latest
PLATFORM ?= linux/amd64,linux/arm64

export DOCKER_CLI_HINTS=false

.PHONY: build run hello wasmtime clean

build: hello

run: hello
	docker run --rm -it ghcr.io/jprendes/wasmtime-distroless/hello:$(VERSION)

wasmtime:
	docker build . \
		--build-arg VERSION=$(VERSION) \
		--platform $(PLATFORM) \
		--tag ghcr.io/jprendes/wasmtime-distroless/wasmtime:$(VERSION) \
		--load

hello: wasmtime
	docker build . \
		-f Dockerfile.hello \
		--build-arg VERSION=$(VERSION) \
		--platform $(PLATFORM) \
		--tag ghcr.io/jprendes/wasmtime-distroless/hello:$(VERSION) \
		--load

clean:
	-docker image rm -f $$(docker image ls -f "reference=ghcr.io/jprendes/wasmtime-distroless/wasmtime:$(VERSION)" --format '{{.ID}}')
	-docker image rm -f $$(docker image ls -f "reference=ghcr.io/jprendes/wasmtime-distroless/hello:$(VERSION)" --format '{{.ID}}')
