class BooksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_book, only: %i[show edit update destroy]

  def index
    @books = Book.search_by_title_or_author(params[:search])
  end

  def show
  end

  def new
    @book = Book.new
    @book.authors.build
  end

  def edit
  end

  def create
    @book = Book.new(book_params)
    save_book_and_redirect(@book, :new)
  end

  def update
    @book.assign_attributes(book_params)
    save_book_and_redirect(@book, :edit)
  end

  def destroy
    @book.destroy
    redirect_to books_url, notice: '本が正常に削除されました。'
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title,
                                 :isbn,
                                 :published_year,
                                 :publisher,
                                 :new_author_names,
                                 author_ids: [],
                                 new_author_names: [])
  end

  def save_book_and_redirect(book, render_action)
    book.new_author_names = book_params[:new_author_names]
    if book.save
      redirect_to book, notice: '本が正常に保存されました。'
    else
      render render_action, status: :unprocessable_content
    end
  end
end
