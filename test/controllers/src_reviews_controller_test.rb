require 'test_helper'

class SrcReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @src_review = src_reviews(:one)
  end

  test "should get index" do
    get src_reviews_url
    assert_response :success
  end

  test "should get new" do
    get new_src_review_url
    assert_response :success
  end

  test "should create src_review" do
    assert_difference('SrcReview.count') do
      post src_reviews_url, params: { src_review: { description: @src_review.description, name: @src_review.name, src_id: @src_review.src_id, url: @src_review.url } }
    end

    assert_redirected_to src_review_url(SrcReview.last)
  end

  test "should show src_review" do
    get src_review_url(@src_review)
    assert_response :success
  end

  test "should get edit" do
    get edit_src_review_url(@src_review)
    assert_response :success
  end

  test "should update src_review" do
    patch src_review_url(@src_review), params: { src_review: { description: @src_review.description, name: @src_review.name, src_id: @src_review.src_id, url: @src_review.url } }
    assert_redirected_to src_review_url(@src_review)
  end

  test "should destroy src_review" do
    assert_difference('SrcReview.count', -1) do
      delete src_review_url(@src_review)
    end

    assert_redirected_to src_reviews_url
  end
end
