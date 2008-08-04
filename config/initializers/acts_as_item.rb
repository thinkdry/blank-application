require 'acts_as_item'

ActiveRecord::Base.send(:include, ActsAsItem::ModelMethods)
ActionController::Base.send(:include, ActsAsItem::ControllerMethods)