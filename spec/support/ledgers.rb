module SpecHelpers
  module Ledgers
    def self.included(base)
      base.let(:empty_ledger) { "" }
    end
  end
end