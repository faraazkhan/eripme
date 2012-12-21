ActiveAdmin.register Note do

  menu :if => proc{ can?(:manage, Note)}
  controller.authorize_resource

    
end
