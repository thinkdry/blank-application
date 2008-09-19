ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.artic-institut.org',
		:domain => 'artic-institut.org',
    :port => '25',
		:user_name => 'contact@artic-institut.org',
		:password => 'passpass',
		:authentication => :login
}

ActionMailer::Base.perform_deliveries = true

ActionMailer::Base.default_charset = "utf-8" 

ActionMailer::Base.raise_delivery_errors = true