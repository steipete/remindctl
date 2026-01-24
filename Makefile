SHELL := /bin/bash

.PHONY: help format lint test check build remindctl clean

help:
	@printf "%s\n" \
		"make format    - swift format in-place" \
		"make lint      - swift format lint + swiftlint" \
		"make test      - sync version + swift test (coverage enabled)" \
		"make check     - lint + test + coverage gate" \
		"make build     - release build into bin/ (codesigned)" \
		"make remindctl - clean rebuild + run debug binary (ARGS=...)" \
		"make clean     - swift package clean"

format:
	swift format --in-place --recursive Sources Tests

lint:
	swift format lint --recursive Sources Tests
	swiftlint lint --no-cache

test:
	scripts/generate-version.sh
	swift test --enable-code-coverage

check:
	$(MAKE) lint
	$(MAKE) test
	scripts/check-coverage.sh

build:
	scripts/generate-version.sh
	mkdir -p bin
	swift build -c release --product remindctl
	cp .build/release/remindctl bin/remindctl
	codesign --force --sign - --identifier com.steipete.remindctl bin/remindctl

remindctl:
	scripts/generate-version.sh
	swift package clean
	swift build -c debug --product remindctl
	./.build/debug/remindctl $(ARGS)

clean:
	swift package clean
