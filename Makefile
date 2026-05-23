BUNDLE_ID := dev.braineo.bssid
BIN       := .build/release/bssid
APP       := dist/bssid.app
APP_BIN   := $(APP)/Contents/MacOS/bssid
APP_PLIST := $(APP)/Contents/Info.plist
PREFIX    ?= /usr/local
DEST      := $(PREFIX)/bin/bssid

.PHONY: all
all: app

.PHONY: build
build:
	swift build -c release

.PHONY: app
app: build
	mkdir -p $(APP)/Contents/MacOS
	cp Resources/Info.plist $(APP_PLIST)
	cp $(BIN) $(APP_BIN)
	codesign --force --sign - --entitlements bssid.entitlements --timestamp=none $(APP)
	@echo "Built $(APP)"

.PHONY: install
install: app
	ln -fs $(PWD)/$(APP_BIN) $(DEST)
	@echo "Linked $(DEST) -> $(PWD)/$(APP_BIN)"
	@echo "Run 'bssid scan' once and approve the Location prompt that appears."
	@echo "If you'd previously denied the prompt, run: make reset-tcc"

.PHONY: reset-tcc
reset-tcc:
	-tccutil reset Location $(BUNDLE_ID)

.PHONY: remove
remove:
	rm -f $(DEST)

.PHONY: clean
clean:
	swift package clean
	rm -rf .build dist
