#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   Option A (preferred for CI secrets):
#     export FIREBASE_ANDROID_JSON_B64="<base64-google-services.json>"
#     export FIREBASE_IOS_PLIST_B64="<base64-GoogleService-Info.plist>"
#     ./scripts/generate_firebase_configs.sh
#
#   Option B (fallback):
#     keep android/app/google-services.json and
#     ios/Runner/GoogleService-Info.plist in repo, then run:
#     ./scripts/generate_firebase_configs.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_OUT="${ROOT_DIR}/android/app/google-services.json"
IOS_OUT="${ROOT_DIR}/ios/Runner/GoogleService-Info.plist"

mkdir -p "$(dirname "${ANDROID_OUT}")" "$(dirname "${IOS_OUT}")"

if [[ -n "${FIREBASE_ANDROID_JSON_B64:-}" && -n "${FIREBASE_IOS_PLIST_B64:-}" ]]; then
  printf '%s' "${FIREBASE_ANDROID_JSON_B64}" | base64 --decode > "${ANDROID_OUT}"
  printf '%s' "${FIREBASE_IOS_PLIST_B64}" | base64 --decode > "${IOS_OUT}"
  echo "Generated from environment secrets:"
  echo "  ${ANDROID_OUT}"
  echo "  ${IOS_OUT}"
  exit 0
fi

if [[ -f "${ANDROID_OUT}" && -f "${IOS_OUT}" ]]; then
  echo "Using existing Firebase native config files from repository:"
  echo "  ${ANDROID_OUT}"
  echo "  ${IOS_OUT}"
  exit 0
fi

echo "Missing Firebase config."
echo "Provide both FIREBASE_ANDROID_JSON_B64 and FIREBASE_IOS_PLIST_B64,"
echo "or commit both files:"
echo "  ${ANDROID_OUT}"
echo "  ${IOS_OUT}"
exit 1
