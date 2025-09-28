class Loan < ApplicationRecord
  belongs_to :user
  belongs_to :book_item

  validates :borrowed_at, presence: true

  validate :no_duplicate_current_loan, on: :create

  scope :currently_borrowed, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }

  private

  def no_duplicate_current_loan
    return unless book_item && Loan.where(book_item: book_item, returned_at: nil).exists?

    errors.add(:book_item, 'は現在貸出中です')
  end
end
