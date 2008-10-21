rake db:drop && \
rake db:create && \
rake db:migrate && \
rake db:fixtures:load && \
rake xapian:rebuild_index models="ArticFile Article Audio Image Publication Video" RAILS_ENV=development && \
rake xapian:update_index RAILS_ENV=development && \
rake cron:pubmed:update_rss
