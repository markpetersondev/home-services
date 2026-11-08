# FixNoww: Project Assessment

*Opinion and recommendations, 8 November 2026. Companion to the [PRD](PRD.md) and [project overview](PROJECT_OVERVIEW.md).*

> **Update:** the project's main goal is now learning backend development, so the MVP uses Node.js and MySQL in a separate workspace. See the [backend guide](BACKEND.md). The Supabase recommendation, timeline and first-step advice below assumed the fastest route to a real launch. They still apply if you later turn this into a business.

## Short answers

| Question | Answer |
| --- | --- |
| **What do I think of the project?** | It's a real, useful idea with a tidy prototype. The hard part ahead is running a trusted marketplace, not writing the code. |
| **Do we need a backend?** | **Yes.** Without one, the app cannot work between two phones. But don't hand-write a server yet: start with a managed Postgres backend such as Supabase. |
| **Do we need a web admin panel?** | **Yes, before public launch, and small.** You don't need it for the first pilot; database tools are enough at that size. |
| **What should happen first?** | Spend 2 to 4 weeks talking to providers and customers, and run real jobs by hand over WhatsApp, **before** building the backend. |

## 1. What I think of the project

### What's good

- **The core loop is clear and already demonstrable:** request, accept, start, complete. A prototype this clear is useful for showing providers and getting feedback.
- **The code is a good starting point:** about 4,000 lines of Dart, well organised by feature, with Riverpod and go_router in place. Screens read from providers, so a backend can be added without rewriting the UI.
- **The focus is sensible:** a specific country, common repair trades, and separate customer and provider experiences.

### What concerns me

