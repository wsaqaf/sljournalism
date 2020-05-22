class ClaimReviewPolicy < ApplicationPolicy
  attr_reader :user, :claim_review

  def initialize(user, claim_review)
    @user = user
    @claim_review = claim_review
  end

  def create?
    user.role!='admin' || user.role!='factchecker'
  end

  def update?
    user.role!='admin' || user.role!='factchecker'
  end

end
