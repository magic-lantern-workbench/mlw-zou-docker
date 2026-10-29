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

In Keycloak, create a confidential client for Zou with **Direct access grants**
enabled, and create the roles you want to map (realm roles, or roles of that
client). Then start the stack with:

`````
AUTH_STRATEGY=auth_remote_keycloak \
KEYCLOAK_SERVER_URL=http://keycloak:8080 \
KEYCLOAK_REALM=mlw \
KEYCLOAK_CLIENT_ID=zou \
KEYCLOAK_CLIENT_SECRET=<secret> \
docker compose up -d --build
`````

`KEYCLOAK_ROLE_MAP` maps Keycloak role names to Kitsu roles as
`keycloak-role:kitsu-role` pairs separated by semicolons; the most privileged
match wins, and `KEYCLOAK_DEFAULT_ROLE` applies when none matches. Accounts
listed in `PROTECTED_ACCOUNTS` (e.g. the local admin) keep their local
password. Keycloak's own two-factor prompts cannot run with the password grant.
