ActiveAdmin.register Customer do
  
menu :if => proc{ can?(:manage, Customer)}
controller.authorize_resource
config.filters = false

index do
  columns do
       column do
           table_for Customer.today do
             column("Contract #") {|customer| customer.contract_number}
             column("Name") {|customer| customer.name}
             column("Email") { |customer| customer.email}
             column("Date") {|customer| customer.created_at}
             column("Send Email") {|customer| "work in progress" }
             column("Status") {|customer| customer.status}
             column("View") {|customer| link_to "View Customer", admin_customer_path(customer)}
         end
       end
    end
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
