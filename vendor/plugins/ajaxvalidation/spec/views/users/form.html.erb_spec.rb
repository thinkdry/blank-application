require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class User < ActiveRecord::Base
end

describe "A form for new user" do
  
  def mock_new_user
    mock_model( User,
                :errors => stub("errors", { :count => 0, :on => nil }),
                :lastname => '',
                :firstname => ''
              ).as_new_record()
  end
  
  def inline_content
    @inline_content ||= %{
      <% form_for @user, :url => '#', :builder => LabelFormBuilder do |f| %>
        <%= f.text_field :lastname %>
        <%= f.text_field :firstname  %>
        <%= f.submit %>
      <% end %>
    }
  end
  
  def page
    { :inline => inline_content } 
  end
  
  before(:each) do
    assigns[:user] = @user = mock_new_user
  end
  
  it "should render" do
    render page
  end
  
  it "should add labels" do
    render page
    response.should have_tag('label', 2)
  end
  
  it "should support :label => false option" do
    render :inline => %{
      <% form_for @user, :url => '#', :builder => LabelFormBuilder do |f| %>
        <%= f.text_field :lastname %>
        <%= f.text_field :firstname, :label => false  %>
        <%= f.submit %>
      <% end %>
    }
    response.should have_tag('label', 1)
  end
  
  it "should add onblur events on text fields" do
    render page
    response.should have_tag("input[type=?][onblur=?]", 'text', /ajax_validation\('User',.+/, 2)
  end
    
end


