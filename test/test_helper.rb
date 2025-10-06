ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    self.use_transactional_tests = true

    # Google Books APIスタブ用ヘルパー
    def stub_google_books_api
      stub_request(:get, /www.googleapis.com/).to_return(
        status: 200,
        body: {
          items: [
            {
              volumeInfo: {
                title: 'ダミー本',
                authors: ['ダミー著者'],
                imageLinks: { thumbnail: 'https://dummy.example.com/image.jpg' }
              }
            }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

# WebMock有効化
require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)
