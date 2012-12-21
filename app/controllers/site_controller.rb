class SiteController < ApplicationController
  layout :installation_layout
  def installation_layout
    $installation.code_name
  end

#    ssl_required  :quote, :purchase

  before_filter :internal_page, :except => [:index, :plans, :quote, :purchase]

  def http_options
    render :nothing => true, :status => 200
  end

  def _check
    render :text => Customer.count
  end
  
  def index
    @without_padding = 'withoutPadding'
  end
  
  
  def thanks
    customer = Customer.create(params[:customer])
    customer.notes.create({
      :note_text => params[:extra].collect { |label, value| "#{label.humanize.titleize}: #{value}" }.join(', ')
    })
    customer.properties.create(params[:property])
    Account.create({
      :parent_id => customer.id,
      :parent_type => 'Customer',
      :email => customer.email,
      :password => Account.generate_random_password,
      :role => 'customer'
    })
    @page_title = "Thank you!"
  end
  
  def termsconditions
    @page_title = "Terms and Conditions"
  end

  def resourcecenter
    redirect_to '/versus'
  end
  
  def versus
    @page_title = "Home Warranty vs. Homeowners Insurance"
  end
  
  def homeownercenter
    @page_title = "Homeowner Center"
    @content_class = "homeowners-page"
  end
  
  def plans
    @page_title = "Coverage Plans"
    @optional_coverages = Coverage.where(:optional => true).collect(&:coverage_name).in_groups(3)
  end
  
  def realestate
    @page_title = "Real Estate Professionals"
    @content_class = "get-quote-page" # TODO: Rename to full-width
  end
  
  def contractors
    @page_title = "Contractor Helpdesk"
    @content_class = "get-quote-page" # TODO: Rename to full-width
  end
  
  def about
    @page_title = "About Us"
  end
  
  def contact
    @page_title = "Contact Us"
  end
  
  def request_thankyou
  	@page_title = "Thank You!"
  	Postoffice.template(
  	  params[:template_name],
  	  [$installation.claims_email],
  	  params[:request]
  	).deliver
  end
  
  def quote
    @page_title = "Get A Free Quote"
    @content_class = "get-quote-page"
    @customer = Customer.new
    @property = @customer.properties.build
  end
  alias :getaquote :quote

  def billing
      @customer = Customer.find(params[:customer_id])
      @property = @customer.properties.build
      if params[:copy_billing_info]
          @copy_address = true
      end
      if request.post?
      params[:billing_address][:address_type] = 'Billing'
      billing_address = @customer.create_billing_address(params[:billing_address])
      
      gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new($installation[:authorize])
      credit_card = ActiveMerchant::Billing::CreditCard.new(
        :first_name => @customer.first_name,
        :last_name => @customer.last_name,
        :number => params[:credit_card_number],
        :month => params[:date][:month],
        :year => params[:date][:year]
      )
      start_date = 1.week.from_now
      options = {
        :billing_address => {
          :first_name => @customer.billing_first_name,
          :last_name => @customer.billing_last_name,
          :address1 => billing_address.address,
          :city => billing_address.city,
          :state => billing_address.state,
          :zip => billing_address.zip_code,
          :country => "US"
        },
        :subscription_name => $installation.name,
        :interval => { :unit => :months, :length => 12 / @customer.num_payments },
        :duration => { :start_date => start_date.strftime('%Y-%m-%d'), :occurrences => @customer.num_payments }
      }
      
      response = gateway.recurring(@customer.pay_amount.to_f * 100.0, credit_card, options)
      
      #<ActiveMerchant::Billing::Response:0x19c80b4 @test=false, @authorization="2966817", @message="Successful.", @success=true, @cvv_result={"message"=>nil, "code"=>nil}, @fraud_review=nil, @avs_result={"message"=>nil, "code"=>nil, "street_match"=>nil, "postal_match"=>nil}, @params={"code"=>"I00001", "text"=>"Successful.", "subscription_id"=>"2966817", "result_code"=>"Ok"}>
      if response.success?
        @customer.update_attributes({
          :subscription_id => response.params['subscription_id'],
          :credit_card_number => params[:credit_card_number],
          :expirationDate => "#{params[:date][:year]}-#{params[:date][:month]}"
        })
        @customer.renewals.create({
          :years => params[:contract_length].to_i,
          :amount => @customer.pay_amount.to_f,
          :starts_at => start_date,
          :ends_at => start_date + params[:contract_length].to_i.years
        })
        password = Digest::SHA1.hexdigest("#{rand(1<<64)}")[0...5]
        Account.create({
          :parent_id => @customer.id,
          :parent_type => 'Customer',
          :email => @customer.email,
          :password => password,
          :role => 'customer',
          :last_login_ip => request.remote_ip,
          :last_login_at => Time.now
        })
        flash[:result] = :success
        Postoffice.template('Welcome', @customer.email, {:customer => @customer, :password => password}).deliver if $installation.auto_delivers_emails
        Postoffice.template('New Web Order', $installation.admin_email, {:customer => @customer}).deliver
      else
        Rails.logger.info "Payment error: #{response.inspect}"
        flash[:result] = response
      end
      
      render :action => 'thankyou'
      end

  end
  
  def faq
    @page_title = "Frequently Asked Questions"
  end
  alias :faqs :faq
  
  def testimonials
    @page_title = "Testimonials"
  end
  
  def please_call
    @page_title = "Please Call Us"
  end
  
  def purchase
    @page_title = "Purchase A Plan"
    if request.get?
      params[:extra] ||= {}
      @customer = params[:customer] ? Customer.create(params[:customer]) : Customer.new
      @property = params[:property] ? @customer.properties.create(params[:property]) : @customer.properties.build
      @note = params[:extra].collect { |label, value| "#{label.humanize.titleize}: #{value}" }.join(', ') if params[:extra]
      redirect_to :action => 'please_call' if @customer.home_size_code == 1
    elsif request.post? 
      params[:coverages] ||= {}
      params[:customer][:status_id] = 0
      params[:customer][:ip] = request.remote_ip
      params[:customer][:coverage_addon] = (params[:coverages].collect { |k,v| k }).join(', ')
      params[:customer][:coverage_ends_at] = 1.year.from_now
      
      @customer = nil
      # The user came from the mini-form and has a Customer object already
      @customer = Customer.find(params[:id]) if params[:id].to_i > 0
      # The user did not come from a mini-form and does not have a Customer object
      @customer = Customer.create(params[:customer]) unless @customer
      @customer.update_attributes(params[:customer])
      @customer.notes.create({ :notes_text => @note }) if @note
      
      if params[:property_id].to_i == 0 then @customer.properties.create(params[:property]) end
      params[:customer_id] = @customer.id if @customer
      params[:property] = @property if @property
      params[:note] = @note if @note
      redirect_to billing_path(params) 
      # @customer.pay_amount is set by JS on the form, so it includes the discount
      end
  end

  protected

  def internal_page
    @content_class = "internal-page"
  end
end
