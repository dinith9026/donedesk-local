web: bin/rails server -p $PORT -e $RAILS_ENV
worker: bundle exec sidekiq -c 2 -e $RAILS_ENV -q default -q mailers
clock: RAILS_ENV=$RAILS_ENV bundle exec clockwork clock.rb
