class LoansController < ApplicationController
  before_action :authenticate_user!
  def create
    book = Book.find(params[:book_id])

    # 貸出可能かチェック
    if book.available?
      loan = Loan.new(user: current_user, book: book, borrowed_at: Time.current)
      if loan.save
        redirect_to book, notice: '本を借りました。'
      else
        redirect_to book, alert: '本の貸出に失敗しました。'
      end
    else
      # 貸出不可の場合
      redirect_to book, alert: '本の貸出に失敗しました。'
    end
  rescue ActiveRecord::RecordNotFound
    # 存在しない本の場合
    head :not_found
  end

  def update
    loan = Loan.find(params[:id])
    if loan.user == current_user && loan.returned_at.nil?
      loan.update(returned_at: Time.current)
      redirect_to loan.book, notice: '本を返却しました。'
    else
      redirect_to loan.book, alert: '本の返却に失敗しました。'
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
