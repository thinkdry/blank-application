#ActionView::Base.send                     :include, ActsAsTaggable::Helpers
ActionController::Base.send               :include, ActsAsTaggable::ControllerMethods
ActiveRecord::Base.send                   :include, ActsAsTaggable::ModelMethods