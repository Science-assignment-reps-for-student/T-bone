class Team < ApplicationRecord
  belongs_to :homework
  has_many :members
  has_many :multi_files
end
