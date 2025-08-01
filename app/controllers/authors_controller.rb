class AuthorsController < ApplicationController
  before_action :set_author, only: [:show, :update, :destroy]

  # GET /authors
  def index
    Rails.logger.info "Fetching all authors"
    @authors = Author.all
    Rails.logger.debug "Found #{@authors.size} authors"

    render json: @authors
  end

  # GET /authors/1
  def show
    Rails.logger.info "Fetching author with ID: #{params[:id]}"
    Rails.logger.debug "Author details: #{@author.attributes}"
    
    render json: @author
  end

  # POST /authors
  def create
    @author = Author.new(author_params)

    if @author.save
      render json: @author, status: :created, location: @author
    else
      render json: @author.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /authors/1
  def update
    if @author.update(author_params)
      render json: @author
    else
      render json: @author.errors, status: :unprocessable_entity
    end
  end

  # DELETE /authors/1
  def destroy
    @author.destroy
  end

  private
    def set_author
      @author = Author.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:name, :gender)
    end
end