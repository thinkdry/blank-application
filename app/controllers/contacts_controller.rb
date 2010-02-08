class ContactsController < ApplicationController
  
  def new  
    
  end

  def create
    website = Website.find(params[:website_id])
    workspace = website.creator.private_workspace
    user_id = website.creator.id
    if yacaph_validated?
			if !(@person = Person.find(:first, :conditions => {:email => params[:person][:email], :user_id => user_id}))
				@person = Person.new(params[:person].merge!({'user_id' => user_id}))
				@person.save
			else
				params[:person].delete('primary_phone') if params[:person][:primary_phone].blank?
				@person.update_attributes(params[:person])
			end
			if @contact_workspace = ContactsWorkspace.find(:first, :conditions => {:workspace_id => workspace.id, :contactable_id => @person.id, :contactable_type => 'Person'})
				@contact_workspace.update_attributes(:state =>'subscribed') if params[:state]
			elsif @person.id
				ContactsWorkspace.create(:contactable_id => @person.id, :contactable_type => "Person", :workspace_id => workspace.id, :state => params[:state] ? 'subscribed' : 'not_subscribed')
			end
			if @person.id && DataPerson.new(:person_id => @person.id, :workspace_id => workspace.id, :origin => params[:person][:origin], :type_data => '', :data => params[:email]).save
				UserMailer.deliver_contact_notification(website, params[:person].merge!(params[:email])) rescue p "email not delivered"
				flash[:notice] = "Votre demande a bien été envoyée."
			else
				flash[:error] = "Votre demande a pu être enregistrée mais pas envoyée."
				session[:person] = @person
				session[:email] = params[:email]
			end
		else
			session[:person] = Person.new(params[:person])
			session[:email] = params[:email]
			flash[:error] = "Le code de vérification est érroné."
		end
#    redirect_to '/'+Page.find(website.home_page_id).title_sanitized
    redirect_to '/'+params[:prev_title_sanitized]
      
  end
  
  
end
