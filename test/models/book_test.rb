require 'test_helper'

class BookBaseTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: 'test@example.com',
                         password: 'password')
    @auth = Author.create!(name: 'テスト著者')
    @book = Book.create!(title: 'テスト本',
                         isbn: '1234567890',
                         published_year: 2024,
                         publisher: 'テスト出版',
                         authors: [@auth])
  end
end

class BookTest < BookBaseTest
  test 'should be valid' do
    assert @book.valid?
  end
end

class BookAssociationTest < BookBaseTest
  def setup
    super
    @loan = @book.loans.create!(user: @user, borrowed_at: Time.current)
  end

  test 'should have many loans' do
    assert_includes @book.loans, @loan
  end

  test 'should have many users through loans' do
    assert_includes @book.users, @user
  end

  test 'should destroy associated loans when book is destroyed' do
    assert_difference 'Loan.count', -1 do
      @book.destroy
    end
  end
end

class BookAuthorAssociationTest < BookBaseTest
  test 'should have many authorships' do
    assert @book.authorships.any?
  end

  test 'should have many authors through authorships' do
    assert_includes @book.authors, @auth
  end

  test 'should destroy associated authorships when book is destroyed' do
    assert_difference 'Authorship.count', -1 do
      @book.destroy
    end
  end
end

class BookAvailabilityTest < BookBaseTest
  test 'available? should return true when no current loans' do
    assert @book.available?
  end

  test 'available? should return false when currently borrowed' do
    @book.loans.create!(user: @user, borrowed_at: Time.current)
    assert_not @book.available?
  end

  test 'available? should return true when book was returned' do
    @book.loans.create!(user: @user, borrowed_at: 1.week.ago, returned_at: 1.day.ago)
    assert @book.available?
  end
end
