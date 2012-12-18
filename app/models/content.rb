class Content < ActiveRecord::Base
  attr_accessible :slug, :html
  set_table_name 'content'

  def self.for(slug)
    c = Content.find_by_slug(slug.to_s)
    c ? c.html : "No such slug - #{slug}"
  end
end
