# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module Shoebox
  class Action < Hanami::Action
    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]
    include Authentication
  end
end
