# TODO: Cleanup after rails3 upgrade script
Eripme::Application.routes.draw do

  match 'login' => 'admin/admin#login', :as => :login
  match 'billing' => 'site#billing', :as => :billing
  match 'purchase' => 'site#purchase', :as => :purchase
  match 'admin/content/async_get_package_prices' => 'admin/content#async_get_package_prices', :via => [:get, :post]
  match '/admin/discounts/async_validate' => 'admin/discounts#async_validate', :via => [:get, :post]

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
  #match ':action' => 'site'

  root :to => 'site#index'
  mount_browsercms
end
