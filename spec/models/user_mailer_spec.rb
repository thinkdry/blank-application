require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserMailer do
  fixtures(:users)
  include ActionMailer::Quoting
  include Configuration
  
  def object
    UserMailer.new
  end
  
  def setup
    @mail = TMail::Mail.new
    @mail.mime_version = '1.0'
    @mail.set_content_type 'text', 'plain'
    @mail.date = Time.now
    @mail.charset = 'utf-8'
  end
  
  it "should create signup notification for user" do
    @mail.from    = 'contact@thinkdry.com'
    @mail.to      = users(:luc).email
    @mail.subject = "ThinkDRY BLANK Application : Ouverture de compte"
    @mail.body    = read_fixture('signup_notification')
    UserMailer.create_signup_notification(users(:luc)).encoded.should == @mail.encoded
  end
  
  # Still to implement, don't know read_fixture giving problems
  it "should send reset notification for user" do
    @mail.from = 'contact@thinkdry.com'
    @mail.to = users(:luc).email
    @mail.subject = "ThinkDRY BLANK Application : Oubli de mot de passe"
    @mail.body = read_fixture('reset_notification')
    #UserMailer.create_reset_notification(users(:luc)).encoded.should == @mail.encoded
  end
  
  # Still to implement, don't know read_fixture giving problems
  it "should create newsletter for user" do
    @mail.from  = 'contact@thinkdry.com'
    @mail.to = 'admin@blankapp.com'
    @mail.subject = 'Test newsletter in rspec'
    @mail.body = read_fixture('send_newsletter')
   # UserMailer.create_send_newsletter('admin@blankapp.com', '11111111111111', 'contact@thinkdry.com', 'Test Newsletter', 'Test Newsletter in rspec', 'Body of the the newsletter contact http://www.thinkdry.com').encoded.should == @mail.encoded
  end
  
end
