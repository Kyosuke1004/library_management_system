class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]

  def index
    @books = Book.all
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

    ActiveRecord::Base.transaction do
      @book.save!

      if params[:book][:new_author_name].present?
        author = Author.find_or_create_by!(name: params[:book][:new_author_name])
        @book.authors << author unless @book.authors.include?(author)
      end
    end

    redirect_to @book, notice: '本が正常に作成されました。'
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  def update
    if params[:book][:new_author_name].present?
      author = Author.find_or_create_by(name: params[:book][:new_author_name])

      # 既存の著者IDリストに新しい著者のIDを追加
      author_ids = Array(params[:book][:author_ids]).reject(&:blank?)
      author_ids << author.id.to_s unless author_ids.include?(author.id.to_s)

      # paramsを更新
      params[:book][:author_ids] = author_ids
    end

    if @book.update(book_params)
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
end
