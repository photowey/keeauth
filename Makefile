# KeeAuth Makefile

.PHONY: help run build apk debug test analyze clean format install icons keystore release

help:
	@echo "KeeAuth — Available Commands:"
	@echo "===================================="
	@echo "  make run              - Run on connected device"
	@echo "  make build            - Build debug APK"
	@echo "  make apk              - Build release APK (signed)"
	@echo "  make release TAG=vX.Y.Z - Build signed APK+AAB & upload to GitHub Release"
	@echo "  make debug            - Build & install debug APK"
	@echo "  make test             - Run all tests"
	@echo "  make analyze          - Run Flutter analyzer"
	@echo "  make clean            - Clean build artifacts"
	@echo "  make format           - Format Dart code"
	@echo "  make install          - Install debug APK to device"
	@echo "  make icons            - Generate launcher icons"
	@echo "  make keystore         - Regenerate release keystore"

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

# Build signed APK + AAB and upload to a GitHub Release.
# Usage: make release TAG=v1.0.0-rc1
# If TAG is omitted, the current git tag (if any) is used.
release:
	@TAG="$(TAG)"; \
	if [ -z "$$TAG" ]; then TAG=$$(git describe --tags --exact-match 2>/dev/null); fi; \
	if [ -z "$$TAG" ]; then \
		echo "ERROR: No TAG provided and HEAD is not on a tag."; \
		echo "Usage: make release TAG=v1.0.0-rc1"; \
		exit 1; \
	fi; \
	echo ""; \
	echo "========================================"; \
	echo " Release: $$TAG"; \
	echo "========================================"; \
	echo ""; \
	echo "[1/4] Running tests..."; \
	flutter test || exit 1; \
	echo ""; \
	echo "[2/4] Building signed APK (split per ABI)..."; \
	flutter build apk --release --split-per-abi || exit 1; \
	echo ""; \
	echo "[3/4] Building signed AAB..."; \
	flutter build appbundle --release || exit 1; \
	echo ""; \
	echo "[4/4] Uploading to GitHub Release..."; \
	gh release upload "$$TAG" \
		build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk \
		build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
		build/app/outputs/flutter-apk/app-x86_64-release.apk \
		build/app/outputs/bundle/release/app-release.aab \
		--clobber; \
	echo ""; \
	echo "Done: https://github.com/photowey/keeauth/releases/tag/$$TAG"
