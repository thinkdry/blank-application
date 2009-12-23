#ActionView::Base.send                     :include, ActsAsItem::Helpers
#ActionView::Base::CompiledTemplates.send  :include, ActsAsItem::FormBuilders

require File.dirname(__FILE__) + "/lib/model.rb"
require File.dirname(__FILE__) + "/lib/items_container.rb"
require File.dirname(__FILE__) + "/lib/controller.rb"
require File.dirname(__FILE__) + "/lib/url_helpers.rb"

# Inclusion of the librairies
ActionController::Base.send               :include, ActsAsContainer::ControllerMethods
ActiveRecord::Base.send                   :include, ActsAsContainer::ModelMethods
ActiveRecord::Base.send                   :include, ItemsContainer::ModelMethods
#ApplicationHelper.send                    :include, ActsAsItem::UrlHelpers
ActionController::Base.send								:include, ActsAsContainer::UrlHelpers
#
## Inclusion of the helpers from /app
##ActionController::Base.send :helper, ContentHelper
##ActionController::Base.send :helper, GenericForItemHelper
##ActionController::Base.send :helper, GenericForItemsHelper
ActionView::Base.send :include, ContainersHelper
