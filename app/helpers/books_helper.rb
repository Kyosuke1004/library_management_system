module BooksHelper
  def sort_select_options(tag: nil)
    sorts = {
      nil => '新着順',
      'title_asc' => 'タイトル昇順',
      'title_desc' => 'タイトル降順',
      'published_year_asc' => '出版年昇順',
      'published_year_desc' => '出版年降順'
    }
    sorts.map do |value, label|
      params_hash = {}
      params_hash[:tag_id] = tag.id if tag
      params_hash[:sort] = value if value.present?
      [label, books_path(params_hash)]
    end
  end

  def tag_links
    Tag.all.map do |tag|
      link_to tag.name, books_path(tag_id: tag.id), class: 'tag is-light'
    end.join(' ').html_safe
  end

  def clear_tag_button
    link_to 'タグ検索解除', books_path, class: 'button is-light'
  end
end
