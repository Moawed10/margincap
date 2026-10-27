#!/usr/bin/env bash
# Deploy site/ (and only site/) to Cloudflare Pages project "margincap", then smoke test it.
#   ./deploy.sh            → production  https://margincap.dev
#   ./deploy.sh staging    → staging     https://staging.margincap-ahy.pages.dev
# First time: run `npx wrangler login` yourself (it opens a browser to authorize).
set -euo pipefail
cd "$(dirname "$0")"

PROJECT="margincap"
TARGET="${1:-production}"
case "$TARGET" in
  production) BRANCH=main;    URL="https://margincap.dev" ;;
  staging)    BRANCH=staging; URL="https://staging.margincap-ahy.pages.dev" ;;
  *) echo "Usage: ./deploy.sh [production|staging]" >&2; exit 2 ;;
esac

# Static assets on Pages are free and unlimited; Functions/_worker.js are billed as Workers requests.
# Refuse to deploy server-side code until someone has consciously set spend caps for it.
if [ -e site/_worker.js ] || [ -d site/functions ] || [ -d functions ]; then
  if [ "${ALLOW_FUNCTIONS:-0}" != 1 ]; then
    echo "✗  Server-side code found (_worker.js or functions/). It makes requests billable." >&2
    echo "   Set spend limits first, then re-run with ALLOW_FUNCTIONS=1." >&2
    exit 1
  fi
fi

if grep -q 'buy.stripe.com/test_' site/index.html; then
  echo "⚠  STRIPE_PREORDER_LINK is still the TEST-mode link — fine for a dry run, swap it before sharing the site."
fi
if grep -q 'buy.stripe.com/REPLACE_ME' site/index.html; then
  echo "✗  STRIPE_PREORDER_LINK is not set in site/index.html" >&2; exit 1
fi

# whoami exits 0 even when logged out, so check its output instead
if npx --yes wrangler whoami 2>&1 | grep -qi "not authenticated"; then
  echo "✗  Not logged in to Cloudflare. Run: npx wrangler login" >&2; exit 1
fi

# Create the project on first run; ignore "already exists"
npx --yes wrangler pages project create "$PROJECT" --production-branch main 2>/dev/null || true

LOG=$(mktemp)
npx --yes wrangler pages deploy site --project-name "$PROJECT" --branch "$BRANCH" --commit-dirty=true | tee "$LOG"
DEPLOYMENT=$(grep -oE 'https://[a-z0-9]+\.margincap-ahy\.pages\.dev' "$LOG" | head -1)
rm -f "$LOG"
echo "✓  Deployed $TARGET → $URL"

# The edge can keep serving the previous deployment for a minute. Smoke test only once
# $URL serves the same page as this deployment's own URL.
if [ -n "$DEPLOYMENT" ]; then
  # Ignore Cloudflare's email obfuscation, which re-encodes mailto links differently on every request
  page() { curl -s "$1" | sed -E 's#<script data-cfasync[^>]*></script>##' | grep -v -E 'email-protection|__cf_email__|mailto:' | shasum | cut -c1-40; }
  want=$(page "$DEPLOYMENT/")
  for i in $(seq 1 24); do
    [ "$(page "$URL/?deploycheck=$i")" = "$want" ] && break
    [ "$i" = 24 ] && echo "⚠  $URL still serves an older page after 2 minutes; testing anyway."
    sleep 5
  done
fi
echo
if ! tests/smoke.sh "$URL"; then
  echo
  echo "Rollback: Cloudflare dashboard → Workers & Pages → $PROJECT → Deployments →"
  echo "          ⋯ on the last good deployment → Rollback to this deployment."
  exit 1
fi
