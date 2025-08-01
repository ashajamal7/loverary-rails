class UsersController < ApplicationController
  skip_before_action :authenticate_user_from_token!, only: [:create]
  before_action :set_user, only: [ :show, :update, :destroy ]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      cookies.signed[:user_id] = {
        value: @user.id,
        httponly: true,
        expires: 2.weeks.from_now
      }
      render json: UserBlueprint.render(@user, root: :user), status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.

  private

  def user_params
    params.require(:user).permit(:email, :username, :password)
  end
end
