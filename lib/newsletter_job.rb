class NewsletterJob

  def perform
    command=<<-end_command
      ruby script/runner QueuedMail.send_email
    end_command
    command.gsub!(/\s+/, " ")
    if system(command)
      p "#{Time.now} : Newsletter sending success#{ $?.exitstatus == 0 ? '' : ', but exit status equal to '+exitstatus.to_s }"
    else
      p "#{Time.now} : Newsletter sending failed"
    end
  end
end

