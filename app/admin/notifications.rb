ActiveAdmin.register Notification do
  menu :if => proc{ can?(:manage, EmailTemplate)}
  controller.authorize_resource
end
