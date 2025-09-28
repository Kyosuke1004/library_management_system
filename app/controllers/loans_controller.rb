class LoansController < ApplicationController
  before_action :authenticate_user!

  def create
    book_item = BookItem.find(params[:book_item_id])
    book = book_item.book

    # BookItemが貸出可能かチェック
    if book_item.loans.currently_borrowed.empty?
      loan = Loan.new(user: current_user, book_item: book_item, borrowed_at: Time.current)
      if loan.save
        redirect_to book, notice: '本を借りました。'
      else
        redirect_to book, alert: '本の貸出に失敗しました。'
      end
    else
      redirect_to book, alert: '本の貸出に失敗しました。'
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def update
    loan = Loan.find(params[:id])
    book = loan.book_item.book
    if loan.user == current_user && loan.returned_at.nil?
      loan.update(returned_at: Time.current)
      redirect_to book, notice: '本を返却しました。'
    else
      redirect_to book, alert: '本の返却に失敗しました。'
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
