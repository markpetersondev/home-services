# FixNoww: Backend Guide

A step-by-step plan for building the FixNoww backend with Node.js and MySQL. The main goal is **learning backend development**, so the plan favours understanding over speed.

**The backend lives in its own workspace, separate from this Flutter repo.** Copy this guide across when you create it. Links to `lib/` and other docs only work from this repo.

This guide replaces the Supabase recommendation in the [project assessment](PROJECT_ASSESSMENT.md), which assumed the goal was the fastest route to launch. Product requirements come from the [MVP PRD](PRD.md).

## Stack

### Use from the start

| Purpose | Choice | Added in |
| --- | --- | --- |
| Runtime | Node.js LTS | Stage 1 |
| Language | TypeScript, run with `tsx` | Stage 1 |
| API framework | Express 5 | Stage 1 |
| Database | MySQL 8.4 LTS, in Docker Compose | Stage 2 |
| Database access | `mysql2` with plain SQL | Stage 2 |
| Migrations | `dbmate` | Stage 2 |
| Validation | Zod | Stage 3 |
| API testing by hand | Postman or Bruno | Stage 3 |
| Login | `jsonwebtoken` and `argon2` | Stage 4 |
| Flutter HTTP client | `dio` | Stage 5 |
| Automated tests | Vitest and Supertest | Stage 6 |

### Add later

| Purpose | Choice | Added in |
| --- | --- | --- |
| Logs | `pino` | Stage 7 |
| Hosting | Railway to start (check current pricing) | Stage 7 |
| File storage | Cloudflare R2 or AWS S3, kept private | Stage 8 |
| Push notifications | Firebase Cloud Messaging | Stage 8 |
| Real SMS | A local Sri Lankan supplier or Twilio (compare prices) | Stage 8 |
| Admin panel | A separate project, in React or Flutter Web; the mobile app stays Android and iOS only | Stage 8 |

### Leave out for now

- **NestJS and Prisma:** good tools, but they hide what you are trying to learn. Revisit them once you have done the work by hand.
- **Redis, microservices, Kubernetes and GraphQL:** this app doesn't need them yet.

## Your setup

| Tool | Status on this Mac | What to do |
| --- | --- | --- |
| Node.js | v22.18.0 installed | Nothing yet; update if it is no longer an LTS version |
| Docker | Not installed | Stage 2: `brew install --cask docker-desktop`, then open it once |
| `dbmate` | Not checked | Stage 2: `brew install dbmate` |

## Project layout

Inside your backend workspace:

```text
fixnoww-backend/
├── src/
│   ├── index.ts     # Starts the server
│   ├── routes/      # URLs and request handling
│   ├── services/    # Business rules
│   ├── db/          # SQL queries
│   └── middleware/  # Login and error checks
├── db/migrations/   # Table changes, as SQL files
├── tests/
├── docker-compose.yml
├── .env             # Local secrets; never commit this
└── package.json
```

A request moves through the layers in one direction:

```text
Flutter app → route → service → db query → MySQL
```

Routes handle HTTP, services hold rules such as "only pending jobs can be claimed", and `db` files hold SQL. Keeping them separate lets you change or test one without touching the others.

## Learning path

Finish each stage's "Done when" test before moving on.

### Stage 1: First API

**You learn:** Node, TypeScript, Express, HTTP methods, status codes and JSON.

From your new, empty backend workspace, run:

```bash
mkdir -p src
npm init -y
npm pkg set type=module
npm pkg set scripts.dev="tsx watch src/index.ts" scripts.typecheck="tsc --noEmit"
npm install express
npm install -D typescript tsx @types/node@22 @types/express
npx tsc --init
printf 'node_modules/\n.env\ndist/\n' > .gitignore
```

Create `src/index.ts`:

```ts
import express from "express";

const app = express();
const port = 3000;

app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.listen(port, () => {
  console.log(`API running at http://localhost:${port}`);
});
```

Start it with `npm run dev`. In another terminal, run:

```bash
curl localhost:3000/health
```

You should get `{"status":"ok"}`.

If TypeScript later can't find `process`, set `"types": ["node"]` in `tsconfig.json`.

**Your task:** add `GET /api/v1/categories`, returning the seven categories from [`dummy_data.dart`](../lib/data/dummy_data.dart).

**Done when:** `curl` returns the category list and `npm run typecheck` shows no errors.

### Stage 2: Database

**You learn:** tables, primary and foreign keys, joins, indexes and migrations.

Create `docker-compose.yml`:

```yaml
services:
  db:
    image: mysql:8.4
    environment:
      MYSQL_ROOT_PASSWORD: dev_root_password
      MYSQL_DATABASE: fixnoww
    ports:
      - "127.0.0.1:3306:3306"
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

These passwords are for your laptop only.

Start the database with `docker compose up -d`.

**Your tasks:**

