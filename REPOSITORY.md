# GitHub repository setup

## Copy-ready metadata

**Repository name**

```text
gearlane-auto-parts
```

**Description**

```text
Automotive e-commerce system built with React, Vite and Supabase. Includes customer shopping, manual bank-transfer checkout, worker order and support tools, admin management, inventory, refunds, product reviews and interactive analytics. Deployable on Vercel.
```

The description is below GitHub's requested 350-character limit.

**Suggested topics**

```text
ecommerce automotive auto-parts react vite supabase postgresql vercel inventory-management order-management admin-dashboard customer-support
```

**Visibility:** start private while preparing this commercial application. Choose public only if sharing the source is intended. No licence has been selected on the owner's behalf.

**Website:** add the actual Vercel production URL after deploying. No deployed URL is assumed here.

## Files provided

| File | Purpose |
| --- | --- |
| `README.md` | Complete system overview, architecture, role capabilities, setup, operation, deployment, testing and limitations |
| `.gitignore` | Excludes dependencies, local environment files, build output, logs and generated/private local files |
| `.env.example` | Empty configuration template for browser and server variables |
| `.editorconfig` | Shared text formatting conventions |
| `.gitattributes` | Consistent text line endings across operating systems |
| `CONTRIBUTING.md` | Local development, change and review guidance |
| `SECURITY.md` | Private vulnerability reporting and safe credential handling |
| `.github/workflows/ci.yml` | Automated tests, frontend build and Chromium preview verification |
| `.github/ISSUE_TEMPLATE/bug_report.md` | Reproduction and environment details for defects |
| `.github/ISSUE_TEMPLATE/feature_request.md` | Business problem, user role and acceptance criteria for proposed features |
| `.github/pull_request_template.md` | Change summary, verification and deployment notes |

`LICENSE` is intentionally not generated until the owner chooses the licence. A logo, screenshots, live URL, named maintainer contact and repository-specific badges can be added once those details are confirmed.

## Create a standalone repository

1. Create an empty GitHub repository named `gearlane-auto-parts` with the description above. When uploading these prepared files, leave automatic README, `.gitignore` and licence generation unselected to avoid duplicate starter files.
2. Copy the **contents** of `automotive/`, including hidden configuration folders such as `.github/`, into a separate empty local folder named `gearlane-auto-parts`. Do not copy `.git`, `.env.local`, `.generated`, `node_modules`, `dist` or `.vercel`. Preserve the provided `.gitignore`, `.env.example` and `.env.demo`; the latter contains the non-secret preview-mode flag.
3. From the new folder, initialise Git and connect your actual repository URL:

```sh
git init -b main
git add .
git status --short
git diff --cached --stat
```

Review staged files before committing. Local environment configuration and private bootstrap SQL must be absent. Then run:

```sh
git commit -m "feat: initialize GearLane automotive ecommerce system"
git remote add origin https://github.com/YOUR_USERNAME/gearlane-auto-parts.git
git push -u origin main
```

Replace `YOUR_USERNAME` with the repository owner. These are instructions; no new Git repository, remote, commit or publication is created automatically.

4. Add the suggested topics and the real production URL to the repository's About details.
5. For a team repository, configure reviews and require the `Tests, build and browser checks` CI result before merging important changes.
6. Import the new repository in Vercel with the application at the repository root, and follow the README's environment, database and launch steps.

If retaining this application in the existing parent repository, keep using `automotive/` as the Vercel root. Do not run `git init` inside the existing application folder. The nested `.github/` files are a starter kit for the standalone repository, not active parent-repository configuration.
