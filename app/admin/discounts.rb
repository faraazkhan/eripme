ActiveAdmin.register Discount do
  menu :parent => "Contents"
  menu :if => proc{ can?(:manage, Discount)}
  controller.authorize_resource
  
end
