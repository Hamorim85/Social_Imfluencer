# frozen_string_literal: true

# app/models/node.rb
class Node < ApplicationRecord
  has_many :influencer_categories
  has_many :influencers, through: :influencer_categories
  has_many :follower_nodes
  has_many :followers, through: :follower_nodes
  has_many :node_categories
  has_many :categories, through: :node_categories
  validates :name, :igid, uniqueness: true, presence: true
end
