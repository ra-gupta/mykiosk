module ApplicationHelper
  def rupees(amount) = number_to_currency(amount, unit: "₹", precision: 2)
end
