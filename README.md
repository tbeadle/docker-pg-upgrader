# Docker pg-upgrader

Docker image to facilitate upgrading a
[PostgreSQL](https://www.postgresql.org) database cluster.

This repo holds the files used for building the image found at
https://hub.docker.com/r/tbeadle/pg-upgrader/.  It is useful for upgrading from
one 9.x PostgreSQL database to another 9.x release.

## Usage

The cluster must not be running when starting the upgrade.

See the provided `example.yml` for an example docker-compose YAML file.  It
assumes that the cluster's current data (`/var/lib/postgresql/data`) is found
at `/var/lib/database/old` on the docker host.  When the upgrade is complete,
the upgraded data for the cluster will be found at `/var/lib/database/new`.  The
`example.yml` file also mounts `/tmp` as a volume because `pg_upgrader` stores
files there and it may be useful to view them after the upgrade is complete.

The environment variables that may be defined in the yml file are:

 * CHECK: If set, the upgrader will only check for compatibility issues but not
   actually perform the upgrade.
 * OLD_VER: This must be defined as the current major version number (e.g. 9.4)
   of the database.

Once that is all set, then just run:

```bash
docker-compose -f example.yml up
```
