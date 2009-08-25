class NewsletterJob

  def perform
    Rails.logger.info "Sending Newsletters at #{Time.now}"
    command=<<-end_command
      ruby script/runner QueuedMail.send_email
    end_command
    command.gsub!(/\s+/, " ")
    if system(command)
      Rails.logger.info "#{Time.now} : Newsletter sending success#{ $?.exitstatus == 0 ? '' : ', but exit status equal to '+exitstatus.to_s }"
    else
      Rails.logger.info "#{Time.now} : Newsletter sending failed"
    end
  end
end

