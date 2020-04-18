class Comment < ApplicationRecord
  belongs_to :board
  belongs_to :user
  has_many :cocomments, dependent: :delete_all
end
