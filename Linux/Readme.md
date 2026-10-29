# First-time initialization

These commands correspond to the Zou CLI database management workflow (init-db, upgrade-db, is-db-ready) documented for installation and configuration.

After the stack is up:

`````
docker compose up -d --build
`````

Initialize the database:

`````
docker compose exec zou zou init-db
`````

Verify:

`````
docker compose exec zou zou is-db-ready
`````

# Keycloak login

Zou can check users against a Keycloak server while Kitsu keeps its own login
form. On each login Zou sends the email and password to Keycloak, creates the
person on the first login and sets their role from their Keycloak roles.

In Keycloak, create a client for Zou with **Direct access grants** enabled
(Client authentication off for a public client, no secret needed), and create
the roles you want to map (realm roles, or roles of that client).

Zou runs in a container, so it must reach Keycloak by a name that works from
inside the Docker network, not `localhost`. `docker-compose.keycloak.yml` joins
the `zou` service to the network of the Keycloak container. Copy
`.env.example` to `.env` (ignored by git), adjust it, then rebuild and start:

`````
cp .env.example .env
docker compose build --no-cache zou
docker compose up -d
`````

`KEYCLOAK_ROLE_MAP` maps Keycloak role names to Kitsu roles as
`keycloak-role:kitsu-role` pairs separated by semicolons; the most privileged
match wins, and `KEYCLOAK_DEFAULT_ROLE` applies when none matches. Accounts
listed in `PROTECTED_ACCOUNTS` (e.g. the local admin) keep their local
password. Keycloak's own two-factor prompts cannot run with the password grant.
