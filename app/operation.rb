# auto_register: false
# frozen_string_literal: true

require "dry/operation"

module Shoebox
  class Operation < Dry::Operation
    include Hanami::Attachments::Steps
  end
end
