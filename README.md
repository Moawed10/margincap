# MarginCap

Margin per customer for AI SaaS: joins LLM spend with Stripe revenue, alerts on and caps unprofitable customers.

## Layout

| Path | What | Public? |
|---|---|---|
| `site/index.html` | Landing page (single file, no build step) | **Yes** — deploy only this folder |
| `validation-kit.md` | 3-day validation plan, outreach templates, 27 prioritised threads, tracker | No — private notes |
| `compliance-audit.md` | Legal/compliance audit: 20 checks + business details, with fixes and open items | No |
| `production-checklist.md` | 40-item ship checklist: done / your steps / MVP | No |
| `tests/smoke.sh` | Smoke + regression tests; run automatically by `deploy.sh` | No |
| `ux-checklist.md` | 20 UX details (from the reel) mapped to landing vs. dashboard MVP | No |
| `site/og.png` | 1200×630 social preview card (Reddit, X, Slack link previews) | Yes |
| `assets/og.html` | Source for `og.png`; re-render command is in its header comment | No |
| `.claude/launch.json` | Local preview server config | No |

## Before deploying `site/`

Fill the `CONFIG` block at the bottom of `site/index.html`:

- `STRIPE_PREORDER_LINK` — Stripe Payment Link, $19/mo recurring
- `WAITLIST_ENDPOINT` — form service accepting a JSON POST (e.g. Formspree)
- `LAUNCH_DATE`, `FOUNDER_LINE`, `CONTACT_EMAIL`
- Paste the analytics tag at the `TODO analytics` comment

Deploy: Cloudflare Pages / Netlify with **`site` as the publish directory**.

### Formspree (waitlist)
1. Sign up at formspree.io → **New form** ("MarginCap waitlist") → copy the endpoint `https://formspree.io/f/xxxxxxx` into `WAITLIST_ENDPOINT`.
2. Submit one test signup from the live page and confirm the form via the email Formspree sends.
3. Free plan is ~50 submissions/month (check formspree.io/plans). Upgrade if a post takes off — over the cap, the page tells visitors to email you instead of losing them.

### Stripe (founding pre-order)
1. Do it all in **Test mode** first.
2. Product catalog → Add product "MarginCap Indie — Founding member", **Recurring, $19.00 USD / month**.
3. Payment Links → New → that product. Limit to 50 payments if the option is offered.
4. **After payment** tab → *Don't show confirmation page* → redirect to `https://margincap.dev/?preorder=thanks` (shows the thank-you banner).
5. Create → copy `https://buy.stripe.com/test_…` into `STRIPE_PREORDER_LINK`, pay with test card 4242 4242 4242 4242, check the banner shows.
6. Recreate the product + link in **Live mode**, swap the live `https://buy.stripe.com/…` URL in.
7. The page appends `?client_reference_id=<ref>` so each payment shows which channel it came from.
8. Subscriptions renew 30 days after purchase. If launch slips, pause payment collection on those subscriptions in Stripe.

### Deploy (Cloudflare Pages, free)
1. Buy `margincap.dev` (Cloudflare Registrar sells .dev at cost: dash.cloudflare.com → Domain Registration → Register Domains).
2. Workers & Pages → Create → **Pages** → **Upload assets** → project name `margincap` → drag in the **`site` folder only** → Deploy. You get `margincap-ahy.pages.dev` (Cloudflare added the suffix; the name was taken).
3. Project → **Custom domains** → Set up a custom domain → `margincap.dev` (DNS is automatic when the domain is on Cloudflare).
4. Or from the terminal: `npx wrangler login` once, then `./deploy.sh staging` → check https://staging.margincap-ahy.pages.dev → `./deploy.sh` for production. Both run `tests/smoke.sh` afterwards.
   Rollback: Workers & Pages → margincap → Deployments → ⋯ on the last good one → Rollback.
5. Live checks: one Formspree signup (confirm the email), one Stripe test checkout → lands on the thank-you banner.

### Local preview
`python3 -m http.server 8766 --directory site` then open http://127.0.0.1:8766 (`?preorder=thanks` previews the banner).

## Status

- [x] Market research + validation of the idea
- [x] Validation kit
- [x] Landing page
- [ ] Buy margincap.dev + getmargincap.com (check premium price + trademark first)
- [x] Formspree endpoint + Stripe **test** link in CONFIG
- [ ] Test checkout (card 4242…) + one test signup
- [ ] Swap in the **live** Stripe link; fill LAUNCH_DATE / FOUNDER_LINE; deploy
- [ ] Run 3-day outreach, decide go/kill (≥30 waitlist + ≥3 pre-orders)
