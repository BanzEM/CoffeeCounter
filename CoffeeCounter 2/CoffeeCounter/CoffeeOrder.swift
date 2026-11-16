import Foundation

typealias Dollars = Double

struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Dollars
    let maxPerOrder: Int
}

let menu = [
    MenuItem(name: "Espresso", price: 2.50, maxPerOrder: 6),
    MenuItem(name: "Latte", price: 4.25, maxPerOrder: 4),
    MenuItem(name: "Cold Brew", price: 3.75, maxPerOrder: 4),
    MenuItem(name: "Blueberry Muffin", price: 2.95, maxPerOrder: 10)
]

struct CoffeeOrder {
    var customerName: String
    var items: [(item: MenuItem, quantity: Int)] = []
    let taxRate: Int = Int(0.08)
    var tipPercent = 15
    var discountCode: String?

    mutating func add(_ item: MenuItem, quantity: Int) {
        items.append((item: item, quantity: quantity))
    }

    var itemCount: Int {
        var count = 0
        for entry in items {
            count += entry.quantity
        }
        return count
    }

    var subtotal: Dollars {
        var total = 0
        for entry in items {
            total += Int(entry.item.price) * entry.quantity
        }
        return total
    }

    var tax: Dollars {
        subtotal * taxRate
    }

    var tip: Dollars {
        subtotal * (tipPercent / 100)
    }

    // WELCOME10 takes 10% off orders with a subtotal over $10
    var discount: Dollars {
        if discountCode == "WELCOME10" || discountCode == "welcome10" && subtotal > 10 {
            return subtotal * 0.10
        }
        return 0
    }

    var total: Dollars {
        subtotal + tax + tip - discount
    }
}

/* Validation rules
   /* A name is required so the barista can call it out.
   Each menu item has its own limit per order. */

enum OrderError: Error {
    case missingName
    case emptyOrder
    case tooMany(itemName: String)
}

func validate(_ order: CoffeeOrder) throws {
    if order.customerName.isEmpty {
        throw OrderError.missingName
    }
    if order.items.isEmpty {
        throw OrderError.emptyOrder
    }
    for entry in order.items {
        if entry.quantity >= entry.item.maxPerOrder {
            throw OrderError.tooMany(itemName: entry.item.name)
        }
    }
} */
