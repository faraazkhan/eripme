namespace :customer do
  desc "Set data on the Customer model"
  task :touch => :environment do
  c = Customer.all
  c.each do |customer|
    customer.save!
  end
end
end
