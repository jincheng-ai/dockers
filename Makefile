#!/usr/bin/make -f
USER := jincheng
IMAGE := camera
VERSION := latest
PWD := $(shell pwd)

.PHONY: all build-test build rebuild shell run test

#--------------------------

all: build

# create image

build-slam:
	docker build -t=$(USER)/$(IMAGE)-slam:$(VERSION) -f ./Dockerfile.SLAM .

build-test:
	docker build -t=$(USER)/$(IMAGE)-test:$(VERSION) -f ./Dockerfile.Test .

build:
	docker build -t=$(USER)/$(IMAGE):$(VERSION) .

rebuild:
	docker build -t=$(USER)/$(IMAGE):$(VERSION) --no-cache .

buildx-arm64:
	docker buildx build --platform linux/arm64  -t=$(USER)/$(IMAGE):$(VERSION) .

buildx-test:
	docker buildx build --platform linux/amd64, linux/arm64, linux/ppc64le  -t=$(USER)/$(IMAGE):$(VERSION) -f ./Dockerfile.Test .

rebuildx:
	docker buildx build --platform linux/amd64, linux/arm64, linux/ppc64le  -t=$(USER)/$(IMAGE):$(VERSION) --no-cache .

shell:
	docker run --rm -it -p 7890:7890 --gpus all $(USER)/$(IMAGE):$(VERSION) bash

shell-test:
	docker run --rm -it --gpus all -e TZ=Asia/Shanghai $(USER)/$(IMAGE)-test:$(VERSION) bash

shell-slam:
	docker run --rm -it -p 7890:7890 --gpus all --privileged -v /dev/video0:/dev/video0  -e DISPLAY=unix$(DISPLAY) -e TZ=Asia/Shanghai -v /tmp/.X11-unix:/tmp/.X11-unix/ -v  $(PWD)/:/home/ubuntu/workspace $(USER)/$(IMAGE)-slam:$(VERSION) bash

# run
run:
	docker run --rm -it -p 7890:7890 --gpus all $(USER)/$(IMAGE):$(VERSION)

# 从镜像导出 docker save -o jincheng_camera_latest.tar jincheng/camera:latest
save:
    docker save -o $(USER)_$(IMAGE)_$(VERSION).tar $(USER)/$(IMAGE):$(VERSION)