1. Create migrations for `users`, `service_categories` and `bookings`.
2. Load the sample users and bookings from the Flutter app's [`lib/repositories/`](../lib/repositories/).
3. Write a query that joins each booking to its customer's name.
4. Change `/api/v1/categories` to read from MySQL.

**Done when:** you can delete the database, run the migrations, reload the sample data, and get the same API results.

### Stage 3: Bookings API

**You learn:** REST design, request validation, status codes and error handling.

**Your tasks:** build create, list, view and cancel for bookings. Validate input with Zod. Temporarily pass the user's ID in a header, until Stage 4 replaces it.

**Done when:** you have Postman or Bruno requests for each endpoint, and bad input returns a clear `400` error without crashing the server.

### Stage 4: Login

**You learn:** OTP flows, hashing, tokens, middleware, and the difference between authentication and authorisation.

**Your tasks:** build OTP request and verify, printing the code to the console instead of sending SMS. Issue a token, add login middleware, and check both role and ownership on every protected route.

**Done when:** one customer gets `403` when opening another customer's booking, a provider gets `403` on customer-only routes, and a request with no token gets `401`.

### Stage 5: Connect Flutter

**You learn:** how a client and server work together: loading states, errors and token storage.

The Flutter app already has a repository layer, so this stage needs no screen rewrites.

**Your tasks:** in the Flutter repo, add `dio` and write `ApiUserRepository` and `ApiBookingRepository`, implementing the interfaces in [`lib/repositories/`](../lib/repositories/). Return them from `userRepositoryProvider` and `bookingRepositoryProvider`, add a place to store the login token, and add loading and network error messages. Run the API on your laptop and connect from the phone over your local network.

**Done when:** a customer on one device books a job, and a provider on another device sees it. **This is the big milestone.**

### Stage 6: Booking rules

**You learn:** transactions, race conditions, state machines and automated testing.

**Your tasks:** implement offers, approval, start, complete and the other PRD booking states. Reject invalid moves, such as completing a pending job. Add earnings, provider areas, the online filter, and reviews.

