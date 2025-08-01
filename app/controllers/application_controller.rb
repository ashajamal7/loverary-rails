class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  before_action :set_csrf_cookie
  before_action :authenticate_user_from_token!
  
  protected
  
  def set_csrf_cookie
    cookie_options = {
      value: form_authenticity_token,
      same_site: Rails.env.production? ? :none : :lax,
      secure: Rails.env.production?,
      domain: :all
    }
    
    # Remove domain in development to avoid issues with localhost
    cookie_options.delete(:domain) if Rails.env.development?
    
    cookies["CSRF-TOKEN"] = cookie_options
  end

  def current_user
    @current_user ||= begin
      token = request.headers['Authorization']&.split(' ')&.last
      if token
        begin
          payload = JWT.decode(token, Rails.application.credentials.secret_key_base).first
          User.find_by(id: payload['user_id'])
        rescue JWT::DecodeError
          nil
        end
      else
        User.find_by(id: cookies.signed[:user_id])
      end
    end
  end

  def require_login
    return if current_user
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  private

  def authenticate_user_from_token!
    return if current_user
    
    if request.headers['Authorization'].present?
      render json: { error: "Invalid or expired token" }, status: :unauthorized
    else
      render json: { error: "Authentication required" }, status: :unauthorized
    end
  end
  
  # Converts a relative URL to an absolute URL for image serving using direct storage
  # @param url [String] The relative URL of the image
  # @return [String, nil] The absolute URL or nil if the input is blank
  # Serves files from the storage directory
  def serve_storage
    Rails.logger.info "[DEBUG] serve_storage called with path: #{request.path}"
    
    # For /covers path, look in storage/covers directory
    if request.path.start_with?('/covers/')
      # Get the path parameter and clean it
      clean_path = params[:path].to_s.gsub(%r{^covers/}, '')
      
      # Log the clean path
      Rails.logger.info "[DEBUG] Clean path: #{clean_path}"
      
      # Construct the full file path
      file_path = Rails.root.join('storage', 'covers', clean_path).to_s
      
      # Log the full file path being checked
      Rails.logger.info "[DEBUG] Looking for file at: #{file_path}"
      
      # Check if file exists and is not a directory
      if File.exist?(file_path) && !File.directory?(file_path)
        Rails.logger.info "[DEBUG] File found, sending file..."
        send_file file_path, disposition: 'inline'
      else
        # Log detailed error information
        if !File.exist?(file_path)
          Rails.logger.error "[ERROR] File does not exist: #{file_path}"
        elsif File.directory?(file_path)
          Rails.logger.error "[ERROR] Path is a directory, not a file: #{file_path}"
        end
        
        # List directory contents for debugging
        dir_path = File.dirname(file_path)
        if File.directory?(dir_path)
          files = Dir.glob(File.join(dir_path, '*')).map { |f| File.basename(f) }
          Rails.logger.info "[DEBUG] Directory contents of #{dir_path}: #{files.inspect}"
        else
          Rails.logger.error "[ERROR] Directory does not exist: #{dir_path}"
        end
        
        head :not_found
      end
    else
      Rails.logger.error "[ERROR] Invalid path, must start with /covers/: #{request.path}"
      head :not_found
    end
  end
  
  def ensure_absolute_url(url)
    return nil if url.blank?
    return url if url.start_with?('http://', 'https://')
    
    # Clean the URL by removing any leading/trailing slashes and 'covers/' prefix if present
    clean_url = url.gsub(%r{^/|/$}, '').gsub(%r{^covers/}, '')
    
    # For local development
    if Rails.env.development? || Rails.env.test?
      "http://localhost:3000/covers/#{clean_url}"
    else
      # For production, use your actual domain
      "https://your-production-domain.com/covers/#{clean_url}"
    end
  end
end
