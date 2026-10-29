# Operations guide

Running GearLane after launch: deploying safely, watching it, recovering from problems, and the optional email and search features.

## 1. Deploying safely

Database changes always go first, then the app. The app is written to keep working if an optional migration is missing, but a missing migration means that feature is switched off.

1. **Back up first.** In Supabase, check the latest backup under Database, Backups. Point-in-time recovery is only available on paid plans, so confirm what your plan includes.
2. **Run the new migrations** in the Supabase SQL Editor, in number order, and only the ones you have not run yet. Each is safe to run twice and changes no business data.

   | File | What it does | If you skip it |
   | --- | --- | --- |
   | `010-privacy-hardening.sql` | Hides bank details, promotion codes and reviewer identifiers from the public | **Required before deploying this version.** The app reads settings through the new view |
   | `011-analytics-previous-period.sql` | "vs previous period" labels on the dashboard | The labels simply do not appear |
   | `012-order-emails.sql` | Remembers which order email was sent | Order emails are not sent |
   | `013-stock-alerts.sql` | "Notify me when back in stock" | Tapping "Notify me" shows an error; nothing else breaks |
   | `014-vehicle-fitment.sql` | Vehicle finder and fitment lists | The vehicle finder does not appear |

3. **Deploy the app** (push to `main`; Vercel builds it). CI must be green first: unit tests, build, every browser check and the dependency audit.
4. **Check `/api/health`** returns `{"status":"ok"}`, then open the store, sign in as a customer and as staff, and place and cancel a test order.
5. **To roll back**, redeploy the previous Vercel build. Database migrations are additive, so the previous app still works with them, except that `010` requires the new app (the old app would no longer find bank details or promotions).

## 2. Watching the store

### Uptime
Point any uptime monitor (UptimeRobot, Better Stack, Vercel's own checks) at:

```
GET https://YOUR-DOMAIN/api/health
```

It returns `200 {"status":"ok"}` only when the site is up **and** the database answers. Anything else is `503` with a short status word and no internal detail. Alert on two failures in a row.

### Browser errors
Uncaught errors in customers' browsers are sent to `/api/client-error` and written as one JSON line each to the **Vercel function logs** (Project, Logs, filter for `client_error`). At most five per page load, never the same message twice, nothing stored in the database, nothing personal beyond the page path and browser name.

To get alerts or keep them longer, add a **Vercel Log Drain** to your log service (Datadog, Better Stack, Axiom and similar) and alert on `type:client_error`. A rise right after a deploy means the deploy broke something.

### Database
Supabase, Reports shows API and database health. Watch connection count, slow queries and storage. Turn on the email alerts Supabase offers for usage limits.

## 3. Order emails (Resend)

Customers receive an email when an order is placed, payment is verified or rejected, shipped, delivered, or cancelled. Emails contain the order number, amount and a link, never bank details.

Set these in the **Vercel server environment** (never with a `VITE_` prefix), then redeploy:

| Variable | Value |
| --- | --- |
| `RESEND_API_KEY` | An API key from Resend |
| `EMAIL_FROM` | For example `GearLane <orders@yourdomain.com>` on a domain you verified in Resend |
| `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SITE_URL` | Already needed for user management |

Until your domain is verified in Resend you can only send to your own Resend account address, so test with an order placed by that address.

How it works, so you can reason about problems: after an action succeeds, the browser asks `/api/order-email` to send the matching email. The server checks the caller may read that order and that the order is really in that state, sends once (the `order_emails` table prevents repeats), and releases the claim if sending fails so the next attempt can retry. Because the request comes from the browser, an email can be missed if the tab is closed at that exact moment. If a customer says an email never arrived, check the order's status in the workspace; the order itself is never affected.

Signup confirmation, password reset and staff invitation emails are separate: they are sent by Supabase Auth through the SMTP settings in the Supabase dashboard.

## 4. Search visibility

- Every public page sets its own title, description and canonical link; product pages include structured data. Prices appear there only when the store has confirmed them.
- Cart, checkout, account, orders, messages, saved items and the whole staff workspace are marked `noindex`.
- `/sitemap.xml` lists the home page, shop, each category and each active product, and `/robots.txt` points to it. Both are generated from `SITE_URL`, so set it to the real domain.
- After launch, add the domain to Google Search Console and submit `/sitemap.xml`.
- Limit: social-media link previews (WhatsApp, Facebook) read only the static tags in `index.html`, so a shared product link shows the generic store preview. Per-product previews need server-side rendering, which this app does not do.

## 5. Vehicle fitment and stock alerts

- **Fitment is data you enter.** In Products, edit a product and fill "Vehicles this product is listed for", one per line: `Make, Model, Years` (for example `Proton, X50, 2020-2024`; years are optional). Customers can then pick their vehicle on the shop page. A product with no list is never described as "fits" or "does not fit"; the page tells customers to ask. The demo store derives sample fitment from product names; a live store starts empty.
- **Back-in-stock alerts** are in-app notifications (the bell). They fire when stock goes from 0 to above 0 through a restock, an edit or a cancelled order returning stock, only for products that are active with a confirmed price. A customer can follow up to 50 products.

## 6. Exports

Staff can export the orders in the current filter and the product list as CSV from the Orders and Products pages. Customer-controlled text that a spreadsheet could read as a formula is neutralised. Exports contain customer names, phone numbers and addresses: store and share them as you would any customer data, and delete them when finished.

## 7. Performance checks

`npm run test:load` seeds the demo store with thousands of products, orders, reviews and users and fails if a page renders everything at once, a list stops paging, an export drops rows, or a render takes much longer than expected. It tests the interface, not Supabase. Before a large promotion, also test the real database with a load tool such as k6 against a staging project, and confirm your Supabase plan's connection and request limits.

The live app loads the 200 most recent orders and 500 most recent reviews into the browser. If you regularly exceed that, the next step is server-side filtering and paging in the repository layer.
