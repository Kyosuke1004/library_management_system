require 'test_helper'

class TagTest < ActiveSupport::TestCase
  def setup
    @tag = Tag.new(name: 'プログラミング')
  end

  test 'should be valid' do
    assert @tag.valid?
  end

  test 'should require name' do
    @tag.name = ''
    assert_not @tag.valid?
  end

  test 'should not allow duplicate name' do
    @tag.save!
    duplicate = Tag.new(name: @tag.name)
    assert_not duplicate.valid?
  end

  test 'should have many books through taggings' do
    book = Book.create!(title: 'テスト本', isbn: SecureRandom.hex(8), published_year: 2024, publisher: 'テスト出版',
                        authors: [Author.create!(name: "著者_#{SecureRandom.hex(4)}")])
    @tag.save!
    book.tags << @tag
    assert_includes @tag.books, book
  end
end
