class CartsController < ApplicationController
  before_action :require_login

  def add
    session[:cart] ||= { cart_items: [] }
    cart_items = session[:cart]["cart_items"]
    valid_items = cart_params.select do |item|
      book = Book.find_by(id: item[:book_id])
      next false unless book && book.stock.to_i >= item[:quantity].to_i
      true
    end

    if valid_items.empty?
      render json: { message: "no valid items" }, status: :not_acceptable and return
    end

    # deduplicate based on book_id
    cart_items.concat(valid_items)

    # Re-assign to session to ensure persistence
    session[:cart]["cart_items"] = cart_items

    render json: { message: "successfully added item/s to cart", cart: { count: cart_items.count, items: cart_items } }, status: :ok
  end

  def remove
    cart_items = session[:cart]["cart_items"]

    book_id = params[:book_id].to_s
    # Find item index to remove
    original_count = cart_items.size
    cart_items.reject! { |item| item["book_id"] == book_id }

    session[:cart]["cart_items"] = cart_items

    if cart_items.size == original_count
      render json: { message: "item not found in cart" }, status: :not_found
    else
      render json: { message: "item removed", cart: { count: cart_items.count, items: cart_items } }, status: :ok
    end
  end

  def clear
    if session[:cart].blank? || session[:cart]["cart_items"].blank?
      render json: { message: "cart already empty" }, status: :ok and return
    end

    reset_cart!

    render json: { message: "cart cleared", cart: { count: 0, items: [] } }, status: :ok
  end

  def update
    cart_items = session[:cart]["cart_items"]
    cart_items.each do |item|
      if item["book_id"] == update_params[:book_id]
        item["quantity"] = update_params[:quantity].to_i
        render json: { message: "item removed", cart: { count: cart_items.count, items: cart_items } }, status: :ok and return
      end
    end
    render json: { message: "item not found in cart" }, status: :not_found
  end

  def checkout
    render json: { message: "cart empty" }, status: :not_found if session[:cart].blank?
    total_price = session[:cart]["cart_items"].reduce(0) { |sum, item| sum + (item["price"].to_f * item["quantity"].to_i) }
    order = Order.new(user: current_user, status: "pending", total_price: total_price)
    if order.save
      session[:cart]["cart_items"].each do |item|
        OrderItem.new(book_id: item[:book_id], quantity: item[:quantity].to_i, price: item[:price].to_f, order_id: order.id).save
      end
    end
    render json: { message: "checked out successfully", order: order }, status: :ok
  end

  private

  def reset_cart!
    session[:cart]["cart_items"] = []
  end

  def cart_params
    params.permit(items: [:book_id, :quantity, :price])[:items] || []
  end

  def update_params
    params.permit(:book_id, :quantity)
  end
end
