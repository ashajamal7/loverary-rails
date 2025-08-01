class CartsController < ApplicationController
  before_action :require_login
  before_action :current_cart, only: [ :show, :active, :add, :update, :remove, :clear, :checkout ]

  def index
    # Return active cart when status=1 is provided
    if params[:status] == "1" || params[:_embed] == "cart_items"
      @cart = current_cart
      render_cart_response("Active cart retrieved")
    else
      render json: { message: "List of carts", carts: [] }, status: :ok
    end
  end

  def create
    # Initialize a new cart in the session
    @cart = {
      cart_items: [],
      user_id: current_user.id,
      status: "active",
      created_at: Time.current,
      updated_at: Time.current
    }
    session[:cart] = @cart
    render_cart_response("Cart created", :created)
  end

  def active
    # Return the active cart for the current user with embedded items
    show
  end

  def show
    render_cart_response("Cart retrieved")
  end

  def add
    Rails.logger.info "DEBUG - cart_params: #{cart_params.inspect}"
    Rails.logger.info "DEBUG - @cart before: #{@cart.inspect}"

    # Initialize cart if it doesn't exist
    @cart ||= {
      cart_items: [],
      user_id: current_user.id,
      status: "active",
      created_at: Time.current,
      updated_at: Time.current
    }
    session[:cart] = @cart

    Rails.logger.info "DEBUG - @cart after: #{@cart.inspect}"

    valid_items = cart_params.map do |item|
      book = Book.find_by(id: item[:book_id])
      Rails.logger.info "DEBUG - Processing item: #{item.inspect}, book found: #{book.present?}"
      next nil unless book && book.stock.to_i >= item[:quantity].to_i

      # Debug logging for cover_url
      Rails.logger.info "DEBUG - Book ID: #{book.id}, cover_url: #{book.cover_url.inspect}"
      absolute_url = book.ensure_absolute_url(book.cover_url)
      Rails.logger.info "DEBUG - Absolute URL: #{absolute_url.inspect}"

      # Convert to string keys for consistency
      {
        "book_id" => item[:book_id].to_s,
        "quantity" => item[:quantity].to_i,
        "price" => book.price.to_f,
        "title" => book.title,
        "cover_url" => absolute_url,
        "created_at" => Time.current,
        "updated_at" => Time.current
      }
    end.compact

    if valid_items.empty?
      render json: { message: "No valid items to add to cart" }, status: :not_acceptable and return
    end

    # Merge with existing items, updating quantities for duplicates
    valid_items.each do |new_item|
      existing_item = @cart[:cart_items].find { |item| item["book_id"] == new_item["book_id"] }

      if existing_item
        existing_item["quantity"] += new_item["quantity"]
      else
        @cart[:cart_items] << new_item
      end
    end

    # Update timestamps
    @cart[:updated_at] = Time.current

    # Re-assign to session to ensure persistence
    session[:cart] = @cart

    render_cart_response("Successfully added item(s) to cart")
  end

  def remove
    book_id = params[:book_id].to_s
    # Find item index to remove
    original_count = @cart[:cart_items].size

    # Convert all items to use string keys for consistent comparison
    @cart[:cart_items].reject! do |item|
      item_book_id = (item[:book_id] || item["book_id"]).to_s
      item_book_id == book_id
    end

    session[:cart] = @cart

    if @cart[:cart_items].size == original_count
      render json: { message: "item not found in cart" }, status: :not_found
    else
      render_cart_response("item removed")
    end
  end

  def clear
    if @cart.blank? || @cart[:cart_items].blank?
      render json: { message: "cart already empty" }, status: :ok and return
    end

    reset_cart!

    render_cart_response("cart cleared")
  end

  def update
    book_id = update_params[:book_id].to_s
    quantity = update_params[:quantity].to_i

    Rails.logger.info "[CART UPDATE] Starting update for book_id: #{book_id}, new quantity: #{quantity}"
    Rails.logger.info "[CART UPDATE] Current cart items before update: #{@cart[:cart_items].inspect}"

    item_updated = false
    item_before = nil

    @cart[:cart_items].each_with_index do |item, index|
      item_book_id = (item[:book_id] || item["book_id"]).to_s
      if item_book_id == book_id
        item_before = item.dup
        item[:quantity] = quantity
        item[:updated_at] = Time.current
        # Ensure all keys are symbols for consistency
        item.transform_keys!(&:to_sym) if item.is_a?(Hash)
        item_updated = true
        Rails.logger.info "[CART UPDATE] Item found at index #{index} and updated. Before: #{item_before.inspect}, After: #{item.inspect}"
        break
      end
    end

    if item_updated
      @cart[:updated_at] = Time.current
      session[:cart] = @cart
      Rails.logger.info "[CART UPDATE] Cart after update: #{@cart.inspect}"
      render_cart_response("Item quantity updated")
    else
      Rails.logger.warn "[CART UPDATE] Item with book_id #{book_id} not found in cart"
      render json: {
        message: "Item not found in cart",
        details: {
          requested_book_id: book_id,
          available_book_ids: @cart[:cart_items].map { |i| i["book_id"] }
        }
      }, status: :not_found
    end
  end

  def checkout
    Rails.logger.info "[CHECKOUT] Starting checkout process for user: #{current_user&.id}"

    if @cart.blank? || @cart[:cart_items].blank?
      Rails.logger.warn "[CHECKOUT] Checkout failed - cart is empty"
      return render json: { message: "Your cart is empty" }, status: :ok
    end

    Rails.logger.info "[CHECKOUT] Processing cart with #{@cart[:cart_items].size} items"

    # Log cart contents for debugging
    @cart[:cart_items].each_with_index do |item, index|
      Rails.logger.debug do
        "[CHECKOUT] Item #{index + 1}: Book ID: #{item[:book_id] || item['book_id']}, " \
        "Qty: #{item[:quantity] || item['quantity']}, " \
        "Price: #{item[:price] || item['price']}"
      end
    end

    total_price = @cart[:cart_items].sum do |item|
      price = (item[:price] || item["price"]).to_f
      quantity = (item[:quantity] || item["quantity"]).to_i
      price * quantity
    end

    Rails.logger.info "[CHECKOUT] Calculated total price: #{'%.2f' % total_price}"

    Rails.logger.info "[CHECKOUT] Creating order..."
    order = Order.create!(
      user_id: current_user.id,
      status: "pending",
      total_price: total_price
    )

    Rails.logger.info "[CHECKOUT] Order #{order.id} created successfully"

    # Process each cart item in a transaction to ensure data consistency
    Order.transaction do
      @cart[:cart_items].each_with_index do |item, index|
        book_id = item[:book_id] || item["book_id"]
        quantity = (item[:quantity] || item["quantity"]).to_i
        price = item[:price] || item["price"]

        Rails.logger.debug { "[CHECKOUT] Processing order item #{index + 1} - Book: #{book_id}, Qty: #{quantity}" }

        # Find the book and lock it for update to prevent race conditions
        book = Book.lock.find(book_id)

        # Check if sufficient stock is available
        if book.stock < quantity
          Rails.logger.error "[CHECKOUT] Insufficient stock for book #{book_id}. Available: #{book.stock}, Requested: #{quantity}"
          raise ActiveRecord::Rollback, "Insufficient stock for #{book.title}"
        end

        # Update book stock
        book.decrement!(:stock, quantity)
        Rails.logger.info "[CHECKOUT] Updated stock for book #{book_id}. New stock: #{book.stock}"

        # Create order item
        OrderItem.create!(
          book_id: book_id,
          quantity: quantity,
          price: price,
          order_id: order.id
        )
      end
    end

    Rails.logger.info "[CHECKOUT] Created #{@cart[:cart_items].size} order items for order #{order.id}"

    # Clear the cart after successful checkout
    reset_cart!
    Rails.logger.info "[CHECKOUT] Cart cleared after successful checkout"

    # Reload order to get all associations
    order.reload

    # Build detailed response
    response = {
      message: "Order placed successfully",
      order: {
        id: order.id,
        status: order.status,
        total: order.total_price,
        created_at: order.created_at,
        items: order.order_items.map do |item|
          {
            book_id: item.book_id,
            title: item.book&.title || "Unknown Book",
            quantity: item.quantity,
            price: item.price,
            subtotal: (item.price * item.quantity).round(2)
          }
        end
      }
    }

    Rails.logger.info "[CHECKOUT] Checkout completed successfully for order #{order.id}"
    render json: response, status: :created

  rescue StandardError => e
    Rails.logger.error "[CHECKOUT] Checkout failed: #{e.class.name} - #{e.message}"
    Rails.logger.error "[CHECKOUT] Backtrace:\n#{e.backtrace.first(10).join("\n")}"

    render json: {
      message: "Could not complete your order",
      error: Rails.env.development? ? e.message : nil
    }, status: :unprocessable_entity
  end

  private

  def reset_cart!
    @cart[:cart_items] = []
    session[:cart] = @cart
  end

  def current_cart
    Rails.logger.info "[CART] Fetching cart. Session cart: #{session[:cart].inspect}"
    # Initialize or update the cart
    cart = if session[:cart].is_a?(Hash)
             # Keep existing cart items if they exist
             existing_items = Array(session[:cart][:cart_items] || session[:cart]["cart_items"])
             {
               cart_items: existing_items,
               user_id: session[:cart][:user_id] || session[:cart]["user_id"] || current_user&.id,
               status: session[:cart][:status] || session[:cart]["status"] || "active",
               created_at: session[:cart][:created_at] || session[:cart]["created_at"] || Time.current,
               updated_at: session[:cart][:updated_at] || session[:cart]["updated_at"] || Time.current
             }
    else
             # New cart
             {
               cart_items: [],
               user_id: current_user&.id,
               status: "active",
               created_at: Time.current,
               updated_at: Time.current
             }
    end

    # Ensure all keys are symbols for consistency
    cart = cart.symbolize_keys
    cart[:cart_items] = cart[:cart_items].map(&:symbolize_keys) if cart[:cart_items].is_a?(Array)

    # Update session and instance variable
    session[:cart] = cart
    @cart = cart

    Rails.logger.info "[CART] Final cart state: #{@cart.inspect}"
    Rails.logger.info "[CART] Cart items count: #{@cart[:cart_items]&.count || 0}"
    Rails.logger.info "[CART] Session ID: #{session.id}"
  end

  def render_cart_response(message, status = :ok)
    # Build the cart response
    cart_response = {
      id: 1, # Session-based carts don't have a database ID
      user_id: @cart[:user_id],
      status: @cart[:status],
      created_at: @cart[:created_at],
      updated_at: @cart[:updated_at] || Time.current
    }

    # Always include cart items in the response
    cart_items = Array(@cart[:cart_items]).map do |item|
      {
        id: item[:id] || item["id"],
        book_id: item[:book_id] || item["book_id"],
        quantity: item[:quantity] || item["quantity"],
        price: item[:price] || item["price"],
        title: item[:title] || item["title"],
        cover_url: item[:cover_url] || item["cover_url"] || nil,
        created_at: item[:created_at] || item["created_at"],
        updated_at: item[:updated_at] || item["updated_at"]
      }
    end

    # Initialize the full response with cart items
    response = {
      message: message,
      cart: cart_response.merge(items: cart_items)
    }

    # Log the exact response that will be sent
    json_response = response.to_json
    Rails.logger.info "[CART] Sending response: #{json_response}"
    Rails.logger.info "[CART] Response status: #{status}"

    render json: response, status: status
  end

  def cart_params
    return [] unless params[:cart].present?

    items = if params[:cart].is_a?(Array)
              params[:cart].map do |item|
                item = item.permit(:book_id, :quantity).to_h.symbolize_keys
                next unless item[:book_id].present? && item[:quantity].present?
                {
                  book_id: item[:book_id].to_i,
                  quantity: item[:quantity].to_i
                }
              end.compact
    elsif params[:cart].is_a?(ActionController::Parameters) || params[:cart].is_a?(Hash)
              if params[:cart].first.is_a?(Array) || params[:cart].first.is_a?(ActionController::Parameters) || params[:cart].first.is_a?(Hash)
                # Handle case where cart is a hash with array values
                params[:cart].map do |_, item|
                  item = item.permit(:book_id, :quantity).to_h.symbolize_keys
                  next unless item[:book_id].present? && item[:quantity].present?
                  {
                    book_id: item[:book_id].to_i,
                    quantity: item[:quantity].to_i
                  }
                end.compact
              else
                # Handle single item case
                item = params.require(:cart).permit(:book_id, :quantity).to_h.symbolize_keys
                if item[:book_id].present? && item[:quantity].present?
                  [ {
                    book_id: item[:book_id].to_i,
                    quantity: item[:quantity].to_i
                  } ]
                else
                  []
                end
              end
    else
              []
    end

    # Ensure all items have positive quantities and valid book_ids
    Array(items).select do |item|
      item[:book_id].to_i.positive? && item[:quantity].to_i.positive?
    end
  end

  def update_params
    params.permit(:book_id, :quantity)
  end

  def ensure_absolute_url(url)
    return url if url.blank? || url.start_with?("http")
    "#{request.base_url}#{url.start_with?('/') ? '' : '/'}#{url}"
  end
end
