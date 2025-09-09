require 'test_helper'

class BooksManagementTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: 'test@example.com', password: 'password')
    @author = Author.create!(name: 'テスト著者')

    # ログイン
    post user_session_path, params: {
      user: { email: @user.email, password: 'password' }
    }
  end

  test 'complete book management workflow with authors' do
    # 1. 新規本作成（既存著者選択）
    get new_book_path
    assert_response :success

    assert_difference 'Book.count' do
      post books_path, params: {
        book: {
          title: 'テスト本',
          isbn: '1234567890',
          published_year: 2024,
          publisher: 'テスト出版',
          author_ids: [@author.id]
        }
      }
    end
    follow_redirect!

    book = Book.last
    assert_match 'テスト本', response.body
    assert_match @author.name, response.body

    # 2. 新規著者追加での編集
    get edit_book_path(book)
    assert_response :success

    assert_difference 'Author.count' do
      patch book_path(book), params: {
        book: {
          title: book.title,
          isbn: book.isbn,
          published_year: book.published_year,
          publisher: book.publisher,
          author_ids: [@author.id],
          new_author_name: '新しい著者'
        }
      }
    end
    follow_redirect!

    book.reload
    assert_includes book.authors.map(&:name), '新しい著者'
    assert_match '新しい著者', response.body
  end

  test 'error handling in book creation' do
    # 無効なデータで作成を試みる
    get new_book_path

    assert_no_difference 'Book.count' do
      post books_path, params: {
        book: {
          title: '', # 必須項目が空
          isbn: '',
          published_year: nil,
          publisher: ''
        }
      }
    end

    assert_response :unprocessable_content

    # HTMLエスケープされた文字列で確認
    assert_match 'Title can&#39;t be blank', response.body
    assert_match 'Isbn can&#39;t be blank', response.body
    assert_match 'Published year can&#39;t be blank', response.body
    assert_match 'Publisher can&#39;t be blank', response.body

    # エラー数の確認（タイポも修正）
    assert_match '4 errors prohibited this book from being saved', response.body
  end
end
