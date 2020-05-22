class ResourcePolicy < ApplicationPolicy
  attr_reader :user, :resource

  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  def create?
    user.role!='admin'
  end

  def update?
    user.role!='admin'
  end

end
