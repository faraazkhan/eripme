class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    debugger
    case user.role
    when "admin"
      can :manage, :all
    when "contractor"
      can :manage, Repair
    when "customer"
      can :manage, Customer
      can :manage, EmailTemplate
      can :manage, Notification
      can :manage, Package
      can :manage, Content
      can :manage, Transaction
      can :manage, Discount
      can :manage, Note
    end
  end
end
