require 'spec_helper'
require 'ledger_scheduler/parser'

module LedgerScheduler
  describe Parser do
    subject(:parser) {LedgerScheduler::Parser.new(EXAMPLE_LEDGER)}

    context 'with an invalid ledger' do
      specify {->{LedgerScheduler::Parser.new}.should raise_error(ArgumentError)}
    end

    describe 'parsing' do
      describe 'entries' do
        subject(:entries) {parser.entries}
        its(:length) {should == 5}

        describe 'first entry' do
          subject(:first_entry) {entries.first}

          its([:desc]) { should == "* Checking balance" }
          its([:date]) { should == "2004/05/01" }

          describe 'first account' do
            subject {first_entry[:accounts].first}

            its([:name])    {should == "Assets:Bank:Checking"}
            its([:amount])  {should == 1000}
          end

          describe 'last account' do
            subject {first_entry[:accounts].last}

            its([:name])    { should == "Equity:Opening Balances" }
            its([:amount])  { should == -1000 }
          end
        end

        describe 'last entry' do
          subject(:last_entry) { entries.last }

          its([:desc]) { should == "(100) Credit card company" }
          its([:desc]) { should == "(100) Credit card company" }
          its([:date]) { should == "2004/05/27" }

          describe 'first account' do
            subject { last_entry[:accounts].first }

            its([:name])    {should == "Liabilities:MasterCard"}
            its([:amount])  {should == 20.24}
          end

          describe 'last account' do
            subject { last_entry[:accounts].last }

            its([:name])    {should == "Assets:Bank:Checking"}
            its([:amount])  {should == -20.24}
          end
          
        end
      end
      
    end

    describe "balance" do
      it "it should balance out missing account values" do
        subject.balance([
            { :name => "Account1", :amount => 1000 },
            { :name => "Account2", :amount => nil }
        ]).should == [ { :name => "Account1", :amount => 1000 }, { :name => "Account2", :amount => -1000 } ]
      end

      it "it should balance out missing account values" do
        subject.balance([
            { :name => "Account1", :amount => 1000 },
            { :name => "Account2", :amount => 100 },
            { :name => "Account3", :amount => -200 },
            { :name => "Account4", :amount => nil }
        ]).should == [
            { :name => "Account1", :amount => 1000 },
            { :name => "Account2", :amount => 100 },
            { :name => "Account3", :amount => -200 },
            { :name => "Account4", :amount => -900 }
        ]
      end

      it "it should work on normal values too" do
        subject.balance([
            { :name => "Account1", :amount => 1000 },
            { :name => "Account2", :amount => -1000 }
        ]).should == [ { :name => "Account1", :amount => 1000 }, { :name => "Account2", :amount => -1000 } ]
      end
    end

  end
end

# Data

EXAMPLE_LEDGER = (<<-LEDGER).strip
= /^Expenses:Books/
  (Liabilities:Taxes)             -0.10

~ Monthly
  Assets:Bank:Checking          $500.00
  Income:Salary

2004/05/01 * Checking balance
  Assets:Bank:Checking        $1,000.00
  Equity:Opening Balances

2004/05/01 * Investment balance
  Assets:Brokerage              50 AAPL @ $30.00
  Equity:Opening Balances

; blah
!account blah

!end

D $1,000

2004/05/14 * Pay day
  Assets:Bank:Checking          $500.00
  Income:Salary

2004/05/27 Book Store
  Expenses:Books                 $20.00
  Liabilities:MasterCard
2004/05/27 (100) Credit card company
  Liabilities:MasterCard         $20.24
  Assets:Bank:Checking
  LEDGER