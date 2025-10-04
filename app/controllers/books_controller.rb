class BooksController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_book, only: %i[show edit update destroy]
  before_action :require_admin, only: %i[new create edit update destroy]

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
    @book.image_url = image_url_from_isbn(@book.isbn)
    @book.tags = Tag.where(id: Array(params[:book][:tag_ids]).compact_blank)
    save_book_and_redirect(@book, :new)
  end

  def update
    @book.tags = Tag.where(id: Array(params[:book][:tag_ids]).compact_blank)
    @book.assign_attributes(book_params)
    @book.image_url = image_url_from_isbn(@book.isbn)
    save_book_and_redirect(@book, :edit)
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: '本が正常に削除されました。'
  end

  private

  def require_admin
    return if current_user.admin?

    redirect_to books_path, alert: '管理者のみ操作可能です。'
  end

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title,
                                 :isbn,
                                 :published_year,
                                 :publisher,
                                 :author_names,
                                 :stock_count,
                                 :tag_names,
                                 author_ids: [],
                                 tag_ids: [])
  end

  def save_book_and_redirect(book, render_action)
    if book.save
      redirect_to book, notice: '本が正常に保存されました。'
    else
      flash.now[:alert] = '保存に失敗しました。入力内容を確認してください。'
      render render_action, status: :unprocessable_content
    end
  end

  def image_url_from_isbn(isbn)
    return if isbn.blank?

    result = GoogleBooksService.fetch_by_isbn(isbn)
    Rails.logger.info("GoogleBooksService.fetch_by_isbnレスポンス: #{result.inspect}")
    image_url = result&.dig(:image_url)
    Rails.logger.info("image_url_from_isbnの戻り値: #{image_url}")
    image_url
  end
end
