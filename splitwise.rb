require 'csv'

COLUMN_PAID_BY = "Paid By"
COLUMN_AMOUNT_PER_PERSON = "Per Person"

# Spits out an array of items of the shape { paid_by, amount_cents, owes }, where
#   paid_by: The person who paid the amount
#   amount_cents: The paid amount, in cents
#   owes: The person who owes paid_by the amount
#
# The file format should include columns:
#   Paid By: name of the person who paid
#   Per Person: the amount a person owes the payer
#   [Person]: the name of the person who owes the payer; the column should should be either true iff this person owes the payer, false otherwise
def parse_csv(file_path)
  expenses = []

  # Read the CSV file
  CSV.foreach(file_path, headers: true) do |row|
    expense = create_expenses(row)
    next unless expense
    expenses << create_expenses(row).compact
  end

  expenses.flatten
end

def create_expenses(row)
  expenses = []
  paid_by = row[COLUMN_PAID_BY]
  amount = row[COLUMN_AMOUNT_PER_PERSON]
  amount_cents = (amount.to_f * 100).to_i

  # For each person who owes, create an entry
  row.each do |column_name, value|
    next if column_name == COLUMN_PAID_BY || column_name == COLUMN_AMOUNT_PER_PERSON || column_name == paid_by

    expenses << {
      paid: paid_by,
      amount_cents: amount_cents,
      owes: column_name
    }
  end

  expenses
end

def summarize_expenses(expenses)
  # Initialize a hash to store total owed between people
  owed_totals = Hash.new { |hash, key| hash[key] = Hash.new(0) }

  # Loop through the expenses to aggregate totals
  expenses.each do |expense|
    payer = expense[:paid]
    ower = expense[:owes]
    amount_cents = expense[:amount_cents]

    debt = owed_totals[ower][payer] += amount_cents
    reverse_debt = owed_totals[payer][ower]
    net_debt = debt - reverse_debt

    if net_debt > 0
      owed_totals[ower][payer] = net_debt
      owed_totals[payer].delete(ower)
    else
      owed_totals[payer][ower] = -net_debt
      owed_totals[ower].delete(payer)
    end
  end

  # Output the totals in a readable format
  owed_totals.each do |owes, debts|
    debts.each do |paid_by, amount_cents|
      amount_dollars = amount_cents / 100.0
      puts "#{owes} owes #{paid_by} $#{'%.2f' % amount_dollars}"
    end
  end
end

# Example usage:
file_path = "expenses.csv"
expenses = parse_csv(file_path)
summarize_expenses(expenses)
