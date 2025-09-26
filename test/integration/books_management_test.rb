class BooksManagementTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    @general = users(:user)
    @author = Author.create!(name: '共通著者')
    @book = Book.create!(title: '共通本', isbn: '1234567890', published_year: 2024, publisher: '共通出版', authors: [@author])
  end

  def login(user)
    post user_session_path, params: { user: { email: user.email, password: 'password' } }
    follow_redirect!
  end

  test 'admin can create a book with existing author' do
    login(@admin)
    get new_book_path
    assert_response :success
    assert_difference 'Book.count' do
      post books_path, params: {
        book: {
          title: '新規本',
          isbn: '9999999999',
          published_year: 2025,
          publisher: '新規出版',
          author_ids: [@author.id]
        }
      }
    end
    follow_redirect!
    assert_match '新規本', response.body
    assert_match @author.name, response.body
  end

  test 'admin can add new author when editing book' do
    login(@admin)
    get edit_book_path(@book)
    assert_response :success
    assert_difference 'Author.count' do
      patch book_path(@book), params: {
        book: {
          title: @book.title,
          isbn: @book.isbn,
          published_year: @book.published_year,
          publisher: @book.publisher,
          author_ids: [@author.id],
          author_names: '追加著者'
        }
      }
    end
    follow_redirect!
    @book.reload
    assert_includes @book.authors.map(&:name), '追加著者'
  end

  test 'admin cannot create book with invalid data' do
    login(@admin)
    get new_book_path
    assert_no_difference 'Book.count' do
      post books_path, params: {
        book: {
          title: '',
          isbn: '',
          published_year: nil,
          publisher: '',
          author_names: ''
        }
      }
    end
    assert_response :unprocessable_entity
    assert_match(/エラー/, response.body)
  end

  test 'general user cannot access new book page' do
    login(@general)
    get new_book_path
    assert_response :redirect
    assert_redirected_to books_path
    assert_equal '管理者のみ操作可能です。', flash[:alert]
  end

  test 'general user cannot create book' do
    login(@general)
    assert_no_difference 'Book.count' do
      post books_path, params: {
        book: {
          title: '一般ユーザー本',
          isbn: '9999999999',
          published_year: 2025,
          publisher: '一般出版',
          author_names: '一般著者'
        }
      }
    end
    assert_response :redirect
    assert_redirected_to books_path
    assert_equal '管理者のみ操作可能です。', flash[:alert]
  end

  test 'general user cannot access edit book page' do
    login(@general)
    get edit_book_path(@book)
    assert_response :redirect
    assert_redirected_to books_path
    assert_equal '管理者のみ操作可能です。', flash[:alert]
  end

  test 'general user cannot update book' do
    login(@general)
    patch book_path(@book), params: {
      book: {
        title: '編集後タイトル',
        isbn: @book.isbn,
        published_year: @book.published_year,
        publisher: @book.publisher
      }
    }
    assert_response :redirect
    assert_redirected_to books_path
    assert_equal '管理者のみ操作可能です。', flash[:alert]
  end

  test 'general user cannot destroy book' do
    login(@general)
    assert_no_difference 'Book.count' do
      delete book_path(@book)
    end
    assert_response :redirect
    assert_redirected_to books_path
    assert_equal '管理者のみ操作可能です。', flash[:alert]
  end

  test 'unauthenticated user is redirected to login for admin-only actions' do
    get new_book_path
    assert_response :redirect
    assert_redirected_to new_user_session_path

    post books_path, params: {
      book: {
        title: '未ログイン本',
        isbn: '7777777777',
        published_year: 2025,
        publisher: '未ログイン出版',
        author_names: '未ログイン著者'
      }
    }
    assert_response :redirect
    assert_redirected_to new_user_session_path

    get edit_book_path(@book)
    assert_response :redirect
    assert_redirected_to new_user_session_path

    patch book_path(@book), params: {
      book: {
        title: '未ログイン編集',
        isbn: @book.isbn,
        published_year: @book.published_year,
        publisher: @book.publisher
      }
    }
    assert_response :redirect
    assert_redirected_to new_user_session_path

    assert_no_difference 'Book.count' do
      delete book_path(@book)
    end
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end
end
