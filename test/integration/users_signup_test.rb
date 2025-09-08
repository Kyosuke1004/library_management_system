require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'invalid signup information' do
    get new_user_registration_path
    assert_no_difference 'User.count' do
      post user_registration_path, params: { user: { email: 'user@invalid',
                                                     password: 'foo',
                                                     password_confirmation: 'bar' } }
    end
    assert_response :unprocessable_content
  end

  test 'valid signup information' do
    get new_user_registration_path
    assert_difference 'User.count', 1 do
      post user_registration_path, params: { user: { email: 'user@example.com',
                                                     password: 'password',
                                                     password_confirmation: 'password' } }
    end
    follow_redirect!
  end
end
