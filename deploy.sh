#!/usr/bin/env bash
# Deploy site/ (and only site/) to Cloudflare Pages project "margincap", then smoke test it.
#   ./deploy.sh            → production  https://margincap-ahy.pages.dev
#   ./deploy.sh staging    → staging     https://staging.margincap-ahy.pages.dev
# First time: run `npx wrangler login` yourself (it opens a browser to authorize).
set -euo pipefail
cd "$(dirname "$0")"

PROJECT="margincap"
TARGET="${1:-production}"
case "$TARGET" in
  production) BRANCH=main;    URL="https://margincap-ahy.pages.dev" ;;
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

npx --yes wrangler pages deploy site --project-name "$PROJECT" --branch "$BRANCH" --commit-dirty=true
echo "✓  Deployed $TARGET → $URL"

echo; sleep 5   # give the edge a moment to pick up the new deployment
if ! tests/smoke.sh "$URL"; then
  echo
  echo "Rollback: Cloudflare dashboard → Workers & Pages → $PROJECT → Deployments →"
  echo "          ⋯ on the last good deployment → Rollback to this deployment."
  exit 1
fi
