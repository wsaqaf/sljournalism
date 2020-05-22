class ClaimPolicy < ApplicationPolicy
  attr_reader :user, :claim

  def initialize(user, claim)
    @user = user
    @claim = claim
  end

  def create?
    user.role!='admin' || user.role!='client'
  end

  def update?
    user.role!='admin' || user.role!='client'
  end

end
