class ApplicationController < ActionController::API
  include ActionController::Cookies

  def current_user
    @current_user ||= User.find_by(id: cookies.signed[:user_id])
  end

  def require_login
    return if current_user

    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
