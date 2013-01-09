ActiveAdmin.register Customer do
  
menu :if => proc{ can?(:manage, Customer)}
controller.authorize_resource
filter :email
config.per_page = 100


index do
  column "Contract #", :contract_number
  column "Name", :name
  column "Email", :email
  column "Date", :created_at
  column("Send Email") { |c| "work in progress"}
  column "Status", :status
  column("View") {|customer| link_to "View Customer", admin_customer_path(customer)}
end

form do |f|
  f.inputs "Details" do
    f.input :contract_number
    f.input :name
    f.input :email
    f.input :status
    f.input :first_name
    f.input :last_name
    
  end 
  f.buttons
  end
  
 
end
