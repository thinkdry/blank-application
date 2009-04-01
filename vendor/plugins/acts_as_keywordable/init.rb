#ActionView::Base.send                     :include, ActsAsTaggable::Helpers
ActionController::Base.send               :include, ActsAsKeywordable::ControllerMethods
ActiveRecord::Base.send                   :include, ActsAsKeywordable::ModelMethods