# frozen_string_literal: true

module Shoebox
  module Relations
    class Photos < Shoebox::DB::Relation
      schema :photos, infer: true do
        associations do
          belongs_to :user
        end
      end
    end
  end
end
