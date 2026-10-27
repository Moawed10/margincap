# 3-Day Validation Kit — MarginCap

**Goal:** prove people will pay *before* writing the product.
**Go:** ≥30 waitlist signups **and** ≥3 paid pre-orders by end of Day 3 (allow replies to trickle in for 4 more days before calling it).
**Kill / pivot:** <10 signups, or the dominant reply is "Langfuse already does this" → test the hard-cap / kill-switch angle alone.

**Product:** MarginCap · **Domain:** margincap.dev (redirect getmargincap.com to it). Before buying, check the registrar price isn't premium and search Google + USPTO for "MarginCap".

---

## Day-by-day

| Day | Do | Done when |
|---|---|---|
| **1 (AM)** | Buy margincap.dev + getmargincap.com. Build the landing page from the copy below (Carrd / Framer / one HTML file on Cloudflare Pages). Add a waitlist form (Tally or a Google Form) + a Stripe Payment Link for the pre-order. Add Plausible or Umami. | Page live, form + payment link tested with a real card (refund yourself) |
| **1 (PM)** | Tier 1 threads: comment (Template A) where comments are open; DM the OP (Template B) on all of them. Max ~10 DMs today — Reddit flags bursts of identical DMs. | 10 contacts made, logged in the tracker |
| **2** | Tier 2 threads: comment + DM. Post your own r/SaaS / Indie Hackers post (Template D). Reply to every Day 1 response within a few hours. | 10 more contacts, own post live |
| **3** | Tier 3 threads (test the kill-switch message). Follow up (Template C) with anyone who replied but didn't sign up. Book 15-min calls with anyone warm. | Numbers in; call notes written |
| **4–7** | Don't post more. Answer replies, run calls, then decide go/kill against the thresholds above. | Decision written down |

**Reddit hygiene (this matters — getting banned from r/SaaS kills your best channel):**
- No link in your first comment or first DM. Link only when someone asks or replies.
- Personalise the first line of every DM with something from *their* post. Never paste identical DMs.
- Use an account with some history. A brand-new account DMing 30 founders looks like spam.
- Read each subreddit's self-promo rules before posting Template D.
- If a thread is archived (no reply box), skip the comment and just DM.

---

## Landing page copy

### Hero
**Find the customers your AI features are losing you money on.**

MarginCap links your LLM spend to your Stripe revenue, so you can see each customer's margin and cap the ones that are draining you. Setup takes 5 minutes, and it never sees your prompts.

`[ Get early access ]`  `[ Pre-order: $19/mo for life → ]`

<sub>Works with OpenAI, Anthropic, OpenRouter and Gemini. TypeScript first, Python next.</sub>

### The problem (3 short lines, big type)
You charge $29 a month.
One customer just cost you $64 in tokens.
Your OpenAI dashboard can't tell you who it was.

### How it works
1. **Wrap your client in one line.**
   ```ts
   const openai = track(new OpenAI(), { customerId: user.stripeId, feature: "summarize" })
   ```
2. **Connect Stripe with read-only access.** We pull each customer's revenue and leave everything else alone.
3. **Open the margin table.** Every customer is listed with revenue, AI cost and margin, and the money-losers sit at the top.

### What you get
- **Margin per customer.** Revenue minus AI cost for every Stripe customer, with a 30-day trend.
- **Cost per feature.** See which feature eats the budget, like "summarize" or "chat".
- **Alerts.** Slack or email when a customer's AI cost passes X% of what they pay you, or spikes 3× overnight.
- **Hard caps.** `canSpend(customerId)` returns allow, warn or block, so a runaway loop can't burn through your month.

### Privacy (put this high, it's the #1 objection)
**We never see your prompts or completions.** The SDK sends token counts, the model name, the customer ID and the feature tag. Nothing else. It runs async, so it never sits in your request path and can't slow down or break your app.

### Pricing
| Free | **Indie, $29/mo** | Startup, $79/mo |
|---|---|---|
| 50k events/mo | 1M events/mo | 10M events/mo |
| Cost per customer | **+ Stripe margin view** | + Hard caps |
| | + Email alerts | + Slack, cost per feature |

**Founding member: $19/mo locked for life on the Indie plan.** First 50 people only.
Charged today. Fully refunded on request any time before launch, no questions asked. Launching **[date, ~3 weeks out]**.

`[ Pre-order for $19 → ]`

