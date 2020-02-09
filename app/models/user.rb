class User < ApplicationRecord
  has_many :single_files
  has_many :chats
  has_many :self_evaluations
  has_many :mutual_evaluations
end
