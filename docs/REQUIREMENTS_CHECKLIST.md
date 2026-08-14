# Information and accounts needed from the owner

## Branding

- Final SVG/PNG logo and app icon
- Splash tagline
- Support email and website/domain
- Privacy policy and terms URL

## Cloud accounts

- Firebase project for authentication, analytics and notifications
- Google Cloud OAuth client for Gmail, Calendar and Drive
- AI provider account and server-side API key
- Managed PostgreSQL and Redis
- S3-compatible object storage
- Android Play Console and, later, Apple Developer account

## Product decisions

- Free and Pro limits
- Subscription prices
- Which agent actions always require approval
- Data retention period
- Countries/languages supported at launch
- Minimum Android/iOS versions

Never commit credentials. Put secrets in `.env` locally and the deployment platform's secret manager in production.
