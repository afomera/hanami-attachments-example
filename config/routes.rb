# frozen_string_literal: true

module Shoebox
  class Routes < Hanami::Routes
    # Add your routes here. See https://hanakai.org/learn/hanami/routing/ for details.

    resource :session, only: %i[new create destroy]
    resources :passwords, only: %i[new create edit update]
  end
end
