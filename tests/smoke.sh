#!/usr/bin/env bash
# Smoke + regression checks against a deployed copy of site/.
# Usage: tests/smoke.sh [base-url]   (default: production)
set -uo pipefail
BASE="${1:-https://margincap.dev}"
BASE="${BASE%/}"
fail=0
ok()   { printf "  ✓ %s\n" "$1"; }
bad()  { printf "  ✗ %s\n" "$1"; fail=1; }
status() { curl -s -o /dev/null -w "%{http_code}" "$BASE$1"; }
ctype()  { curl -s -o /dev/null -w "%{content_type}" "$BASE$1"; }

echo "Smoke testing $BASE"

# Pages and assets that must exist
for p in / /privacy /terms /support /og.png /favicon.svg /apple-touch-icon.png /robots.txt /sitemap.xml; do
  s=$(status "$p"); [ "$s" = 200 ] && ok "$p → 200" || bad "$p → $s (want 200)"
done
[[ "$(ctype /og.png)" == image/png* ]] && ok "og.png is image/png" || bad "og.png content type: $(ctype /og.png)"

# Real 404s (no SPA fallback), and private project files must not be public
for p in /does-not-exist /validation-kit.md /README.md /deploy.sh /assets/og.html; do
  s=$(status "$p"); [ "$s" = 404 ] && ok "$p → 404" || bad "$p → $s (want 404)"
done

# Security headers
H=$(curl -sI "$BASE/")
for h in x-content-type-options x-frame-options referrer-policy permissions-policy; do
  grep -qi "^$h:" <<<"$H" && ok "header $h" || bad "missing header $h"
done

# Page content regressions
HTML=$(curl -s "$BASE/")
grep -q 'WAITLIST_ENDPOINT: "https://formspree.io/f/' <<<"$HTML" && ok "waitlist endpoint set" || bad "WAITLIST_ENDPOINT empty"
grep -q 'buy.stripe.com/REPLACE_ME' <<<"$HTML" && bad "Stripe link is a placeholder" || ok "Stripe link set"
grep -q 'buy.stripe.com/test_' <<<"$HTML" && echo "  ⚠ Stripe link is TEST mode"
grep -q 'property="og:image"' <<<"$HTML" && ok "og:image tag" || bad "missing og:image"
grep -q 'href="/privacy"' <<<"$HTML" && grep -q 'href="/terms"' <<<"$HTML" && ok "privacy + terms linked" || bad "footer legal links missing"
for p in /privacy /terms; do
  P=$(curl -s "$BASE$p")
  grep -q "operated by <strong>Omar Kamel</strong>" <<<"$P" && ok "$p shows operator name" || bad "$p missing operator name"
  grep -q "will be listed here" <<<"$P" && bad "$p still has the operator placeholder" || true
done
grep -q 'href="/support"' <<<"$HTML" && ok "support page linked" || bad "support link missing"
grep -q 'class="consent"' <<<"$HTML" && ok "waitlist consent notice" || bad "waitlist consent notice missing"
grep -qiE 'for life|Most popular' <<<"$HTML" && bad "misleading claim (for life / Most popular) is back" || ok "no misleading claims"
grep -q 'rel="preconnect" href="https://buy.stripe.com"' <<<"$HTML" && bad "third-party preconnect on page load" || ok "no third-party contact on load"
python3 - "$HTML" <<'PY' && ok "JSON-LD parses (SoftwareApplication + FAQPage)" || bad "JSON-LD invalid"
import json, re, sys
m = re.search(r'<script type="application/ld\+json">(.*?)</script>', sys.argv[1], re.S)
types = {n["@type"] for n in json.loads(m.group(1))["@graph"]}
sys.exit(0 if {"SoftwareApplication", "FAQPage"} <= types else 1)
PY
# Every same-origin script the page loads must exist (a missing vendor file breaks all interactions)
for src in $(grep -o '<script src="/[^"]*"' <<<"$HTML" | sed 's/<script src="//; s/"$//'); do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE$src")
  [ "$code" = 200 ] && ok "$src → 200" || bad "$src → $code"
done
size=$(curl -s -o /dev/null -w "%{size_download}" "$BASE/")
[ "$size" -lt 100000 ] && ok "homepage HTML ${size} bytes (< 100 KB)" || bad "homepage HTML ${size} bytes (budget 100 KB)"

[ $fail = 0 ] && echo "All smoke tests passed." || echo "SMOKE TESTS FAILED."
exit $fail
