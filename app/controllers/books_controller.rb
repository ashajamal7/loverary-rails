class BooksController < ApplicationController
  before_action :set_book, only: [:show, :update, :destroy]

  # GET /books
  # Paginated list of books with optional filtering
  # @param page [Integer] Page number (default: 1)
  # @param per_page [Integer] Number of items per page (default: 10, max: 100)
  # @param in_stock [Boolean] Filter books that are in stock
  # @return [Hash] Paginated list of books with metadata
  def index
    per_page = [params.fetch(:per_page, 10).to_i, 100].min
    books = Book.includes(:author).all
    
    # Apply in_stock filter if present
    books = books.where('stock > 0') if params[:in_stock] == 'true'
    
    @books = books.paginate(page: params[:page], per_page: per_page)
    
    render json: {
      books: BookBlueprint.render_as_hash(@books, view: :normal),
      meta: {
        current_page: @books.current_page,
        next_page: @books.next_page,
        prev_page: @books.previous_page,
        total_pages: @books.total_pages,
        total_count: @books.total_entries
      }
    }
  end
  
  # GET /books/:id
  # @return [Hash] Book details with author information
  def show
    if @book
      render json: BookBlueprint.render(@book, view: :extended)
    else
      render json: { error: "Book not found" }, status: :not_found
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      render json: @book, status: :created, location: @book
    else
      render json: { errors: @book.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(book_params)
      render json: @book
    else
      render json: { errors: @book.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /books/1
  def destroy
    @book.destroy
  end

  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_book
    @book = Book.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def book_params
    params.require(:book).permit(:title, :isbn, :language, :page_count, :stock, :price, :author_id, :summary, :published_date, :edition, :cover_url, :category_id)
  end
end