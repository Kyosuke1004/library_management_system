require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @author = Author.create!(name: 'テスト著者')
    @book = Book.create!(
      title: 'テスト本',
      isbn: '1234567890',
      published_year: 2024,
      publisher: 'テスト出版',
      authors: [@author]
    )
    @user = User.create!(email: 'test@example.com', password: 'password')

    # 検索テスト用データを追加
    @author_yamada = Author.create!(name: '山田太郎')
    @author_tanaka = Author.create!(name: '田中花子')

    @ruby_book = Book.create!(
      title: 'Ruby on Rails入門',
      isbn: '1111111111',
      published_year: 2024,
      publisher: 'プログラミング出版',
      authors: [@author_yamada]
    )

    @java_book = Book.create!(
      title: 'Java基礎講座',
      isbn: '2222222222',
      published_year: 2023,
      publisher: 'テクノロジー出版',
      authors: [@author_tanaka]
    )
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

  # New アクションのテスト（認証あり）
  test 'should get new with authentication' do
    sign_in @user
    get new_book_url
    assert_response :success
    assert_includes response.body, '新しい本を登録'
  end

  # Create アクションのテスト
  test 'should create book' do
    sign_in @user
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
    sign_in @user
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

  test 'should create book with multiple authors' do
    sign_in @user
    author2 = Author.create!(name: '著者2')
    assert_difference('Book.count') do
      post books_url, params: {
        book: {
          title: '複数著者本',
          isbn: '1111111111',
          published_year: 2024,
          publisher: 'テスト出版',
          author_ids: [@author.id, author2.id]
        }
      }
    end
    assert_equal 2, Book.last.authors.count
  end

  # Edit アクションのテスト
  test 'should get edit' do
    sign_in @user
    get edit_book_url(@book)
    assert_response :success
    assert_includes response.body, @book.title
  end

  # Update アクションのテスト
  test 'should update book' do
    sign_in @user
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
    sign_in @user
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
    sign_in @user
    assert_difference('Book.count', -1) do
      delete book_url(@book)
    end
    assert_redirected_to books_url
  end

  # 無効なデータのテスト
  test 'should not create book with invalid data' do
    sign_in @user
    assert_no_difference('Book.count') do
      post books_url, params: {
        book: {
          title: '',
          isbn: '',
          published_year: nil,
          publisher: ''
        }
      }
    end
    assert_response :unprocessable_content
  end

  test 'should not update book with invalid data' do
    sign_in @user
    patch book_url(@book), params: {
      book: {
        title: '',
        isbn: @book.isbn,
        published_year: @book.published_year,
        publisher: @book.publisher
      }
    }
    assert_response :unprocessable_content
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

  # === 認証テスト ===

  # 未ログインユーザーのアクセステスト
  test 'should get index without login' do
    get books_url
    assert_response :success
  end

  test 'should show book without login' do
    get book_url(@book)
    assert_response :success
  end

  test 'should redirect to login for new without authentication' do
    get new_book_url
    assert_redirected_to new_user_session_path
  end

  test 'should redirect to login for create without authentication' do
    post books_url, params: {
      book: {
        title: '新しい本',
        isbn: '9876543210',
        published_year: 2023,
        publisher: '新出版社'
      }
    }
    assert_redirected_to new_user_session_path
  end

  test 'should redirect to login for edit without authentication' do
    get edit_book_url(@book)
    assert_redirected_to new_user_session_path
  end

  test 'should redirect to login for update without authentication' do
    patch book_url(@book), params: {
      book: {
        title: '更新されたタイトル',
        isbn: @book.isbn,
        published_year: @book.published_year,
        publisher: @book.publisher
      }
    }
    assert_redirected_to new_user_session_path
  end

  test 'should redirect to login for destroy without authentication' do
    delete book_url(@book)
    assert_redirected_to new_user_session_path
  end

  # === 検索機能のテスト ===
  test 'should search books by title' do
    get books_path, params: { search: 'Ruby' }
    assert_response :success
    assert_select 'td', text: 'Ruby on Rails入門'
    assert_select 'td', text: 'Java基礎講座', count: 0
  end

  test 'should search books by author name' do
    get books_path, params: { search: '山田' }
    assert_response :success
    assert_select 'td', text: 'Ruby on Rails入門'
    assert_select 'td', text: 'Java基礎講座', count: 0
  end

  test 'should search case insensitively' do
    get books_path, params: { search: 'ruby' }
    assert_response :success
    assert_select 'td', text: 'Ruby on Rails入門'
  end

  test 'should show all books when no search parameter' do
    get books_path
    assert_response :success
    assert_select 'td', text: 'テスト本'
    assert_select 'td', text: 'Ruby on Rails入門'
    assert_select 'td', text: 'Java基礎講座'
  end

  test 'should show search results count' do
    get books_path, params: { search: '山田' }
    assert_response :success
    assert_select 'p', text: '「山田」の検索結果: 1件'
  end
end
