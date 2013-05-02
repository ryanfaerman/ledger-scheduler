require 'spec_helper'
require 'ledger_scheduler/parser'

module LedgerScheduler
  describe Parser do
    subject {LedgerScheduler::Parser}
    
    let(:empty_ledger) {""}
    let(:single_transaction) {
      "2006/10/15 Exxon\n" +
      "\tExpenses:Auto:Gas\t\t\t\t\t$10.00\n" +
      "\tLiabilities:MasterCard\t\t\t\t\t$-10.00\n\n"
    }
    let(:multiple_transactions) {
      "2006/10/15 Exxon\n" +
      "\tExpenses:Auto:Gas\t\t\t\t\t$10.00\n" +
      "\tLiabilities:MasterCard\t\t\t\t\t$-10.00\n\n" +
      "2006/11/15 Exxon\n" +
      "\tExpenses:Auto:Gas\t\t\t\t\t$10.00\n" +
      "\tLiabilities:MasterCard\t\t\t\t\t$-10.00\n\n"
    }

    let(:partial_transactions) {
      "2006/10/15 Exxon\n" +
      "\tExpenses:Auto:Gas\t\t\t\t\t$10.00\n" +
      "\tLiabilities:MasterCard\t\t\t\t\t$-5.00\n"+
      "\tLiabilities:Visa\t\t\t\t\t$-5.00\n\n"
    }

    let(:credit_inferred){}
    let(:debit_inferred) {}
    let(:multiple_inferred){}

    context 'with an invalid ledger' do
      specify {->{subject.new}.should raise_error(ArgumentError)}
    end

    describe 'valid ledgers' do
      it 'empty ledger' do
        ->{subject.new("")}.should_not raise_error(ArgumentError)
      end

      it 'single transaction' do
        ->{subject.new(single_entry)}.should_not raise_error(ArgumentError)
      end

      it 'multiple transaction' do
        ->{subject.new(multiple_transactions)}.should_not raise_error(ArgumentError)
      end
    end

    describe 'parsing' do
      it 'single' do
        puts subject.new(multiple_transactions).parse!
      end

      it 'partisl' do
        puts subject.new(partial_transactions).parse!
      end
    end
  end
end