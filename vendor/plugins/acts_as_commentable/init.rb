ActionView::Base.send                     :include, ActsAsCommentable::Helpers
ActionController::Base.send               :include, ActsAsCommentable::ControllerMethods
ActiveRecord::Base.send                   :include, ActsAsCommentable::ModelMethods