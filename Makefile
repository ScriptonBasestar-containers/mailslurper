DOCKER_IMAGE_NAME=archmagece/mailslurper

build-enter:
	# 도커 이미지 에러나면 뒷쪽 주석치고 이렇게 실행
	@echo "Building..."
	docker build . -t testimg
	docker run -it --rm testimg sh

.phony: build
build:
	@echo "Building..."
	@go get
	@go generate
	@go build

.phony: docker-build
docker-build:
	@echo "Building Docker image..."
	@docker build -t $(DOCKER_IMAGE_NAME) .

.phony: docker-deploy
docker-deploy:
	@echo "Deploying Docker image..."
	@docker push $(DOCKER_IMAGE_NAME)
