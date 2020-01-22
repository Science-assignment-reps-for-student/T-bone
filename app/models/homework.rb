class Homework < ApplicationRecord
  has_many :teams
  has_one :notice_file
  has_one :single_file
  has_one :multi_file
end
