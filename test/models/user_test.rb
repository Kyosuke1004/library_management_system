require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: 'user@example.com',
                     password: 'foobar', password_confirmation: 'foobar')
  end
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
    @user.save
    user2 = User.new(email: @user.email, password: 'foobar', password_confirmation: 'foobar')
    assert_not user2.valid?
  end

  test 'password should be at least 6 characters' do
    @user.password = @user.password_confirmation = '123'
    assert_not @user.valid?
  end
end
