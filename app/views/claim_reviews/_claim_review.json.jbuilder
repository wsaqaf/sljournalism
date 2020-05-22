json.extract! claim_review, :id, :src_id, :title, :url, :description, :created_at, :updated_at
json.url claim_review_url(claim_review, format: :json)
