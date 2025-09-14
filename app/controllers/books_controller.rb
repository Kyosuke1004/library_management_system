class BooksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_book, only: %i[show edit update destroy]

  def index
    @books = if params[:search].present?
               search_term = "%#{params[:search]}%"
               Book.joins(:authors)
                   .where('LOWER(books.title) LIKE LOWER(?) OR LOWER(authors.name) LIKE LOWER(?)',
                          search_term, search_term)
                   .distinct
             else
               Book.all
             end
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
    assign_authors_to_book

    if @book.save
      redirect_to @book, notice: '本が正常に作成されました。'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @book.assign_attributes(book_params)
    assign_authors_to_book

    if @book.save
      redirect_to @book, notice: '本が正常に更新されました。'
    else
      render :edit, status: :unprocessable_content
    end
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

  def assign_authors_to_book
    ids = Array(params[:book][:author_ids]).compact_blank
    if (name = params[:book][:new_author_name]).present?
      author = Author.find_or_create_by!(name: name)
      ids << author.id unless ids.include?(author.id)
    end
    @book.author_ids = ids
  end
end
