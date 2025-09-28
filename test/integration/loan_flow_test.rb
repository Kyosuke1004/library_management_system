require 'test_helper'

class LoanFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user1 = User.create!(email: 'user1@example.com', password: 'password')
    @user2 = User.create!(email: 'user2@example.com', password: 'password')
    @author = Author.create!(name: 'テスト著者')
    @book = Book.create!(
      title: 'テスト本',
      isbn: '1111111111',
      published_year: 2024,
      publisher: 'テスト出版',
      authors: [@author]
    )
    @book_item = @book.book_items.create!
  end

  # ========================================
  # 完全な貸出・返却フロー
  # ========================================

  test 'complete user journey from book list to loan and return' do
    sign_in @user1

    # 本一覧ページの確認
    get books_path
    assert_response :success

    # 本の詳細ページにアクセス
    get book_path(@book)
    assert_response :success
    assert_select 'p', text: /貸出可能/
    assert_select 'form button', text: '貸出'

    # 貸出実行
    post loans_path, params: { book_item_id: @book_item.id }
    assert_redirected_to book_path(@book)
    follow_redirect!

    # 貸出後の状態確認
    assert_select 'p', text: /貸出中/
    assert_select 'form button', text: '返却'

    # 返却実行
    loan = Loan.last
    patch loan_path(loan)
    assert_redirected_to book_path(@book)
    follow_redirect!

    # 返却後の状態確認
    assert_select 'p', text: /貸出可能/
    assert_select 'form button', text: '貸出'
  end

  # ========================================
  # UI表示の確認
  # ========================================

  test 'ui shows correct buttons based on loan status and user' do
    # User1が本を借りている状態を作成
    Loan.create!(user: @user1, book_item: @book_item, borrowed_at: 1.day.ago)

    # 借りた本人でログイン: 返却ボタンあり
    sign_in @user1
    get book_path(@book)
    assert_response :success
    assert_select 'p', text: /貸出中/
    assert_select 'form button', text: '返却'

    # ログアウト
    sign_out @user1

    # 他のユーザーでログイン: 返却ボタンなし
    sign_in @user2
    get book_path(@book)
    assert_response :success
    assert_select 'p', text: /貸出中/
    assert_select 'form button', text: '返却', count: 0
  end

  test 'guest user cannot see loan buttons' do
    # ログインせずに本の詳細ページにアクセス
    get book_path(@book)
    assert_response :success
    assert_select 'p', text: /貸出可能/

    # ゲストユーザーには貸出ボタンが表示されない
    assert_select 'form button', text: '貸出', count: 0
    assert_select 'a', text: 'ログイン'
  end

  # ========================================
  # 複数ユーザーの利用シナリオ
  # ========================================

  test 'multiple users can interact with different books' do
    @author2 = Author.create!(name: '別の著者')
    @book2 = Book.create!(
      title: 'テスト本2',
      isbn: '2222222222',
      published_year: 2024,
      publisher: 'テスト出版',
      authors: [@author2]
    )
    @book_item2 = @book2.book_items.create!

    # User1が本1を借りる
    sign_in @user1
    post loans_path, params: { book_item_id: @book_item.id }
    sign_out @user1

    # User2が本2を借りる
    sign_in @user2
    post loans_path, params: { book_item_id: @book_item2.id }
    sign_out @user2

    # User1でログインして状況確認
    sign_in @user1

    # 本1（自分が借りた本）- 返却ボタンが表示される
    get book_path(@book)
    assert_select 'p', text: /貸出中/
    assert_select 'form button', text: '返却'

    # 本2（他人が借りた本）- 返却ボタンは表示されない
    get book_path(@book2)
    assert_select 'p', text: /貸出中/
    assert_select 'form button', text: '返却', count: 0
  end
end
