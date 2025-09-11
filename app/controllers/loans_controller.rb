class LoansController < ApplicationController
  def create
    user = current_user
    book = Book.find(params[:book_id])
    loan = Loan.new(user: user, book: book, borrowed_at: Time.current)
    if loan.save
      redirect_to book, notice: '本を借りました。'
    else
      redirect_to book, alert: '本の貸出に失敗しました。'
    end
  end

  def update
    loan = Loan.find(params[:id])
    if loan.user == current_user && loan.returned_at.nil?
      loan.update(returned_at: Time.current)
      redirect_to loan.book, notice: '本を返却しました。'
    else
      redirect_to loan.book, alert: '本の返却に失敗しました。'
    end
  end
end
