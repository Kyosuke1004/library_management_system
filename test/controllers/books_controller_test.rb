require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @book = Book.create!(
      title: 'テスト本',
      isbn: '1234567890',
      published_year: 2024,
      publisher: 'テスト出版'
    )
    @author = Author.create!(name: 'テスト著者')
  end

  # Index アクションのテスト
  test 'should get index' do
    get books_url
    assert_response :success
    assert_includes response.body, @book.title
  end

  # Show アクションのテスト
  test 'should show book' do
    get book_url(@book)
    assert_response :success
    assert_includes response.body, @book.title
    assert_includes response.body, @book.isbn
  end

  # New アクションのテスト
  test 'should get new' do
    get new_book_url
    assert_response :success
    assert_includes response.body, '新しい本を登録'
  end

  # Create アクションのテスト
  test 'should create book' do
    assert_difference('Book.count') do
      post books_url, params: {
        book: {
          title: '新しい本',
          isbn: '9876543210',
          published_year: 2023,
          publisher: '新出版社',
          author_ids: [@author.id]
        }
      }
    end
    assert_redirected_to book_url(Book.last)
  end

  test 'should create book with new author' do
    assert_difference(['Book.count', 'Author.count']) do
      post books_url, params: {
        book: {
          title: '新しい本',
          isbn: '9876543210',
          published_year: 2023,
          publisher: '新出版社',
          new_author_name: '新著者'
        }
      }
    end
    assert_redirected_to book_url(Book.last)
    assert_includes Book.last.authors.map(&:name), '新著者'
  end

  # Edit アクションのテスト
  test 'should get edit' do
    get edit_book_url(@book)
    assert_response :success
    assert_includes response.body, @book.title
  end

  # Update アクションのテスト
  test 'should update book' do
    patch book_url(@book), params: {
      book: {
        title: '更新されたタイトル',
        isbn: @book.isbn,
        published_year: @book.published_year,
        publisher: @book.publisher,
        author_ids: [@author.id]
      }
    }
    assert_redirected_to book_url(@book)
    @book.reload
    assert_equal '更新されたタイトル', @book.title
  end

  test 'should update book with new author' do
    assert_difference('Author.count') do
      patch book_url(@book), params: {
        book: {
          title: @book.title,
          isbn: @book.isbn,
          published_year: @book.published_year,
          publisher: @book.publisher,
          author_ids: [@author.id],
          new_author_name: '追加著者'
        }
      }
    end
    assert_redirected_to book_url(@book)
    @book.reload
    assert_includes @book.authors.map(&:name), '追加著者'
  end

  # Destroy アクションのテスト
  test 'should destroy book' do
    assert_difference('Book.count', -1) do
      delete book_url(@book)
    end
    assert_redirected_to books_url
  end

  # 無効なデータのテスト
  test 'should not create book with invalid data' do
    assert_no_difference('Book.count') do
      post books_url, params: {
        book: {
          title: '', # タイトルが空
          isbn: '',
          published_year: nil,
          publisher: ''
        }
      }
    end
    assert_response :unprocessable_content
  end

  test 'should not update book with invalid data' do
    patch book_url(@book), params: {
      book: {
        title: '', # タイトルが空
        isbn: @book.isbn,
        published_year: @book.published_year,
        publisher: @book.publisher
      }
    }
    assert_response :unprocessable_content
  end

  # 複数著者のテスト
  test 'should create book with multiple authors' do
    author2 = Author.create!(name: '著者2')
    post books_url, params: {
      book: {
        title: '複数著者本',
        isbn: '1111111111',
        published_year: 2024,
        publisher: 'テスト出版',
        author_ids: [@author.id, author2.id]
      }
    }
    assert_equal 2, Book.last.authors.count
  end

  # 貸出状況表示のテスト
  test 'should show availability status' do
    get book_url(@book)
    assert_includes response.body, '貸出可能'
  end

  # 404エラーのテスト
  test 'should return 404 for non-existent book' do
    get book_url(99_999)
    assert_response :not_found
  end
end
