all: build

.PHONY: all build build-web-base build-web-api run-base run-base-bash run-api run-api-bash exec-bash update

build:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile --progress=plain -t jimpick/localnet-farm-gateway .

run:
	-docker stop localnet-farm-gateway
	-docker rm localnet-farm-gateway
	docker run -it --name localnet-farm-gateway -p 3000:3000 jimpick/localnet-farm-gateway

exec-bash:
	docker exec -it localnet-farm-gateway bash -i
