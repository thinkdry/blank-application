require "acts_as_item/model.rb"
ActiveRecord::Base.send(:include, ActsAsItem::ModelMethods)

require "acts_as_item/controller.rb"
ActionController::Base.send(:include, ActsAsItem::ControllerMethods)

#require "acts_as_item/helper.rb"
#ApplicationHelper.send(:include, ActsAsItem::HelperMethods)
