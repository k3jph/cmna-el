EMACS ?= emacs
BUILD_DIR := dist

.PHONY: check clean compile install package test

check: compile test

clean:
	eask clean all
	rm -rf $(BUILD_DIR)

install:
	eask install-deps --dev

compile: install
	eask compile

test: install
	eask exec ert-runner test

package: check
	mkdir -p $(BUILD_DIR)
	eask package $(BUILD_DIR)