1. **Trust is the actual product.** People are inviting a stranger into their home. Provider checks, reviews and dispute handling aren't in the prototype, and they are what would make someone choose this over a cousin's plumber.
2. **Each side needs the other.** Customers leave if nobody answers; providers leave if no jobs come. A narrow launch, such as three trades in part of Colombo, gives you a chance to make both work.
3. **Deals will move off the app.** Once a customer has a good plumber's number, they have little reason to return. The prototype shows the customer's phone number to the provider, which makes this easier. Decide how you will earn money with this in mind, and don't assume a commission will stick.
4. **The price flow needs changing.** Right now, a provider sets the price and the job is immediately accepted, without the customer agreeing. Customers need to approve the price, and the PRD adds this step.
5. **The idea isn't new.** Search results show several Sri Lankan efforts:
   - [Blu](https://apps.apple.com/app/id6749176134), which has separate customer and provider apps and looks like the most recent entrant
   - [QuickHelp](https://www.life.lk/article/top_story/Quick-Help:-On-demand-services-at-your-fingertips/28/19936)
   - [FASTFIX](https://www.ft.lk/PropertyConstruction/FASTFIX-app-to-facilitate-easy-home-repairs/10516-703827)
   - [Worky](https://www.ft.lk/business/Worky-aims-to-revolutionise-Sri-Lanka-s-job-market/34-760164)
   - [Fynd.lk](https://www.pressreader.com/sri-lanka/sunday-times-sri-lanka/20190113/282699048285769)

   I couldn't confirm which are still active or how well they're doing, and competition isn't a reason to stop. But you should try each one and ask providers about them. If earlier attempts stalled, the reason is the most valuable thing you can learn right now.

### My overall view

It's worth pursuing **as a small, hands-on local test**, and I'd be cautious about investing months in features first. The prototype is far enough along. What you don't yet know is whether customers will trust it, whether providers will respond, and who will pay. Those answers come from running real jobs.

## 2. Do we need our own backend?

**Yes, you need a backend.** Today all data lives in memory on one device, so a customer's request can never reach a provider's phone. A backend also has to handle things that can't be trusted to the app:

- Real login and enforcing what each role can see and do
- Letting only one provider claim a job when two tap at once
- Triggering push notifications
- Protecting phone numbers, addresses and NIC images
- Keeping provider ratings and earnings from being altered by the client
- Keeping an audit trail for disputes

**But "our own backend" doesn't have to mean writing a custom server yet.** You need to own your data and rules, and a managed platform lets you do that without running servers.

### Options

| Option | Good for | Downsides | Verdict |
| --- | --- | --- | --- |
| **Supabase** (managed Postgres, auth, storage, realtime, functions) | Relational data like users, bookings, offers and reviews; strong server-side access rules; standard Postgres you can move elsewhere | You need to learn row-level security; the free plan pauses after a week of inactivity | **Recommended** |
| **Firebase** (Firestore, auth, functions) | Very smooth Flutter and push setup, offline sync | Document storage suits this kind of linked data less well; moving away later is a real project | Reasonable second choice |
| **Custom server** (such as NestJS or Laravel, with Postgres) | Full control, complex logic, no platform limits | You build and run auth, hosting, security, backups and monitoring yourself; slowest route to a pilot | Not yet |

I recommend Supabase because bookings, offers, reviews and users are linked data that suits Postgres. Comparisons generally [favour Postgres for marketplace-style data](https://toolradar.com/compare/supabase-vs-firebase), though many of those sources are vendor-adjacent blogs. If you or a future teammate already knows Firebase well, that could reasonably change the choice, because familiarity counts for a lot on a small team.

### How to keep your options open

- Add a repository layer between the Riverpod providers and the backend, so the choice stays out of your screens.
- Keep business rules, such as booking state changes, in database functions or server functions.
- Use Firebase Cloud Messaging for push notifications with either option.

### When to move to a custom server

Consider adding one when you hit a concrete need:

- Automated dispatch that outgrows database functions
- Online payments with payouts and reconciliation
- A team with backend engineers who would move faster on their own stack
- Platform costs or limits that are measurably hurting you

You can add a custom service next to Supabase and keep the same Postgres database, so this doesn't have to be a rewrite.

### Costs to expect

| Item | What I found | Notes |
| --- | --- | --- |
| **Supabase** | [Free plan, or Pro from $25/month](https://supabase.com/pricing.md) plus compute beyond the included credit | Use Pro for real users so the project doesn't pause; check limits first |
| **SMS OTP** | Google lists Sri Lanka at [roughly $0.28 to $0.31 per SMS](https://cloud.google.com/identity-platform/pricing) in the page versions I saw | This could be your most noticeable early cost: 1,000 logins would be about $300 at that rate. Check the live price, compare local SMS suppliers, and keep users logged in for a long time |
| **Payments** | [PayHere](https://support.payhere.lk/api-&-mobile-sdk/flutter-sdk) has an official Flutter SDK and [T+2 daily settlement](https://support.payhere.lk/general-questions) | I couldn't confirm its official fees or whether it can split payments between you and providers. Ask PayHere before designing around it. Start with cash |

## 3. Do we need a web admin panel?

**Yes, a marketplace can't run without admin tools, but the timing and size matter.** Somebody has to approve providers, see stuck jobs, handle complaints, suspend bad actors and check metrics. Those jobs don't belong in the customer or provider apps.

### Recommended approach

| Stage | Admin tool | Why |
| --- | --- | --- |
| **Phase 0: manual test** | WhatsApp and a spreadsheet | There's no software to manage yet |
| **Closed pilot: 20 to 50 jobs** | Supabase dashboard and saved queries, used only by you | Fast, and you learn which actions you repeat. Fine for one trusted person, risky for more |
| **Before public launch** | A small custom web panel | Needed once more than one person handles operations, or volume makes direct database edits risky |
| **After launch** | Add features only when manual work justifies them | Avoids building reports nobody reads |

### First version of the panel

Build only these five areas:

1. **Provider approvals:** review applications and NIC images; approve, reject or suspend.
2. **Bookings:** search jobs and see each one's history.
3. **Disputes:** read reports, record decisions, cancel or reassign jobs.
4. **Users and reviews:** suspend accounts, remove abusive reviews.
5. **Dashboard:** open, unanswered, completed and disputed jobs.

### How to build it

- **Technology:** use **Flutter Web** if you're working alone. You keep one language and can share models and backend code, and search-engine visibility doesn't matter behind a login. If you hire web developers or need heavy data tables, React with an admin framework is the better choice.
- **Security:**
  - Staff get named accounts with two-step verification.
  - Admin rights are enforced by the server. Never put a Supabase service key in browser code.
  - Every admin action goes in an audit log, especially viewing NIC images.

## 4. Other things to plan for

- **Data protection law:** key provisions of Sri Lanka's Personal Data Protection Act are [gazetted to take effect on 1 January 2027](https://www.ft.lk/front-page/Data-protection-compliance-regime-takes-effect-on-1-Jan-2027/44-795776), so they will likely apply by the time you launch. You'd be storing phone numbers, home addresses and ID images. Reports differ on the exact sections covered, so check the gazette and get local legal advice.
- **Customer and provider terms:** decide who is responsible for bad work, damage and safety incidents. Get this reviewed by a lawyer before public launch.
- **Operations time:** even a small pilot needs someone answering calls during the hours you advertise. Plan for this as real work.

## 5. Recommended order

1. **Now, in about a day:** fix the small demo problems in the prototype, especially the price approval step and the logic gaps, so it's credible to show people. Commit the current working changes.
2. **Weeks 1 to 4:** talk to at least 10 providers and 10 customers, try competitors, and run real jobs by hand with 5 to 10 providers.
3. **Then decide:** continue only if customers book and providers show up. If they don't, change the idea before building more.
4. **Next 4 to 6 weeks:** build the Supabase backend and the revised booking flow.
5. **Next 3 to 4 weeks:** run a closed pilot of 20 to 50 real jobs, using database tools for admin.
6. **Next 4 to 6 weeks:** build the web admin panel, handle legal documents, and release publicly.

All time estimates assume one full-time developer and are rough.

## Sources

- **Competitors:** [Blu](https://apps.apple.com/app/id6749176134), [QuickHelp](https://www.life.lk/article/top_story/Quick-Help:-On-demand-services-at-your-fingertips/28/19936), [FASTFIX](https://www.ft.lk/PropertyConstruction/FASTFIX-app-to-facilitate-easy-home-repairs/10516-703827), [Worky](https://www.ft.lk/business/Worky-aims-to-revolutionise-Sri-Lanka-s-job-market/34-760164), [Fynd.lk](https://www.pressreader.com/sri-lanka/sunday-times-sri-lanka/20190113/282699048285769)
- **Backend:** [Supabase pricing](https://supabase.com/pricing.md), [Supabase vs Firebase comparison](https://toolradar.com/compare/supabase-vs-firebase), [Google Identity Platform pricing](https://cloud.google.com/identity-platform/pricing)
- **Payments:** [PayHere Flutter SDK](https://support.payhere.lk/api-&-mobile-sdk/flutter-sdk), [PayHere general questions](https://support.payhere.lk/general-questions)
- **Law:** [Daily FT on the PDPA effective date](https://www.ft.lk/front-page/Data-protection-compliance-regime-takes-effect-on-1-Jan-2027/44-795776)

Prices and laws change, so confirm them on the official pages before relying on them.
