# MyKiosk — where things stand

Written 12 Sep 2026, updated 14 Sep 2026. Everything below is on `master` and green in CI.

**Since 12 Sep:** the Android decision is made — a Flutter app (repo `ra-gupta/mykiosk_android`,
folder `~/Documents/prince_vegetables/android`) serves both shoppers and the owner; Rails stays as
backend + web admin. The API grew an owner side for it (below). The app is brand-free: the shop's
name comes from `GET /api/v1/shop`, which reads `SHOP_NAME` from the server environment.

## What exists

**Storefront (Rails 8.1, Tailwind, SQLite)**
- Catalog with real produce photos, pack size, price beside MRP, discount ribbon, search. Two cards per row on a phone, three on desktop.
- Session basket with +/− steppers, clamped to stock.
- Sign in with a mobile number + OTP (the code also signs up first-timers) or email + password. One `User.authenticate` serves web and API.
- Checkout with an Amazon-shaped address (name, mobile, pincode, flat/building, area/street, landmark, town, state) and a delivery choice: **in 30 minutes** or **by 9 pm today**. Cash on delivery only.
- Address prefills from the shopper's last order. Every past order has **Reorder**, clamped to today's stock.
- Order stages: placed → packed → out for delivery → delivered, or cancelled while open.

**Owner console** (`owner: true` on the user)
- `/owner/orders` — live board (Turbo Streams); each card carries the one button that moves the order along, plus a ⚡/🌙 pill for the delivery choice. A browser notification fires for orders that arrive while the page is open.
- `/owner/products` — add/edit items, upload a photo (Active Storage), one-click **Mark out of stock**.

**Alerts** — all through jobs, all no-ops without credentials
- New order → FCM push to every owner device + SMS to every owner with a phone number (`OrderAlertJob`).
- Status change → FCM push to the shopper's devices.
- OTP → `SmsJob`. `Sms` module is Twilio-shaped today; see decisions below.

**API for the app** (`/api/v1`, bearer token = session token)
- `GET shop` — `{ name, delivery_options }`; name is `SHOP_NAME` (default `MyKiosk`)
- `POST session` (email+password or phone+code; JSON carries `owner`), `POST phone_verification`, `POST registration`
- `GET products?q=` (with `image_url`, `mrp`, `discount_percentage`), `GET/POST orders`, `GET orders/:id`, `POST/DELETE device_tokens`
- Owner only: `GET owner/orders`, `PATCH owner/orders/:id` (status), `POST owner/products`, `PATCH owner/products/:id`

**Flutter app** — sign in (OTP or email), catalog with product sheet, basket with bill summary,
checkout (address + delivery choice), orders with a tracking timeline and Reorder; owner tabs:
Incoming (accept / send out / deliver / cancel, push banner) and Shelf (add/edit products, sold-per
presets, one-tap out of stock). FCM is wired but off until `flutterfire configure` is run.
`integration_test/screenshots_test.dart` walks both roles on an emulator and writes screenshots.

**Tests** — 16 integration/job tests plus two system tests: the full shopper→owner walk (10 screenshots in `tmp/screenshots/`) and a responsive guard that visits seven screens at 390/820/1440px and fails on any sideways scroll.

## How to run

    bin/rails db:prepare db:seed     # owner@mykiosk.test / kiosk1234, 14 products
    bin/dev                          # Rails + Tailwind watcher
    bin/rails test test:system

Credentials (`bin/rails credentials:edit`), all optional in development:

    fcm:    { project_id:, client_email:, private_key: }     # push
    twilio: { account_sid:, auth_token:, from: }             # SMS — to be replaced, see below

## Decisions and why

- **SQLite + solid_cache/queue/cable** — one box, no Redis/Postgres, fits a single shop. `Order.place!` relies on SQLite's single-writer transaction instead of row locks; add `Product.lock` if this ever moves to Postgres.
- **No courier role.** The kiosk delivers its own orders; the shopper's *when* (instant vs evening round) is what matters, so that is what checkout asks.
- **FCM HTTP v1 with a hand-signed JWT** rather than the `googleauth` gem — fifteen lines vs a dependency tree.
- **Twilio was the first SMS shape, but the decision is MSG91.** Twilio to India is ~$0.083/SMS (≈₹7); MSG91 is ₹0.16–0.25. At kiosk volumes that is ~₹18k vs ~₹600 a month. Not yet switched.
- **DLT changes the interface.** Indian transactional SMS must match a registered template, so `Sms.deliver(phone, body)` should become `Sms.deliver(phone, template:, vars:)` when MSG91 lands. Also drop `₹` from SMS bodies — it forces UCS-2 encoding and halves the per-segment length (70 vs 160 chars).
- **Personal SIM for sending: no.** Server can't drive it without a gateway phone, carriers throttle automated P2P sending, and 100/day vanishes under OTPs. OTP must go through a gateway; the owner alert doesn't need SMS at all (push already exists; a Telegram bot is a free second channel).
- **WhatsApp via MSG91: yes, later.** Same vendor. Best for customer order updates, not for OTP, not for the owner. Needs a WABA, a dedicated number, and Meta-approved templates — nothing to build until those exist.
- **Flutter app, Rails backend.** The app is the client, not the backend; `/api/v1` covers everything it needs. Flutter over Kotlin for hot reload and a future iOS build; the PWA idea was dropped once a store-listed app was wanted.
- **One build for any shop.** No shop name in the app; `SHOP_NAME` on the server fills it in. Rename the Android package (`com.princevegetables.mykiosk`) before the first Play upload — it is permanent after that.
- **Squash merges, sentence-case PR titles, no attribution trailers** — same conventions as mybilling.
- Product photos are Wikimedia Commons (CC licences, mostly BY-SA) — fine now, replace or attribute before commercial use. The owner can upload their own.

## Known gaps

1. ~~Cancelling an order doesn't restore stock.~~ Fixed in #12.
2. Seeds ship `kiosk1234` for the owner — must not reach a public server.
3. `config/deploy.yml` and `production.rb` still carry `example.com` / `192.168.0.1` / `your-user`.
4. No backups: SQLite on one box needs a nightly copy off-server or Litestream.
5. No delivery radius / pincode check, no minimum order, no delivery fee, no payments.
6. No grouped "evening round" list for the owner to pack from — the data is collected, never shown together.
7. The `gh` token on the dev machine lacks the `workflow` scope; PRs touching `.github/workflows` have to be pushed over SSH (`gh auth refresh -s workflow` fixes it).

## Launch sequence

1. Start MSG91 signup + DLT entity/header/template registration **now** — it takes days and nothing works for real customers without it.
2. Switch `Sms` to MSG91 in the template shape; `Rs.` not `₹`.
3. Fix stock-restore-on-cancel; remove the seeded password.
4. Server + domain, fill in `deploy.yml` (set `SHOP_NAME`), add mybilling's gated deploy job.
5. Backups.
6. Firebase project → `flutterfire configure` in the app, service account under `fcm:` here; Telegram owner alert if wanted.
