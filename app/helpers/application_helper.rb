module ApplicationHelper
  include TagLib
  def layout(website)
    if WEBSITE_TEMPLATES.include?(website.template)
      render :file => WEBSITE_TEMPLATES_FOLDER + "/" + website.template + "/layout.html.erb"
    elsif website.template == 'custom' && website.layout_file_name
      render :file => website.layout.path
    else
      render :text => "No Layout Defined"
    end 
  end

  def liquidize(content)
    @template = Liquid::Template.parse(content)
    @template.render(
		'current_page' => current_page,		
		'page_title' => page_title,
    'page_description' => page_description,
    'page_keywords' => page_keywords,
    'path' => path,
    'site_title' => site_title,
    'site_description' => site_description,
    'powered_by' => powered_by,
    'page_body' => page_body)
  end

  def liquidize_page_body(content)
    @template = Liquid::Template.parse(content)
    @template.render('contact_form' => (render :partial => 'websites/contact'))
  end
end
