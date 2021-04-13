VERSION := `cat VERSION`
CURRENT := retro:${VERSION}
DOCKERHUB_TARGET := enterhaken/retro:${VERSION}
DOCKERHUB_TARGET_LATEST := enterhaken/retro:latest


.PHONY: default
default: build

.PHONY: check_deps
check_deps:
	if [ ! -d deps ]; then mix deps.get; fi

.PHONY: client
client:
	make -C ./client

.PHONY: build_client_if_missing
build_client_if_missing:
	if [ ! -d ./client/dist/Retro/ ]; then make client; fi;

.PHONY: build
build: check_deps build_client_if_missing 
	mix compile --force --warnings-as-errors

.PHONY: run
run: build
	iex -S mix

.PHONY: clean
clean:
	rm _build/ -rf || true

.PHONY: clean_deps
clean_deps:
	rm deps/ -rf || true

.PHONY: clean_client
clean_client:
	make -C ./client deep_clean

.PHONY: deep_clean
deep_clean: clean clean_deps clean_client

.PHONY: test
test: check_deps
	mix test --trace

.PHONY: release
release: build
	MIX_ENV=prod mix release

.PHONY: loc
loc:
	make -C client loc
	find lib -type f | while read line; do cat $$line; done | sed '/^\s*$$/d' | wc -l

.PHONY: docker
docker: 
	docker build -t ${CURRENT} .

.PHONY: docker_run
docker_run:
	docker run \
		-p 5053:4050 \
		--name retro \
		-d \
		-t retro:${VERSION}

.PHONY: docker_push
docker_push:
	docker tag $(CURRENT) $(DOCKERHUB_TARGET) 
	docker push $(DOCKERHUB_TARGET)
	docker tag $(CURRENT) $(DOCKERHUB_TARGET_LATEST) 
	docker push $(DOCKERHUB_TARGET_LATEST)
	
.PHONY: update
update: docker
	docker stop retro 
	docker rm retro 
	make docker_run

.PHONY: logs
logs:
	docker logs -tf retro

.PHONY: ignore
ignore:
	find deps/ > .ignore || true
	find doc/ >> .ignore || true
	find _build/ >> .ignore || true
	find client/node_modules/ >> .ignore || true
