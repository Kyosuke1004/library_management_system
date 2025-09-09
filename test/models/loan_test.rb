require 'test_helper'

class LoanTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: 'test@example.com', password: 'password')
    @book = Book.create!(title: 'テスト本', isbn: '1234567890', published_year: 2024, publisher: 'テスト出版')
    @loan = Loan.new(user: @user, book: @book, borrowed_at: Time.current)
  end

  test 'should be valid' do
    assert @loan.valid?
  end

  test 'borrowed_at should be present' do
    @loan.borrowed_at = nil
    assert_not @loan.valid?
  end

  test 'should belong to user' do
    @loan.user = nil
    assert_not @loan.valid?
  end

  test 'should belong to book' do
    @loan.book = nil
    assert_not @loan.valid?
  end

  test 'currently_borrowed scope should return loans without returned_at' do
    @loan.save!
    returned_loan = Loan.create!(
      user: @user,
      book: @book,
      borrowed_at: 1.week.ago,
      returned_at: 1.day.ago
    )

    currently_borrowed = Loan.currently_borrowed
    assert_includes currently_borrowed, @loan
    assert_not_includes currently_borrowed, returned_loan
  end

  test 'returned scope should return loans with returned_at' do
    @loan.save!
    returned_loan = Loan.create!(
      user: @user,
      book: @book,
      borrowed_at: 1.week.ago,
      returned_at: 1.day.ago
    )

    returned_loans = Loan.returned
    assert_includes returned_loans, returned_loan
    assert_not_includes returned_loans, @loan
  end
end
