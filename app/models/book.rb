class Book < ApplicationRecord
  has_many :book_items, dependent: :destroy # 本が削除されたときに関連する本のアイテムも削除
  has_many :loans, through: :book_items # 本の貸出記録を取得するための関連付け
  has_many :users, through: :loans # 本を借りたユーザーを取得するための関連付け

  has_many :authorships, dependent: :destroy # 本が削除されたときに関連する著者情報も削除
  has_many :authors, through: :authorships # 本の著者を取得するための関連付け

  has_many :taggings, dependent: :destroy # 本が削除されたときに関連するタグ付けも削除
  has_many :tags, through: :taggings # 本のタグを取得するための関連付け

  validates :title, presence: true
  validates :isbn, presence: true
  validates :published_year, presence: true
  validates :publisher, presence: true
  validates :authors, presence: true

  # 仮想属性
  attr_accessor :author_names, :stock_count, :tag_names

  # 入力された author_names / tag_names から関連を作成
  before_validation -> { assign_names(:authors, author_names) }
  before_validation -> { assign_names(:tags, tag_names) }

  after_save :adjust_book_items_stock, if: -> { stock_count.present? }

  scope :search_by_title_or_author, lambda { |search_term|
    return all if search_term.blank?

    search_term = "%#{search_term}%"
    joins(:authors)
      .where('LOWER(books.title) LIKE LOWER(?) OR LOWER(authors.name) LIKE LOWER(?)',
             search_term,
             search_term)
      .distinct
  }

  def available?
    book_items.any? && book_items.any? { |item| item.loans.currently_borrowed.empty? }
  end

  private

  def assign_names(association, raw_names)
    return if raw_names.blank?

    names = normalize_names(raw_names)
    public_send("#{association}=", names.map { |name| find_or_create_record(association, name) })
  end

  # 入力を正規化
  # - String の場合: カンマや改行で分割 → strip → 重複除去
  # - Array の場合: strip → 重複除去
  def normalize_names(names)
    case names
    when String
      names.split(/[,\n]/).map(&:strip).compact_blank.uniq
    when Array
      names.map(&:strip).compact_blank.uniq
    else
      []
    end
  end

  # Author や Tag を find_or_create
  def find_or_create_record(association, name)
    klass = association.to_s.singularize.classify.constantize
    klass.find_or_create_by!(name: name)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    klass.find_by!(name: name)
  end

  def adjust_book_items_stock
    desired = stock_count.to_i
    current = book_items.count

    if desired > current
      (desired - current).times { book_items.create! }
    elsif desired < current
      # 未貸出のBookItemのみ削除
      removable = book_items.where.missing(:loans).limit(current - desired)
      removable.each(&:destroy)
    end
  end
end
