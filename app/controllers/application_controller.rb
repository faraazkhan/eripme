class ApplicationController < ActionController::Base
  protect_from_forgery

  #include ::SslRequirement
rescue_from CanCan::AccessDenied do |exception|
  redirect_to admin_dashboard_path, :alert => exception.message
end

  FOUR_OH_FOUR_EXCEPTIONS = [ActionController::UnknownAction, ActionController::RoutingError]
  IGNORABLE_EXCEPTIONS = [ActionController::InvalidAuthenticityToken, ActionController::RoutingError, Net::SMTPFatalError]
  
  def current_account
    session[:account_id].nil? ? Account.empty_account : Account.find(session[:account_id])
  end

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end
  
  
  def with_timezone(time)
    #logger.debug("time = #{time}")
    if time.nil? then return "" end
  	time + current_account.timezone.hours + (time.isdst ? 1.hours : 0.hour)
  end
  
  #
  # retrieve the per_page request parameter or use a default value if request parameter not found
  #
  def get_per_page(params, default = 20)
    (params[:per_page]) ? params[:per_page].to_i : default
  end
  
  def rescue_action_in_public(exception)
    if FOUR_OH_FOUR_EXCEPTIONS.include?(exception.class)
      #Postoffice.message_(
      #  [$installation.admin_email],
      #  'Page Not Found',
      #  "The following page was errantly accessed:",
      #  "http://www.nationwidehomewarranty.com/#{params[:controller] != 'site' ? params[:controller] + '/' : ''}#{params[:action]}"
      #).deliver unless IGNORABLE_EXCEPTIONS.include?(exception.class)
      render :file => "#{Rails.root}/public/404.html", :layout => $installation.code_name, :status => 404
      return
    else
      Postoffice.message_(
        ['sherrod@softilluminations.com'],
        "Error on #{$installation.short_name}: #{exception.class.to_s}",
        "<em>#{exception.to_s}</em> in #{params[:controller]}##{params[:action]}",
        exception.backtrace.join("\n").to_s.gsub('<','&lt;').gsub('>', '&gt;') << "\n\n\n" << params.inspect.to_s
      ).deliver unless IGNORABLE_EXCEPTIONS.include?(exception.class)
      render :file => "#{Rails.root}/public/500.html", :layout => $installation.code_name, :status => 500
      return
    end
  end

  def local_request?
    false
  end
  
  def notify(type, options)
    Notification.notify(type, options, current_account)
  end
  
  protected
  
  def check_login
    @current_account = current_account
    if @current_account.empty? or Time.now > (session[:timeout_after] || 1.second.ago)
      session[:account_id] = nil
      redirect_to '/admin/login'
    else
      session[:last_customers_async_list_page] ||= {}
      session[:timeout_after] = 30.minutes.from_now
    end
  end
end

