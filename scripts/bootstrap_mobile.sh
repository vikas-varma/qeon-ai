#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../mobile"
flutter create . --platforms=android,ios,web
flutter pub get
flutter run
