require 'net/http'
require 'uri'
require 'json'

class GoogleBooksService
  API_ENDPOINT = 'https://www.googleapis.com/books/v1/volumes'

  def self.fetch_by_isbn(isbn)
    response = request_api(isbn)
    return unless response.is_a?(Net::HTTPSuccess)

    parse_response(response)
  end

  def self.request_api(isbn)
    api_key = ENV.fetch('GOOGLE_BOOKS_API_KEY', nil)
    url = "#{API_ENDPOINT}?q=isbn:#{isbn}&key=#{api_key}"
    Rails.logger.info("Google Books APIリクエストURL: #{url}")
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # SSL証明書の設定
    http.ca_file = '/opt/homebrew/etc/ca-certificates/cert.pem'
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Get.new(uri.request_uri)
    request['User-Agent'] = 'curl/7.64.1'
    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.warn("Google Books APIレスポンス: code=#{response.code}, message=#{response.message}, body=#{response.body}")
    end
    response
  end

  def self.parse_response(response)
    json = JSON.parse(response.body)
    item = json['items']&.first
    if item
      info = item['volumeInfo']
      {
        title: info['title'],
        authors: info['authors'],
        published_date: info['publishedDate'],
        image_url: info.dig('imageLinks', 'thumbnail')
      }
    else
      Rails.logger.warn("Google Books API request failed: #{response.code} #{response.message}")
      nil
    end
  end
end
