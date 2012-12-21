ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }
    #collection_action :claims_dashboard, :method => :get do
      #@page = session[:last_claims_page] || 1
      #@active_statuses = session[:last_active_statuses] || Claim.statuses.collect { |k,v| v }
      #@page_title = "Claims"
      #@selected_tab = 'index'
    #end
  end
ActiveAdmin::Dashboards.build do
  section "Yesterday's Customers" do
    div do
      render 'dashboard'
    end
  end 

  #section "Today's Customers" do
    #table_for Customer.where("updated_at >= '#{Date.today}'").limit(20) do
    #column :contract_number
    #column :date
    #column :name
    #column :email
    #column :action do |customer|
        #link_to 'Edit', '#' 
      #end
    #column :status
    #end
  #end

    #section "Yesterday's Customers" do
    #table_for Customer.where("updated_at >= '#{1.day.ago}'").limit(20) do
    #column :contract_number
    #column :date
    #column :name
    #column :email
    #column :status
    #end

  #end

  #content :title => proc{ I18n.t("active_admin.dashboard") } do
    #div :class => "blank_slate_container", :id => "dashboard_default_message" do
      #span :class => "blank_slate" do
        #span I18n.t("active_admin.dashboard_welcome.welcome")
        #small I18n.t("active_admin.dashboard_welcome.call_to_action")
      #end
    #end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  #end # content
end
