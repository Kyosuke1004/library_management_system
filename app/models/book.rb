class Book < ApplicationRecord
  has_many :loans, dependent: :destroy # 本が削除されたときに関連する貸出記録も削除
  has_many :users, through: :loans # 本を借りたユーザーを取得するための関連付け

  has_many :authorships, dependent: :destroy # 本が削除されたときに関連する著者情報も削除
  has_many :authors, through: :authorships # 本の著者を取得するための関連付け

  validates :title, presence: true
  validates :isbn, presence: true
  validates :published_year, presence: true
  validates :publisher, presence: true
  validates :authors, presence: true

  attr_accessor :new_author_names

  before_validation :assign_authors_from_params

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
    loans.currently_borrowed.empty?
  end

  class AuthorCreationError < StandardError; end

  private

  def assign_authors_from_params
    self.author_ids = build_author_ids
  rescue AuthorCreationError => e
    errors.add(:base, e.message)
  rescue StandardError => e
    errors.add(:base, "予期しないエラーが発生しました: #{e.message}")
  end

  def build_author_ids
    ids = Array(author_ids).compact_blank.map(&:to_i)
    new_ids = new_author_ids_from_names
    (ids + new_ids).uniq
  end

  def new_author_ids_from_names
    normalize_author_names(new_author_names).map do |name|
      find_or_create_author(name).id
    end
  end

  def normalize_author_names(names)
    return [] if names.blank?

    raw = case names
          when String
            names.split(/[,\n]/)
          when Array
            names
          else
            [names.to_s]
          end

    raw.map { |n| n.to_s.strip }.compact_blank.uniq
  end

  def find_or_create_author(name)
    Author.find_or_create_by!(name: name)
  rescue ActiveRecord::RecordInvalid => e
    raise AuthorCreationError, "著者「#{name}」の作成に失敗しました: #{e.record.errors.full_messages.join(', ')}"
  rescue ActiveRecord::RecordNotUnique
    Author.find_by!(name: name)
  end
end
