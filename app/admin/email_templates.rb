ActiveAdmin.register EmailTemplate do
  menu :parent => "Contents"
  menu :if => proc{ can?(:manage, EmailTemplate)}
  controller.authorize_resource
  
end
