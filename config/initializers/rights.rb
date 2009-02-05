require "#{RAILS_ROOT}/lib/rights.rb"

include Blank::Rights

create_default_roles_if_empty
create_default_permissions_if_empty