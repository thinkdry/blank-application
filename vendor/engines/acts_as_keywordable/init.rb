ActionController::Base.send               :include, ActsAsKeywordable::ControllerMethods
ActiveRecord::Base.send                   :include, ActsAsKeywordable::ModelMethods

ActionView::Base.send :include, KeywordsHelper