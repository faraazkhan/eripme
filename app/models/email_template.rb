class EmailTemplate < ActiveRecord::Base
  attr_accessor :data
  
  def edit_url
    "/admin/email_templates/edit/#{self.id}"
  end
  
  def notification_summary
    "&ldquo;#{self.name}&rdquo; Template"
  end
  
  def parsed_subject
    return self.parse(self.subject)
  end
  
  def parse(s)
		return s.gsub(/\{(.+?)\s(.+?)\}/) do |match|
			begin
				case $1
				when 'the'
					@data[$2.to_sym]
				when 'installation'
				  $installation.send($2)
				when 'customer'
					if @data[:customer] then @data[:customer].send($2) end
				when 'contractor'
				  if @data[:contractor] then @data[:contractor].send($2) end
				when 'my'
					if @data[:my] then @data[:my].parent.send($2) end
				when 'image'
					if $2 == 'logo'
					  '<a href="http://' + $installation.www_domain + '"><img src="http://' + $installation.www_domain + '/images/email/logo.gif" alt="' + $installation.name + '"/></a>'
					end
				end
			rescue
				# Suppress Errors
			end
		end
  end
  
  def parsed_body
   return self.parse(self.body).html_safe
  end
  
  def EmailTemplate.placeholders
  	[
  		['image logo', 'Logo and Slogan with link to site'],
  		['customer first_name', 'John'],
  		['customer last_name', 'Smith'],
  		['customer name', 'John Smith'],
  		['customer contract_number',  "##{$installation.invoice_prefix}000321"],
  		['customer _contract_number', "#{$installation.invoice_prefix}000321"],
  		['customer contract_url', "https://#{$installation.www_domain}/contract/#{$installation.invoice_prefix}000321"],
  		['customer email', 'johnsmith@fake.com'],
  		['customer full_address', '123 Maple St., Springfield, VA, 12345'],
  		['customer address', '123 Maple St.'],
  		['customer city', 'Springfield'],
  		['customer state', 'VA'],
  		['customer zip_code', '12345'],
  		['customer package_name', 'Full System'],
  		['customer pay_amount', 'Amount Per Payment'],
  		['customer package_price', '399.99'],
  		['customer list_price', 'Pkg. Price + Cvg. Addons'],
  		['customer coverage_option_names', 'Pool/Spa, Septic System'],
  		['customer payment_schedule', '4 Monthly Payment(s)'],
  		['customer service_fee', '$60 (Sixty Dollars)'],
  		['contractor name', 'Joe Schmoe'],
  		['contractor company', 'Joe Schmoe Contracting'],
        ['installation phone', $installation.phone],
        ['installation fax', $installation.fax],
       
  	]
  end
end
