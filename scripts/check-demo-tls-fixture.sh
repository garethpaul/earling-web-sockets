#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CERTIFICATE="$ROOT_DIR/demo/test_certificate.pem"
PRIVATE_KEY="$ROOT_DIR/demo/test_privkey.pem"
DEMO_SOURCE="$ROOT_DIR/demo/demo_ssl.erl"
FIXTURE_PASSWORD=misultin
EXPECTED_FINGERPRINT='88:32:97:52:0C:98:78:34:A5:D0:AF:BE:91:4A:03:30:90:A2:DD:FB:89:B7:DD:DE:80:4A:65:41:25:E9:49:8D'
EXPECTED_NOT_AFTER='notAfter=Apr 17 17:47:38 2020 GMT'

if ! command -v openssl >/dev/null 2>&1; then
  printf '%s\n' "OpenSSL is required to verify the demo TLS fixtures." >&2
  exit 127
fi

for fixture in "$CERTIFICATE" "$PRIVATE_KEY" "$DEMO_SOURCE"; do
  if [ ! -f "$fixture" ]; then
    printf '%s\n' "Required demo TLS fixture input is missing: ${fixture#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

fingerprint_output=$(openssl x509 -in "$CERTIFICATE" -noout -fingerprint -sha256 2>/dev/null) || {
  printf '%s\n' "The tracked demo certificate is not valid PEM certificate data." >&2
  exit 1
}
case $fingerprint_output in
  *=*) fingerprint=${fingerprint_output#*=} ;;
  *)
    printf '%s\n' "The tracked demo certificate fingerprint output is malformed." >&2
    exit 1
    ;;
esac
fingerprint=$(printf '%s' "$fingerprint" | tr '[:lower:]' '[:upper:]')
if [ "$fingerprint" != "$EXPECTED_FINGERPRINT" ]; then
  printf '%s\n' "The tracked demo certificate fingerprint is not the reviewed fixture." >&2
  exit 1
fi

not_after=$(openssl x509 -in "$CERTIFICATE" -noout -enddate 2>/dev/null) || exit 1
if [ "$not_after" != "$EXPECTED_NOT_AFTER" ]; then
  printf '%s\n' "The tracked demo certificate expiry metadata is not the reviewed fixture." >&2
  exit 1
fi

if ! grep -Fxq 'Proc-Type: 4,ENCRYPTED' "$PRIVATE_KEY" ||
  ! grep -Eq '^DEK-Info: [A-Z0-9-]+,[A-F0-9]+$' "$PRIVATE_KEY"; then
  printf '%s\n' "The tracked demo private key must remain encrypted PEM material." >&2
  exit 1
fi

if ! grep -Fq '{password, "misultin"}' "$DEMO_SOURCE"; then
  printf '%s\n' "The SSL demo must retain the reviewed test-fixture password." >&2
  exit 1
fi

TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/earling-demo-tls.XXXXXX")
trap 'rm -rf -- "$TMP_ROOT"' EXIT HUP INT TERM

if ! openssl pkey -in "$PRIVATE_KEY" -passin "pass:$FIXTURE_PASSWORD" \
  -pubout -outform DER -out "$TMP_ROOT/key-public.der" 2>/dev/null; then
  printf '%s\n' "The tracked demo private key cannot be opened with the reviewed fixture password." >&2
  exit 1
fi

if ! openssl x509 -in "$CERTIFICATE" -pubkey -noout 2>/dev/null |
  openssl pkey -pubin -outform DER -out "$TMP_ROOT/certificate-public.der" 2>/dev/null; then
  printf '%s\n' "The tracked demo certificate public key cannot be decoded." >&2
  exit 1
fi

if ! cmp -s "$TMP_ROOT/certificate-public.der" "$TMP_ROOT/key-public.der"; then
  printf '%s\n' "The tracked demo certificate and private key do not match." >&2
  exit 1
fi

printf '%s\n' "Earling demo TLS fixture integrity checks passed."
