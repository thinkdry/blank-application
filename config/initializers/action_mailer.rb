ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.think-alternative.net',
		:domain => 'think-alternative.net',
    :port => '25',
		:user_name => 'test@think-alternative.net',
		:password => 'test',
		:authentication => :login
}

#ActionMailer::Base.smtp_settings = {
#    :address => 'smtp2.phpnet.org',
#		:domain => 'phpnet.org',
#    :port => '25',
##		:pop3_auth => {
##			:server => 'pop.phpnet.org',
##			:user_name => 'blank@thinkdry.com',
##			:password => 'blank',
##			:expires => 1.hour # expiration time for the credentials
##		}
#		:user_name => 'blank@thinkdry.com',
#		:password => 'blank',
#		:authentication => :login
#}

ActionMailer::Base.perform_deliveries = true

ActionMailer::Base.default_charset = "utf-8" 

ActionMailer::Base.raise_delivery_errors = true