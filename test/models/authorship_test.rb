require 'test_helper'

class AuthorshipTest < ActiveSupport::TestCase
  def setup
    @author = Author.create!(name: 'テスト著者')
    @book = Book.create!(title: 'テスト本',
                         isbn: '1234567890',
                         published_year: 2024,
                         publisher: 'テスト出版',
                         authors: [@author])
    @authorship = Authorship.new(book: @book, author: @author)
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
