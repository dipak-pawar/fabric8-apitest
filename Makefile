.PHONY: all
## Executes the prereq, deps, generate, and test targets
all: prereq deps generate test

VENDOR_DIR=./vendor
GLIDE_BIN=$(GOPATH)/bin/glide
GOAGEN_BIN=$(VENDOR_DIR)/github.com/goadesign/goa/goagen/goagen
SOURCES := $(shell find . -path ./vendor -prune -o -name '*.go' -print)
# For the global "clean" target all targets in this variable will be executed
CLEAN_TARGETS =

.PHONY: help
# Based on https://gist.github.com/rcmachado/af3db315e31383502660
## Display this help text.
help:/
	$(info Available targets)
	$(info -----------------)
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		helpCommand = substr($$1, 0, index($$1, ":")-1); \
		if (helpMessage) { \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub(/##/, "\n                                     ", helpMessage); \
		} else { \
			helpMessage = "(No documentation)"; \
		} \
		printf "%-35s - %s\n", helpCommand, helpMessage; \
		lastLine = "" \
	} \
	{ hasComment = match(lastLine, /^## (.*)/); \
          if(hasComment) { \
            lastLine=lastLine$$0; \
	  } \
          else { \
	    lastLine = $$0 \
          } \
        }' $(MAKEFILE_LIST)

.PHONY: prereq
## Installs the GO package management tool "glide" to $GOPATH/bin
prereq:
	curl https://glide.sh/get | sh

.PHONY: deps
## Download all dependencies into the vendor directory
deps:
	$(GLIDE_BIN) update

CLEAN_TARGETS += clean-deps
.PHONY: clean-deps
## Removes the ./vendor directory
clean-deps:
	-rm -rf $(VENDOR_DIR)

# Build the GOA generation tool that later takes a design folder and generates a
# client libraries from it.
$(GOAGEN_BIN): $(VENDOR_DIR)
	cd $(VENDOR_DIR)/github.com/goadesign/goa/goagen && go build -v

.PHONY: generate
## Generate the client libraries for the various services to test
generate: $(GOAGEN_BIN)
	$(GOAGEN_BIN) client -d github.com/fabric8-services/fabric8-wit/design --notool --pkg wit
	$(GOAGEN_BIN) client -d github.com/fabric8-services/fabric8-tenant/design --notool --pkg tenant
	$(GOAGEN_BIN) client -d github.com/fabric8-services/fabric8-notification/design --notool --pkg notification
	$(GOAGEN_BIN) client -d github.com/fabric8-services/fabric8-auth/design --notool --pkg auth

CLEAN_TARGETS += clean-generated
.PHONY: clean-generated
## Removes the ./wit, ./tenant, ./notification, and ./auth directory directory.
clean-generated:
	-rm -rf ./wit ./tenant ./notification ./auth

.PHONY: test
## Runs the API tests
test: $(SOURCES)
	go test -v

# Keep this "clean" target here at the bottom
.PHONY: clean
## Runs all clean-* targets.
clean: $(CLEAN_TARGETS)