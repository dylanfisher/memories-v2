# README

Connect to server via dokku

`ssh dokku@photos.dylanfisher.com`

Database export

`ssh dokku@photos.dylanfisher.com dokku postgres:export memories_database | gzip -1 > latest.dump.gz`
