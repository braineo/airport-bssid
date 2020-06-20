
.PHONY: all
all: build

.PHONY: build
build:
	swift build

.PHONY: install
install:
	ln -fs $(PWD)/.build/x86_64-apple-macosx/debug/bssid /usr/local/bin/

.PHONY: remove
remove:
	rm /usr/local/bin/bssid
