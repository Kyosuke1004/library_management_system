require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :authors, :books

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @author = authors(:author)
    @book = books(:book)
    @ruby_book = books(:ruby_book)
    @java_book = books(:java_book)
    stub_google_books_api
  end

  # === 一般・管理者のアクセス権限テスト ===
  def sign_in_as(user)
    sign_in user
  end

  test '管理者は新規作成・編集・削除・著者追加ができる' do
    sign_in_as(@admin)
    get new_book_url
    assert_response :success

    assert_difference('Book.count') do
      post books_url,
           params: { book: { title: '新しい本', isbn: '9876543210', published_year: 2023, publisher: '新出版社',
                             author_ids: [@author.id] } }
    end
    assert_redirected_to book_url(Book.last)

    get edit_book_url(@book)
    assert_response :success

    patch book_url(@book),
          params: { book: { title: '更新タイトル',
                            isbn: @book.isbn,
                            published_year: @book.published_year,
                            publisher: @book.publisher,
                            author_ids: [@author.id], author_names: '追加著者' } }
    assert_redirected_to book_url(@book)
    @book.reload
    assert_equal '更新タイトル', @book.title
    assert_includes @book.authors.map(&:name), '追加著者'

    assert_difference('Book.count', -1) do
      delete book_url(@book)
    end
    assert_redirected_to books_url
  end

  test '一般ユーザーは新規作成・編集・削除画面にアクセスできない' do
    sign_in_as(@user)
    get new_book_url
    assert_redirected_to books_url
    follow_redirect!
    assert_match '管理者のみ操作可能です。', response.body

    get edit_book_url(@book)
    assert_redirected_to books_url
    follow_redirect!
    assert_match '管理者のみ操作可能です。', response.body
  end

  test '一般ユーザーは本の新規作成・編集・削除ができない' do
    sign_in_as(@user)
    assert_no_difference('Book.count') do
      post books_url,
           params: { book: { title: '新しい本', isbn: '9876543210', published_year: 2023, publisher: '新出版社',
                             author_ids: [@author.id] } }
    end
    assert_redirected_to books_url
    follow_redirect!
    assert_match '管理者のみ操作可能です。', response.body

    patch book_url(@book),
          params: { book: { title: '更新タイトル',
                            isbn: @book.isbn,
                            published_year: @book.published_year,
                            publisher: @book.publisher,
                            author_ids: [@author.id] } }
    assert_redirected_to books_url
    follow_redirect!
    assert_match '管理者のみ操作可能です。', response.body
    @book.reload
    assert_not_equal '更新タイトル', @book.title

    assert_no_difference('Book.count') do
      delete book_url(@book)
    end
    assert_redirected_to books_url
    follow_redirect!
    assert_match '管理者のみ操作可能です。', response.body
  end

  # === バリデーションテスト ===
  test 'should not create book with invalid data' do
    sign_in_as(@admin)
    assert_no_difference('Book.count') do
      post books_url, params: { book: { title: '', isbn: '', published_year: nil, publisher: '' } }
    end
    assert_response :unprocessable_content
  end

  test 'should not update book with invalid data' do
    sign_in_as(@admin)
    patch book_url(@book),
          params: { book: { title: '', isbn: @book.isbn, published_year: @book.published_year,
                            publisher: @book.publisher } }
    assert_response :unprocessable_content
  end

  # === 未ログインユーザーのアクセス制限 ===
  test 'should redirect to login for new/create/edit/update/destroy without authentication' do
    get new_book_url
    assert_redirected_to new_user_session_path

    post books_url, params: { book: { title: '新しい本', isbn: '9876543210', published_year: 2023, publisher: '新出版社' } }
    assert_redirected_to new_user_session_path

    get edit_book_url(@book)
    assert_redirected_to new_user_session_path

    patch book_url(@book),
          params: { book: { title: '更新タイトル', isbn: @book.isbn, published_year: @book.published_year,
                            publisher: @book.publisher } }
    assert_redirected_to new_user_session_path

    delete book_url(@book)
    assert_redirected_to new_user_session_path
  end

  # === 検索機能のテスト ===
  test 'should search books by title' do
    get books_path, params: { search: 'Ruby' }
    assert_response :success
    assert_select 'h2.title', text: 'Ruby on Rails入門'
    assert_select 'h2.title', text: 'Java基礎講座', count: 0
  end

  test 'should search books by author name' do
    get books_path, params: { search: '山田' }
    assert_response :success
    assert_select 'h2.title', text: 'Ruby on Rails入門'
    assert_select 'h2.title', text: 'Java基礎講座', count: 0
  end

  test 'should search case insensitively' do
    get books_path, params: { search: 'ruby' }
    assert_response :success
    assert_select 'h2.title', text: 'Ruby on Rails入門'
  end

  test 'should show all books when no search parameter' do
    get books_path
    assert_response :success
    assert_select 'h2.title', text: 'テスト本'
    assert_select 'h2.title', text: 'Ruby on Rails入門'
    assert_select 'h2.title', text: 'Java基礎講座'
  end

  test 'should show search results count' do
    get books_path, params: { search: '山田' }
    assert_response :success
    assert_select 'p', text: '「山田」の検索結果: 1件'
  end

  # === その他のテスト ===
  test 'should show availability status' do
    get book_url(@book)
    assert_includes response.body, '貸出可能'
  end

  test 'should return 404 for non-existent book' do
    get book_url(99_999)
    assert_response :not_found
  end

  test 'should get index and show without login' do
    get books_url
    assert_response :success
    get book_url(@book)
    assert_response :success
  end

  # ストロングパラメータでrole属性が許可されていないことのテスト
  test 'should not allow role update via book params' do
    sign_in_as(@admin)
    original_role = @user.role
    patch book_url(@book),
          params: { book: { title: @book.title, isbn: @book.isbn, published_year: @book.published_year,
                            publisher: @book.publisher, author_ids: [@author.id], role: :admin } }
    @user.reload
    assert_equal original_role, @user.role, 'role should not be updated via book params'
  end
end
