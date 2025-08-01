class BookBlueprint < Blueprinter::Base
  # Normal view - basic book information for lists
  view :normal do
    fields :id, :title, :isbn, :language, :page_count, :stock, :summary, :edition
    
    field :price do |book, _options|
      book.price.to_f
    end
    
    field :author_name do |book, _options|
      book.author.name if book.author
    end
    
    field :cover_url do |book, _options|
      book.cover_url.present? ? book.ensure_absolute_url(book.cover_url) : nil
    end
  end
  
  # Extended view - includes all book details
  view :extended do
    include_view :normal
    
    field :published_date do |book, _options|
      book.published_date&.strftime('%Y-%m-%d')
    end
    
    field :created_at do |book, _options|
      book.created_at&.iso8601
    end
    
    field :updated_at do |book, _options|
      book.updated_at&.iso8601
    end
  end
  
  # Default to normal view
  view :default do
    include_view :normal
  end
end
