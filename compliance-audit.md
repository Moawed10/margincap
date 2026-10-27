# Compliance audit — margincap.dev (pre-launch site)

**Date:** October 26, 2026 · **Scope:** everything in `site/` as deployed to Cloudflare Pages, the Formspree waitlist, and the Stripe (test-mode) pre-order link.
**Target countries assumed:** United States, Canada, European Union, United Kingdom (the prompt left `[TARGET COUNTRIES]` blank; MarginCap sells online in USD to anyone).
**Method:** behaviour was verified, not assumed: live response headers (cookies), browser resource timing (third-party requests on load), localStorage contents after a test signup, axe-core WCAG 2.2 AA scan of every page in light **and** dark mode with all content revealed, manual contrast math, and a line-by-line read of every claim against what the code and the policies actually say.

> **Not legal advice.** This is an engineering audit against published rules. Have a lawyer review the privacy policy and terms before taking live payments, especially once you know which country you're operating from.

## Summary

| Status | Count |
|---|---|
| Fixed in code and deployed | 15 |
| Open — needs you (accounts/legal details) | 6 (2 Critical before live payments) |
| Not applicable to this site | 2 |

**Resolved:** operator name is on the site, `hello@margincap.dev` works, and the mailing address is given privately on receipts and in emails. **Before live payments:** set the Stripe support address and register the "MarginCap" business name in New Brunswick. **High:** online cancellation (Stripe customer portal) and enforcing the "first 50" limit in Stripe.

---

## The 20 checks

### 1. Missing or inadequate Privacy Policy — **Fixed** (was High)
- **Location:** `site/privacy.html` (whole file).
- **Problem found:** the old policy said the browser stores "whether you've joined" — the code actually stored the **raw email address** in localStorage. It also said Cloudflare Web Analytics was in use — it **was never enabled**. It lacked legal bases, controller identity, retention per category, international transfers, complaint rights, children, and a Do-Not-Track statement.
- **Why it's risky:** a policy that misdescribes processing is itself a deceptive practice and fails transparency duties.
- **Fix applied:** policy rewritten to match verified behaviour; localStorage now stores only a SHA-256 hash (`site/index.html`, `hashEmail()`), analytics described as "not currently running". Added table of data/purpose/legal basis, processors with links, transfers (SCCs / Data Privacy Framework), retention, rights + regulators, children, DNT/GPC, effective date.
- **Laws:** GDPR Arts 5, 12–14, 44–49 · UK GDPR & DPA 2018 · PIPEDA Principles 4.1, 4.8 (Canada) · CalOPPA (Cal. Bus. & Prof. Code §22575, incl. DNT disclosure) · FTC Act §5.

### 2. Missing or inadequate Terms of Service — **Fixed** (was High)
- **Location:** `site/terms.html`.
- **Problem found:** no operator identity, no tax wording, cancellation only implied, no statement preserving statutory rights, no governing law.
- **Fix applied:** sections for who you're dealing with, pre-order price/billing/lock/availability, cancellation, refunds, waitlist, governing law (placeholder), statutory-rights savings clause.
- **Open item (you):** fill the `TODO(owner)` governing-law line, e.g. *"These terms are governed by the laws of the Province of New Brunswick and the federal laws of Canada applicable there."*
- **Laws:** EU Consumer Rights Directive 2011/83/EU Art 6 · UK Consumer Contracts Regs 2013 · provincial consumer-protection acts (internet-agreement disclosure rules) · US state contract law.

### 3. Missing or unclear Refund Policy — **Fixed** (was High)
- **Location:** `site/terms.html#refunds`, linked from the pricing section (`site/index.html`, `.founding`) and `site/support.html#refunds`.
- **Fix applied:** dedicated refund section: full refund any time before launch; pause or refund if launch slips; automatic full refund if it never launches; refund on material change; after launch, most-recent-month refund if unused; 5–10 business-day timing; EU/UK 14-day withdrawal right preserved.
- **⚠ Review:** "automatic refund if it never launches" and the post-launch unused-month refund are commitments I drafted — keep only what you're willing to honour.
- **Laws:** EU CRD Arts 9–16 (withdrawal) · UK CCRs 2013 · Competition Act (Canada) s.52, 74.01 · FTC Act §5.

### 4. Missing Cookie Policy — **Fixed** (was Medium)
- **Location:** `site/privacy.html#cookies`.
- **Verified:** live site sends **no `Set-Cookie`** on `/`, `/privacy`, `/terms`. Only storage: `mc_waitlist` (hash) after signup. Stripe sets its own cookies on `buy.stripe.com` only after you click through.
- **Fix applied:** cookie section listing exactly this, plus how to clear it.
- **Laws:** ePrivacy Directive Art 5(3) · UK PECR reg 6.

