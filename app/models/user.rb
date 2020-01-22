class User < ApplicationRecord
  has_one :code
  has_many :teams
  has_many :members
  has_many :single_files
  has_many :chats
end
