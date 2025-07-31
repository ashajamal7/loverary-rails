class SessionsController < ApplicationController
  def register
    user = User.new(register_params)

    if user.save
      render json: UserBlueprint.render(user, root: :user), status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: login_params[:email])
    if user && user.authenticate(login_params[:password])
      session[:user_id] = user.id
      cookies.signed[:user_id] = {
        value: user.id,
        httponly: true,
        expires: 2.weeks.from_now
      }
      session[:cart] = {}
      session[:cart][:user_id] = user.id
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

  private

  def register_params
    params.require(:user).permit(:username, :email, :password)
  end

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