### 5. Invalid cookie consent — **Not applicable (verified)**
- No non-essential cookies or storage exist, so no banner is required. `mc_waitlist` is strictly necessary for a feature the user requested (duplicate-signup check) and holds no readable personal data.
- **Re-check trigger:** if you ever add Google Analytics, Meta/LinkedIn pixels, Hotjar, etc., you need a consent banner that blocks them **before** consent. Cloudflare Web Analytics (cookieless) doesn't.
- **Laws:** ePrivacy Art 5(3) · PECR reg 6 · GDPR Art 7.

### 6. Invalid form consent — **Fixed** (was High)
- **Location:** `site/index.html`, waitlist form (`p.consent`).
- **Problem found:** the form collected emails with no statement of purpose or link to the policy.
- **Fix applied:** *"By joining, you agree to get emails from MarginCap about the launch. No spam, unsubscribe any time. See our privacy policy."* Purpose-limited, with link; no pre-ticked boxes.
- **You, when emailing the list:** every email must identify MarginCap + a postal address and include a working unsubscribe link.
- **Laws:** CASL ss.6, 10, 11 (express consent, sender ID, unsubscribe) · CAN-SPAM 15 U.S.C. §7704 · GDPR Arts 6(1)(a), 7 · PECR reg 22.

### 7. Undisclosed analytics — **Fixed** (was Medium)
- **Verified:** no analytics script runs. The policy previously **claimed** Cloudflare analytics — now says none run and that the section will be updated **before** it's switched on.
- **When you enable Web Analytics:** change that bullet to *"We use Cloudflare Web Analytics, which counts page views and load performance without cookies or cross-site tracking."*
- **Laws:** GDPR Art 13 · CalOPPA · FTC Act §5.

### 8. Undisclosed user tracking — **Fixed** (was Medium)
- **Problem found:** `<link rel="preconnect">` to `buy.stripe.com` and `formspree.io` sent every visitor's IP address to those companies **on page load**, before any interaction (cf. LG München I, 3 O 17493/20 — Google Fonts IP transfer).
- **Fix applied:** preconnects removed from `<head>`; now added only on hover/focus of the pre-order buttons or the email field (`warm()` in `site/index.html`). Verified: **0 third-party requests on load**.
- **Laws:** GDPR Arts 5(1)(c), 6 · UK GDPR.

### 9. Undisclosed third-party SDKs — **Fixed / verified** (was Low)
- **Verified:** no third-party JavaScript SDK is loaded by the site (no Stripe.js, no analytics, no chat widgets). Stripe and Formspree are reached only via a link and a form POST.
- **Fix applied:** processors table in the privacy policy names each with what it receives and a link to its policy.

### 10. Undisclosed external tools — **Fixed** (was Low)
- Cloudflare (hosting, logs IPs), Formspree (waitlist; receives email, ref tag, IP), Stripe (checkout) — all disclosed in `site/privacy.html#processors`.
- **Laws:** GDPR Arts 13(1)(e), 28.

### 11. Collection of unnecessary data — **Partly open** (Medium)
- **Site:** collects only email + referral tag. OK.
- **Open (you):** the Stripe checkout asks for a **phone number** and offers a "Business name" field. Neither is needed. Keeping phone numbers also creates TCPA exposure (47 U.S.C. §227; $500–$1,500 per unsolicited text) if anyone ever texts them. The privacy policy now commits to never texting. Stripe Dashboard → Payment Links → your link → Edit → turn off phone-number collection and the optional business-name field.
- **Laws:** GDPR Art 5(1)(c) data minimisation · PIPEDA Principle 4.4.

### 12. Collection of sensitive data — **Not applicable (verified)**
- No health, biometric, ID, precise-location, children's, or financial-account data is collected by the site; card data is entered on Stripe only. Stated in the policy.

### 13. Missing accessibility alt text — **Fixed** (was Low)
- **Verified:** no `<img>` elements. 6 inline SVG icons were exposed to screen readers → now `aria-hidden="true" focusable="false"`. Sample dashboard keeps `role="img"` + descriptive `aria-label`. OG image has `og:image:alt`.
- **Laws:** WCAG 2.2 SC 1.1.1.

