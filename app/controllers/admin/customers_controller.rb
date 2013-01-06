include ActionView::Helpers::SanitizeHelper

class Admin::CustomersController < ApplicationController
  before_filter :check_login, :except => [:esign, :contract]
  before_filter :assemble_search_string, :only => [:async_advanced_search_check, :advanced_search]
  

  customer_can :update, :claims, :edit, :claim_history, :contract, :esign
  
  def async_get_overrides
    customer = Customer.find(params[:id])
    render :json => customer.contract_overrides
  end
  
  def revert_to_new
    offset = (params[:page].to_i - 1) * params[:count].to_i
    ids = Customer.find(:all, :select => 'id', :order => 'updated_at DESC', :readonly => true,
                        :conditions => { :status_id => Customer.id_for_status(params[:id].to_sym) },
                        :offset => offset, :limit => 30).collect(&:id)
    Customer.update_all("status_id = #{Customer.id_for_status(:new)}", "id IN (#{ids.join(',')})") unless ids.empty?
    render :json => { :ids => ids }
  end

  def contract
    debugger
    id_match            = params[:id].match(/(#{$installation.invoice_prefix})?0*(\d+)/i)
    @customer           = Customer.find(id_match[2])
    @contract_number    = @customer.dashed_contract_number.delete('#')
    @payment            = "$%.2f" % @customer.pay_amount.to_f
    @purchase_date      = (@customer.transactions.empty? ? @customer.date : @customer.transactions.approved.last.created_at.in_time_zone(EST)).strftime("%B %d, %Y")
    @home_type          = @customer.formatted_home_type
    @home_size          = @customer.home_size
    @billing_address    = @customer.first_billing_address.to_s_for_contract
    @coverage_address   = @customer.first_property.to_s_for_contract
    @tos                = Safe.unicode(Content.for(:terms_of_service).gsub(/#\{(.+?)\}/i) { |match| @customer.send($1.to_sym) }).html_safe
    
    num_payments        = @customer.num_payments_override == 0 ? '' : (@customer.num_payments_override || @customer.num_payments)
    @payment_schedule   = "#{num_payments} #{@customer.payment_schedule_override}"
    
    @package_coverage_sets = (@customer.package.coverages.empty? ? ["None"] : @customer.package.coverages.collect(&:coverage_name).collect(&:upcase)).each_slice(3).to_a
    # If coverages is empty, we have to make it [[]] or else Prawn will complain
    @optional_coverage_sets = (@customer.coverages.empty? ? ["None"] : @customer.coverages.collect(&:coverage_name).collect(&:upcase)).each_slice(3).to_a
    purchaseable_coverages = Coverage.all_optional - @customer.coverages
    @purchaseable_optional_coverage_sets = (purchaseable_coverages.empty? ? ["None"] : purchaseable_coverages.collect(&:coverage_name).collect(&:upcase)).each_slice(3).to_a
    
    require 'prawn'
    doc = Prawn::Document.new(:margin => [20, 20, 40, 20]) do |pdf|
      tos_font  = "#{Rails.root}/app/views/admin/customers/Arial Narrow.ttf"
      body_font = 'Helvetica'
      body_font_size  = 10
      table_font_size = 9.5
      three_column_table_options = {
        :cell_style => {
           :border_width => 1, :size => table_font_size, :align => :center,
           :padding => [2,0,2,0]
         },
        :column_widths => { 0 => 190, 1 => 190, 2 => 190 }
      }

      draw_header_box = Proc.new {
        pdf.table([[$installation.name.upcase], ['POLICY HOLDER AGREEMENT']],
                  :cell_style => {:align => :center, :padding => [1,0,1,0]},
                  :position           => :center,
                  :column_widths      => { 0 => 570 }
                  )
        pdf.move_down 20
      }

      draw_signature_lines = Proc.new { |y|
        pdf.font body_font, :size => body_font_size, :style => :normal
        pdf.text_box "I AGREE TO THE TERMS AND CONDITIONS SET FORTH HEREIN. PLEASE SIGN ALL OF THE ATTACHED PAGES AND FAX THEM TO #{$installation.fax} OR YOU MAY SCAN AND EMAIL THEM TO #{$installation.customercare_email}", :at => [0, y+55]
        pdf.stroke_line [0,y,   200,y]
        pdf.text_box 'POLICY HOLDER (PRINT)',     :at => [5,y-10]
        pdf.stroke_line [210,y, 440,y]
        pdf.text_box 'POLICY HOLDER (SIGNATURE)', :at => [215,y-10]
        pdf.stroke_line [450,y, 573,y]
        pdf.text_box 'DATE',                      :at => [455,y-10]
      }

      pdf.font_size = body_font_size
      pdf.font body_font
      pdf.line_width = 1

      # Policy Info

      draw_header_box.call

      data = [
              ['POLICY #:',             @contract_number,                     '',                 ''],
              ['POLICY HOLDER:',        @customer.name.upcase,                '',                 ''],
              ['COVERAGE ADDRESS:',     @coverage_address,                    'BILLING ADDRESS:', @billing_address],
              ['RATE:',                 @customer.formatted_annual_rate,      'CUSTOMER EMAIL:',  @customer.email ],
              ['PAYMENT:',              @payment,                             'TYPE OF HOME:',    @home_type      ],
              ['PAYMENT SCHEDULE:',     @payment_schedule,                    'SIZE OF HOME:',    @home_size      ],
              ['PURCHASE DATE:',        @purchase_date,                       '',                 ''],
              ['NOTES:',                {:content => @customer.notes_override.to_s.strip,
                                         # :colspan => 3 # col- & rowspan is broken as of prawn 1.0.0.rc1 -Alex
                                        }]

              ]

      
      pdf.table(data,
                :cell_style => {:border_width => 0, :size => table_font_size, :padding => [3,0,3,0]},
                :column_widths => { 0 => 120, 1 => 180, 2 => 100, 3 => 170 })

      pdf.stroke_line [0,500, 573,500]
      pdf.stroke_line [0,498, 573,498]
      pdf.move_down 35

      pdf.font_size = body_font_size
      pdf.font body_font, :style => :bold
      pdf.text "PLAN SELECTED: #{@customer.package.package_name.upcase}"
      pdf.text "This #{$installation.name} coverage plan will protect the following\nhome systems and appliances:".upcase, :align => :center


      pdf.font body_font, :style => :normal
      pdf.table @package_coverage_sets, three_column_table_options

      pdf.move_down 10
      pdf.text 'OPTIONAL COVERAGE SELECTED:', :style => :bold
      pdf.table @optional_coverage_sets, three_column_table_options

      pdf.move_down 10
      pdf.text "Please call us at #{$installation.phone} to take advantage of the optional coverage below:".upcase, :align => :center, :style => :bold

      pdf.table @purchaseable_optional_coverage_sets, three_column_table_options

      pdf.stroke_line [0,220, 573,220]
      pdf.stroke_line [0,218, 573,218]
      pdf.move_down 45

      draw_signature_lines.call(130)

      pdf.move_down 130
      pdf.stroke_color '000000'

      pdf.bounding_box [0, 60], :width => 573, :height => 50 do
        pdf.text_box "TO ENROLL ANOTHER PROPERTY OR TO REQUEST SERVICES, PLEASE CALL OR VISIT US 24 HOURS A DAY, 7 DAYS", :at => [5, 36]
        pdf.text_box "A WEEK, 365 DAYS A YEAR AT:", :at => [5, 25]
        pdf.text_box $installation.phone,           :at => [90,  10], :style => :bold
        pdf.text_box $installation.domain,          :at => [330, 10], :style => :bold

        pdf.stroke_bounds
      end     

      # Terms of Service

      pdf.start_new_page

      draw_header_box.call

      #pdf.font tos_font, :size => 8
      pdf.font_size = 7
      pdf.text strip_tags(@tos)

      draw_signature_lines.call(40)

      # Footer

      #pdf.font tos_font, :size => 8
      pdf.font_size = 7
      pdf.number_pages "Page <page> of <total>", :at => [250, -20]
      pdf.number_pages "Policy Holder Initials ______________", :at => [433, -20]

    end

    send_data(doc.render,
              :filename => "#{$installation.name.delete(' ')} Intro Packet-Agreement #{@customer.dashed_contract_number.delete('#')}",
              :type => "application/pdf")
  end
  
  def async_get_customers
    count = Customer.send(params[:id]).count
    customers = Customer.send(params[:id]).paginate(
      :per_page => (params[:CIPaginatorItemsPerPage] || 1).to_i,
      :page => params[:CIPaginatorPage], :order => 'id DESC')
    render :json => {
      :CIPaginatorPage => params[:CIPaginatorPage],
      :CIPaginatorItemCount => count,
      :CIPaginatorCollection => customers
    }
  end
  
  def list
    @page_title = "Customers"
    @selected_tab = 'customers'
    @status = params[:id]
    #logger.info("Last @page = #{session[:last_customers_async_list_page][params[:id]].inspect}")
    @page = session[:last_customers_async_list_page][params[:id]] || 1
    #logger.info("Now @page = #{@page.inspect}")
    
    @count = Customer.count(:conditions => {
      :status_id => Customer.id_for_status(params[:id].to_sym)
    })
    render :layout => 'new_admin'
  end
  
  def async_list
    params[:id] ||= 'new'
    
    #logger.info("Last :last[#{params[:id]}] = #{session[:last_customers_async_list_page][params[:id]].inspect}")
    session[:last_customers_async_list_page][params[:id]] = params[:CIPaginatorPage]
    #logger.info("Now :last[#{params[:id]}] = #{session[:last_customers_async_list_page][params[:id]].inspect}")
    
    conditions = { :status_id => Customer.id_for_status(params[:id].to_sym) }
    
    customers = Customer.paginate(:page => params[:CIPaginatorPage],
                                  :per_page  => (params[:CIPaginatorItemsPerPage] || 1).to_i,
                                  :conditions => conditions, :order => 'id DESC')
    
    count = Customer.count(:conditions => conditions)
    render :json => {
      :CIPaginatorPage => params[:CIPaginatorPage],
      :CIPaginatorItemCount => count,
      :CIPaginatorCollection => customers
    }
  end
  
  def async_get_page_data
    customer = Customer.find(params[:id])
    # This needs to be done here because there is no other place to perform this action
    #if customer.properties.length >= 1 then customer.update_coverage_address_and_drop_first_property end
    #if customer.coverage_address? then customer.properties << customer.build_and_nullify_property end
    customer_hash = {
      :id                     => customer.id,
      :name                   => customer.name,
      :from                   => customer.from,
      :contract_number        => customer.contract_number,
      :agent_id               => customer.agent_id,
      :added                  => customer.date ? customer.date.in_time_zone(EST).strftime("%m/%d/%y %I:%M %p EST") : '',
      :last_updated           => customer.updated_at ? customer.updated_at.in_time_zone(EST).strftime("%m/%d/%y %I:%M %p EST") : '',
      :first_name             => customer.first_name,
      :last_name              => customer.last_name,
      :email                  => customer.email,
      :phone                  => customer.customer_phone,
      :status_id              => customer.status_id,
      :cancellation_reason_id => customer.cancellation_reason_id,
      
      :billing_address => customer.billing_address,
      
      :list_price => "$%5.2f" % customer.list_price,
      :home_type => customer.home_type || '',
      :home_size_code => customer.home_size_code,
      :work_phone => customer.work_phone,
      :mobile_phone => customer.mobile_phone,
      :coverage_type => customer.coverage_type,
      :esigned => customer.esigned? ? 'Signed' : 'Unsigned',
      
      :last_login               => customer.account ? customer.account.last_login : nil,
      :has_web_account          => !customer.account.nil?,
      :first_property_zip_code  => customer.properties.empty? ? nil : customer.properties.first.zip_code
    }
    Coverage.all_optional.each { |cvg| 
      customer_hash["coverage_#{cvg.id}"] = (customer.coverage_addon || '').split(', ').include?(cvg.id.to_s)
    }
    
    agents_hash = {}
    Agent.all.each { |a| agents_hash[a.name] = a.id }
    
    packages_hash = {}
    Package.all.each { |p| packages_hash[p.package_name] = p.id }
    
    reasons_hash = {}
    CancellationReason.all.each { |r| reasons_hash[r.reason] = r.id }
    
    render :json => {
      :customer => customer_hash,
      :agentOptions => agents_hash,
      :cancelReasonOptions => reasons_hash,
      :packageOptions => packages_hash
    }
  end
  
  def async_get_billing_address
    customer = Customer.find(params[:id])
    render :json => customer.billing_address || {}
  end
  
  def async_update_billing_address
    customer = Customer.find(params[:id])
    params[:billing][:address_type] = 'Billing'
    updated = (customer.billing_address || customer.build_billing_address).update_attributes(params[:billing])
    notify(Notification::CHANGED, { :message => 'updated', :subject => customer.billing_address })
    render :json => updated
  end
  
  def async_get_billing_info
    customer = Customer.find(params[:id])
    ccn_method = "credit_card_number"
    ccn = current_account.cannot_see_credit_card_number ? customer.credit_card_number_last_4 : customer.credit_card_number
    
    render :json => {
      :num_payments => customer.num_payments,
      :pay_amount => customer.pay_amount,
      :total_paid => "%.2f" % (customer.num_payments.to_i * customer.pay_amount.to_f),
      :discount => customer.discount.nil? ? 'None' : "#{customer.discount.code}, #{customer.discount.amount} off",
      :credit_card_number => ccn,
      :expirationDate => customer.expirationDate,
      :subscription_id => customer.subscription_id
    }
  end
  
  # Deprecated
  def grant_web_account
    customer = Customer.find(params[:id])
    password = customer.grant_web_account
    if password
      Postoffice.template('Welcome', customer.email, {:customer => customer, :password => password}).deliver if $installation.auto_delivers_emails
    end
    redirect_to "/admin/customers/edit/#{params[:id]}"
  end
  
  def async_grant_web_account
    customer = Customer.find(params[:id])
    result = customer.grant_web_account
    if result.length == 8
      Postoffice.template('Welcome', customer.email, {:customer => customer, :password => result}).deliver if $installation.auto_delivers_emails
      render :json => {
        :text => "#{customer.name} has been granted a web account. Their password is \"#{result}\", and they have been emailed the \"Welcome\" email."
      }
    else
      render :json => { :text => result }
    end
  end
  
  def async_advanced_search_check
    render :json => {:count => eval(@search << 'count')}
  end
  
  def advanced_search
    @page_title = "Advanced Search Results"
    @customers = eval(@search << 'to_a')
    redirect_to(:action => 'edit', :id => @customers.first.id) and return if @customers.length == 1
    @customers ||= []
    render :action => 'search', :layout => 'new_admin'
  end
  
  def smart_search
    @page_title = "Search Results"
    q = params[:query].to_s.strip
    q_is_string = q.to_i == 0
    go_to_claim = false
    @customers = []
    
    if params[:param] == 'id'
      if q.include?('@')
        @customers = Customer.with_email(q)
      elsif q_is_string and q.length == 2
        @customers = Customer.with_state(q)
      elsif q =~ /-\d+$/
        @customers = Customer.with_claim_number(q)
        go_to_claim = true
      elsif q =~ /^\d{10}/
        @customers = Customer.with_phone(q)
      elsif q =~ /^\d+\s+\w+/i
        @customers = Customer.with_street(q)
      else
        begin
          @customers = [Customer.find(q)]
        rescue ActiveRecord::RecordNotFound
          @customers = []
        end
      end
    else
      # Prevent injection attacks
      allowed_params = ['first_name', 'last_name', 'email', 'street', 'city', 'state', 'zip_code', 'phone']
      @customers = allowed_params.include?(params[:param]) ? Customer.send("with_#{params[:param]}", q) : []
    end
    
    redirect_to(:action => 'edit', :id => @customers.first.id, :anchor => go_to_claim ? 'claims' : '') and return if @customers.length == 1
    @customers ||= []
    
    render :action => 'search', :layout => 'new_admin'
  end
  
  def index
    redirect_to :action => 'list', :id => 'new'
  end
  
  def edit
    @selected_tab = 'customers'
    
    if params[:id] and params[:id].to_i > 0
      @customer = Customer.find params[:id]
      @page_title = "Customers - #{@customer.contract_number} #{@customer.name}"
      @property = @customer.properties.first || @customer.properties.build
      # Nullify agent_id if the agent no longer exists
      @customer.update_attributes({ :agent_id => nil }) if @customer.agent_id and @customer.agent.nil?
      @coverage_options = Coverage.all_optional
      if params[:print]
        render :layout => 'print', :action => 'print'
      else
        render :layout => current_account.customer? ? 'admin' : 'new_admin'
      end
    else
      redirect_to :action => 'list', :id => 'new'
    end
  end
  
  def async_update
    customer = Customer.find(params[:id])
    if params[:customer][:home_type] && params[:customer][:home_type] == ''
      params[:customer][:home_type] = nil
    end
    
    updated = customer.update_attributes(params[:customer])
    
    notify(Notification::CHANGED, { :message  => 'updated', :subject => customer}) if updated
    
    if params[:customer][:email] and customer.account
      customer.account.update_attributes({:email => customer.email})
    end
    
    render :json => { :result => 'ok' }
  end
  
  def update
    @customer = Customer.find params[:id]
    @property = @customer.properties.first || @customer.properties.build
    
    if params[:customer]
    	if params[:customer][:coverage_type] 
		  	params[:coverages] ||= {}
		  	params[:customer][:coverage_addon] = (params[:coverages].collect { |k,v| k }).join(', ')
			end
			
			if params[:customer][:home_type] and params[:customer][:home_type] == ''
				params[:customer][:home_type] = nil
			end
    end
    
    customer_updated = @customer.update_attributes(params[:customer])
    notify(Notification::UPDATED, { :message  => 'updated', :subject => @customer }) if customer_updated
    
    @property.update_attributes(params[:property])
    if params[:customer] and params[:customer][:email] and @customer.account
      @customer.account.update_attributes({:email => @customer.email})
    end
    
    if current_account.customer?
      redirect_to '/admin/customers/claims'
    else
      redirect_to "/admin/customers/edit/#{@customer.id}##{params[:anchor]}"
    end
  end
  
  def add
    @selected_tab = 'customers'
    @customer = Customer.new
    @property = @customer.properties.build
    @billing = @customer.build_billing_address
    render :layout => 'new_admin'
  end
  
  def create
  	params[:customer][:disabled] = 0
    customer = Customer.create(params[:customer])
    customer.properties.create(params[:property])
    params[:billing][:address_type] = 'Billing'
    customer.create_billing_address(params[:billing])
    
    notify(Notification::CREATED, { :message  => 'created', :subject => customer })
    
    redirect_to :action => 'edit', :id => customer.id
  end
  
  def claims
    @selected_tab = 'claims'
    @customer = Customer.find current_account.parent.id
    premier_condition = @customer.coverage_type.to_i != 1 ? 'AND premier != 1' : ''
    @coverages = @customer.coverages | Coverage.find(:all, :conditions => ["optional = 0 #{premier_condition}"])
    render :layout => 'admin'
  end
  
  def claim_history
    @selected_tab = 'history'
    @customer = Customer.find current_account.parent.id
    render :layout => 'admin'
  end
  
  def async_related_customers
    customer = Customer.find(params[:id])
    related = []#customer.related_customers.reject { |c| c.id == customer.id }
    render :json => related.collect { |c|
      {
        :contract => c.contract_number
      }
    }
  end
  
  def esign
    @customer = Customer.find params[:id]
  end

  def perform_relationship_actions
    # Find the primary account
    primary_account = Customer.find(params[:customers].index('primary') || params[:id])
    # Take the primary account's current property and make it into a property if it doesn't have any properties
    if primary_account.properties.empty?
      primary_account.properties << primary_account.build_and_nullify_property
    end
    # Create properties on the primary account for each of the identified properties
    params[:customers].select { |k,v| v == 'property' }.each do |id, action|
      customer = Customer.find(id)
      primary_account.properties << customer.build_and_nullify_property
      if customer.can_be_purged? then customer.destroy end
    end
    # Delete the identified customers
    Customer.destroy(params[:customers].select { |k,v| v == 'purge' }.collect { |id, action| id })
    # Redirect back to the edit page
    redirect_to "/admin/customers/edit/#{primary_account.id}"
  end
  
  protected
  
  def assemble_search_string
    @search = "Customer."
    params[:query].sort.each do |i, query|
      next if query[:value] == ''
      @search << %Q{#{query[:op]}_#{query[:param]}("#{query[:value]}").}
    end
  end
end
