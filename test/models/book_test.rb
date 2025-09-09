require 'test_helper'

class BookTest < ActiveSupport::TestCase
  def setup
    @book = Book.new(title: 'テスト本', isbn: '1234567890', published_year: 2024, publisher: 'テスト出版')
  end

  # バリデーションテスト
  test 'should be valid' do
    assert @book.valid?
  end
end

# BookとLoanの関連付けテスト
class BookAssociationTest < ActiveSupport::TestCase
  def setup
    @book = Book.new(title: 'テスト本', isbn: '1234567890', published_year: 2024, publisher: 'テスト出版')
    @user = User.new(email: 'test@example.com', password: 'password')
    @book.save!
    @user.save!
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

# 著者関連のテスト
class BookAuthorAssociationTest < ActiveSupport::TestCase
  def setup
    @book = Book.new(title: 'テスト本', isbn: '1234567890', published_year: 2024, publisher: 'テスト出版')
    @author = Author.new(name: 'テスト著者')
    @book.save!
    @author.save!
    @authorship = @book.authorships.create!(author: @author)
  end

  test 'should have many authorships' do
    assert_includes @book.authorships, @authorship
  end

  test 'should have many authors through authorships' do
    assert_includes @book.authors, @author
  end

  test 'should destroy associated authorships when book is destroyed' do
    assert_difference 'Authorship.count', -1 do
      @book.destroy
    end
  end
end

# available? メソッドテスト
class BookAvailabilityTest < ActiveSupport::TestCase
  def setup
    @book = Book.new(title: 'テスト本', isbn: '1234567890', published_year: 2024, publisher: 'テスト出版')
    @user = User.new(email: 'test@example.com', password: 'password')
    @book.save!
    @user.save!
  end

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
