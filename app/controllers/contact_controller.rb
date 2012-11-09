class ContactController < ApplicationController
  layout "main"
  skip_before_filter :authorize
  def new
      @message = Message.new
  end
        
  def create
      @message = Message.new(params[:message])
                  
      if @message.valid?
          NotificationsMailer.new_message(@message).deliver
          redirect_to("http://www.aulele.com", :notice => "Message was successfully sent.")
      else
          flash.now.alert = "Please fill all fields."
          render :new
      end
  end
end


