ActiveAdmin.register Transaction do
  menu :if => proc{ can?(:manage, Transaction)}
  controller.authorize_resource
  
end
