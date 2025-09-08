class Loan < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :borrowed_at, presence: true

  scope :currently_borrowed, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }
end
