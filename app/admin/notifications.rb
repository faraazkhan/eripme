ActiveAdmin.register Notification do
  menu :if => proc{ can?(:manage, EmailTemplate)}
  controller.authorize_resource

 index :as => :block do |note|
 end 
end
