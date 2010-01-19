class Superadmin::AuditsController < Admin::ApplicationController

  def index
    @audits = Audit.find(:all, :order => "created_at DESC")
  end

end
