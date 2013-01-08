# laminar

laminar explores the ‘bag of data’ approach to running a website.

## How to run

* `git clone git@github.com:stilist/laminar.git`
* `bundle install --path vendor/gems`
* create a Postgres database named `laminar`
* `export DATABASE_URL=postgres://postgres_username:postgres_password@localhost:5432/laminar`
* **Server:** `bundle exec rake server` / **Console:** `bundle exec tux`
