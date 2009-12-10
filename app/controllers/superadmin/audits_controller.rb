class Superadmin::AuditsController < Admin::ApplicationController

def index
      @audits = Audit.find(:all)
end

end
