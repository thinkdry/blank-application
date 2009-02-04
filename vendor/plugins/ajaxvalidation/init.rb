ActionView::Base.send                     :include, AjaxValidation::Helpers
ActionView::Base::CompiledTemplates.send  :include, AjaxValidation::FormBuilders
ActionController::Base.send               :include, AjaxValidation::ControllerMethods
ActiveRecord::Base.send                   :include, AjaxValidation::ModelMethods
