class StylesheetsController < ApplicationController
  
  
  def application
    @header=Element.find_by_name("header")
    respond_to do |format|
      format.css do
        render
      end
    end
  end
  
  def form
    respond_to do |format|
      format.css do
        render
      end
    end
  end
  
  def middle
    respond_to do |format|
      format.css do
        render
      end
    end
  end
  
  def starbox
    respond_to do |format|
      format.css do
        render
      end
    end
  end
  
  def login
    respond_to do |format|
      format.css do
        render
      end
    end
  end
end