### 14. Insufficient color contrast — **Fixed** (was **High**)
- **Location:** `site/index.html` `:root --accent / --neg`, `site/page.css`.
- **Problem found:** light-mode green text **3.64:1**, white-on-green buttons **3.77:1**, green on the founding box **3.38:1**, red on pink **4.23:1**, footer trademark line **3.77:1** — all below AA 4.5:1. (Earlier Lighthouse runs scored 100 because scroll-reveal hid most content during the audit; this audit forced all content visible.)
- **Fix applied:** light accent `#059669 → #047857` (5.30:1 on background, 5.48:1 under white text), red `#dc2626 → #b91c1c` (5.66:1), removed opacity on footer line. Dark mode already passed (≥6.2:1).
- **Verified:** axe-core WCAG 2.2 AA — **0 violations** on all pages, light and dark.
- **Laws:** WCAG 2.2 SC 1.4.3 · ADA Title III (US litigation risk) · European Accessibility Act (Directive 2019/882; micro-enterprises <10 staff and <€2M turnover are exempt for services, but follow it anyway) · AODA (Ontario, 50+ employees) · UK Equality Act 2010.

### 15. Missing keyboard navigation — **Fixed** (was Medium)
- **Added:** "Skip to content" link on every page, `<main>` landmark on every page (was missing on the homepage), visible focus rings on links/buttons/summary. FAQ uses native `<details>` (keyboard-operable). Banner close is a real `<button>`.
- **Laws:** WCAG 2.2 SC 2.1.1, 2.4.1, 2.4.7.

### 16. Fake or misleading reviews — **Fixed** (was **High**)
- **Location:** `site/index.html` pricing card.
- **Problem found:** a **"Most popular"** badge on the Indie plan. With zero customers, that's a fabricated popularity claim. The sample dashboard ("7% of customers → 51% of AI spend", customer IDs) wasn't labelled as illustrative.
- **Fix applied:** badge → **"Recommended"** (an opinion, not a fact); dashboard header now says **"example data"**. No testimonials, ratings, user counts or logos exist on the site. Smoke test now fails the build if "Most popular" or "for life" returns.
- **Laws:** FTC Trade Regulation Rule on Consumer Reviews and Testimonials (16 CFR Part 465, 2024) · FTC Endorsement Guides (16 CFR Part 255) · EU UCPD Annex I as amended by Omnibus Directive 2019/2161 · UK DMCC Act 2024 (fake reviews banned) · Competition Act (Canada) s.52, 74.01.

