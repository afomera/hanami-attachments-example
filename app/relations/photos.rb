# frozen_string_literal: true

module Shoebox
  module Relations
    class Photos < Shoebox::DB::Relation
      schema :photos, infer: true
    end
  end
end
