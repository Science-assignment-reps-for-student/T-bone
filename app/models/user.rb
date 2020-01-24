class User < ApplicationRecord
  has_one :code
  has_many :homework
  has_many :teams
  has_many :single_files
  has_many :chats
  has_one :self_evaluation
  has_many :mutual_evaluations
end
