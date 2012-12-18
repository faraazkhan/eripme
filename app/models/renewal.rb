class Renewal < ActiveRecord::Base
  belongs_to :customer
  attr_accessible :starts_at, :ends_at, :amount, :years
  
  def edit_url
  end
  
  def notification_summary
    "#{self.duration} Year Contract Renewal for #{self.customer.notification_summary}"
  end
  
  def as_json(a=nil,b=nil)
    {
      :id => self.id,
      :starts => self.starts,
      :ends => self.ends,
      :formatted_duration => self.formatted_duration,
      :formatted_amount => self.formatted_amount
    }
  end
  
  def formatted_amount
    "$%.2f" % self.amount.to_f
  end
  
  def starts
    self.starts_at.strftime('%m/%d/%Y') if self.starts_at
  end
  
  def ends
    self.ends_at.strftime('%m/%d/%Y') if self.ends_at
  end
  
  def formatted_duration
    "#{self.duration} Year#{'s' if self.duration > 1}"
  end
  
  def duration
    return 0 if (self.years.nil? || self.years == 0) && (self.ends_at.nil? || self.starts_at.nil?)
    (self.years || 0) > 0 ? self.years : (self.ends_at.jd - self.starts_at.jd).abs / 365
  end
end
