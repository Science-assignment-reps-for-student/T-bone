class User < ApplicationRecord
  has_one :code
  has_many :teams
  has_many :single_files
  has_many :chats
  has_many :self_evaluations
  has_many :mutual_evaluations
end
