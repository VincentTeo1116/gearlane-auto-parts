# Security

## Reporting a vulnerability

Contact the repository owner privately through an agreed support channel. A dedicated reporting address has not yet been configured; the owner should add one before opening the project to external users.

Do not put exploit details, access tokens, customer records, private receipts or database credentials into a public issue. Provide the affected commit/version, reproduction steps using test accounts, expected and observed behaviour, and the potential impact. Test only environments you are authorised to access. No response-time commitment or bug-bounty programme is established by this file.

## Implementation boundaries

- Supabase Auth identifies the signed-in user. Database functions validate current active roles and business rules; RLS controls record reads and realtime visibility.
- The public Supabase publishable/anon key is browser configuration. A service-role key is privileged and belongs only in server-side configuration.
- The Vercel user-management endpoint validates the bearer token, request origin and current active admin role before privileged operations.
- Product images are public; payment proofs are private and accessed using short-lived signed links.
- Customer receipt confirmation is required before reviewing a purchased item. Payment submission, deposit verification, refund approval and a recorded refund transfer are distinct events.
- Preview credentials apply only to local demonstration data and confer no live privileges.
- Bank details are not publicly readable. Signed-out visitors and customers read store settings through a view that omits them, admins read the full record through a role-checked function, and each order keeps its own copy of the bank details at the time it was placed.
- Promotion codes cannot be listed. Customers check one code at a time; every failure returns one generic message after a short delay. Admins manage the full list.
- Signed-out visitors can read review text but not reviewer or order identifiers.

These controls do not imply independent security certification or a guarantee of no vulnerabilities. The database test scaffold does not replace live Supabase Auth, Storage and deployment testing.

## Deployment responsibilities

Before going live, confirm these in the Supabase dashboard (they cannot be set from this repository): email confirmation is required for new sign-ups; the Auth rate limits for sign-in, sign-up and password reset are enabled; the minimum password length is at least 8 and leaked-password protection is on; the Site URL and redirect URLs list only your production domain; and the service-role key exists only in the Vercel server environment. Keep secrets out of browser variables and source control. Configure email delivery, authentication abuse controls, production origins, backups, monitoring and an appropriate retention policy. Keep dependencies updated and run `npm audit --omit=dev` when assessing production dependency advisories. Investigate advisories in context rather than applying unreviewed breaking upgrades.

If a privileged credential is exposed, rotate/revoke it in the relevant service, review access and affected data, and remove it from repository history where necessary. Removing only the visible file does not revoke an exposed credential.
