# frozen_string_literal: true

# app/models/influencer.rb
class Influencer < ApplicationRecord
  belongs_to :follower, optional: true # Temporary solution

  has_many :influencer_mails, dependent: :destroy
  has_many :mailings, through: :influencer_mails

  has_many :influencer_categories, dependent: :destroy
  has_many :categories, through: :influencer_categories
  has_many :nodes,      through: :influencer_categories

  validates :username, uniqueness: true
  validates :username, :followers_count, :following_count, presence: true

  mount_uploader :photo, PhotoUploader

  scope :validated, -> { where("email <> '' AND media_score > 50 AND engagement_rate < 9") }
  # scope :validated, -> { where('media_score > 50 AND engagement_rate < 9') }
  # scope :has_email, -> { where.not(email: '' || nil) }

  def instagram_path
    "http://www.instagram.com/#{username}"
  end

  def follow_ratio
    followers_count / following_count.to_f
  end

  def name
    full_name.empty? ? username : full_name
  end

  def json
    follower.json
  end

  def parse_email
    ParseService.email(self)
  end

  def update_photo
    self.remote_photo_url = ig_pic_url
    save
  rescue Cloudinary::CarrierWave::UploadError => exs
    p exs.to_s
    follower.visit
    follower.promote!
    reload
    retry
  rescue CloudinaryException => exs
    p exs.to_s
    p 'Waiting 2 seconds to retry'
    sleep 2
    retry
  end

  def reparse!
    parse_email
    follower.promote!
  end

  def parse_engagement_rate
    update(engagement_rate: media_score / followers_count.to_f * 100.0)
  end

  def self.search(params)
    # search_result = order(followers_count: :DESC)
    params[:min_f] = 5_000 unless params[:min_f].present?
    params[:max_f] = 5_000_000 unless params[:max_f].present?
    search_result = order(media_score: :DESC)
    search_result = search_result.joins(:categories).where(categories: {id: params[:categories]}).distinct if params[:categories].present?
    search_result = search_result.where('followers_count BETWEEN ? AND ?', params[:min_f], params[:max_f])
    search_result
  end
end
# > ? && following_count < ?
# > ? && followers_count < ?
