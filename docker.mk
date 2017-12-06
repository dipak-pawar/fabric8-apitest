IMAGE_NAME=fabric8-apitest-image
CONTAINER_NAME=fabric8-apitest-container

$(IMAGE_NAME):
	# TODO(kwk): add --quiet param when using in CI
	docker build -t $(IMAGE_NAME) -f Dockerfile.builder $(CUR_DIR) 

.PHONY: docker-start
## Starts a docker container that is ready to run all make target in using
## make docker-XY where XY is a target from this make file
docker-start: $(IMAGE_NAME)
ifneq ($(strip $(shell docker ps -qa --filter "name=$(CONTAINER_NAME)" 2>/dev/null)),)
	@echo "Docker container \"$(CONTAINER_NAME)\" already exists. To recreate, run \"make clean-docker && make docker-start\"."
else
	docker run \
		--detach=true \
		-t \
		--name="$(CONTAINER_NAME)" \
		-u $(shell id -u $(USER)):$(shell id -g $(USER)) \
		-v $(CUR_DIR):/home/test/go/src/github.com/fabric8-services/fabric8-apitest:Z \
		$(IMAGE_NAME)
endif

CLEAN_TARGETS += clean-docker
.PHONY: clean-docker
## Removes the docker image and container
clean-docker:
ifneq ($(strip $(shell docker ps -qa --filter "name=$(CONTAINER_NAME)" 2>/dev/null)),)
	docker rm -f "$(CONTAINER_NAME)"
else
	@echo "No container named \"$(CONTAINER_NAME)\" to remove."
endif

# This is a wildcard target to let you call any make target from the normal makefile
# but it will run inside the docker container. This target will only get executed if
# there's no specialized form available. For example if you call "make docker-start"
# not this target gets executed but the "docker-start" target.
docker-%:
	$(eval makecommand:=$(subst docker-,,$@))
ifeq ($(strip $(shell docker ps -qa --filter "name=$(CONTAINER_NAME)" 2>/dev/null)),)
	$(error No container name "$(CONTAINER_NAME)" exists to run the command "make $(makecommand)")
endif
	docker exec -it "$(CONTAINER_NAME)" bash -ec 'make $(makecommand)'