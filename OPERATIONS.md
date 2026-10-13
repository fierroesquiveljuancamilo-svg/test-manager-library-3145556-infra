# Local infrastructure

Keep the API and React application checkouts next to this repository, or set
`API_PATH` and `FRONTEND_PATH` in `.env`. Docker Compose with BuildKit and
additional build contexts is required. The API image uses PHP 8.3 and PostgreSQL
support; the frontend expects a React/Vite `package.json` with a `dev` script.

1. Copy `.env.example` to `.env` and fill the blank values. Set `DATABASE_URL` to
   `postgresql://USER:PASSWORD@db:5432/DATABASE`, matching the PostgreSQL variables
   and URL-encoding credentials. Generate `APP_KEY` with
   `php -r 'echo "base64:".base64_encode(random_bytes(32)).PHP_EOL;'` and
   `JWT_SECRET` with `php -r 'echo bin2hex(random_bytes(32)).PHP_EOL;'`.
2. Validate with `docker compose config --quiet`.
3. Start with `docker compose up --build`. API: `http://localhost:8000/health`;
   frontend: `http://localhost:5173`.

PostgreSQL creates only the database and its user on a fresh `postgres_data`
volume. There are no initialization scripts, schema creation, migrations or
seeds in container startup. Laravel's session and cache use files, and its queue
runs synchronously, so those facilities do not require database tables.

Before running application migrations, verify the empty application schema:

```sh
docker compose exec db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname NOT IN ('\''pg_catalog'\'', '\''information_schema'\'');"'
```

Expected result: zero rows. Then explicitly run the API-owned migrations:

```sh
docker compose exec api php artisan migrate --force
```

Category seeds and initial administrator creation belong to the API. This
repository passes the documented administrator credentials without inserting
application data. The API must implement JWT, CORS and cover configuration
using the supplied environment variables.

`docker compose down` retains data. Existing database volumes retain their
schema and credentials; starting the stack again does not reset them. Cover
files persist in `covers`; frontend dependencies persist in
`frontend_dependencies`. The frontend source mount is read-only.

The frontend checkout currently needs its application implementation before
the frontend service can start. Infrastructure does not scaffold application
code. Rebuild the API image after changes in the API checkout.
