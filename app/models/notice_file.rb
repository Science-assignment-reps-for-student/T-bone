class NoticeFile < ApplicationRecord
  belongs_to :homework, dependent: :destroy
end
