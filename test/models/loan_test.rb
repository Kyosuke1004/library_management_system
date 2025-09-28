require 'test_helper'

class LoanTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: 'test@example.com', password: 'password')
    @auth = Author.create!(name: 'テスト著者')
    @book = Book.create!(title: 'テスト本', isbn: '1234567890', published_year: 2024, publisher: 'テスト出版', authors: [@auth])
    @book_item = BookItem.create!(book: @book)
    @loan = Loan.new(user: @user, book_item: @book_item, borrowed_at: Time.current)
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

  test 'currently_borrowed scope should return loans without returned_at' do
    @loan.save!

    # 別のユーザーと別の本で返却済みのloanを作成
    user2 = User.create!(email: 'user2@example.com', password: 'password')
    author2 = Author.create!(name: 'テスト著者2')
    book2 = Book.create!(title: 'テスト本2', isbn: '0987654321', published_year: 2023, publisher: 'テスト出版2',
                         authors: [author2])
    book_item2 = BookItem.create!(book: book2)
    returned_loan = Loan.create!(
      user: user2,
      book_item: book_item2,
      borrowed_at: 1.week.ago,
      returned_at: 1.day.ago
    )

    currently_borrowed = Loan.currently_borrowed
    assert_includes currently_borrowed, @loan
    assert_not_includes currently_borrowed, returned_loan
  end

  test 'returned scope should return loans with returned_at' do
    @loan.save!

    # 別のユーザーと別の本で返却済みのloanを作成
    user2 = User.create!(email: 'user3@example.com', password: 'password')
    author3 = Author.create!(name: 'テスト著者3')
    book3 = Book.create!(title: 'テスト本3', isbn: '1122334455', published_year: 2022, publisher: 'テスト出版3',
                         authors: [author3])
    book_item3 = BookItem.create!(book: book3)
    returned_loan = Loan.create!(
      user: user2,
      book_item: book_item3,
      borrowed_at: 1.week.ago,
      returned_at: 1.day.ago
    )

    returned_loans = Loan.returned
    assert_includes returned_loans, returned_loan
    assert_not_includes returned_loans, @loan
  end
end
