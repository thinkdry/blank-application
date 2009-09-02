load 'authorized.rb'
load 'authorizable.rb'

ActiveRecord::Base.send                   :include, Authorized::ModelMethods
ActionController::Base.send               :include, Authorizable::ControllerMethods
ActiveRecord::Base.send                   :include, Authorizable::ModelMethods