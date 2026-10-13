# frozen_string_literal: true

module Shoebox
  module Relations
    class Clips < Shoebox::DB::Relation
      schema :clips, infer: true do
        associations do
          belongs_to :user
        end
      end
    end
  end
end
