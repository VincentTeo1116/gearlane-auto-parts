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

These controls do not imply independent security certification or a guarantee of no vulnerabilities. The database test scaffold does not replace live Supabase Auth, Storage and deployment testing.

## Deployment responsibilities

Keep secrets out of browser variables and source control. Configure email delivery, authentication abuse controls, production origins, backups, monitoring and an appropriate retention policy. Keep dependencies updated and run `npm audit --omit=dev` when assessing production dependency advisories. Investigate advisories in context rather than applying unreviewed breaking upgrades.

If a privileged credential is exposed, rotate/revoke it in the relevant service, review access and affected data, and remove it from repository history where necessary. Removing only the visible file does not revoke an exposed credential.
