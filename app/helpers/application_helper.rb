module ApplicationHelper
  def layout(website)
    if WEBSITE_TEMPLATES.include?(website.template)
      render :file => WEBSITE_TEMPLATES_FOLDER + "/" + website.template + "/layout.html.erb"
    elsif website.template == 'custom' && website.layout_file_name
      render :file => website.layout.path
    else
      render :text => "No Layout Defined"
    end 
  end
end
