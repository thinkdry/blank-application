class FontsController < ApplicationController
  
  def new
    
  end
  
  def create
    if !params[:fonts].blank?
        @fonts=Font.new(params[:fonts])
       if @fonts.save
          flash[:notice]="Saved Sucessfully"
          render "/superadministration/fonts"
      end
    end
  end
end
