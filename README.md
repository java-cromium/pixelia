# Pixelia

Full-stack SaaS platform for web presence management — sites, e-commerce, Google Ads, Meta Ads, custom domains, and billing.

## Tech Stack

- **Framework**: Rails 8 (Ruby 3.2)
- **Database**: PostgreSQL 16
- **Background Jobs**: Sidekiq + Redis
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS v4
- **Payments**: Stripe (via pay gem)
- **Ads**: Google Ads API, Meta Marketing API (Koala)
- **Domains**: Cloudflare for Platforms
- **Auth**: Devise + OmniAuth

## Local Development

```bash
# 1. Install dependencies
bundle install
yarn install

# 2. Copy environment variables
cp .env.example .env
# Fill in required values

# 3. Setup database
rails db:create db:migrate db:seed

# 4. Start all processes
bin/dev
```

This starts Rails server, JS bundler, and CSS watcher via `Procfile.dev`.

## Running Tests

```bash
rails test
```

## Deployment (Render)

This app deploys to **Render** using Infrastructure-as-Code (`render.yaml`).

### Services Provisioned

| Service | Type | Purpose |
|---------|------|---------|
| `pixelia-web` | Web Service | Rails app (Puma) |
| `pixelia-worker` | Background Worker | Sidekiq |
| `pixelia-db` | PostgreSQL | Primary database |
| `pixelia-redis` | Redis | Job queue + cache |

### Deploy Steps

1. Push code to GitHub
2. In Render Dashboard → **New** → **Blueprint**
3. Connect your repo and select the branch
4. Render reads `render.yaml` and provisions all services
5. Set secret env vars in the Render dashboard (marked `sync: false` in blueprint)
6. First deploy runs `bin/render-build.sh` which installs deps, compiles assets, and migrates

### Required Secrets (set in Render Dashboard)

See `.env.example` for the full list. Critical ones:

- `RAILS_MASTER_KEY` — from `config/master.key`
- `ACTIVE_RECORD_ENCRYPTION_*` — three encryption keys
- `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`
- `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`
- `META_APP_ID`, `META_APP_SECRET`
- `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ZONE_ID`
- `APP_HOST` — your production domain (e.g. `pixelia.com`)

### Custom Domains

Configure in Render Dashboard under the web service settings. The app uses subdomain routing:
- `www.pixelia.com` — marketing site
- `app.pixelia.com` — self-serve portal

## Project Structure

```
app/
├── controllers/
│   ├── admin/          # Super-admin panel
│   ├── marketing/      # Public marketing site
│   └── portal/         # Self-serve client portal
├── models/             # Account, User, Site, campaigns, etc.
├── services/           # GoogleAdsService, MetaAdsService, CloudflareDomainService
└── views/
    ├── layouts/        # portal.html.erb, admin.html.erb, marketing
    └── portal/         # Dashboard, sites, campaigns, billing, settings
```
