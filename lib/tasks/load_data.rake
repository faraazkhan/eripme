namespace :db do
    desc <<-DESC
        Load testing data.
        Run using the command 'rake db:load_demo_data'
        DESC
    task :load_demo_data => [:environment] do
      system("mysql -u root eripme_development < /Users/faraaz/Desktop/eripme_production_data.sql")
    end
end