### FAQ
**How is this different from Langfuse or Helicone?**
They're observability tools. They show what a user *cost*, but they don't know what that user *pays* you. MarginCap joins the two and gives you margin. (Helicone has also been in maintenance mode since its acquisition. If you're on it, we'll help you switch.)

**Can't Stripe's token billing do this?**
Stripe token billing helps you *charge* customers for tokens. If you're on flat or per-seat pricing, which most of us are, it doesn't show which customers you're losing money on.

**Do I need usage-based pricing?**
No. It's built for flat and per-seat pricing, which is exactly where power users hide.

**What if I don't use Stripe?**
You'll still get cost per customer and the caps. A CSV revenue import is coming soon.

**Who's building this?**
Me. [Name], a solo developer. [One line on why: "I run an AI side project and got burned by a power user" — only if true.] Questions go to [email].

### Footer CTA
**Stop guessing which customers are profitable.** `[ Get early access ]`

---

## Templates

### A. Thread comment (value first, no link)
Adapt the first line to the post. Keep the free tip; it's what earns the reply.

> Had the same problem. What finally worked for me without buying anything:
>
> 1. Every LLM response comes back with a `usage` object. Log `customer_id, feature, model, input_tokens, output_tokens, cached_tokens` to a table on each call.
> 2. Multiply by a small price table (keep cached tokens separate, they're much cheaper).
> 3. Export Stripe's customers + MRR, join on customer ID, and sort by `ai_cost / revenue`.
>
> The first time you run it you'll usually find a handful of accounts eating most of the spend. After that, put a per-customer daily budget check in front of the call so one runaway loop can't wreck your month.
>
> I'm turning this into a small tool because I got tired of redoing the spreadsheet every month. Happy to share if it's useful, but the steps above get you 80% of the way.

### B. DM to the original poster (short and curious, no link)
> Hey [name], saw your post about [their specific detail: "users triggering 50x more calls" / "the surprise OpenAI bill"]. Did you ever work out which customers were driving it?
>
> I'm building a small tool that joins LLM cost with Stripe revenue to show margin per customer and cap the expensive ones. Before I build more, I'm trying to learn how people handle this today.
>
> Two quick questions if you have a sec:
> 1. How are you tracking it now (spreadsheet, Langfuse, nothing)?
> 2. If something showed you margin per customer in 5 minutes, would that be worth ~$29/mo to you, or is it a nice-to-have?
>
> No pitch either way. Your answer is genuinely useful.

**If they answer positively:**
> Thanks, that's really helpful. Here's the page if you want early access: margincap.dev. I'm giving the first 50 people $19/mo for life (refundable until launch). Would you be up for a 15-min call this week? I'd love to see how you're handling it now.

### C. Follow-up for warm-but-silent replies (Day 3, once only)
> Quick follow-up. I'm closing the $19-for-life founding spots this week and wanted to make sure you saw it: margincap.dev. No worries at all if the timing's wrong. Thanks again for the earlier reply.

### D. Your own post (r/SaaS / Indie Hackers)
**Title:** I went through 27 threads of founders asking "which customers are my AI features losing money on?" Here's what people actually do.

> Body: summarise the patterns you found (spreadsheet + Stripe export, Langfuse with no revenue data, rate limits as a blunt fix, a 50x spread between heavy and light users). Include the DIY steps from Template A. End with: "I'm building a tool for this. If you want early access or just want to tell me why it's a bad idea, comment or DM." Link only if the sub's rules allow it, otherwise "link in profile".

### E. Launch email to the waitlist (legally required footer)
Send from `hello@margincap.dev`. Only email people who joined the waitlist (they consented on the form). **Never remove the footer.**

> **Subject:** MarginCap is live: see which customers your AI features lose money on
>
> Hi,
>
> You joined the MarginCap waitlist, so you're first to know: it's live. [One line on what they can do now + link to https://margincap.dev]
>
> Founding members keep $19/mo while they stay subscribed: [link]
>
> Omar
>
> —
> MarginCap · Omar Kamel · [your mailing address]
> You're getting this because you joined the waitlist at margincap.dev. Don't want these? Reply "unsubscribe" and you won't hear from us again.

Footer rules (CASL s.6 + CAN-SPAM): sender name, a valid mailing address, and a working unsubscribe that you honour within 10 business days (CASL) / 10 days (CAN-SPAM). Keep a list of unsubscribes and remove them before every send.

### Call script (15 min)
1. "Walk me through the last time AI costs surprised you." (Let them talk.)
2. "What did you do about it?" (Shows the current workaround, which is your real competitor.)
3. "What have you tried? Langfuse, Helicone, Revenium, a spreadsheet?"
4. "If this existed tomorrow, what would stop you from installing it?" (Listen for: privacy, it's another SDK, cost, Python-only.)
5. Close: "Want a founding spot at $19?" A yes-with-card is the only signal that counts.

---

## The 27 threads, prioritised

**How to read it:** Reddit post IDs are roughly chronological, so higher IDs (`1x…`, `1v…`) are newer and more likely to still accept comments. Older ones (`1m…`, `1o…`, `1p…`, `1i…`) are probably archived, so **DM only**.

### Tier 1: they asked for exactly this (Day 1, comment + DM)
| # | Thread | Why first |
|---|---|---|
| 1 | [How are you tracking LLM API costs per feature in production?](https://www.reddit.com/r/SaaS/comments/1tozxqo/how_are_you_tracking_llm_api_costs_per_feature_in/) | Said they "couldn't find anything" that fit. That's a direct buyer. |
| 2 | [How do you know if an AI feature is actually profitable?](https://www.reddit.com/r/SaaS/comments/1u0ynn9/how_do_you_know_if_an_ai_feature_is_actually/) | Matches token usage to customers by hand today. |
| 3 | [Those of you running LLM-powered SaaS, do you know your [per-customer cost]?](https://www.reddit.com/r/SaaS/comments/1r2qwgf/those_of_you_running_llmpowered_saas_do_you_know/) | Flat per-seat pricing with a 50x usage spread: your exact ICP. |
| 4 | [Looking for advice from people dealing with high LLM/AI API costs](https://www.reddit.com/r/AI_Agents/comments/1vgwuk0/looking_for_advice_from_people_dealing_with_high/) | Recent, active subreddit. |
| 5 | [I built the whole SaaS. Then the API bill killed it before launch](https://www.reddit.com/r/vibecoding/comments/1v4lzij/i_built_the_whole_saas_then_the_api_bill_killed/) | Recent and emotional. Lead with caps, not dashboards. |
| 6 | [Is there a good way to track costs per AI agent without doing it manually?](https://www.reddit.com/r/MLQuestions/comments/1swq1is/is_there_a_good_way_to_track_costs_per_ai_agent/) | Literally asking for the tool. |
| 7 | [Who's actually feeling the pain of AI API costs?](https://www.reddit.com/r/SaaS/comments/1srfdyk/whos_actually_feeling_the_pain_of_ai_api_costs/) | Small team, bills creeping up monthly. |
| 8 | [Unexpected OpenAI bill — how do you track usage?](https://www.reddit.com/r/SaaS/comments/1r87yv8/unexpected_openai_bill_how_do_you_track_usage/) | Had a spike and wants attribution. |
| 9 | [Anyone else getting unexpected AI bills? How are you tracking usage?](https://www.reddit.com/r/LLMDevs/comments/1s0cuh8/anyone_else_getting_unexpected_ai_bills_how_are/) | Same pain, different audience. |
| 10 | [How are you tracking AI API costs per customer / feature?](https://www.reddit.com/r/SaaS/comments/1pjl3g7/how_are_you_tracking_ai_api_costs_per_customer/) | Perfect fit but older, so **DM only**. |

### Tier 2: general cost pain (Day 2, comment where open, DM if they engaged)
| # | Thread |
|---|---|
| 11 | [AI API costs get crazy once people actually start using your product](https://www.reddit.com/r/SaaS/comments/1rpex96/ai_api_costs_get_crazy_once_people_actually_start/) |
| 12 | [How are you handling AI API costs as they scale?](https://www.reddit.com/r/SaaS/comments/1s3gu6j/how_are_you_handling_ai_api_costs_as_they_scale/) |
| 13 | [How do you manage AI costs in your SaaS?](https://www.reddit.com/r/SaaS/comments/1runb1z/how_do_you_manage_ai_costs_in_your_saas/) |
| 14 | [AI cost calculation, how?](https://www.reddit.com/r/SaaS/comments/1tymrvm/ai_cost_calculation_how/) |
| 15 | [Most AI SaaS founders probably don't know their real gross margins](https://www.reddit.com/r/ideavalidation/comments/1tpgy7u/most_ai_saas_founders_probably_dont_know_their/) (check whether the OP is building a competitor) |
| 16 | [How are early-stage SaaS founders managing LLM API costs?](https://www.reddit.com/r/micro_saas/comments/1sru3gs/how_are_earlystage_saas_founders_managing_llm_api/) |
| 17 | [How do you guys manage and monitor your AI / LLM API costs?](https://www.reddit.com/r/microsaas/comments/1rqjehb/how_do_you_guys_manage_and_monitor_your_ai_llm/) |
| 18 | [If your app makes requests to AI providers, how much are you spending?](https://www.reddit.com/r/saasbuild/comments/1sbh02g/if_your_app_needs_to_make_requests_to_ai/) |
| 19 | [For those building AI apps, how do you calculate AI API costs per user to stay profitable?](https://www.reddit.com/r/SaaS/comments/1odw6p6/for_those_building_ai_apps_how_do_you_calculate/) (older but the most-linked one. DM the OP **and** the top commenters.) |
| 20 | [How are you all modeling AI token usage + API costs?](https://www.reddit.com/r/SaaS/comments/1p5i5ol/how_are_you_all_modeling_ai_token_usage_api_costs/) (DM only) |
| 21 | [Need advice on real token usage & billing](https://www.reddit.com/r/SaaS/comments/1mecs2d/api_usage_cost_breakdown_for_ai_saas_need_advice/) (DM only) |
| 22 | [For AI SaaS – which LLMs do you use and how do you manage costs?](https://www.reddit.com/r/SaaS/comments/1iq18ta/for_ai_saas_which_llms_do_you_use_and_how_do_you/) (DM only. One commenter uses Lago; ask them what's missing.) |

### Tier 3: the caps and kill-switch angle (Day 3, lead with "cap runaway users" instead of "margin")
| # | Thread |
|---|---|
| 23 | [The $5,000 OpenAI bill story: why every vibe-coded app needs rate limiting](https://www.reddit.com/r/VibeCodersNest/comments/1ths1ro/the_5000_openai_bill_story_why_every_vibecoded/) |
| 24 | [About handling AI token usage in your SaaS](https://www.reddit.com/r/SaaS/comments/1qbs3uu/about_handling_ai_token_usage_in_your_saas/) |
| 25 | [How are you handling usage-based billing for AI agents? Stripe…](https://www.reddit.com/r/SaaS/comments/1t3hlj9/how_are_you_handling_usagebased_billing_for_ai/) |
| 26 | [For AI web applications, how can I limit usage per user?](https://www.reddit.com/r/webdevelopment/comments/1m8c9ps/for_ai_web_applications_how_can_i_limit_usage_per/) (DM only) |

> Track Tier 3 replies separately. If caps get more yeses than margin, that's your pivot signal.

### Don't pitch: these are competitors (use them for research)
| # | Thread | Use it to |
|---|---|---|
| 27 | [My OpenAI bill jumped 3× overnight, so I built a tool…](https://www.reddit.com/r/SaaS/comments/1qo5xap/my_openai_bill_jumped_3_overnight_so_i_built_a/) | Read the comments. Objections people raised there are objections you'll face. |
| – | [Tired of messy spreadsheets for API pricing, so I built a tool…](https://www.reddit.com/r/SaaS/comments/1xbk1lc/tired_of_messy_spreadsheets_for_api_pricing_so_i/) (5 days old) | Watch its traction. If it gets lots of upvotes and signups, that's demand. If it gets nothing, that's a warning. |
| – | [u/FaithlessnessVast136: per-user cost + guardrails tool](https://www.reddit.com/user/FaithlessnessVast136/) | Same. Note how they position it. |

---

## Tracker (copy into a sheet)

| Date | Thread # | Contact | Channel (comment/DM) | Replied? | Tracking today | Would pay $29? | Waitlist | Pre-order | Notes / objection |
|---|---|---|---|---|---|---|---|---|---|

**Scoreboard at end of Day 3:**
- Contacts made: __ / ~40
- Reply rate: __% (anything above 20% on cold DMs is strong)
- Waitlist: __ / 30
- Pre-orders: __ / 3
- Top 3 objections: __
- Margin vs caps: which message got more yeses? __
