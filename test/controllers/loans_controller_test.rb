require 'test_helper'

class LoansControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: 'test@example.com', password: 'password')
    @author = Author.create!(name: "テスト著者_#{SecureRandom.hex(4)}")
    @book = Book.create!(
      title: 'テスト本',
      isbn: SecureRandom.hex(8),
      published_year: 2024,
      publisher: 'テスト出版',
      authors: [@author]
    )
    @book_item = @book.book_items.create!
  end

  # ========================================
  # 貸出機能のテスト
  # ========================================

  test 'should create loan' do
    sign_in @user

    # 実行前の状態確認
    assert @book.available?
    assert_equal 0, @book_item.loans.currently_borrowed.count

    # 貸出処理の実行
    assert_difference 'Loan.count', 1 do
      post loans_path, params: { book_item_id: @book_item.id }
    end

    # レスポンスの確認
    assert_redirected_to @book
    assert_match '本を借りました。', flash[:notice]

    # 作成されたloanレコードの確認
    loan = Loan.last
    assert_equal @user.id, loan.user_id
    assert_equal @book_item.id, loan.book_item_id
    assert_not_nil loan.borrowed_at
    assert_nil loan.returned_at
  end

  test 'should not create loan when not logged in' do
    # ログインせずに貸出を試行
    assert_no_difference 'Loan.count' do
      post loans_path, params: { book_item_id: @book_item.id }
    end

    # 認証エラーでログインページにリダイレクト
    assert_redirected_to new_user_session_path
    assert_match 'You need to sign in or sign up before continuing.', flash[:alert]
  end

  test 'should not create loan for already borrowed book' do
    # 他のユーザーが既に借りている状況を作成
    @other_user = User.create!(email: 'borrower@example.com', password: 'password')
    @existing_loan = Loan.create!(
      user: @other_user,
      book_item: @book_item,
      borrowed_at: 1.day.ago
    )

    sign_in @user

    # 実行前の状態確認（貸出中であることを確認）
    assert_not @book.reload.available?
    assert_equal 1, @book_item.loans.currently_borrowed.count

    # 貸出処理を試行（失敗するはず）
    assert_no_difference 'Loan.count' do
      post loans_path, params: { book_item_id: @book_item.id }
    end

    # 失敗レスポンスの確認
    assert_redirected_to @book
    assert_match '本の貸出に失敗しました。', flash[:alert]

    # 本の状態が変わっていないことを確認
    assert_not @book.reload.available?
  end

  test 'should not create loan for non-existent book' do
    sign_in @user
    non_existent_id = BookItem.maximum(:id).to_i + 1

    # 存在しないBookItemの貸出を試行
    assert_no_difference 'Loan.count' do
      post loans_path, params: { book_item_id: non_existent_id }
    end

    # 404エラーが返されることを確認
    assert_response :not_found
  end

  # ========================================
  # 返却機能のテスト
  # ========================================

  test 'should return loan' do
    # 貸出中のloanを事前に作成
    @loan = Loan.create!(
      user: @user,
      book_item: @book_item,
      borrowed_at: 1.day.ago
    )

    sign_in @user

    # 実行前の状態確認
    assert_not @book.reload.available?
    assert_nil @loan.returned_at

    # 返却処理の実行
    patch loan_path(@loan)

    # レスポンスの確認
    assert_redirected_to @book
    assert_match '本を返却しました。', flash[:notice]

    # loanレコードの更新確認
    @loan.reload
    assert_not_nil @loan.returned_at

    # 本の状態確認（貸出可能になったことを確認）
    assert @book.reload.available?
  end

  test 'should not return loan of another user' do
    # 他のユーザーが借りている本を作成
    @other_user = User.create!(email: 'other@example.com', password: 'password')
    @loan = Loan.create!(
      user: @other_user,
      book_item: @book_item,
      borrowed_at: 1.day.ago
    )

    sign_in @user

    # 実行前の状態確認
    assert_equal @other_user, @loan.user
    assert_not @book.reload.available?
    assert_nil @loan.returned_at

    # 他人の本の返却を試行（失敗するはず）
    patch loan_path(@loan)

    # 失敗レスポンスの確認
    assert_redirected_to @book
    assert_match '本の返却に失敗しました。', flash[:alert]

    # データが変更されていないことを確認
    @loan.reload
    assert_nil @loan.returned_at
    assert_not @book.reload.available?
  end

  test 'should not return already returned loan' do
    # 既に返却済みのloanを作成
    @loan = Loan.create!(
      user: @user,
      book_item: @book_item,
      borrowed_at: 2.days.ago,
      returned_at: 1.day.ago # 既に返却済み
    )

    sign_in @user

    # 実行前の状態確認
    assert @book.reload.available? # 返却済みなので貸出可能
    assert_not_nil @loan.returned_at # 既に返却済み

    original_returned_at = @loan.returned_at

    # 再返却を試行（失敗するはず）
    patch loan_path(@loan)

    # 失敗レスポンスの確認
    assert_redirected_to @book
    assert_match '本の返却に失敗しました。', flash[:alert]

    # returned_atが変更されていないことを確認
    @loan.reload
    assert_equal original_returned_at, @loan.returned_at
  end

  test 'should not return non-existent loan' do
    sign_in @user
    non_existent_id = Loan.maximum(:id).to_i + 1

    # 存在しないloanの返却を試行
    patch loan_path(non_existent_id)

    # 404エラーが返されることを確認
    assert_response :not_found
  end
end
