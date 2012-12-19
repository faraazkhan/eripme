ActiveAdmin.register Contractor do
  menu :if => proc{ can?(:manage, Contractor)}
  controller.authorize_resource
  
end
