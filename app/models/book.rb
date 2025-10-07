class Book < ApplicationRecord
  # =====================
  # 関連
  # =====================
  has_many :book_items, dependent: :destroy
  has_many :loans, through: :book_items
  has_many :users, through: :loans

  has_many :authorships, dependent: :destroy
  has_many :authors, through: :authorships

  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  # =====================
  # バリデーション
  # =====================
  validates :title, :isbn, :published_year, :publisher, presence: true
  validates :authors, presence: true

  # =====================
  # 仮想属性（フォーム入力用）
  # =====================
  attr_accessor :author_names, :tag_names, :stock_count

  # =====================
  # コールバック
  # =====================
  before_validation :build_authors_from_input
  before_validation :build_tags_from_input
  after_save :adjust_book_items_stock, if: -> { stock_count.present? }

  # =====================
  # スコープ
  # =====================
  scope :search_by_title_or_author, lambda { |term|
    return all if term.blank?

    pattern = "%#{term}%"
    joins(:authors)
      .where('LOWER(books.title) LIKE LOWER(?) OR LOWER(authors.name) LIKE LOWER(?)', pattern, pattern)
      .distinct
  }

  scope :sort_by_param, lambda { |param|
    case param
    when 'title_asc'          then order(title: :asc)
    when 'title_desc'         then order(title: :desc)
    when 'published_year_asc' then order(published_year: :asc)
    when 'published_year_desc'then order(published_year: :desc)
    else order(created_at: :desc)
    end
  }

  # =====================
  # インスタンスメソッド
  # =====================
  def available?
    book_items.exists? && book_items.any? { |item| item.loans.currently_borrowed.empty? }
  end

  private

  # ==================================================
  # 著者・タグの入力値を関連に変換
  # ==================================================
  def build_authors_from_input
    assign_association_from_input(:authors, author_names)
  end

  def build_tags_from_input
    assign_association_from_input(:tags, tag_names)
  end

  def assign_association_from_input(association, raw_input)
    return if raw_input.blank?

    names = normalize_names(raw_input)
    records = names.map { |name| find_or_create_record(association, name) }

    public_send("#{association}=", records)
  end

  # 文字列または配列で与えられた名前を整理する
  # - 空白を除去し、重複をなくす
  # - カンマまたは改行で分割
  def normalize_names(input)
    case input
    when String
      input.split(/[,\n]/).map(&:strip).compact_blank.uniq
    when Array
      input.map(&:strip).compact_blank.uniq
    else
      []
    end
  end

  # 重複登録を避けて Author/Tag を取得または作成する
  def find_or_create_record(association, name)
    klass = association.to_s.singularize.classify.constantize
    klass.find_or_create_by!(name: name)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    klass.find_by!(name: name)
  end

  # ==================================================
  # 在庫数に応じて BookItem を増減させる
  # ==================================================
  def adjust_book_items_stock
    desired = stock_count.to_i
    current = book_items.count

    if desired > current
      add_book_items(desired - current)
    elsif desired < current
      remove_unborrowed_items(current - desired)
    end
  end

  def add_book_items(count)
    count.times { book_items.create! }
  end

  def remove_unborrowed_items(count)
    book_items.where.missing(:loans).limit(count).each(&:destroy)
  end
end
