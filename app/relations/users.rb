# frozen_string_literal: true

module Shoebox
  module Relations
    class Users < Shoebox::DB::Relation
      schema :users, infer: true do
        associations do
          has_many :sessions
          has_many :photos
          has_many :clips
        end
      end
    end
  end
end
