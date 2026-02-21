# Fleet Flow — Backend & Frontend Setup

This repository contains a Node.js backend (with Prisma & PostgreSQL) and a Flutter frontend located under `frontend/fleet_flow`.

**Prerequisites**
- **Docker & Docker Compose**: recommended for running the backend database and services.
- **Node.js** (v18+ recommended) and **npm** (for local backend development).
- **Flutter SDK** (for frontend). Install from https://flutter.dev. For web or desktop targets follow Flutter docs for platform setup.

**Backend (Node.js + Prisma)**

Location: `backend`

1) Quick (recommended) — Docker Compose

	- From the repository root run:

```bash
cd backend
docker compose up --build
```

	This brings up the backend service and the database (if defined in `docker-compose.yaml`). The API will default to `http://localhost:3000` unless `PORT` is set.

2) Local Node (development)

	- Install dependencies and run the server locally:

```bash
cd backend
npm install
npm run dev
```

	- Prisma migrations & seeding

```bash
# apply migrations and start a local dev database migration flow
npm run migration:apply
# run the project's seed script
npm run seed
```

3) Environment variables

	Create a `.env` file in `backend` with at least the following keys:

```
DATABASE_URL=postgresql://USER:PASSWORD@HOST:PORT/DATABASE
JWT_SECRET=your_jwt_secret_here
PORT=3000
NODE_ENV=development
```

	- `DATABASE_URL` is used by Prisma (see `backend/src/config/db.config.js`).
	- `JWT_SECRET` is used for auth tokens (see `backend/src/config/auth.js`).

4) Useful backend scripts (see `backend/package.json`)

- `npm run dev` — start the server with `nodemon` (development)
- `npm run migration:apply` — run Prisma migrate dev
- `npm run seed` — run the JavaScript seed script (`prisma/seed.js`)

**Frontend (Flutter)**

Location: `frontend/fleet_flow`

1) Install packages

```bash
cd frontend/fleet_flow
flutter pub get
```

2) Run the app

- For web (Chrome):

```bash
flutter run -d chrome
```

- For Windows desktop:

```bash
flutter run -d windows
```

3) Configuration

- The frontend uses HTTP requests to the backend API. Update the API base URL in the frontend where applicable (search for the API client or `http` calls under `frontend/fleet_flow/lib`).

**Health check**

- After the backend is running visit `http://localhost:3000/health` to verify the server is up.

**Notes & Troubleshooting**
- If you run into Prisma errors, ensure `DATABASE_URL` is reachable and the database user has the needed privileges.
- On Windows, ensure Docker Desktop is running if using Docker Compose. For Flutter Windows builds, make sure Visual Studio + required workloads are installed.
- The backend logs print the running port and environment in the console (see `backend/src/server.js`).

If you want, I can:
- add a `.env.example` in `backend` with placeholders
- add a small README in `backend` and `frontend/fleet_flow` with target-specific details

