require 'test_helper'

class BookBaseTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: 'test@example.com', password: 'password')
    @auth = Author.create!(name: 'テスト著者')
    @book = Book.new(title: 'テスト本',
                     isbn: '1234567890',
                     published_year: 2024,
                     publisher: 'テスト出版',
                     authors: [@auth],
                     tag_names: "タグ_#{SecureRandom.hex(4)}")
    @book.save!
  end
end

class BookTest < BookBaseTest
  test 'should be valid' do
    assert @book.valid?
  end

  test 'should have many book_items' do
    item1 = @book.book_items.create!
    item2 = @book.book_items.create!
    assert_includes @book.book_items, item1
    assert_includes @book.book_items, item2
    assert_equal 2, @book.book_items.count
  end

  test 'should destroy associated book_items when book is destroyed' do
    @book.book_items.create!
    @book.book_items.create!
    assert_difference 'BookItem.count', -2 do
      @book.destroy
    end
  end

  test 'should not be valid without authors' do
    book = Book.new(title: 'No Author Book', isbn: '9999999999', published_year: 2024, publisher: 'テスト出版', authors: [])
    assert_not book.valid?
  end

  test 'adjust_book_items_stock increases book_items when stock_count is increased' do
    @book.stock_count = 3
    @book.save!
    assert_equal 3, @book.book_items.count
  end

  test 'adjust_book_items_stock decreases book_items when stock_count is decreased' do
    5.times { @book.book_items.create! }
    @book.stock_count = 2
    @book.save!
    assert_equal 2, @book.book_items.count
  end

  test 'adjust_book_items_stock does not delete borrowed book_items' do
    item1 = @book.book_items.create!
    item2 = @book.book_items.create!
    Loan.create!(user: @user, book_item: item1, borrowed_at: Time.current)
    @book.stock_count = 1
    @book.save!
    assert_equal 1, @book.book_items.count
    assert @book.book_items.exists?(item1.id)
  end
end

class BookAssociationTest < BookBaseTest
  def setup
    super
    @book_item = @book.book_items.create!
    @loan = Loan.create!(user: @user, book_item: @book_item, borrowed_at: Time.current)
  end

  test 'should have many loans' do
    loans = @book.book_items.flat_map(&:loans)
    assert_includes loans, @loan
  end

  test 'should have many users through loans' do
    users = @book.book_items.flat_map { |item| item.loans.map(&:user) }
    assert_includes users, @user
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
  def setup
    super
    @book_item = @book.book_items.create!
  end
  test 'available? should return true when no current loans' do
    assert @book.available?
  end

  test 'available? should return false when currently borrowed' do
    Loan.create!(user: @user, book_item: @book_item, borrowed_at: Time.current)
    assert_not @book.available?
  end

  test 'available? should return true when book was returned' do
    Loan.create!(user: @user, book_item: @book_item, borrowed_at: 1.week.ago, returned_at: 1.day.ago)
    assert @book.available?
  end
end
