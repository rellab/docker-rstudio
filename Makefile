IMAGE=rel/rstudio

build: build-latest

build-latest: Dockerfile-base
	docker build -t ${IMAGE}:latest --build-arg TAG=latest -f Dockerfile-base .

clean:
	docker images | grep ${IMAGE} | awk '{print $3;}' | xargs docker rmi 
	