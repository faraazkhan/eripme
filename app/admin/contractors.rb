ActiveAdmin.register Contractor do
  menu :if => proc{ can?(:manage, Contractor)}
  controller.authorize_resource

  index do
    column "Company" , :company
    column "Email", :email
    column "Phone", :phone
    column "Rating", :rating
    default_actions
  end

  form :partial => 'form'

  controller do
    
    def update
      @contractor = Contractor.find(params[:id])
      if params[:contractor][:reset_password] == '1'
        @contractor.reset_password
      end
      no_email_before = @contractor.email.empty?
      @address = @contractor.address || @contractor.build_address
      if @contractor.update_attributes(params[:contractor]) && @address.update_attributes(params[:address])
        unless @contractor.account.nil? then @contractor.account.update_attributes({ :email => @contractor.email }) end
        notify(Notification::CHANGED, { :message => 'updated', :subject => @contractor })
        if (no_email_before and !@contractor.email.empty?) || params[:contractor][:grant_web_access] == '1' 
          @contractor.grant_account_and_send_welcome_email
          notify(Notification::INFO, { :message => 'granted web access', :subject => @contractor })
        end
        redirect_to :action => 'index'
      else
        render :action => 'edit', :id => params[:id]
      end
    end
  end
end
  
