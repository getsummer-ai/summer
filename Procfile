web: bundle exec rails server
worker: bundle exec good_job start

release: env DATABASE_URL="${DATABASE_PROXY_URL:-$DATABASE_URL}" bundle exec rails db:migrate:with_data