**Done when:** an automated test sends two claims for the same job at once and exactly one succeeds. See [Claiming a job safely](#claiming-a-job-safely).

### Stage 7: Go online

**You learn:** deployment, environment variables, logs, backups and HTTPS.

**Your tasks:** deploy the API and database, add logging, and point a Flutter test build at the live API.

**Done when:** the full job flow works over mobile data, and you have successfully restored a backup to a separate database.

### Stage 8: Extras

**You learn:** third-party services, private file storage and admin permissions.

Add one at a time: push notifications, real SMS, photo and NIC uploads, then the admin panel from section 7 of the PRD.

**Done when:** each feature works from start to finish, and its secret keys exist only on the server.

## Database design

This is a starting point. Try designing the tables yourself first, then compare.

| Table | Purpose | Key columns | Stage |
| --- | --- | --- | --- |
| `users` | Customers, providers and admins | `id`, `name`, `phone` (unique), `role`, `status` | 2 |
| `service_categories` | Plumbing, Electrical and so on | `id`, `name`, `icon`, `is_active` | 2 |
| `bookings` | Each customer request | `id`, `customer_id`, `provider_id`, `category_id`, `area_id`, `address`, `description`, `scheduled_at`, `status`, `agreed_price` | 2 |
| `otp_codes` | Login codes | `phone`, `code_hash`, `expires_at`, `attempts` | 4 |
| `provider_profiles` | Provider details | `user_id`, `category_id`, `is_online`, `approval_status` | 5 |
| `service_areas` | Fixed list of areas | `id`, `name` | 6 |
| `provider_areas` | Which provider covers which area | `provider_id`, `area_id` | 6 |
| `offers` | Prices sent by providers | `id`, `booking_id`, `provider_id`, `price`, `status`, `expires_at` | 6 |
| `reviews` | Ratings after a job | `booking_id` (unique), `rating`, `comment` | 6 |
| `booking_declines` | Which providers declined which request | `booking_id`, `provider_id` | 6 |
| `booking_events` | Audit trail of status changes | `booking_id`, `actor_id`, `from_status`, `to_status`, `created_at` | 6 |
| `device_tokens` | Phones for push notifications | `user_id`, `token` | 8 |
| `disputes` | Reported problems | `booking_id`, `opened_by`, `reason`, `status`, `resolution` | 8 |

Rules worth following from the start:

- **Money:** use `DECIMAL(10,2)`, never `FLOAT` or `DOUBLE`, which introduce rounding errors.
- **Dates:** store them in UTC and convert to Sri Lankan time in the app.
- **Booking statuses:** use the PRD's states. Keep cancelled bookings; don't delete them.
- **Ratings and earnings:** calculate them from reviews and completed jobs. Don't let clients send them.
- **Foreign keys and indexes:** add foreign keys for relationships, and indexes on columns you often search, such as `bookings.status`.

## API design

All endpoints start with `/api/v1`.

| Method and path | Who | Purpose | Stage |
| --- | --- | --- | --- |
| `GET /health` (no prefix) | Anyone | Check the server is up | 1 |
| `GET /categories` | Anyone | List services | 1 |
| `POST /bookings` | Customer | Create a request | 3 |
| `GET /bookings` | Customer, provider | List your own bookings | 3 |
| `GET /bookings/:id` | Owner | View a booking | 3 |
| `POST /bookings/:id/cancel` | Owner | Cancel a booking | 3 |
| `POST /auth/request-otp` | Anyone | Send a login code | 4 |
| `POST /auth/verify-otp` | Anyone | Exchange a code for a token | 4 |
| `GET /me` | Logged in | Get your profile | 4 |
| `GET /jobs/incoming` | Provider | List matching open requests | 6 |
| `POST /bookings/:id/offers` | Provider | Send a price | 6 |
| `POST /bookings/:id/decline` | Provider | Hide a request from yourself | 6 |
| `POST /offers/:id/approve` | Customer | Approve an offer | 6 |
| `POST /offers/:id/reject` | Customer | Reject an offer | 6 |
| `POST /bookings/:id/start` | Assigned provider | Start the job | 6 |
| `POST /bookings/:id/complete` | Assigned provider | Complete the job | 6 |
| `POST /bookings/:id/reviews` | Customer | Review a completed job | 6 |
| `PATCH /me/availability` | Provider | Go online or offline | 6 |

### What the Flutter app already expects

Each repository method in the app needs an endpoint. The app expects a false result, or `409` from the API, when a booking isn't in the right state:

| Flutter method | Endpoint |
| --- | --- |
| `UserRepository.login` | `POST /auth/request-otp`, `POST /auth/verify-otp` |
| `UserRepository.fetchUsers` | Replace with `GET /me` and user details inside booking responses; clients shouldn't download every user |
| `UserRepository.toggleOnline` | `PATCH /me/availability` |
| `UserRepository.addEarnings` | None; the server adds earnings when a job completes. Remove this method and refresh the user instead |
| `BookingRepository.fetchBookings` | `GET /bookings`, `GET /jobs/incoming` |
| `BookingRepository.createBooking` | `POST /bookings` |
| `BookingRepository.acceptBooking` | `POST /bookings/:id/offers` |
| `BookingRepository.declineBooking` | `POST /bookings/:id/decline` |
| `BookingRepository.startJob` | `POST /bookings/:id/start` |
| `BookingRepository.completeJob` | `POST /bookings/:id/complete` |
| `BookingRepository.cancelBooking` | `POST /bookings/:id/cancel` |

The app's `declinedBy` list on bookings is a mock shortcut. Keep declines in their own table, and return only what each user may see.

Use the same error format everywhere, so Flutter can handle errors in one place:

```json
{ "error": { "code": "BOOKING_NOT_PENDING", "message": "This job has already been taken." } }
```

| Status | Meaning |
| --- | --- |
| `200` / `201` | Success / created |
| `400` | The request data is invalid |
| `401` | Not logged in |
| `403` | Logged in, but not allowed |
| `404` | Not found |
| `409` | Conflict with the current state, such as a job that was already taken |
| `429` | Too many requests |
| `500` | A bug or failure on the server |

## Claiming a job safely

Two providers can tap **Accept** at almost the same moment. If your code checks the status and then updates it in two separate steps, both can succeed. Put the check and the change into one statement instead:

```sql
UPDATE bookings
SET status = 'offered', provider_id = ?
WHERE id = ? AND status = 'pending' AND provider_id IS NULL;
```

Then check `affectedRows` in the result:

- `1` means this provider got the job. Create the offer in the same transaction.
- `0` means someone else got there first. Return `409`.

## Security rules

Learn these early, because they're much harder to add later.

**Always:**

- Use `?` placeholders in SQL; never build SQL by joining user input into a string. This prevents SQL injection.
- Validate every request body, and check both role and ownership on every protected route.
- Hash OTP codes, make them expire within a few minutes, and limit attempts per phone number.
- Keep secrets in `.env` or your host's settings, and never commit them.
- Return generic messages for `500` errors, and keep the details in your server logs.

**Before going live:**

- Use HTTPS only, and restrict database access so it isn't open to the internet.
- Add rate limiting across the API.
- Test your backups by restoring one.
- Use only fake data until the security has been reviewed. Do not collect real NIC images or customer details before then.
- Check your obligations under Sri Lanka's Personal Data Protection Act, which the [assessment](PROJECT_ASSESSMENT.md#4-other-things-to-plan-for) covers.

## How we'll work

1. Pick the next task from the current stage.
2. Ask for an explanation of anything new.
3. Write the code yourself, even if it feels slow.
4. Ask for a review, and for help when you've been stuck for a while.
5. Run the "Done when" test, commit, and move on.
