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

    ids = Array(params[:book][:author_ids]).reject(&:blank?)
    if (name = params[:book][:new_author_name]).present?
      author = Author.find_or_create_by!(name: name)
      ids << author.id unless ids.include?(author.id)
    end
    @book.author_ids = ids

    if @book.save
      redirect_to @book, notice: '本が正常に作成されました。'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    ActiveRecord::Base.transaction do
      @book.assign_attributes(book_params)

      ids = Array(params[:book][:author_ids]).reject(&:blank?)
      if (name = params[:book][:new_author_name]).present?
        author = Author.find_or_create_by!(name: name)
        ids |= [author.id]
      end

      if ids.empty?
        @book.errors.add(:authors, :blank)
        raise ActiveRecord::RecordInvalid, @book
      end

      @book.author_ids = ids
      @book.save!
    end

    redirect_to @book, notice: '本が正常に更新されました。'
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_content
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
end
