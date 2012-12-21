ActiveAdmin.register Customer do
  
menu :if => proc{ can?(:manage, Customer)}
controller.authorize_resource
end
