class Installation
  attr_reader :name, :short_name, :code_name, :domain, :www_domain, :phone, :fax, :invoice_prefix, :fax_service
  attr_reader :admin_email, :claims_email, :info_email, :noreply_email, :customercare_email
  attr_reader :ga_tracking_id
  attr_accessor :active_states
  
  attr_reader :credentials
  
  attr_accessor :auto_delivers_emails
  alias :auto_delivers_email :auto_delivers_emails
  
  def [](key)
     nil
  end
  
  def initialize(name, short_name, code_name, domain, www_domain, phone, fax, invoice_prefix, fax_service, auto_delivers_emails=true, ga_tracking_id='')
    @name           = name
    @short_name     = short_name
    @code_name      = code_name
    @domain         = domain
    @www_domain     = www_domain
    @phone          = phone
    @fax            = fax
    @invoice_prefix = invoice_prefix
    @fax_service    = fax_service.constantize
    
    @admin_email    = "admin@#{domain}"
    @claims_email   = "claims@#{domain}"
    @info_email     = "info@#{domain}"
    @noreply_email  = "info@#{domain}"
    @customercare_email = "info@#{domain}"
    
    @auto_delivers_emails = auto_delivers_emails

    @ga_tracking_id = ga_tracking_id
    @active_states = []
  end
  
  def add_credentials(service, data)
    return if @credentials.has_key?(service)
    @credentials[service.to_sym] = data
    return self
  end
  
  def self.default_email_templates
    {
      'Proforma'                  => ['Proforma Invoice {customer contract_number}', :tabular],
      'Welcome'                   => 'Welcome to {installation name}, {customer name}',
      'New Web Order'             => 'New Web Order, Customer {customer contract_number}',
      'Join Our Team'             => ['Request to Join {installation short_name}', :tabular],
      'Become Contractor'         => ['Request to become {installation short_name} Contractor', :tabular],
      'Billing'                   => ['{installation name}', :agent],
      'Renewal'                   => ['{installation name}', :agent],
      'New Claim by Customer'     => 'New Claim by Customer {customer contract_number}',
      'Welcome Contractor'        => 'Welcome to {installation name}',
      'Monthly'                   => ['Home Warranty Account', :agent],
      'Contractor Assigned'       => ['Contractor Assigned to {installation short_name} Claim {customer contract_number}', :agent],
      'Price Quote'               => ['Your Price Quote', :tabular],
      'Signed Contract Reminder'  => ['Signed Contract Reminder', :agent]
    }
  end
  
  def self.default_content
    %w(terms_of_service testimonials terms_and_conditions faq)
  end
  
  def self.load!
    $installation = Installation.new('Select Home Warranty', 'Select', 'select', 'selecthomewarranty.com', 'www.selecthomewarranty.com', '1-855-267-3532', '1-732-876-0339', 'SHW1', 'EFaxFaxService', false, 'UA-30123828-1')
    $installation.active_states = ["AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID", "IL", "IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","UT","VT","VA","WV","WI","WY"] 
    smtp_settings = {
                      :user_name => 'info@selecthomewarranty.com',
                      :password => 'monjoe28',
                      :authentication => 'login',
                      :address => 'smtp.gmail.com',
                      :domain => 'gmail.com',
                      :port => 587,
                      :enable_starttls_auto => true
    }
    gmaps_settings = {
                    :authorize => {
                                    :login => '4r5NsQM8qazX',
                                    :password => '4Qq8z4RNXm265g5S'
                    }
    }
    @credentials = {}
    @credentials['smtp'] = smtp_settings
    @credentials['gmaps'] = gmaps_settings
  end
end
