#ActionView::Base.send                     :include, ActsAsItem::Helpers
#ActionView::Base::CompiledTemplates.send  :include, ActsAsItem::FormBuilders

require File.dirname(__FILE__) + "/lib/model.rb"
require File.dirname(__FILE__) + "/lib/controller.rb"
require File.dirname(__FILE__) + "/lib/url_helpers.rb"

# Inclusion of the librairies
ActionController::Base.send               :include, ActsAsItem::ControllerMethods
ActiveRecord::Base.send                   :include, ActsAsItem::ModelMethods
#ApplicationHelper.send                    :include, ActsAsItem::UrlHelpers
ActionController::Base.send								:include, ActsAsItem::UrlHelpers

# Inclusion of the helpers from /app
#ActionController::Base.send :helper, ContentHelper
#ActionController::Base.send :helper, GenericForItemHelper
#ActionController::Base.send :helper, GenericForItemsHelper
ActionView::Base.send :include, GenericForItemHelper
ActionView::Base.send :include, GenericForItemsHelper