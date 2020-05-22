json.extract! medium_review, :id, :medium_id, :name, :url, :description, :created_at, :updated_at
json.url medium_review_url(medium_review, format: :json)
