require 'test_helper'

class AuthorshipTest < ActiveSupport::TestCase
  def setup
    @author = Author.create!(name: "テスト著者_#{SecureRandom.hex(4)}")
    @book = Book.create!(title: 'テスト本',
                         isbn: SecureRandom.hex(8),
                         published_year: 2024,
                         publisher: 'テスト出版',
                         authors: [@author])
    @authorship = Authorship.find_by(author: @author, book: @book)
  end

  test 'should be valid' do
    assert @authorship.valid?
  end

  test 'should belong to book' do
    @authorship.book = nil
    assert_not @authorship.valid?
  end

  test 'should belong to author' do
    @authorship.author = nil
    assert_not @authorship.valid?
  end

  test 'should access book through authorship' do
    @authorship.save!
    assert_equal @book, @authorship.book
  end

  test 'should access author through authorship' do
    @authorship.save!
    assert_equal @author, @authorship.author
  end
end
