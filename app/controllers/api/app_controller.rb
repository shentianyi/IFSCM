#encoding: utf-8
module Api
  class AppController<ActionController::Base
    skip_before_filter :verify_authenticity_token
  end
end