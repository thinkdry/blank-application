ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.think-alternative.net',
		:domain => 'think-alternative.net',
    :port => '25',
		:user_name => 'test@think-alternative.com',
		:password => 'test',
		:authentication => :login
}

ActionMailer::Base.perform_deliveries = true

ActionMailer::Base.default_charset = "utf-8" 

ActionMailer::Base.raise_delivery_errors = true