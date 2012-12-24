class Content < ActiveRecord::Base
  attr_accessible :slug, :html
  set_table_name 'content'

  def self.for(slug)
    c = Content.find_by_slug(slug.to_s)
    c ? c.html : "No such slug - #{slug}"
  end

   def self.for_navigation_step(step_num=nil)
    if step_num
      text_with_commas = Content.for(:quote_wizard)
      text = text_with_commas.split(',') if text_with_commas
      text[step_num-1]|| 'Text Not Available' if step_num
    end
  end
end
