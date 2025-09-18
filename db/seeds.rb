Loan.destroy_all
Authorship.destroy_all
Author.destroy_all
User.destroy_all
Book.destroy_all

authors = Author.create!([
  { name: "Michael Hartl" },
  { name: "Peter J. Jones" },
  { name: "Dustin Boswell" },
  { name: "Trevor Foucher" },
  { name: "Douglas Crockford" },
  { name: "Yukihiro Matsumoto" },
  { name: "Sandi Metz" },
  { name: "Martin Fowler" },
  { name: "Kent Beck" },
  { name: "David Heinemeier Hansson" }
])

created_books = []

created_books << Book.create!(
  title: "Ruby on Rails チュートリアル",
  isbn: "9784274069727",
  published_year: 2019,
  publisher: "オーム社",
  authors: [authors[0]]
)

created_books << Book.create!(
  title: "エフェクティブ Ruby",
  isbn: "9784798139821",
  published_year: 2014,
  publisher: "翔泳社",
  authors: [authors[1]]
)

created_books << Book.create!(
  title: "リーダブルコード",
  isbn: "9784873115658",
  published_year: 2012,
  publisher: "オライリー・ジャパン",
  authors: [authors[2], authors[3]]
)

created_books << Book.create!(
  title: "JavaScript: The Good Parts",
  isbn: "9784873113913",
  published_year: 2008,
  publisher: "オライリー・ジャパン",
  authors: [authors[4]]
)

created_books << Book.create!(
  title: "たのしいRuby",
  isbn: "9784797398892",
  published_year: 2021,
  publisher: "SBクリエイティブ",
  authors: [authors[5]]
)

created_books << Book.create!(
  title: "Practical Object-Oriented Design",
  isbn: "9780134456478",
  published_year: 2018,
  publisher: "Addison-Wesley",
  authors: [authors[6]]
)

created_books << Book.create!(
  title: "Refactoring",
  isbn: "9780321356680",
  published_year: 2018,
  publisher: "Addison-Wesley",
  authors: [authors[7]]
)

created_books << Book.create!(
  title: "テスト駆動開発",
  isbn: "9784274067815",
  published_year: 2003,
  publisher: "オーム社",
  authors: [authors[8]]
)

created_books << Book.create!(
  title: "Ruby on Rails Guides",
  isbn: "9781234567897",
  published_year: 2020,
  publisher: "Rails Community",
  authors: [authors[9], authors[0]]
)

created_books << Book.create!(
  title: "Clean Code",
  isbn: "9780132350884",
  published_year: 2008,
  publisher: "Prentice Hall",
  authors: [authors[8], authors[7]]
)