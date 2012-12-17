class Coverage < ActiveRecord::Base
  scope :all_optional, :conditions => ['optional = 1']
  scope :for_packages, { :conditions => ['optional = 0'], :order => 'coverage_name' }
  
  has_and_belongs_to_many :packages
  
  attr_accessor :should_be_deleted # Only used for the CRUD form in /admin/packages
  
  def to_s
    "#{self.coverage_name} $%.2f" % self.price
  end
  
  def self.reload_defaults!
    Coverage.destroy_all
    coverages = ActiveSupport::JSON.decode(File.read("#{RAILS_ROOT}/app/models/defaults/coverages.json"))
    coverages.each do |object|
      coverage = Coverage.create(object['coverage'])
      puts "  #{coverage.coverage_name}...Created"
    end
  end
  
  def notification_summary
    "#{self.coverage_name} Coverage"
  end
  
  def edit_url
    "/admin/packages"
  end
end
