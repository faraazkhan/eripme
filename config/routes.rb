# TODO: Cleanup after rails3 upgrade script
Eripme::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  match 'login' => 'admin/admin#login', :as => :login

  match 'contract/:id' => 'admin/customers#contract', :as => :contract_pdf, :format => 'pdf'
  match 'admin/customers/contract/:id' => 'admin/customers#contract', :format => 'pdf'

  match '/:controller(/:action(/:id))', :controller => /admin\/[^\/]+/

  namespace :admin do
    match 'customers/edit/:id.print' => 'customers#edit', :print => true
    match 'authenticate' => 'admin#authenticate'
    match ':action' => 'admin#index'
    root :to => "admin#index"
  end

  match '/:controller(/:action(/:id))'
  scope :constraints => { :protocol => 'https'} do
    match '/quote' => 'site#quote'
  end
  match ':action' => 'site'

  root :to => 'site#index'
end
