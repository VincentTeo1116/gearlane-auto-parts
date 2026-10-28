# Sample orders, reports and inventory

This scenario is fictional and is intended for the confirmed **testing** Supabase project and local previews. It demonstrates the existing reports using order records, rather than hard-coded dashboard figures. No bank transfer, delivery, warehouse count or customer identity is real.

## Add examples to your testing Supabase project

1. Open **Supabase → SQL Editor** as the project owner.
2. Review and run [seed-analytics.sql](../supabase/examples/seed-analytics.sql). Run the whole file. It is a data example, not a replacement for `setup.sql`.
3. The final result should show **12 sample customers** and **84 sample orders**. Existing customers/orders remain in the database.
4. Refresh the website, sign in using your existing administrator account and open **Workspace → Overview**. Compare **Last 7 / 30 / 90 days** and select chart bars or category breakdowns.
5. Visit **Orders**, **Returns & refunds**, **Customer feedback**, **Users & roles**, and **Products** to examine the records behind the reports. Rebuild/redeploy the updated frontend to include the dashboard's testing-data notice.

The public application key cannot execute this owner-only SQL. No secret key needs to be shared. Rerunning the same file is a no-op: it does not add duplicate orders, customers, activity or inventory.

## What is included

| Example records | Quantity / behaviour |
| --- | --- |
| Fictional customers | 12: three each of personal, workshop, retailer and distributor |
| Orders | 84 spread across approximately 80 days, within the 90-day report |
| Verified paid orders | 70; includes delivered, processing/shipped and pending-refund examples |
| Other payment states | Awaiting, submitted, rejected, unpaid cancellation and fully refunded |
| Refund cases | 7 across requested, approved and paid states |
| Received-only reviews | 18, with fictional feedback and seller responses |
| Wishlist entries | 42 across different categories |
| Activity events | 336: sessions, product views, checkout starts and order placement |
| Inventory examples | 48 products with at least 10 remaining units, five low-stock and three sold out, before adding existing stock |

Customers with business classifications generally buy larger quantities: personal orders use one or two units per line, workshops three to six, retailers six to twelve and distributors twelve to twenty. These are examples, not newly introduced wholesale price rules or real customer behaviour.

Generated reference-price figures for the example orders alone:

| Period | Orders | Verified paid orders | Recorded paid sales |
| --- | ---: | ---: | ---: |
| 7 days | 8 | 3 | RM 1,906.96 |
| 30 days | 36 | 28 | RM 21,915.91 |
| 90 days | 84 | 70 | RM 53,633.76 |

The installed reports can differ: the SQL uses **your current product prices and delivery configuration**, includes your existing records, and shifts example timestamps relative to execution. Seven-day boundary counts can vary with execution time. The totals above are not revenue forecasts.

## Example remaining stock

| Product | Added remaining sample units |
| --- | ---: |
| Toyota Fully Synthetic 0W-20 Engine Oil 4L | 95 |
| SAE 40 Engine Oil 1L | 104 |
| Castrol GTX Ultraclean 15W-40 Engine Oil 4L | 119 |
| Aftermarket Engine Oil Filters — 10 Pack | 221 |
| 10W-30 Engine Oil + Perodua Oil Filter Bundle | 183 |
| TRW GDB8977 Front Brake Pads | 135 |
| SUPERCIRCUIT Proton X70 Downpipe | 4 |
| Liqui Moly DOT 5.1 EV Brake Fluid 500ml | 0 |
| Bosch Aerotwin Plus AP32 Wiper Blade — Single Pack | 0 |

The script adds these remaining units to any existing stock. It models fictional opening receipts minus reserved/sold quantities plus cancelled/returned units. It preserves current selling prices and marks products with available sample stock as price-confirmed for testing. It does not change checkout availability, bank details, delivery settings or product activation. Enabling checkout still requires the normal store configuration.

All money uses integer cents. Unpaid/rejected/submitted orders and completed paid refunds are excluded from paid-sales figures. An approved refund remains part of verified sales until its transfer is recorded. Category values represent item revenue before delivery charges; their sum therefore need not equal total order revenue. Active hours use Malaysia time; activity counts represent recorded events, not unique people. Average paid order is verified paid sales divided by verified paid orders, not an average across cancelled or unpaid orders.

Sample customer Auth rows are **non-login placeholders** with no password, identity, session or invitation. They use `example.invalid` email addresses. This follows [Supabase's documented seed pattern](https://supabase.com/docs/guides/local-development/cli-workflows#step-4-add-seed-data); use your existing admin account to inspect them. The script does not send emails.

## Local preview

Run `npm run dev:demo` and sign in with the displayed admin preview account. New previews include the full scenario automatically, alongside the original two customer orders. For an older saved preview, use **Load sample report data** on the admin overview. This appends the examples once while preserving existing preview records. Local preview data and the testing Supabase seed are separate datasets.

## Optional removal

Review and run [remove-analytics.sql](../supabase/examples/remove-analytics.sql) in SQL Editor. It deletes only the recorded scenario IDs and restores earlier stock/price-confirmation values. It stops without removing anything if product stock, versions or price-confirmation flags have changed, or a sample customer has additional orders. Do not bypass that conflict check: later testing work must be reconciled first. Database foreign keys also prevent deleting sample users that later records still reference. Existing orders, accounts, settings and prices are preserved. Identity sequences are not rewound.

The database test verifies installation, correct totals using changed prices/delivery charges, agreement with actual `dashboard_stats` SQL, customer isolation, repeat installation, conflict-protected cleanup and restoration. The browser workflow verifies the admin report against its underlying preview orders. To regenerate the standalone example after changing the scenario, run `npm run seed:examples`; it does not connect to Supabase or apply SQL. Example data is deliberately excluded from `setup.sql` and the normal catalogue seed.
