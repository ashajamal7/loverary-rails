class CategoriesController < ApplicationController
  before_action :set_category, only: [ :show, :update, :destroy ]

  # GET /categories
  def index
    Rails.logger.info "Fetching all categories"
    @categories = Category.all
    Rails.logger.debug "Found #{@categories.size} categories"

    render json: @categories
  end

  # GET /categories/1
  def show
    Rails.logger.info "Fetching category with ID: #{params[:id]}"
    Rails.logger.debug "Category details: #{@category.attributes}"

    render json: @category
  end

  # POST /categories
  def create
    @category = Category.new(category_params)

    if @category.save
      render json: @category, status: :created, location: @category
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  def update
    if @category.update(category_params)
      render json: @category
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
    head :no_content
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def category_params
    params.require(:category).permit(:name, :description)
  end
end