### 17. Dark UX patterns — **Fixed in copy; enforcement open** (High)
- **Problems found:** "Pre-order: $19/mo **for life**" (it's actually "while you stay subscribed"); **"First 50 people only"** scarcity that nothing enforces; cancellation possible **only by email**.
- **Fixed:** copy is now "$19/mo founding price" and "locked while you stay subscribed"; scarcity reworded to "Limited to the first 50 founding members" — **only true once enforced**.
- **Open (you):**
  1. Stripe → your payment link → **Limit the number of payments → 50**. If you can't, delete the scarcity sentence (`site/index.html` `.founding p`, and `site/terms.html#preorder`).
  2. Stripe → Settings → Billing → **Customer portal** → enable cancellation; send me the portal link and I'll add a "Manage subscription" button to `/support` and the terms. California requires online cancellation for subscriptions bought online.
- **Laws:** ROSCA 15 U.S.C. §8403 · California Automatic Renewal Law (Bus. & Prof. Code §17600–17606, online-cancellation requirement) · FTC Act §5 (the FTC's 2024 "click-to-cancel" rule was vacated by the 8th Circuit in July 2025, but ROSCA and state laws still apply) · EU UCPD (false scarcity) · DSA Art 25 (platforms) · UK DMCC Act 2024 subscription-contract rules.

### 18. Hidden fees — **Fixed** (was Medium)
- **Location:** `site/index.html` `.founding p`, `site/terms.html#preorder`.
- **Fix applied:** *"US$19/month, charged today and monthly until you cancel; taxes extra where they apply."* Terms: *"Prices are in US dollars. If sales tax or VAT applies to you, it is shown on the checkout page before you pay. There are no other fees."* (Earlier draft wrongly said tax "is added" — Stripe Tax isn't enabled.)
- **You:** if you sell to consumers in the EU/UK, VAT-inclusive pricing may be required for them; decide whether to enable Stripe Tax once you have a business location.
- **Laws:** Competition Act (Canada) drip-pricing provisions (s.74.01(1.1), 2022) · EU Price Indication Directive 98/6/EC & CRD Art 6(1)(e) · UK CCRs · FTC Act §5 / state UDAP laws.

### 19. Unlicensed images, icons, fonts, assets, trademarks — **Fixed** (was Low)
- **Verified:** fonts are the visitor's system fonts (nothing downloaded). Logo, OG card and favicon are original. Four feature icons are adapted from **Feather** (MIT) → licence credit added as a source comment in `site/index.html`.
- **Trademarks:** competitors and platforms are named nominatively. Added footer notice: *"OpenAI, Anthropic, Gemini, OpenRouter, Stripe, Langfuse and Helicone are trademarks of their respective owners. MarginCap is independent and not affiliated with them."*
- **Open (you):** search "MarginCap" in USPTO (TESS), CIPO and EUIPO before investing in the brand.
- **Laws:** Copyright Act (US/Canada), MIT licence terms · Lanham Act §43(a) / Trademarks Act (Canada) s.7 (false affiliation).

### 20. Unsupported or misleading claims — **Fixed** (was **High**)
- **Problems found:** "Works with OpenAI, Anthropic, OpenRouter & Gemini", "5-minute setup", "Never sees your prompts" stated as present fact for a product that doesn't exist yet; FAQ asserted "Helicone has been in maintenance mode since its acquisition" (based on secondary sources about a named competitor).
- **Fix applied:** hero now states **"Pre-launch: MarginCap is in development. Planned at launch: OpenAI, Anthropic, OpenRouter & Gemini, TypeScript SDK first."**; terms say features "are planned and may change"; Helicone sentence removed.
- **Laws:** FTC Act §5 (substantiation doctrine) · Competition Act (Canada) s.52, 74.01(1)(b) · EU UCPD Arts 6–7 · UK DMCC Act 2024 Part 4 · Lanham Act §43(a) (statements about competitors).

---

## Business details — **Done, with a private-address approach** (Low)

| Detail | Displayed? | Verified? | Required by |
|---|---|---|---|
| Trading name (MarginCap) | Yes, every page | ✓ | — |
| Operator name — "Omar Kamel" | `/privacy#who`, `/terms#who`, homepage footer | ✓ (smoke test checks it) | EU E-Commerce Directive Art 5 · UK E-Commerce Regs 2002 reg 6 · CRD Art 6 · provincial internet-agreement rules |
| Mailing address | **Not on the website** (owner's privacy). Given privately instead: on every Stripe receipt/invoice (Stripe Public details → support address) and in the footer of every commercial email | ✓ once Stripe live mode is set up | EU E-Commerce Directive Art 5(1)(b) · UK E-Commerce Regs reg 6(1)(b) · CRD Art 6(1)(c) · CASL s.6(2) / CAN-SPAM (a postal address in every commercial email) |
| Contact email `hello@margincap.dev` | Every page | ✓ forwards to the owner's inbox | all of the above |
| Domain margincap.dev | Canonical, OG, JSON-LD | ✓ registered, HTTPS live | — |
| Governing law | `/terms#law`: New Brunswick + federal laws of Canada | ✓ | — |

**Approach chosen (option A):** the website shows the operator name only; the mailing address is disclosed privately to the people who need it.
- **Emails:** every launch/marketing email ends with the footer in `validation-kit.md` → *Launch email*, which includes the mailing address and an unsubscribe line. This satisfies CASL s.6(2) and CAN-SPAM, which require it **in the email**, not on the website.
- **Payments:** the address is set as the support address in Stripe's Public details, so it appears on every receipt and invoice. This gives Canadian buyers the business details at the point of sale.
- **Residual risk (Low):** EU/UK e-commerce and consumer-contract rules expect a geographic address to be easily accessible on the site itself. MarginCap sells mainly to businesses, which lowers this. **Revisit:** switch to a PO box or virtual mailbox (~$10–20/month) once paying customers arrive, and put it on `/privacy#who` and `/terms#who`.

**Still open (you):**
1. Stripe → Settings → Public details → add your support address (in live mode).
2. Register the business name **"MarginCap"** with Service New Brunswick (Partnerships and Business Names Registration Act).

---

## App Store list (the other screenshot)

| Rule | Result |
|---|---|
| Don't just ship a web app as a mobile app | N/A — no native app. If one ever ships, it must offer native value beyond the website (App Store Guideline 4.2). |
| Disclose AI features/content | Done: privacy policy states MarginCap uses no AI models on your data. |
| Privacy policy + terms | Done (above). |
| Delete account | Site: email-based deletion within 30 days. Dashboard MVP: self-serve "Delete workspace" (Guideline 5.1.1(v) if an app ships). |
| Restore purchases | Web equivalent: Stripe customer portal (open item #17). |
| Sign in with Apple | N/A — only required for iOS apps offering third-party social login (Guideline 4.8). |
| No fake ratings/reviews | Done (#16). |
| Data consent | Done (#6, #8). |
| Website for the app | Done. |
| Support page linked from the app | Done: `/support`, linked in every footer. |
