class Board < ApplicationRecord
  has_many :image_files, dependent: :delete_all
  has_many :comments, dependent: :delete_all
  belongs_to :user
end
