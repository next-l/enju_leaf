cd $WORKSPACE
bundle config build.pg --with-pg-dir=/usr/local/pgsql/
bundle install
cd $WORKSPACE
./script/enju_setup pgsql
#rake db:drop RAILS_ENV=test
#rake db:create RAILS_ENV=test
#rake db:migrate RAILS_ENV=test
rake sunspot:solr:stop RAILS_ENV=test
rake sunspot:solr:start RAILS_ENV=test
#rake db:seed RAILS_ENV=test
rake sunspot:reindex RAILS_ENV=test

# test
rake ci:setup:rspec spec:models spec:rcov
#bundle exec rspec spec/models/


