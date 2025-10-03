# 既存データ削除
Loan.destroy_all
Tagging.destroy_all
Tag.destroy_all
Authorship.destroy_all
Author.destroy_all
User.destroy_all
Book.destroy_all
BookItem.destroy_all

# ユーザー
admin = User.create!(email: 'admin@example.com', password: 'password', role: :admin)
user1 = User.create!(email: 'user1@example.com', password: 'password', role: :general)
user2 = User.create!(email: 'user2@example.com', password: 'password', role: :general)

# 著者
authors = Author.create!([
  { name: "Michael Hartl" },
  { name: "Robert C. Martin" },
  { name: "Yukihiro Matsumoto" },
  { name: "Martin Fowler" },
  { name: "Kent Beck" },
  { name: "村上春樹" },
  { name: "Alexander Osterwalder" }
])

# タグ
tags = Tag.create!([
  { name: "技術書" },
  { name: "小説" },
  { name: "ビジネス" },
  { name: "デザイン" },
  { name: "自己啓発" },
  { name: "プログラミング" },
  { name: "Web" }
])

books = []
books << Book.create!(
  title: "Clean Code",
  isbn: "9780132350884",
  published_year: 2008,
  publisher: "Prentice Hall",
  authors: [authors[1]],
  tags: [tags[0], tags[5]]
)
books << Book.create!(
  title: "Ruby on Rails Tutorial",
  isbn: "9780134598628", # Michael Hartl
  published_year: 2016,
  publisher: "Addison-Wesley",
  authors: [authors[0], authors[2]],
  tags: [tags[0], tags[5], tags[6]]
)
books << Book.create!(
  title: "Refactoring",
  isbn: "9780134757599", # Martin Fowler
  published_year: 2018,
  publisher: "Addison-Wesley",
  authors: [authors[3]],
  tags: [tags[0], tags[5], tags[3]]
)
books << Book.create!(
  title: "Test-driven Development: By Example",
  isbn: "9780321146533", # Kent Beck
  published_year: 2002,
  publisher: "Addison-Wesley",
  authors: [authors[4]],
  tags: [tags[0], tags[5]]
)
books << Book.create!(
  title: "Business Model Generation",
  isbn: "9780470876411", # Alex Osterwalder
  published_year: 2010,
  publisher: "John Wiley & Sons",
  authors: [authors[6]],
  tags: [tags[2], tags[3]]
)
books << Book.create!(
  title: "Norwegian Wood",
  isbn: "9780307762719", # Haruki Murakami
  published_year: 2000,
  publisher: "Vintage",
  authors: [authors[5]],
  tags: [tags[1]]
)

books.each do |book|
  3.times { BookItem.create!(book: book) }
end

Loan.create!(user: user1, book_item: books[0].book_items.first, borrowed_at: 2.days.ago, returned_at: 1.day.ago)
Loan.create!(user: user2, book_item: books[1].book_items.second, borrowed_at: 1.day.ago)
