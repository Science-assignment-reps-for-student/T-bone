class User < ApplicationRecord
  has_many :single_files, dependent: :delete_all
  has_many :self_evaluations, dependent: :delete_all
  has_many :mutual_evaluations, dependent: :delete_all\
end
