json.extract! src_review, :id, :src_id, :name, :url, :description, :created_at, :updated_at
json.url src_review_url(src_review, format: :json)
