# The shop this deployment serves. One codebase, one build of the app, any
# shop: everything customer-facing that names the shop reads from here.
module Shop
  def self.name = ENV.fetch("SHOP_NAME", "MyKiosk")
end
