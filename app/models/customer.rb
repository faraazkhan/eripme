require 'openssl'
require 'base64'

class Customer < ActiveRecord::Base
  belongs_to :package, :foreign_key => 'coverage_type'
  belongs_to :discount
  belongs_to :agent
  belongs_to :cancellation_reason
  
  before_save :create_icontact_id
  after_save  :update_icontact_info

  has_many :fax_assignable_joins, :as => :assignable
  has_many :renewals, :order => 'created_at DESC', :dependent => :destroy
  has_many :transactions, :order => 'created_at DESC', :dependent => :destroy
  has_many :notes, :order => 'created_at DESC', :dependent => :destroy
  has_many :claims, :order => 'created_at DESC', :dependent => :destroy
  has_many :addresses, :as => :addressable, :dependent => :destroy
  has_many :properties, :class_name => 'Address', :as => :addressable, :dependent => :destroy, :conditions => { :address_type => 'Property' }
  has_many :credit_cards, :dependent => :destroy
  
  has_one  :account, :as => :parent, :dependent => :destroy
  has_one  :billing_address, :class_name => 'Address', :as => :addressable, :dependent => :destroy, :conditions => { :address_type => 'Billing' }
  attr_accessible :email, :first_name, :last_name, :customer_address, :customer_city, :customer_state, :customer_zip, :customer_phone, :customer_type, :coverage_type, :coverage_addon, :home_type, :pay_amount, :num_payments, :disabled, :coverage_end, :coverage_ends_at, :validated, :customer_comment, :credit_card_number_hash, :expirationDate, :timestamp, :billing_first_name, :billing_last_name, :billing_address, :billing_city, :billing_state, :billing_zip, :from, :service_fee_text_override, :service_fee_amt_override, :wait_period_text_override, :wait_period_days_override, :num_payments_override, :num_payments_override, :payment_schedule_override, :notes_override, :home_size_code, :home_occupancy_code, :work_phone, :mobile_phone
  
  scope :with_contract_number, lambda { |s|
    match = s.match(/#{$installation.invoice_prefix}(\d{1,})$/)
    { :conditions => { :id => match[1] }, :limit => 1 }
  }
  
  scope :today, lambda { { :conditions => ["`customers`.created_at > ?", DateTime.now.beginning_of_day], :order => 'created_at DESC' } }
  scope :yesterday, lambda {
    today = DateTime.now.beginning_of_day
    { :conditions => { :created_at => today.yesterday .. today }, :order => "created_at DESC" }
  }
  # Advanced Searching
  scope :with_name_like, lambda { |n|
    like = '%' << n.split(' ').join('%') << '%'
    { :conditions => ["CONCAT_WS(' ', first_name, last_name) LIKE ?", like] }
  }
  scope :with_first_name, lambda { |f| { :conditions => { :first_name => f} }}
  scope :without_first_name, lambda { |f| { :conditions => ['first_name != ?', f] }}
  
  scope :with_last_name, lambda { |f| { :conditions => { :last_name => f} }}
  scope :without_last_name, lambda { |f| { :conditions => ['last_name != ?', f] }}
  
  scope :with_first_name, lambda { |f| { :conditions => { :first_name => f} }}
  scope :without_first_name, lambda { |f| { :conditions => ['first_name != ?', f] }}
  
  scope :with_phone, lambda { |p|
    # Strip '(', ')', '.', '-', ' ' from `customer_phone` and the query
    { :conditions => ["REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(customer_phone, '.', ''), ')', ''), '(', '') ,' ', ''), '-', '') = ?", p.gsub(/\(|\)|\s|-|\./, '')] }
  }
  scope :without_phone, lambda { |p|
    { :conditions => ["REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(customer_phone, '.', ''), ')', ''), '(', '') ,' ', ''), '-', '') != ?", p.gsub(/\(|\)|\s|-|\./, '')] }
  }
  
  scope :with_claim_number, lambda { |n|
    id = n.match(/-(\d+)$/)[1].to_i
    { :conditions => ['claims.id = ?', id], :include => :claims }
  }
  
  scope :with_email, lambda { |e| { :conditions => { :email => e } } }
  scope :without_email, lambda { |e| { :conditions => ['email != ?', e] } }
  
  scope :with_street, lambda { |s|
    { :conditions => ['addresses.address_type = "Property" AND addresses.address LIKE ?', "#{s}%"], :include => :addresses }
  }
  scope :without_street, lambda { |s|
    { :conditions => ['addresses.address_type = "Property" AND addresses.address != ?', s], :include => :addresses }
  }
  
  scope :with_city, lambda { |c|
    { :conditions => ['addresses.address_type = "Property" AND addresses.city = ?', c], :include => :addresses }
  }
  scope :without_city, lambda { |c|
    { :conditions => ['addresses.address_type = "Property" AND addresses.city != ?', c], :include => :addresses }
  }
  
  scope :with_state, lambda { |s|
    { :conditions => ['addresses.address_type = "Property" AND addresses.state = ?', s.downcase], :include => :addresses }
  }
  scope :without_state, lambda { |s|
    { :conditions => ['addresses.address_type = "Property" AND addresses.state != ?', s.downcase], :include => :addresses }
  }
    
  scope :with_zip_code, lambda { |z|
    { :conditions => ['addresses.address_type = "Property" AND addresses.zip_code = ?', z], :include => :addresses }
  }
  scope :with_zip_code, lambda { |z|
    { :conditions => ['addresses.address_type = "Property" AND addresses.zip_code != ?', z], :include => :addresses }
  }
  
  scope :with_status_id, lambda { |sid| { :conditions => { :status_id => sid.to_i }} }
  scope :without_status_id, lambda { |sid| { :conditions => ['status_id != ?', sid.to_i] } }
  
  scope :with_agent_id, lambda { |aid| { :conditions => { :agent_id => aid.to_i }} }
  scope :without_agent_id, lambda { |aid| { :conditions => ['agent_id != ?', aid.to_i] } }
  
  # Other Searches
  
  scope :with_credit_card_number_hash, lambda { |ccnh| { :conditions => { :credit_card_number_hash => ccnh } } }
  
  scope :not_deleted, :conditions => ['status_id != ?', 2]
  scope :with_billing_address, lambda { |ba| { :conditions => { :billing_address => ba } } }
  scope :with_first_and_last_name, lambda { |f,l|
    { :conditions => { :first_name => f, :last_name => l } }
  }
  scope :without_id, lambda { |id| { :conditions => ['id != ?', id] } }
  #scope :with_email_like, lambda { |e|
  #  split = e.split('@'); query = "%#{split[0].to_s}%@%#{split[1].to_s}%"
  #  { :conditions => ['email LIKE ?', query] }
  #}
  
  def Customer.telecom_number_strip_condition(field, value)
    ["REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(`#{field}`, '.', ''), ')', ''), '(', '') ,' ', ''), '-', '') = ?", value.gsub(/\(|\)|\s|-|\./, '')]
  end
  
  def formatted_home_type
    Package.home_type_names[self.home_type] || 'Single-Family'
  end
  
  @@home_occupancies = Dictionary[
    0,'Single Family',
    1,'2 Family',
    2,'3 Family',
    3,'4 Family',
    4,'Condominium'
  ]
  def self.home_occupancies; @@home_occupancies; end
  
  @@home_sizes = Dictionary[0,'Less than 5,000 sq ft.', 1,'More than 5,000 sq ft.'].freeze
  def self.home_sizes; @@home_sizes; end
  def self.home_size_options
    json = []
    @@home_sizes.each do |code, size|
      json << "'#{size}': #{code}"
    end
    "{#{json.join(', ')}}"
  end
  def home_size
    Customer.home_sizes[self.home_size_code] || Customer.home_sizes.first
  end
  
  def service_fee_text_override!
    self.service_fee_text_override.nil? || self.service_fee_text_override.empty? ? 'sixty' : self.service_fee_text_override
  end
  def service_fee_amt_override!
    "%.2f" % (self.service_fee_amt_override.nil? || self.service_fee_amt_override == 0 ? 60.0 : self.service_fee_amt_override)
  end
  
  def wait_period_text_override!
    self.wait_period_text_override.nil? || self.wait_period_text_override.empty? ? 'thirty' : self.wait_period_text_override
  end
  def wait_period_days_override!
    self.wait_period_days_override.nil? || self.wait_period_days_override == 0 ? 30 : self.wait_period_days_override
  end
  
  def contract_overrides
    attrs = [ :service_fee_text_override, :service_fee_amt_override,
              :wait_period_text_override, :wait_period_days_override,
              :num_payments_override,     :payment_schedule_override,
              :notes_override ]
    overrides = {}
    attrs.each { |attrib| overrides[attrib] = self[attrib] }
    return overrides
  end
  
  def service_fee
    "$#{self.service_fee_amt_override!.gsub(/\.00/, '')} (#{self.service_fee_text_override!.titleize} Dollars)"
  end
  
  def payment_schedule
    "#{self.num_payments_override || self.num_payments} #{self.payment_schedule_override}"
  end
  
  @@payment_schedules = ['','Monthly Payment(s)', 'Consecutive Monthly Payment(s)', 'Quarterly Payment(s)', 'Semi-Annual Payment(s)', 'Annual Payment(s)', 'Payment(s)']
  def self.payment_schedules; @@payment_schedules; end
  
  # TODO There must be a better way to do this;
  #      we need to use an array because we need it in order
  def payment_schedule_options_json
    json = []
    @@payment_schedules.each_with_index do |s, i|
      json << (i == 0 ? "'': null" : "'#{s}': '#{s}'")
    end
    return "{#{json.join(', ')}}"
  end
  
  def first_billing_address
    if !self.billing_address.nil? && !self.billing_address.address.empty?
      self.billing_address
    elsif not self.attributes[:billing_address].nil?
      Address.new({
        :address  => self.attributes[:billing_address],
        :city     => self.billing_city,
        :state    => self.billing_state,
        :zip_code => self.billing_zip
      })
    elsif not self.credit_cards.first.nil?
      self.credit_cards.first.address
    else
      self.first_property
    end
  end
  
  def contract_term_years
    !self.renewals.empty? && self.renewals.first.duration > 0 ? self.renewals.first.duration : 1
  end
  
  def contract_url
    "https://#{$installation.www_domain}/contract/#{self.contract_number.delete('#')}"
  end
  
  def edit_url
    "/admin/customers/edit/#{self.id}"
  end
  
  def notification_summary
    "#{self.contract_number} #{self.name}"
  end
  
  def as_json(a=nil,b=nil)
    {
      :id => self.id,
      :contract => self.contract_number,
      :updated => self.updated_at ? self.updated_at.in_time_zone(EST).strftime("%m/%d/%y %I:%M %p") : '',
      :date => self.date ? self.date.in_time_zone(EST).strftime("%m/%d/%y %I:%M %p") : 'No Date',
      :from => self.from,
      :name => self.name,
      :email => self.email,
      :status => self.status,
      :standing => self.transactional_standing,
      :isWebOrder => self.web_order?
    }
  end
  
  def first_property
    self.properties.empty? ? nil : self.properties.first
  end
  
  def Customer.id_for_status(status)
    return {
      :new => 0,
      :leftmessage => 1,
      :deleted => 2,
      :followup => 3,
      :completedorder => 4,
      :proforma => 6,
      :tobebilled => 7,
      :cancelled => 5,
    }[status.to_sym] || 0
  end
  
  def Customer.formatted_status_array
    [
      ["New", 0],
      ["Left Message", 1],
      ["Deleted", 2],
      ["Follow Up", 3],
      ["Completed Order", 4],
      ["Proforma", 6],
      ["To Be Billed", 7],
      ["Cancelled", 5]
    ]
  end
  
  def esigned?
    self.account and self.account.signature_hash
  end
  
  def cancel_reason
    self.cancellation_reason.nil? ? '--' : self.cancellation_reason.reason
  end
  
  def contract_number
  	"##{$installation.invoice_prefix}#{self.id.to_s.rjust(5, '0')}"
  end
  
  def _contract_number
    self.contract_number.delete('#')
  end
  
  def dashed_contract_number
    self.contract_number.split(/(\d+)/).join('-')
  end
  
  def _dashed_contract_number
    self.dashed_contract_number.delete('#')
  end
  
  def name
    "#{self.first_name} #{self.last_name}"
  end
  alias to_s name
  
  def full_coverage_address
    "#{self.customer_address} #{self.customer_city}, #{self.customer_state}, #{self.customer_zip}"
  end
  
  def date
    self.created_at || (Time.at(self.timestamp).utc if timestamp)
  end
  
  def status
    case self.status_id
    when 0
      "New Customer"
    when 1
      "Left Message"
    when 2
      "Deleted"
    when 3
      "Follow Up"
    when 4
      "Completed Order"
    when 5
      "Cancelled"
    when 6
      "Proforma"
    when 7
      "To Be Billed"
    end
  end
  
  def rate_mode
    case self.num_payments.to_i % (self.contract_term_years * 12)
    when 0
      "MONTHLY"
    when 1
      "ANNUAL"
    when 4
      "QUARTERLY"
    else
      "SEMI-ANNUAL"
    end
  end
  
  def formatted_annual_rate
    "$%.2f" % case self.num_payments.to_i % (self.contract_term_years * 12)
    when 0
      self.pay_amount.to_f * 12
    else
      self.pay_amount.to_f * self.num_payments.to_i
    end
  end
  
  def web_order?
    self.subscription_id && self.subscription_id.to_i > 0
  end
  
  def class_for_status
    'webOrder' if self.web_order?
  end
  
  def coverages=(hash)
    self.coverage_addon = hash.collect { |k,v| k if v != 'false' }.delete_if { |x| x == nil }.join(', ')
  end
  
  def coverages
    if self.coverage_addon.nil? or self.coverage_addon.empty? then return [] end
    
    coverage_ids = self.coverage_addon.split(", ")
    coverages = coverage_ids.collect { |id| Coverage.find_by_id(id) }.compact
    return coverages
  end
  
  def coverage_text
    self.package_covers + (", #{self.coverage_option_names}" if self.coverages.length > 0).to_s
  end
  
  def coverage_option_names
    self.coverages.collect { |c| c.coverage_name }.join(', ')
  end
  
  def has_coverage?(coverage)
    if self.coverage_addon
      return self.coverage_addon.split(', ').include?(coverage.id.to_s)
    else
      return false
    end
  end
  
  def package_covers
    self.package.covers if self.package
  end
  
  def package_name
  	self.package.package_name if self.package
  end
  
  def package_price
    ht = (self.home_type.nil? or self.home_type.empty?) ? 'single' : self.home_type
  	self.package.send("#{ht}_price")
  end
  
  def list_price
    total = self.package_price
    total += (self.coverages.collect { |c| c.price }).sum
    return total
  end
  
  def credit_card_number
    if self.credit_card_number_hash and not self.credit_card_number_hash.empty?
      private_key = OpenSSL::PKey::RSA.new(File.read('app/security/private.pem'), 'aENtkiJ0')
      return private_key.private_decrypt(Base64.decode64(self.credit_card_number_hash))
    else
      return ''
    end
  end
  
  def credit_card_number=(number)
    public_key = OpenSSL::PKey::RSA.new(File.read('app/security/public.pem'));
    self.credit_card_number_hash = Base64.encode64(public_key.public_encrypt(number))
  end
  
  def credit_card_number_last_4
    number = self.credit_card_number
    (number[-4..-1] || "").rjust(number.length, '*')
  end
  
  def coverage_has_ended?
    Time.now > self.coverage_ends_at
  end
  
  def grant_web_account
    unless self.account.nil? then return "#{self.name} already has a web account" end
    if self.email.nil? or self.email.empty? then return "#{self.name} must have a valid email address." end
    
    password = Account.generate_random_password #length is 8
    self.create_account({
      :email => self.email,
      :password => password,
      :role => 'customer',
      :parent_id => self.id,
      :parent_type => 'Customer',
      :timezone => '-5'
    })
    if self.account.nil?
      return "A web account could not be created for #{self.name}"
    else
      return password
    end
  end
  
  def transactional_standing
    self.transactions.first.result.downcase.gsub(/\s/, '') if self.transactions.first
  end
  
  def related_customers
    by_hash = Customer.with_credit_card_number_hash(self.credit_card_number_hash)
    by_email = Customer.with_email(self.email)
    #by_billing = self.billing_address == '' || self.billing_address.nil? ? [] : Customer.with_billing_address(self.billing_address)
    by_name = Customer.with_first_and_last_name(self.first_name, self.last_name)

    return by_hash | by_email | by_billing | by_name
  end
  
  def can_be_purged?
    self.transactions.empty? and self.notes.empty? and self.claims.empty?
  end
  
  def default_grouping_action(viewed_customer)
    if self.status_id == 2 && self.can_be_purged?
      return 'purge'
    elsif self.full_coverage_address != viewed_customer.full_coverage_address
      return 'property'
    elsif self.status_id != 2
      return 'primary'
    else
      return 'ignore'
    end
  end
  
  def coverage_address?
    !(self.customer_address.nil? or self.customer_address.empty?)
  end
  
  def billing_address?
    !(self.billing_address.nil? or self.billing_address.empty?)
  end
  
  def convert_addresses!
    Address.transaction do
      if self.coverage_address?
        self.addresses.create({
          :address => self.customer_address,
          :city => self.customer_city,
          :state => self.customer_state,
          :zip_code => self.customer_zip,
          :address_type => 'Property'
        })
        self.update_attributes({
          :customer_address => nil,
          :customer_city => nil,
          :customer_state => nil,
          :customer_zip => nil
        })
      end
      if self.billing_address?
        self.addresses.create({
          :address => self.billing_address,
          :city => self.billing_city,
          :state => self.billing_state,
          :zip_code => self.billing_zip,
          :address_type => 'Billing'
        })
        self.update_attributes({
          :billing_address => nil,
          :billing_city => nil,
          :billing_state => nil,
          :billing_zip => nil
        })
      end
      self.properties.each do |p|
        self.addresses.create({
          :address => p.address,
          :city => p.city,
          :state => p.state,
          :zip_code => p.zip,
          :address_type => 'Property'
        })
        p.destroy
      end
      self.addresses
    end
  end
  
  def build_and_nullify_property
    p = Property.new({
      :address => self.customer_address,
      :city => self.customer_city,
      :state => self.customer_state,
      :zip => self.customer_zip
    })
    self.update_attributes({
      :customer_address => nil,
      :customer_city => nil,
      :customer_state => nil,
      :customer_zip => nil
    })
    return p
  end
  
  def update_coverage_address_and_drop_first_property 
    p = self.properties.first
    if p.nil? then return end
      
    self.update_attributes({
      :customer_address => p.address,
      :customer_city => p.city,
      :customer_state => p.state,
      :customer_zip => p.zip
    })
    
    p.destroy
  end
  
  def address
    self.properties.empty? ? '' : self.properties.first.address
  end
  
  def city
    self.properties.empty? ? '' : self.properties.first.city
  end
  
  def state
    self.properties.empty? ? '' : self.properties.first.state
  end
  
  def zip_code
    self.properties.empty? ? '' : self.properties.first.zip_code
  end
  
  def full_address
    [self.address, self.city, self.state, self.zip_code].reject { |x| x == '' }.join(', ')
  end
  
  def to_icontact_record
    <<-XML
<?xml version="1.0"?>
    <contact id="#{self.icontact_id}">
      <fname>#{self.first_name}</fname>
      <lname>#{self.last_name}</lname>
      <email>#{self.email}</email>
      <address1>#{self.billing_address.address if self.billing_address}</address1>
      <address2>#{self.billing_address.address2 if self.billing_address}</address2>
      <city>#{self.billing_address.city if self.billing_address}</city>
      <state>#{self.billing_address.state if self.billing_address}</state>
      <zip>#{self.billing_address.zip_code if self.billing_address}</zip>
      <phone>#{self.customer_phone}</phone>
    </contact>
    XML
  end
  
  def enqueue_follow_up_list_action(action)
    IContactRequest.create({
      :path => "contact/#{self.icontact_id}/subscription/#{IContactRequest::FOLLOW_UP_LIST_ID}",
      :put => IContactRequest.follow_up_subscription(action == :add)
    })
  end
  
  def enqueue_left_message_list_action(action)
    IContactRequest.create({
      :path => "contact/#{self.icontact_id}/subscription/#{IContactRequest::LEFT_MESSAGE_LIST_ID}",
      :put => IContactRequest.left_message_subscription(action == :add)
    })
  end

  protected
  
  def create_icontact_id(arg=nil) # occurs before_save
    return true
    
    unless self.icontact_id
      # Create a new iContact immediately
      response = IContactRequest.new({
        :path => 'contact',
        :put => self.to_icontact_record
      }).call
      if response.successful?
        self.icontact_id = response.xml.root.elements['result'].elements['contact'].attributes['id'].to_i
      end
    else
      # Queue a contact update
      IContactRequest.create({
        :path => "contact/#{self.icontact_id}",
        :put => self.to_icontact_record
      })
    end
    return true
  end
  
  def update_icontact_info(arg=nil) # occurs after_save
    return true
    
    return true unless self.icontact_id
    
    # login to iContact and update the information based on the current status
    case self.status_id
    when 1              # Left Message
      self.enqueue_follow_up_list_action(:remove)
      self.enqueue_left_message_list_action(:add)
    when 2              # Deleted
      self.enqueue_follow_up_list_action(:add)
      self.enqueue_left_message_list_action(:remove)
    when 3              # Follow up
      self.enqueue_follow_up_list_action(:add)
      self.enqueue_left_message_list_action(:remove)
    when 4              # Completed Order
      self.enqueue_follow_up_list_action(:add)
      self.enqueue_left_message_list_action(:remove)
    when 5              # Cancelled
      self.enqueue_follow_up_list_action(:remove)
      self.enqueue_left_message_list_action(:remove)
    when 6              # Proforma
      self.enqueue_follow_up_list_action(:add)
      self.enqueue_left_message_list_action(:remove)
    end
    
    return true
  end
end
