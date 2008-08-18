# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def right_menu
    content_tag(:div,
      render(:partial => "#{session[:menu]}/menu"),
      :id => :right_menu
    ) if session[:menu]
  end
end
