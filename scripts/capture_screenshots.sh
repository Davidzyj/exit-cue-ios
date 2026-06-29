#!/bin/zsh
set -euo pipefail

APP_ID="com.zhouyajie.exitcue"
PROJECT="ExitCue.xcodeproj"
SCHEME="ExitCue"
DERIVED_DATA="build/DerivedData"
LOG_DIR="build/logs"
OUT_ROOT="screenshots/iphone-6.5"
LANGS=("${(@s: :)${SCREENSHOT_LANGS:-en zh-Hans ja}}")
DEVICE_NAME="${DEVICE_NAME:-ExitCue-6.5}"
DEVICE_TYPE="${DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-11-Pro-Max}"
RUNTIME="${RUNTIME:-com.apple.CoreSimulator.SimRuntime.iOS-26-2}"
EXPECTED_WIDTH="${EXPECTED_WIDTH:-1242}"
EXPECTED_HEIGHT="${EXPECTED_HEIGHT:-2688}"

mkdir -p "$LOG_DIR" "$OUT_ROOT"

echo "building Debug simulator app"
xcodebuild -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  build > "$LOG_DIR/screenshots-xcodebuild.log" 2>&1

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/ExitCue.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "missing app at $APP_PATH"
  exit 1
fi

UDID="$(xcrun simctl list devices available | awk -v name="$DEVICE_NAME" '$0 ~ name { gsub(/[()]/, "", $2); print $2; exit }')"
if [[ -z "$UDID" ]]; then
  echo "creating simulator $DEVICE_NAME"
  UDID="$(xcrun simctl create "$DEVICE_NAME" "$DEVICE_TYPE" "$RUNTIME")"
fi

echo "booting $DEVICE_NAME ($UDID)"
xcrun simctl boot "$UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl ui "$UDID" appearance dark >/dev/null 2>&1 || true
xcrun simctl install "$UDID" "$APP_PATH"

capture_screen() {
  local lang="$1"
  local screen="$2"
  local file="$3"
  shift 3
  local expected=("$@")

  echo "capturing $lang $screen"
  xcrun simctl terminate "$UDID" "$APP_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$UDID" "$APP_ID" \
    -ExitCueScreenshotMode YES \
    -ExitCueScreenshotLanguage "$lang" \
    -ExitCueScreenshotScreen "$screen" >/dev/null

  local marker_ok=0
  for marker_attempt in {1..12}; do
    sleep 0.5
    local container
    container="$(xcrun simctl get_app_container "$UDID" "$APP_ID" data 2>/dev/null || true)"
    local marker="$container/Documents/exitcue-screenshot-marker.json"
    if [[ -f "$marker" ]] && rg -q "\"language\":\"$lang\"" "$marker" && rg -q "\"screen\":\"$screen\"" "$marker"; then
      marker_ok=1
      break
    fi
  done

  if [[ "$marker_ok" != "1" ]]; then
    echo "screenshot marker did not confirm $lang $screen"
    exit 1
  fi

  local ok=0
  for attempt in {1..8}; do
    sleep 1
    xcrun simctl io "$UDID" screenshot "$file" >/dev/null
    if swift scripts/verify_screenshot.swift "$file" "$EXPECTED_WIDTH" "$EXPECTED_HEIGHT" "${expected[@]}" >/dev/null 2>&1; then
      ok=1
      break
    fi
  done

  if [[ "$ok" != "1" ]]; then
    echo "verification failed for $lang $screen"
    swift scripts/verify_screenshot.swift "$file" "$EXPECTED_WIDTH" "$EXPECTED_HEIGHT" "${expected[@]}" || true
    exit 1
  fi

  sips -g pixelWidth -g pixelHeight "$file" | sed 's/^/  /'
}

capture_language() {
  local lang="$1"
  local out_dir="$OUT_ROOT/$lang"
  mkdir -p "$out_dir"

  case "$lang" in
    en)
      capture_screen "$lang" "home" "$out_dir/01-home.png" "Exit Cue" "Safe exit"
      capture_screen "$lang" "callers" "$out_dir/02-callers.png" "Caller profiles"
      capture_screen "$lang" "ringing" "$out_dir/03-ringing.png" "Exit cue" "Family"
      ;;
    zh-Hans)
      capture_screen "$lang" "home" "$out_dir/01-home.png"
      capture_screen "$lang" "callers" "$out_dir/02-callers.png"
      capture_screen "$lang" "ringing" "$out_dir/03-ringing.png"
      ;;
    ja)
      capture_screen "$lang" "home" "$out_dir/01-home.png"
      capture_screen "$lang" "callers" "$out_dir/02-callers.png"
      capture_screen "$lang" "ringing" "$out_dir/03-ringing.png"
      ;;
    *)
      echo "unsupported screenshot language: $lang"
      exit 1
      ;;
  esac
}

for lang in "${LANGS[@]}"; do
  capture_language "$lang"
done

echo "screenshots written to $OUT_ROOT"
