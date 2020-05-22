class SrcPolicy < ApplicationPolicy
  attr_reader :user, :src

  def initialize(user, src)
    @user = user
    @src = src
  end

  def create?
    user.role!='admin' || user.role!='client'
  end

  def update?
    user.role!='admin' || user.role!='client'
  end

end
