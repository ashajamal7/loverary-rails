class OrdersController < ApplicationController
  before_action :require_login
  before_action :set_order, only: [ :show, :update ]

  # GET /users/orders
  def index
    @orders = current_user.orders.order(created_at: :desc)
    render json: {
      orders: @orders.as_json(include: {
        order_items: {
          include: {
            book: {
              methods: [ :cover_url ],
              only: [ :id, :title, :price, :cover_url ]
            }
          },
          only: [ :id, :quantity, :price ]
        }
      })
    }
  end

  # GET /users/orders/:id
  def show
    if @order.user_id != current_user.id
      return render_unauthorized("You are not authorized to view this order")
    end

    render json: {
      order: @order.as_json(include: {
        order_items: {
          include: {
            book: {
              methods: [ :cover_url ],
              only: [ :id, :title, :price, :cover_url ]
            }
          },
          only: [ :id, :quantity, :price ]
        }
      })
    }
  end

  # POST /users/orders
  def create
    # Orders should be created through the checkout process, not directly
    render json: { error: "Please use the checkout process to create an order" },
           status: :method_not_allowed
  end

  # PATCH/PUT /users/orders/:id
  def update
    if @order.user_id != current_user.id
      return render_unauthorized("You are not authorized to update this order")
    end

    # Only allow updating status to 'cancelled' by the user
    if params[:order] && params[:order][:status] == "cancelled"
      if @order.update(status: "cancelled")
        render json: { message: "Order cancelled successfully" }
      else
        render json: { errors: @order.errors }, status: :unprocessable_entity
      end
    else
      render json: { error: "You can only cancel your own orders" },
             status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find_by(id: params[:id])
    render_not_found("Order not found") unless @order
  end

  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end

  def render_not_found(message)
    render json: { error: message }, status: :not_found
  end
end
