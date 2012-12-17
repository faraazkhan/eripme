class Admin::RepairsController < ApplicationController
  before_filter :check_login
 
  contractor_can :index, :complete
  layout 'admin', :except => :async_create_or_update_for_claim

  ssl_exceptions []
  
  def index
    @selected_tab = 'repairs'
    @repairs = current_account.parent.repairs
  end
  
  def work_order
    repair = Repair.find(params[:id])
    
    contractor_company = repair.contractor.company
    contractor_phone = repair.contractor.phone
    contractor_fax = repair.contractor.fax
    dispatch_date = repair.created_at.in_time_zone(EST).strftime("%B %d, %Y EST")
    claim_number = repair.claim.customer._dashed_contract_number
    problem = (repair.claim.claim_text || '').gsub(/\n/, "\\\n")
    policy_holder = repair.claim.customer.name
    property = repair.claim.property
    coverage_address = "#{property.address}\\\n#{property.city_state_zip}"
    customer_phone = repair.customer.customer_phone
    customer_cell = repair.customer.mobile_phone
    service_fee = repair.formatted_service_charge
    service_fee_text = repair.service_charge.to_i.to_english.titleize << ' Dollars'
    
    rtf = File.read("#{RAILS_ROOT}/app/views/admin/content/work_order_template.rtf")
    rtf.gsub!(/#([A-Za-z0-9.$!_]+?)#/) { |cmd| eval($1) }
    send_data(rtf, { :filename => "Work Order for Customer #{claim_number}.rtf", :type => 'text/rtf' })
  end
  
  def async_toggle_status
    render :json => Repair.find(params[:id]).toggle_status!
  end
  
  def async_toggle_authorization
    render :json => Repair.find(params[:id]).toggle_authorization!
  end
  
  def async_unassign_contractor_for_claim
    claim = Claim.find(params[:id])
    if claim.repair
      contractor = claim.repair.contractor
      updated = claim.repair.update_attributes({:contractor_id => nil})
      notify(Notification::UPDATED, { :message => "unassigned from Claim on #{claim.customer.contract_number}", :subject => contractor }) if updated
    end
    render :json => claim
  end
  
  def complete
    @selected_tab = 'repairs'
    @repair = Repair.find(params[:id])
    if request.post?
      params[:note][:note_text] = "#{@repair.contractor.company}:\n#{params[:note][:note_text]}"
      @repair.claim.customer.notes.create(params[:note])
      @repair.update_attributes({ :status => 1 })
      notify(Notification::UPDATED, { :message => 'completed', :subject => @repair })
      redirect_to :action => 'index'
    end
  end
end
