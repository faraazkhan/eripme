ActiveAdmin.register Content do
  menu :if => proc{ can?(:manage, Content)}
  controller.authorize_resource

 
  
end
