class Team < ApplicationRecord
  belongs_to :user
  belongs_to :homework
  has_many :members
  has_one :multi_file
end
