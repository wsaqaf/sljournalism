class MediumPolicy < ApplicationPolicy
  attr_reader :user, :medium

  def initialize(user, medium)
    @user = user
    @medium = medium
  end

  def create?
    user.role!='admin' || user.role!='client'
  end

  def update?
    user.role!='admin' || user.role!='client'
  end

end
