# Contributing

Coordinate changes with the repository owner. The licence and external contribution policy have not yet been selected.

## Development

Use Node.js 24 and run commands from the application root:

```sh
npm ci
npm run dev:demo
```

Preview mode uses browser-local sample data, does not require Supabase credentials and must remain clearly labelled. For live integration, follow the README using a development Supabase project. Do not use customer production records as test fixtures.

## Changes and review

1. Create a branch describing the change, such as `fix/order-status-validation`.
2. Describe the user problem and expected behaviour before changing business rules.
3. Keep interface checks and authoritative database checks consistent. Never rely on hidden buttons as permission enforcement.
4. Preserve historical orders and financial records. Coordinate changes to live schema through a separate incremental migration; changing fresh-project setup alone does not update existing deployments.
5. If live repository operations change, update the preview implementation where appropriate and document any remaining differences.
6. Update relevant documentation and verification for changed behaviour.

Before opening a pull request:

```sh
npm test
npm run build
npx playwright install chromium
npm run test:browser
git diff --check
```

Run browser checks for changes affecting screens or workflows. For backend changes, include meaningful permission and state-transition coverage. Record any required Supabase migration, environment update or manual acceptance step in the pull request. Do not claim live email, storage or payment acceptance based only on preview tests.

## Credentials and data

Commit `.env.example` with empty values. Never commit `.env.local`, service-role keys, database passwords, real receipts, private messages or customer exports. Review staged files before pushing. Report suspected vulnerabilities privately as described in [SECURITY.md](SECURITY.md).
