class Package < ActiveRecord::Base
  has_many :customers
  has_and_belongs_to_many :coverages
  attr_accessible :package_name, :single_price, :condo_price, :duplex_price, :triplex_price, :fourplex_price
  
  HOME_TYPES = ['single', 'condo', 'duplex', 'triplex', 'fourplex'].freeze
  @@home_type_names = {
    'single' => "Single-Family",
    'condo'  => 'Condominium',
    'duplex' => '2-Family',
    'triplex' => '3-Family',
    'fourplex' => '4-Family'
  }
  def self.home_type_names; @@home_type_names; end
  
  def covers
    self.coverages.collect(&:coverage_name).join(', ')
  end
end
