# frozen_string_literal: true

module Shoebox
  module Relations
    class Users < Shoebox::DB::Relation
      schema :users, infer: true do
        associations do
          has_many :sessions
        end
      end
    end
  end
end
