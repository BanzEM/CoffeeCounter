import SwiftUI

struct ContentView: View {
    @State private var order = CoffeeOrder(customerName: "")
    @State private var selectedItem = menu[0]
    @State private var quantityText = "1"
    @State private var discountText = ""
    @State private var orderNumber = 0
    @State private var loyaltyPoints: UInt8 = 0
    @State private var statusMessage = ""

    let tipOptions = [10, 15, 20]

    var body: some View {
        NavigationStack {
            Form {
                Section("Customer") {
                    TextField("Name", text: $order.customerName)
                    Text(greeting)
                        .foregroundStyle(.secondary)
                }

                Section("Add to order") {
                    Picker("Item", selection: $selectedItem) {
                        ForEach(menu) { item in
                            Text(item.name).tag(item)
                        }
                    }
                    TextField("Quantity", text: $quantityText)
                        .keyboardType(.numberPad)
                    Button("Add to order") {
                        addSelectedItem()
                    }
                }

                Section("Your order") {
                    ForEach(0...order.items.count, id: \.self) { index in
                        HStack {
                            Text(lineText(order.items[index]))
                            Spacer()
                            Text(lineTotal(order.items[index]), format: .currency(code: "USD"))
                        }
                    }
                    Text(itemCountLabel)
                        .foregroundStyle(.secondary)
                }

                Section("Tip") {
                    Picker("Tip", selection: $order.tipPercent) {
                        ForEach(tipOptions, id: \.self) { percent in
                            Text("\(percent)%").tag(percent)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Discount") {
                    TextField("Discount code", text: $discountText)
                        .textInputAutocapitalization(.characters)
                    Button("Apply code") {
                        order.discountCode = discountText
                    }
                    Text(discountLabel)
                        .foregroundStyle(.secondary)
                }

                Section("Total") {
                    summaryRow("Subtotal", order.subtotal)
                    summaryRow("Tax (8%)", order.tax)
                    summaryRow("Tip", order.tip)
                    summaryRow("Discount", -order.discount)
                    summaryRow("Total", order.total)
                }

                Section {
                    Button("Place order") {
                        placeOrder()
                    }
                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                    }
                    Text("Loyalty points: \(loyaltyPoints)")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Coffee Counter")
        }
    }

    // MARK: - Labels

    var greeting: String {
        var message: String
        if !order.customerName.isEmpty {
            message = "Hi, \(order.customerName)!"
        }
        return message
    }

    var itemCountLabel: String {
        order.itemCount == 1 ? "1 item" : String(order.itemCount) + " items"
    }

    var discountLabel: String {
        if order.discountCode == nil {
            return "No code applied"
        }
        
        let unwrappedDiscount = order.discountCode ?? ""
        
        return "Code applied: " + unwrappedDiscount
    }

    func lineText(_ entry: (item: MenuItem, quantity: Int)) -> String {
        "\(entry.quantity) × \(entry.item.name)"
    }

    func lineTotal(_ entry: (item: MenuItem, quantity: Int)) -> Dollars {
        entry.item.price * Double(entry.quantity)
    }

    func summaryRow(_ title: String, _ amount: Dollars) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(amount, format: .currency(code: "USD"))
        }
    }

    // MARK: - Actions

    func addSelectedItem() {
        let default = "1"
        let quantity: Int = Int(quantityText)
        order.add(selectedItem, quantity: quantity)
        quantityText = default
    }

    func placeOrder() {
        let statusMessage = ""

        validate(order)

        orderNumber++
        loyaltyPoints += 50

        // Every 5th order is free
        if orderNumber / 5 == 0 {
            statusMessage = "Order #\(orderNumber) is on the house!"
        } else {
            statusMessage = "Order #\(orderNumber) placed. Total: \(order.total)"
        }

        if order.discount {
            statusMessage += " You saved \(order.discount)."
        }

        if order.tipPercent = 20 {
            statusMessage += " Thanks for the generous tip!"
        }

        order = CoffeeOrder(customerName: "")
    }
}

#Preview {
    ContentView()
}
