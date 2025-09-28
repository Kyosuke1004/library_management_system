require 'test_helper'

class BookItemTest < ActiveSupport::TestCase
  fixtures :books, :book_items, :users

  def setup
    @book = books(:book)
    @user = users(:user)
    @book_item = book_items(:book_item1)
  end

  test 'should belong to book' do
    assert_equal @book, @book_item.book
  end

  test 'can create loan for book_item' do
    loan = Loan.create!(user: @user, book_item: @book_item, borrowed_at: Time.current)
    assert_includes @book_item.loans, loan
  end

  test 'book_item is not available when currently borrowed' do
    Loan.create!(user: @user, book_item: @book_item, borrowed_at: Time.current)
    assert @book_item.loans.currently_borrowed.any?
  end

  test 'book_item is available after return' do
    loan = Loan.create!(user: @user, book_item: @book_item, borrowed_at: Time.current)
    loan.update!(returned_at: Time.current)
    assert @book_item.loans.currently_borrowed.empty?
  end

  test 'destroying book_item destroys associated loans' do
    Loan.delete_all
    loan = Loan.create!(user: @user, book_item: @book_item, borrowed_at: Time.current)
    assert_difference('Loan.count', -1) do
      @book_item.destroy
    end
    assert_nil Loan.find_by(id: loan.id)
  end
end
