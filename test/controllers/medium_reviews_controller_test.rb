require 'test_helper'

class MediumReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @medium_review = medium_reviews(:one)
  end

  test "should get index" do
    get medium_reviews_url
    assert_response :success
  end

  test "should get new" do
    get new_medium_review_url
    assert_response :success
  end

  test "should create medium_review" do
    assert_difference('MediumReview.count') do
      post medium_reviews_url, params: { medium_review: { description: @medium_review.description, medium_id: @medium_review.medium_id, name: @medium_review.name, url: @medium_review.url } }
    end

    assert_redirected_to medium_review_url(MediumReview.last)
  end

  test "should show medium_review" do
    get medium_review_url(@medium_review)
    assert_response :success
  end

  test "should get edit" do
    get edit_medium_review_url(@medium_review)
    assert_response :success
  end

  test "should update medium_review" do
    patch medium_review_url(@medium_review), params: { medium_review: { description: @medium_review.description, medium_id: @medium_review.medium_id, name: @medium_review.name, url: @medium_review.url } }
    assert_redirected_to medium_review_url(@medium_review)
  end

  test "should destroy medium_review" do
    assert_difference('MediumReview.count', -1) do
      delete medium_review_url(@medium_review)
    end

    assert_redirected_to medium_reviews_url
  end
end
