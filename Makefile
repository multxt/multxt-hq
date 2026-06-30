# multxt-hq — master monorepo orchestration
# The real code lives in the submodules; this just drives them.

SUBMODULES := multxt smxt

.PHONY: bootstrap build test lint clean update-pointers help

help:
	@echo "multxt-hq targets:"
	@echo "  bootstrap  init submodules + install deps in each package"
	@echo "  build      build every package (tsc)"
	@echo "  test       run each package's test suite"
	@echo "  lint       lint every package"
	@echo "  update-pointers  fetch latest of each submodule's default branch"
	@echo "  clean      remove build artifacts"

bootstrap:
	git submodule update --init --recursive
	@for d in $(SUBMODULES); do \
		if [ -f $$d/package.json ]; then echo "==> npm install ($$d)"; (cd $$d && npm install); fi; \
	done

build:
	@for d in $(SUBMODULES); do \
		if [ -f $$d/package.json ]; then echo "==> build ($$d)"; (cd $$d && npm run build --if-present); fi; \
	done

test:
	@for d in $(SUBMODULES); do \
		if [ -f $$d/package.json ]; then echo "==> test ($$d)"; (cd $$d && npm test --if-present); fi; \
	done

lint:
	@for d in $(SUBMODULES); do \
		if [ -f $$d/package.json ]; then echo "==> lint ($$d)"; (cd $$d && npm run lint --if-present); fi; \
	done

update-pointers:
	git submodule update --remote --merge

clean:
	@for d in $(SUBMODULES); do \
		[ -d $$d/dist ] && rm -rf $$d/dist || true; \
	done
