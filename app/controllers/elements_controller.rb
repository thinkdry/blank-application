class ElementsController < ApplicationController
  
  def index
     if params[:temp]
          @elements = Element.find(:all,:conditions=>{:template=>params[:temp]})
          @temp=Element.find( :all,:select => 'DISTINCT template' )
     else
          @elements = Element.find(:all,:conditions=>{:template=>"current"})
    end
  end
  
  def update
    if !params[:newtemplate].blank?
       params[:template].each do |k_elmt, v_elmt|
      @element=Element.create(:name => k_elmt.to_s, :bgcolor=>v_elmt.to_s,:template=>params[:newtemplate])
    end
      flash[:notice]="New Template Created"
      redirect_to "/"
    elsif params[:template]
      params[:template].each do |k_elmt, v_elmt|
      Element.find(:first, :conditions => {:name => k_elmt.to_s, :template => "current"}).update_attributes(:bgcolor => v_elmt.to_s)
      end
       flash[:notice]="Saved Sucessfully"
       redirect_to  "/"
    else
       flash[:notice]="Changes not Saved"
       render :action=> "/"
    end
  end  
end

