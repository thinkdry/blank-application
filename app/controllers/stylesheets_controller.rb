class StylesheetsController < ApplicationController
   
  def application
    @header=Element.find(:first,:conditions=>{:template=>"current",:name=>"header"})
    @body=Element.find(:first,:conditions=>{:template=>"current",:name=>"body"})
    @footer=Element.find(:first,:conditions=>{:template=>"current",:name=>"footer"})
    @top=Element.find(:first,:conditions=>{:template=>"current",:name=>"top"})
    @search=Element.find(:first,:conditions=>{:template=>"current",:name=>"search"})
    @ws=Element.find(:first,:conditions=>{:template=>"current",:name=>"ws"})
    @border=Element.find(:first,:conditions=>{:template=>"current",:name=>"border"})
    @accordion=Element.find(:first,:conditions=>{:template=>"current",:name=>"accordion"})
    @links=Element.find(:first,:conditions=>{:template=>"current",:name=>"links"})
    @clicked=Element.find(:first,:conditions=>{:template=>"current",:name=>"clicked"})
    respond_to do |format|
      format.css do
        render
      end
    end
  end
  
  def middle
    @header=Element.find(:first,:conditions=>{:template=>"current",:name=>"header"})
    @search=Element.find(:first,:conditions=>{:template=>"current",:name=>"search"})
    @accordion=Element.find(:first,:conditions=>{:template=>"current",:name=>"accordion"})
     @ws=Element.find(:first,:conditions=>{:template=>"current",:name=>"ws"})
    @border=Element.find(:first,:conditions=>{:template=>"current",:name=>"border"})
    @links=Element.find(:first,:conditions=>{:template=>"current",:name=>"links"})
    respond_to do |format|
      format.css do
        render
      end
    end
  end
  
end 
  
 
