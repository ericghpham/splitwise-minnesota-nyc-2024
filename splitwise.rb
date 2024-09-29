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
  items = []

  # Read the CSV file
  CSV.foreach(file_path, headers: true) do |row|
    paid_by = row[COLUMN_PAID_BY]
    amount = row[COLUMN_AMOUNT_PER_PERSON]
    amount_cents = (amount.to_f * 100).to_i

    # For each person who owes, create an entry
    row.each do |column_name, value|
      next if column_name == COLUMN_PAID_BY || column_name == COLUMN_AMOUNT_PER_PERSON || column_name == paid_by

      items << {
        paid: paid_by,
        amount_cents: amount_cents,
        owes: column_name
      }
    end
  end

  items
end

def summarize_expenses(expenses)
  # Initialize a hash to store total owed between people
  owed_totals = Hash.new { |hash, key| hash[key] = Hash.new(0) }

  # Loop through the expenses to aggregate totals
  expenses.each do |expense|
    paid_by = expense[:paid]
    owes = expense[:owes]
    amount_cents = expense[:amount_cents]

    # Add the amount owed by each person
    owed_totals[owes][paid_by] += amount_cents
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
# puts result
