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

# ---- 技術・開発系 ----
books << Book.create!(
  title: "Clean Code",
  isbn: "9780132350884",
  published_year: 2008,
  publisher: "Prentice Hall",
  author_names: "Robert C. Martin",
  tag_names: "技術書,プログラミング"
)

books << Book.create!(
  title: "Refactoring",
  isbn: "9780134757599",
  published_year: 2018,
  publisher: "Addison-Wesley",
  author_names: "Martin Fowler",
  tag_names: "技術書,プログラミング,設計"
)

books << Book.create!(
  title: "Ruby on Rails Tutorial",
  isbn: "9780134598628",
  published_year: 2016,
  publisher: "Addison-Wesley",
  author_names: "Michael Hartl",
  tag_names: "技術書,Web,プログラミング"
)

books << Book.create!(
  title: "Design Patterns: Elements of Reusable Object-Oriented Software",
  isbn: "9780201633610",
  published_year: 1994,
  publisher: "Addison-Wesley",
  author_names: "Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides",
  tag_names: "技術書,設計,デザイン"
)

books << Book.create!(
  title: "The Pragmatic Programmer",
  isbn: "9780135957059",
  published_year: 2019,
  publisher: "Addison-Wesley",
  author_names: "Andrew Hunt, David Thomas",
  tag_names: "技術書,自己啓発,プログラミング"
)

books << Book.create!(
  title: "You Don’t Know JS Yet: Get Started",
  isbn: "9781098124045",
  published_year: 2020,
  publisher: "O'Reilly Media",
  author_names: "Kyle Simpson",
  tag_names: "技術書,Web,JavaScript"
)

# ---- 小説 ----
books << Book.create!(
  title: "Norwegian Wood",
  isbn: "9780307762719",
  published_year: 2000,
  publisher: "Vintage",
  author_names: "Haruki Murakami",
  tag_names: "小説"
)

books << Book.create!(
  title: "1Q84",
  isbn: "9780307476463",
  published_year: 2009,
  publisher: "Knopf",
  author_names: "Haruki Murakami",
  tag_names: "小説,現代文学"
)

books << Book.create!(
  title: "Kafka on the Shore",
  isbn: "9781400079278",
  published_year: 2005,
  publisher: "Vintage",
  author_names: "Haruki Murakami",
  tag_names: "小説,幻想文学"
)

books << Book.create!(
  title: "The Midnight Library",
  isbn: "9780525559474",
  published_year: 2020,
  publisher: "Viking",
  author_names: "Matt Haig",
  tag_names: "小説,自己啓発,ファンタジー"
)

# ---- ビジネス・デザイン・自己啓発 ----
books << Book.create!(
  title: "Business Model Generation",
  isbn: "9780470876411",
  published_year: 2010,
  publisher: "John Wiley & Sons",
  author_names: "Alexander Osterwalder, Yves Pigneur",
  tag_names: "ビジネス,デザイン"
)

books << Book.create!(
  title: "Atomic Habits",
  isbn: "9780735211292",
  published_year: 2018,
  publisher: "Avery",
  author_names: "James Clear",
  tag_names: "自己啓発,習慣,ビジネス"
)

books << Book.create!(
  title: "Deep Work",
  isbn: "9781455586691",
  published_year: 2016,
  publisher: "Grand Central Publishing",
  author_names: "Cal Newport",
  tag_names: "自己啓発,生産性"
)

books << Book.create!(
  title: "Hooked: How to Build Habit-Forming Products",
  isbn: "9781591847786",
  published_year: 2014,
  publisher: "Portfolio",
  author_names: "Nir Eyal",
  tag_names: "ビジネス,Web,デザイン"
)

books << Book.create!(
  title: "Show Your Work!: 10 Ways to Share Your Creativity and Get Discovered",
  isbn: "9780761178972",
  published_year: 2014,
  publisher: "Workman Publishing",
  author_names: "Austin Kleon",
  tag_names: "デザイン,自己啓発,創作"
)

books << Book.create!(
  title: "The Design of Everyday Things",
  isbn: "9780465050659",
  published_year: 2013,
  publisher: "Basic Books",
  author_names: "Don Norman",
  tag_names: "デザイン,UX,技術書"
)


books.each do |book|
  3.times { BookItem.create!(book: book) }
end

Loan.create!(user: user1, book_item: books[0].book_items.first, borrowed_at: 2.days.ago, returned_at: 1.day.ago)
Loan.create!(user: user2, book_item: books[1].book_items.second, borrowed_at: 1.day.ago)
