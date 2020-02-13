class Team < ApplicationRecord
  belongs_to :homework
  has_many :members, dependent: :delete_all
  has_many :multi_files, dependent: :delete_all
end
