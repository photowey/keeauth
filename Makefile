# KeeAuth Makefile

.PHONY: help run build apk debug test analyze clean format install icons keystore

help:
	@echo "KeeAuth — Available Commands:"
	@echo "===================================="
	@echo "  make run      - Run on connected device"
	@echo "  make build    - Build debug APK"
	@echo "  make apk      - Build release APK"
	@echo "  make debug    - Build & install debug APK"
	@echo "  make test     - Run all tests"
	@echo "  make analyze  - Run Flutter analyzer"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make format   - Format Dart code"
	@echo "  make install  - Install debug APK to device"
	@echo "  make icons    - Generate launcher icons"
	@echo "  make keystore - Regenerate release keystore"

run:
	flutter run

run_release:
	flutter run --release

build:
	flutter build apk --debug

apk:
	flutter build apk --release

debug: build install

test:
	flutter test

analyze:
	flutter analyze

clean:
	flutter clean

format:
	dart format lib/ test/

install:
	flutter install

icons:
	dart run flutter_launcher_icons:main

keystore:
	@PASS=$$(grep '^storePassword=' android/key.properties | cut -d'=' -f2 | tr -d '"'); \
	ALIAS=$$(grep '^keyAlias=' android/key.properties | cut -d'=' -f2); \
	echo "Generating keystore for alias: $$ALIAS"; \
	rm -f android/app/keeauth-release.keystore; \
	keytool -genkey -v \
		-keystore android/app/keeauth-release.keystore \
		-alias "$$ALIAS" \
		-keyalg RSA \
		-keysize 2048 \
		-validity 10000 \
		-storepass "$$PASS" \
		-keypass "$$PASS" \
		-dname "CN=photowey, OU=KeeAuth, O=KeeAuth, L=Unknown, ST=Unknown, C=CN"
