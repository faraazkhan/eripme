class Admin::NotificationsController < ApplicationController
  before_filter :check_login
  
  layout 'new_admin'

  ssl_exceptions []
  
  def index
    @page_title = 'Notifications'
    @selected_tab = 'dashboard'
    @notifications = Notification.find(:all, :order => 'created_at DESC', :limit => 50)
  end
end
