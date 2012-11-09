class NotificationsMailer < ActionMailer::Base

  default from: "noreply@bulsat.com"
  default :to => "veselin.yanev@gmail.com"
  
  def new_message(message)
      @message = message
      mail(:subject => "[AuleleGallery.tld] #{message.subject}")
  end  
  
end
