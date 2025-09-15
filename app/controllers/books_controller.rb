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
    @book = Book.new
    save_book(:new, '本が正常に作成されました。')
  end

  def update
    save_book(:edit, '本が正常に更新されました。')
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
    params.require(:book).permit(:title, :isbn, :published_year, :publisher, author_ids: [])
  end

  def author_assignment_params
    params.require(:book).permit(:new_author_names, author_ids: [], new_author_names: [])
  end

  def save_book(render_action, success_message)
    @book.assign_attributes(book_params)
    @book.assign_authors_by_ids_and_names(
      author_assignment_params[:author_ids],
      author_assignment_params[:new_author_names]
    )

    if @book.save
      redirect_to @book, notice: success_message
    else
      render render_action, status: :unprocessable_content
    end
  rescue Book::AuthorCreationError => e
    @book.errors.add(:base, e.message) # エラーメッセージを追加
    render render_action, status: :unprocessable_content
  rescue StandardError => e
    @book.errors.add(:base, "予期しないエラーが発生しました: #{e.message}")
    render render_action, status: :internal_server_error
  end
end
