class Homework < ApplicationRecord
  belongs_to :user
  has_many :teams
  has_many :notice_files
  has_many :single_files
  has_many :multi_files
  has_one :excel_file
  has_many :self_evaluations
  has_many :mutual_evaluations
end
