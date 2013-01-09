ActiveAdmin.register Contractor do
  menu :if => proc{ can?(:manage, Contractor)}
  controller.authorize_resource

  index do
    column("Company") {|con| con.company }
    column("Email") {|con| con.email }
    column("Phone") {|con| con.phone }
    column("Rating") {|con| con.stars}
    default_actions
  end

  #form do |f|
    #@ratings = %w[ * ** *** **** *****]
    #f.inputs "Details" do
      #f.input :first_name
      #f.input :last_name
      #f.input :company
      #f.input :job_title
      #f.input :email
      #f.input :phone
      #f.input :fax
      #f.input :notes
      #f.input :priority
      #f.input :rating, :as => :select, :collection => @ratings
      #f.input :flagged, :label => 'This contractor is flagged for warning'
    #end
    
    #f.buttons

  #end
  #
  form :partial => 'form'
  
end
