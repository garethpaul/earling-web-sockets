#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/earling-demo-tls-tests.XXXXXX")
trap 'rm -rf -- "$TMP_ROOT"' EXIT HUP INT TERM
PRIVATE_KEY_SAMPLE=$(awk '
  found && NF { print; exit }
  /^DEK-Info:/ { found = 1 }
' "$ROOT_DIR/demo/test_privkey.pem")

prepare_case() {
  label=$1
  CASE_DIR="$TMP_ROOT/$label"
  mkdir -p "$CASE_DIR/scripts" "$CASE_DIR/demo"
  cp "$ROOT_DIR/scripts/check-demo-tls-fixture.sh" "$CASE_DIR/scripts/"
  cp "$ROOT_DIR/demo/test_certificate.pem" "$CASE_DIR/demo/"
  cp "$ROOT_DIR/demo/test_privkey.pem" "$CASE_DIR/demo/"
  cp "$ROOT_DIR/demo/demo_ssl.erl" "$CASE_DIR/demo/"
}

replace_in_file() {
  expression=$1
  path=$2
  temporary="$path.tmp"
  sed "$expression" "$path" >"$temporary"
  cat "$temporary" >"$path"
  rm -f "$temporary"
}

assert_rejected() {
  label=$1
  expected=$2
  if output=$("$CASE_DIR/scripts/check-demo-tls-fixture.sh" 2>&1); then
    printf '%s\n' "$label: expected fixture rejection" >&2
    exit 1
  fi
  case $output in
    *"$expected"*) ;;
    *)
      printf '%s\n%s\n' "$label: unexpected diagnostic" "$output" >&2
      exit 1
      ;;
  esac

  case $output in
    *misultin*|*"$PRIVATE_KEY_SAMPLE"*)
      printf '%s\n' "$label: scanner output exposed fixture credential material" >&2
      exit 1
      ;;
  esac
}

prepare_case clean
"$CASE_DIR/scripts/check-demo-tls-fixture.sh" >/dev/null

prepare_case certificate-replacement
openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
  -subj '/CN=unreviewed-earling-fixture' \
  -keyout "$CASE_DIR/replacement-key.pem" \
  -out "$CASE_DIR/demo/test_certificate.pem" >/dev/null 2>&1
assert_rejected certificate-replacement "fingerprint is not the reviewed fixture"

prepare_case key-replacement
openssl genrsa -out "$CASE_DIR/replacement-key.pem" 1024 >/dev/null 2>&1
if openssl rsa -help 2>&1 | grep -q -- '-traditional'; then
  openssl rsa -in "$CASE_DIR/replacement-key.pem" -traditional -des3 \
    -passout pass:misultin -out "$CASE_DIR/demo/test_privkey.pem" >/dev/null 2>&1
else
  openssl rsa -in "$CASE_DIR/replacement-key.pem" -des3 \
    -passout pass:misultin -out "$CASE_DIR/demo/test_privkey.pem" >/dev/null 2>&1
fi
assert_rejected key-replacement "do not match"

prepare_case password-drift
replace_in_file 's/{password, "misultin"}/{password, "changed"}/' "$CASE_DIR/demo/demo_ssl.erl"
assert_rejected password-drift "reviewed test-fixture password"

prepare_case encryption-marker-removal
replace_in_file '/^Proc-Type: 4,ENCRYPTED$/d' "$CASE_DIR/demo/test_privkey.pem"
assert_rejected encryption-marker-removal "remain encrypted PEM material"

prepare_case wrong-key-password
replace_in_file 's/FIXTURE_PASSWORD=misultin/FIXTURE_PASSWORD=changed/' \
  "$CASE_DIR/scripts/check-demo-tls-fixture.sh"
assert_rejected wrong-key-password "cannot be opened"

printf '%s\n' "Earling demo TLS fixture regression tests passed."
