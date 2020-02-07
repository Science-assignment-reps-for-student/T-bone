class Homework < ApplicationRecord
  has_many :teams
  has_many :notice_files, dependent: :delete_all
  has_many :single_files, dependent: :delete_all
  has_many :multi_files, dependent: :delete_all
  has_one :excel_file, dependent: :delete
  has_many :self_evaluations, dependent: :delete_all
  has_many :mutual_evaluations, dependent: :delete_all
end
