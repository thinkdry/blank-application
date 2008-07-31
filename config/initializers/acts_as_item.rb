require 'acts_as_item'
ActiveRecord::Base.send(:include, ActsAsItem::ModelMethods)