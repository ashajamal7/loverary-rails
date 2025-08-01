class SessionsController < ApplicationController
  def login
    user = User.find_by(email: login_params[:email])
    if user && user.authenticate(login_params[:password])
      session[:user_id] = user.id
      cookies.signed[:user_id] = {
        value: user.id,
        httponly: true,
        expires: 2.weeks.from_now
      }
      session[:cart] = { user_id: user.id, cart_items: [] }
      render json: UserBlueprint.render(user, root: :user), status: :ok
    else
      render json: user&.errors, status: :unauthorized
    end
  end

  def logout
    reset_session
    cookies.delete(:user_id)
    render json: { message: "logout successful" }, status: :ok
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  private
  def register_params
    params.require(:user).permit(:username, :email, :password)
  end

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
