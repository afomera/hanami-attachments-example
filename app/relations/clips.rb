# frozen_string_literal: true

module Shoebox
  module Relations
    class Clips < Shoebox::DB::Relation
      schema :clips, infer: true
    end
  end
end
