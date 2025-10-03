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
    uri = URI.parse(url)
    Net::HTTP.get_response(uri)
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
