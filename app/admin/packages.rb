ActiveAdmin.register Package do
  menu :parent => "Contents"
  menu :if => proc{ can?(:manage, Package)}
  controller.authorize_resource
  
end
