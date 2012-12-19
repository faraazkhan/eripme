ActiveAdmin.register Repair do
  menu :if => proc { can?(:manage, Repair) }
  controller.authorize_resource
  
end
