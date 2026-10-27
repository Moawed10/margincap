# UX checklist — MarginCap dashboard & SDK

Source: Aidan Murphy's reel "20 UI tips to send to Claude for better design" (Apple, Linear, Gmail, Stripe, Amazon details).
Status is per surface: **Landing** = `site/index.html` (live), **MVP** = the dashboard/SDK in the 2-week build.

| # | Tip | Where it applies in MarginCap | Status |
|---|---|---|---|
| 1 | Skeleton loaders | Margin table and per-feature chart while Stripe + usage data load. Match real row height so nothing jumps. | MVP |
| 2 | Optimistic updates | Waitlist form (done). Dashboard: toggling a customer's cap or alert flips instantly, rolls back on error. | Landing ✓ · MVP |
| 3 | Command menu | ⌘K: jump to a customer ID, feature, or setting. Customers with many accounts will live in this. | MVP |
| 4 | Shortcut hints | Show the key next to actions (`C` cap customer, `/` search, `⌘K`) in tooltips and menus. No animation on keyboard actions. | MVP |
| 5 | Undo toasts | "Capped cus_8fK2… · Undo" instead of a confirm dialog. Capping a paying customer is high-stakes; undo beats "are you sure?". | MVP |
| 6 | Stale-while-revalidate | Show the last margin numbers immediately, refresh in the background, mark "updated 2m ago". | MVP |
| 7 | Pre-rendering | Landing: preconnect to Stripe + Formspree (done). Dashboard: prefetch a customer's detail on row hover. | Landing ✓ · MVP |
| 8 | BlurHash placeholders | Only if we show images (avatars/logos). Low priority. | Later |
| 9 | View transitions | Table row → customer detail page morph (same-document View Transitions API). | MVP |
| 10 | Swipe-to-dismiss sheets | Mobile customer-detail sheet, dismiss by velocity not distance. | Later (mobile) |
| 11 | Interruptible animations | CSS transitions, not keyframes, for anything toggled quickly (done on landing). | Landing ✓ · MVP |
| 12 | Predictive back | Android back gesture previews the previous screen. Only matters if we ship a PWA. | Later |
| 13 | Hit slop | Landing × button (done). Dashboard: row action icons, chart points — 44px targets with invisible padding. | Landing ✓ · MVP |
| 14 | Safe area insets | Done on landing (`viewport-fit=cover` + `env()`). Reuse in dashboard shell. | Landing ✓ · MVP |
| 15 | One-time code autofill | Email OTP login: `autocomplete="one-time-code"`, `inputmode="numeric"`, paste fills all boxes. | MVP |
| 16 | Tabular numbers | All money and token columns (done on landing). Mandatory in the margin table. | Landing ✓ · MVP |
| 17 | Balanced headlines | `text-wrap: balance` on headings, `pretty` on body (done on landing). | Landing ✓ · MVP |
| 18 | Continuous corners | `corner-shape: squircle` behind `@supports` (done on landing). | Landing ✓ · MVP |
| 19 | Idempotency keys | Landing: no duplicate signups (done). **SDK ingest: each usage event carries a client-generated ID; the API dedupes, so retries never double-count cost.** This one is correctness, not polish. | Landing ✓ · **MVP must** |
| 20 | Amazon safe triangle | Nested menus (e.g. customer → actions → cap level) stay open while the cursor moves diagonally into the submenu. | MVP |
