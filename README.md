# README

Connect to server via dokku

`ssh dokku@photos.dylanfisher.com`

Database export

- `ssh dokku@photos.dylanfisher.com postgres:export memories_database | gzip -1 > latest.dump.gz`
- extract the dump before restoring it below
- `bin/rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1`
- `bin/rails db:create`
- `pg_restore --verbose --clean --no-acl --no-owner -h localhost -d memories_v2_development latest.dump.gz`
- `rm latest.dump.gz`

Deploy to dokku

`git push dokku main`
