class Comment < ApplicationRecord
  belongs_to :board
  belongs_to :user
  has_many :cocoments, dependent: :delete_all
end
