require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: 'user@example.com',
                     password: 'foobar', password_confirmation: 'foobar')
  end

  # バリデーションテスト
  test 'should be valid' do
    assert @user.valid?
  end

  test 'email should be present' do
    @user.email = ''
    assert_not @user.valid?
  end

  test 'password should be present' do
    @user.password = ''
    assert_not @user.valid?
  end

  test 'password confirmation should match password' do
    @user.password_confirmation = 'different'
    assert_not @user.valid?
  end

  test 'email should be unique' do
    @user.save!
    duplicate_user = @user.dup
    assert_not duplicate_user.valid?
  end

  test 'password should be at least 6 characters' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end
end

# 関連付けテスト用の別クラス
class UserAssociationTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: 'user@example.com',
                     password: 'foobar', password_confirmation: 'foobar')
    @book = Book.new(title: 'テスト本', isbn: '1234567890', published_year: 2024, publisher: 'テスト出版')
    @user.save!
    @book.save!
    @loan = @user.loans.create!(book: @book, borrowed_at: Time.current)
  end

  test 'should have many loans' do
    assert_includes @user.loans, @loan
  end

  test 'should have many books through loans' do
    assert_includes @user.books, @book
  end

  test 'should destroy associated loans when user is destroyed' do
    assert_difference 'Loan.count', -1 do
      @user.destroy
    end
  end
end
