IMAGE_NAME = bookkeeper
CONTAINER_NAME = bookkeeper-container

.PHONY: build run rebuild clean

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -d --name $(CONTAINER_NAME) --env-file .env -p 8080:8080 $(IMAGE_NAME)

rebuild: clean build run

clean:
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true

logs:
	docker logs -f $(CONTAINER_NAME)