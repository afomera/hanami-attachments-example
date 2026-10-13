# frozen_string_literal: true

module Shoebox
  module Operations
    module Users
      # Changes a user's avatar: a new upload, a file kept from a re-rendered form or
      # uploaded directly by the browser, or removal (hanami-attachments).
      class UpdateAvatar < Shoebox::Operation
        include Deps["repos.user_repo"]

        def call(user, params)
          avatar = step attach(:avatar, to: user,
            file: params[:avatar], cached: params[:cached_avatar], remove: params[:remove_avatar])

          persist(avatar) { |values| user_repo.update_avatar(user.id, values) }
        end
      end
    end
  end
end
