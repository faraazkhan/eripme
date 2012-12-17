namespace :select do
  task :create_default_admin => :environment do
	return if Agent.count != 0

	agent = Agent.create({
	  :name => 'Administrator', 
	  :email => 'admin',
	  :admin => true
	})
	account = Account.create({
	  :parent_id => agent.id,
	  :parent_type => 'Agent',
	  :email => $installation.admin_email,
	  :password => 'password',
	  :role => 'admin',
	  :timezone => -5
	})
	Notification.notify(Notification::CREATED, { :subject => agent })
  end
end
