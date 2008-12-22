ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.think-alternative.net',
		:domain => 'think-alternative.net',
    :port => '25',
#		:pop3_auth => {
#			:server => 'pop.think-alternative.net',
#			:user_name => 'test@think-alternative.net',
#			:password => 'test',
#			:expires => 1.hour # expiration time for the credentials
#		}
		:user_name => 'test@think-alternative.com',
		:password => 'test',
		:authentication => :login
}

#ActionMailer::Base.smtp_settings = {
#    :address => 'smtp.phpnet.org',
#		#:domain => 'phpnet.org',
#    :port => '25',
#		:user_name => 'blank@thinkdry.com',
#		:password => 'blank',
#		:authentication => :plain
#}

ActionMailer::Base.perform_deliveries = true

ActionMailer::Base.default_charset = "utf-8" 

ActionMailer::Base.raise_delivery_errors = true