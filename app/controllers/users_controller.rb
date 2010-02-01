class UsersController < ApplicationController
  
  layout 'login'

  acts_as_ajax_validation
  
  make_resourceful do
    actions :new, :create

    before :create do
      if yacaph_validated?
        @current_object.system_role_id = Role.find_by_name('user').id
      else
        @captcha_valid = false
      end
    end

    response_for :create do |format|
      format.html{ redirect_to root_url }
    end

    response_for :create_fails do |format|
      format.html{render :action => 'new'}
    end

  end  
  
end
