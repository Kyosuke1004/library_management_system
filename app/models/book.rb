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

  def assign_authors_by_ids_and_name(author_ids, new_author_name)
    ids = Array(author_ids).compact_blank

    if new_author_name.present?
      author = find_or_create_author(new_author_name)
      ids << author.id unless ids.include?(author.id)
    end

    self.author_ids = ids
  end

  private

  def find_or_create_author(name)
    Author.find_or_create_by!(name: name.strip)
  rescue ActiveRecord::RecordInvalid => e
    raise AuthorCreationError, "著者「#{name}」の作成に失敗しました: #{e.record.errors.full_messages.join(', ')}"
  rescue ActiveRecord::RecordNotUnique
    # 同時リクエストで作成された場合、再取得を試行
    Author.find_by!(name: name.strip)
  end
end
