# Production checklist — MarginCap

Source: the "before you ship" list from the second reel (40 items).
**Done** = in place now · **You** = needs your account/hands · **MVP** = applies once the dashboard/SDK exists · **N/A** = nothing to do for a static site.

## Done now (site at margincap-ahy.pages.dev)

| Item | How |
|---|---|
| Smoke tests | `tests/smoke.sh [url]` — pages, assets, real 404s, private files not public, headers, settings, JSON-LD, page weight. Runs automatically after every deploy. |
| Regression tests | Same script guards content that broke before (placeholder Stripe link, empty waitlist endpoint, missing OG/legal links). |
| SEO and AEO | sitemap.xml, robots.txt, canonical URLs, JSON-LD (SoftwareApplication + pricing + FAQPage), OG card. Lighthouse SEO 100. |
| Staging environment | `./deploy.sh staging` → https://staging.margincap-ahy.pages.dev, smoke-tested before production. |
| Rollback plan | Cloudflare keeps every deployment; a failed smoke test prints the one-click rollback path (Deployments → ⋯ → Rollback). |
| Test on slow networks | Lighthouse mobile + slow-4G simulation: performance 100, first/largest paint 0.9 s, 37 KB HTML, zero layout shift. |
| Test on multiple devices | 375 px phone + desktop, light + dark, reduced motion. (Real-hardware check: see **You**.) |
| Make it accessible | Lighthouse accessibility 100 on all pages; focus rings, reduced motion, labelled form, table headers. |
| 404 / loading / error / success states | Real 404 page (no more "every URL returns the homepage"); waitlist form has instant, error, rate-limit and already-signed-up states. |
| Privacy policy and terms | `/privacy`, `/terms` — drafts written to match what the site actually does. **Review them; not legal advice.** |
| Cookie consent | Not required: no cookies; analytics is cookieless; one functional localStorage flag. Revisit if you add tracking pixels. |
| Let users delete their data | Privacy policy: email-based access/correction/deletion within 30 days. |
| OG images and favicon | og.png (1200×630), favicon.svg, apple-touch-icon.png. |
| Optimize images | Page loads no images; icons ~2 KB; OG card 124 KB (only fetched by link previews). |
| Caching | `_headers`: HTML revalidates every request (deploys show instantly), images 1 day, CSS 1 hour. |
| Keep secrets out of the repo | There are none: the Formspree endpoint and Stripe link are public by design. `.gitignore` blocks `.env*` and `.wrangler/`. |
| Dependency audit | The site has zero runtime dependencies. |
| README | Updated with layout, setup, deploy, staging, rollback, tests. |

## You (needs your accounts, ~30 min total)

| Item | What to do |
|---|---|
| Custom domain and SSL | Buy `margincap.dev`, add it under the Pages project's Custom domains. SSL is automatic (and mandatory on .dev). |
| **Email (urgent)** | `hello@margincap.dev` is on every page but **doesn't exist yet**. After buying the domain: Cloudflare → Email → Email Routing → forward `hello@` to your Gmail (free; sets MX + SPF). Add a DMARC TXT record `_dmarc` = `v=DMARC1; p=none; rua=mailto:hello@margincap.dev`. |
| Analytics + performance monitoring | Pages project → Metrics → enable **Web Analytics** (free, cookieless, includes Core Web Vitals). The privacy policy already describes it. |
| Uptime monitoring + alerting | Free monitor (UptimeRobot or Better Stack) on `https://margincap.dev` every 5 min → email/SMS alert. |
| Spend caps and billing alerts | Cloudflare Pages free plan has no overage. Formspree free caps at ~50/month (page tells visitors to email you past that). Set a Stripe email alert for failed payments/disputes. |
| Back up data | Weekly: export Formspree submissions to CSV. Stripe keeps payment records. |
| Test on real devices | Open the site on your phone (iPhone + one Android if you can): tap targets, form, checkout. |
| Legal details | Add your legal name/business + country at the `TODO(owner)` comments in `site/privacy.html` and `site/terms.html` before taking live payments. |
| Live Stripe link | Recreate the product/link in Live mode, send the URL to swap in. |

## MVP (dashboard + SDK)

| Item | MarginCap-specific requirement |
|---|---|
| CI/CD | Put the project on GitHub; GitHub Actions runs tests on every push and deploys `main` (needs a scoped Cloudflare API token as a repo secret). |
| Unit tests | Cost calculator (price table × tokens incl. cached/reasoning tokens), margin math, Stripe revenue join. |
| Check auth on every endpoint | Every API route verifies the API key **and** that the customer/tenant belongs to that key. Ingest keys are write-only. |
| Rate limiting | Per-API-key limits on ingest; per-IP limits on login. |
| Error tracking + logging | Sentry (free tier) for dashboard + API; structured request logs with tenant ID, never prompt content. |
| Back up DB + **actually test a restore** | Postgres point-in-time recovery on; do one restore drill into staging before launch. |
| Evals | Cost-accuracy evals: replay real provider usage, compare computed cost to the provider invoice; fail CI if drift > 1%. |
| Fallback when the model API is down | Inverted for us: **the SDK must fail open.** If MarginCap is down or slow, the customer's LLM call proceeds; `canSpend()` defaults to allow after a short timeout. |
| Token limits / context overflow | Price table must handle long-context pricing tiers and cached-token discounts per model. |
| Prompt injection | Low surface: MarginCap never reads or sends prompts. Keep it that way (SDK sends counts only). |
| Password reset / email verification | Use email one-time codes instead of passwords (no reset flow needed); verify email on signup. |
| Idempotency | Every usage event carries a client-generated ID; ingest dedupes (see `ux-checklist.md` #19). |
| Delete account and data | Self-serve "delete workspace" that removes usage data and revokes keys. |
