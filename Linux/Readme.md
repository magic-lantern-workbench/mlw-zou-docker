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
