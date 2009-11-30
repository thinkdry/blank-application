class StylesheetsController < ApplicationController#:nodoc: all

  before_filter :basic_styles

  # Dynamic CSS for Application Layout
  def application
    @body = Element.style_for("body").first
    @footer = Element.style_for("footer").first
    @top = Element.style_for("top").first
    @clicked = Element.style_for("clicked").first
    respond_to do |format|
      format.css do
        render
      end
    end
  end

  # Dynamic CSS for Middle Layout
  def middle
    @accordion = Element.style_for("accordion").first
    @border = Element.style_for("border").first
    @links = Element.style_for("links").first
    respond_to do |format|
      format.css do
        render
      end
    end
  end

  private

  def basic_styles
    @header = Element.style_for("header").first
    @accordion = Element.style_for("accordion").first
    @search = Element.style_for("search").first
    @ws = Element.style_for("ws").first
    @border = Element.style_for("border").first
    @links = Element.style_for("links").first
  end
  
  
end 
  
 
