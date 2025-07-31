# frozen_string_literal: true

Rails.application.config.middleware.use ActionDispatch::Cookies
Rails.application.config.middleware.use ActionDispatch::Session::CookieStore, key: "_loverary_session"

