require 'test_helper'

class BooksAuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: 'test@example.com', password: 'password')
    @author = Author.create!(name: 'テスト著者')
    @book = Book.create!(
      title: 'テスト本',
      isbn: '1234567890',
      published_year: 2024,
      publisher: 'テスト出版',
      authors: [@author]
    )
  end

  test 'unauthenticated user can browse books but cannot manage them' do
    # 1. 未ログインで書籍一覧にアクセス
    get books_path
    assert_response :success
    assert_match '図書一覧', response.body
    assert_match @book.title, response.body

    # 2. 詳細ページも見れる
    get book_path(@book)
    assert_response :success
    assert_match @book.title, response.body

    # 3. 新規作成を試みる → ログインページへ
    get new_book_path
    assert_redirected_to new_user_session_path

    # 4. 編集を試みる → ログインページへ
    get edit_book_path(@book)
    assert_redirected_to new_user_session_path

    # 5. 削除を試みる → ログインページへ
    delete book_path(@book)
    assert_redirected_to new_user_session_path
  end

  test 'authenticated user can manage books' do
    # 1. ログイン
    post user_session_path, params: {
      user: { email: @user.email, password: 'password' }
    }
    follow_redirect!

    # 2. 書籍一覧にアクセス
    get books_path
    assert_response :success
    assert_match '新しい本を登録', response.body # ログイン時のみ表示

    # 3. 新規作成ページにアクセス
    get new_book_path
    assert_response :success
    assert_match '新しい本を登録', response.body

    # 4. 実際に本を作成
    assert_difference 'Book.count' do
      post books_path, params: {
        book: {
          title: '新しいテスト本',
          isbn: '9876543210',
          published_year: 2023,
          publisher: '新テスト出版',
          author_ids: [@author.id]
        }
      }
    end
    follow_redirect!
    assert_match '新しいテスト本', response.body
    assert_match '本が正常に保存されました', response.body

    # 5. 作成した本を編集
    new_book = Book.last
    get edit_book_path(new_book)
    assert_response :success

    patch book_path(new_book), params: {
      book: {
        title: '更新されたテスト本',
        isbn: new_book.isbn,
        published_year: new_book.published_year,
        publisher: new_book.publisher,
        author_ids: [@author.id]
      }
    }
    follow_redirect!
    assert_match '更新されたテスト本', response.body
    assert_match '本が正常に保存されました', response.body

    # 6. 本を削除
    assert_difference 'Book.count', -1 do
      delete book_path(new_book)
    end
    follow_redirect!
    assert_match '本が正常に削除されました', response.body
  end

  test 'login required message and redirect flow' do
    # 1. 未ログインで新規作成を試みる
    get new_book_path
    assert_redirected_to new_user_session_path

    # 2. ログインページに移動
    follow_redirect!
    assert_response :success
    assert_match 'ログイン', response.body

    # 3. ログイン
    post user_session_path, params: {
      user: { email: @user.email, password: 'password' }
    }
    follow_redirect!

    # 4. 今度は新規作成ページにアクセス可能
    get new_book_path
    assert_response :success
  end
end
