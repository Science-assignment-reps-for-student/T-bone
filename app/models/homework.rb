class Homework < ApplicationRecord
  has_many :teams
  has_many :notice_files, dependent: :delete_all
  has_many :single_files
  has_many :multi_files
  has_one :excel_file
  has_many :self_evaluations
  has_many :mutual_evaluations
end
