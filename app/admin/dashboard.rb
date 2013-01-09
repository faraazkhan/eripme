ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    # Here is an example of a simple dashboard with columns and panels.
    #
     columns do
       column do
         panel "Today's Customers" do
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
   columns do
       column do
         panel "Yesterday's Customers" do
           table_for Customer.yesterday do
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


  end # content
end
