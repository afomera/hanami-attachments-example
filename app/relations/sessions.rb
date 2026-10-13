# frozen_string_literal: true

module Shoebox
  module Relations
    class Sessions < Shoebox::DB::Relation
      schema :sessions, infer: true do
        associations do
          belongs_to :user
        end
      end
    end
  end
end
