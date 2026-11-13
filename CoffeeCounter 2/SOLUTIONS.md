# Solutions (spoilers!)

## Level 1: compile errors

### CoffeeOrder.swift

**1. Unterminated nested comment** (The Basics → Comments)
Swift's multiline comments can be nested. The inner `/*` needs its own `*/`, so the outer
comment never ends and swallows `OrderError` and `validate`. That's why ContentView
complains they don't exist: a single mistake causing errors in a *different file*.
```swift
/* Validation rules
   A name is required so the barista can call it out.
   Each menu item has its own limit per order. */
```

**2. `let taxRate: Int = 0.08`** (The Basics → Type Annotations)
`0.08` is a `Double`. The annotation must match.
```swift
let taxRate = 0.08   // or: let taxRate: Double = 0.08
```

**3 & 4. `subtotal`** (Type Inference; Integer and Floating-Point Conversion)
`var total = 0` is inferred as `Int`, and `Double * Int` isn't allowed.
```swift
var total: Dollars = 0
for entry in items {
    total += entry.item.price * Double(entry.quantity)
}
```

**5. `tip`** (Integer and Floating-Point Conversion)
`subtotal * (tipPercent / 100)` multiplies a `Double` by an `Int`.
The trap: `Double(tipPercent / 100)` compiles but `15 / 100` is integer division, which is `0`,
so the tip is always $0. Convert *before* dividing:
```swift
subtotal * Double(tipPercent) / 100
```

### ContentView.swift

**6. `greeting`: variable used before being initialized** (Declaring Constants and Variables)
```swift
var message = "Who's this order for?"
if !order.customerName.isEmpty {
    message = "Hi, \(order.customerName)!"
}
return message
```

**7. `itemCountLabel`: mixing `Int` and `String`** (Ternary Conditional Operator; Printing / string interpolation)
```swift
order.itemCount == 1 ? "1 item" : "\(order.itemCount) items"
```

**8. `discountLabel`: using an optional as if it weren't one** (Optionals, Optional Binding)
```swift
if let code = order.discountCode, !code.isEmpty {
    return "Code applied: " + code
}
return "No code applied"
```
Shorter alternative with nil-coalescing (Basic Operators): `"Code applied: " + (order.discountCode ?? "")`.

**9. `entry.qty`: wrong tuple label** (Tuples)
```swift
"\(entry.quantity) × \(entry.item.name)"
```

**10. `let default`: reserved keyword** (Naming Constants and Variables)
`default` is a Swift keyword (used in `switch`). Rename it, e.g. `defaultQuantityText`.
(Backticks, `` let `default` ``, also work, but the book recommends avoiding keywords as names.)

**11. `let quantity: Int = Int(quantityText)`** (Optionals, Optional Binding)
`Int("hello")` can't produce a number, so `Int(_:)` returns `Int?`. Use optional binding,
and also reject zero or negative amounts:
```swift
func addSelectedItem() {
    let defaultQuantityText = "1"
    guard let quantity = Int(quantityText), quantity > 0 else {
        statusMessage = "Enter a whole number greater than 0."
        return
    }
    order.add(selectedItem, quantity: quantity)
    quantityText = defaultQuantityText
    statusMessage = ""
}
```
❌ `Int(quantityText)!` compiles, but crashes when the text isn't a number.

**12. `let statusMessage = ""` inside `placeOrder`** (Constants and Variables)
This local constant *shadows* the `@State` property, and constants can't be changed.
Delete the line so the code uses the property.

**13. `validate(order)` without `try`** (Error Handling)
See the full `placeOrder` below. Note the `return` in each `catch`, without which the
invalid order is still placed (a Level 2 bug).

**14. `orderNumber++`** (Compound Assignment Operators)
Swift removed `++`. Use `orderNumber += 1`.

**15. `if order.discount`** (Booleans)
Swift won't treat a number as true/false. Say what you mean: `if order.discount > 0`.

**16. `if order.tipPercent = 20`** (Assignment Operator)
In Swift, `=` doesn't return a value, so this mistake can't silently compile like it can
in C. Use `==`.

## Level 2: runtime and logic bugs

**A. Crash on launch: "Index out of range"** (Range Operators)
`0...order.items.count` with 0 items still visits index `0`. A list of `n` items has
indexes `0..<n`. Use the half-open range, or better, let the array tell you:
```swift
ForEach(order.items.indices, id: \.self) { index in
```

**B. Force-unwrap crash** (Forced Unwrapping), if you fixed #11 with `!`. See #11.

**C. Tip is $0.00.** Integer division. See #5.

**D. Discount applies to small orders** (Logical Operators → Explicit Parentheses)
`&&` binds tighter than `||`, so the code means
`code == "WELCOME10" || (code == "welcome10" && subtotal > 10)`.
The minimum only applies to the lowercase code.
```swift
if (discountCode == "WELCOME10" || discountCode == "welcome10") && subtotal > 10 {
```

**E. Can't order exactly 4 lattes** (Comparison Operators)
`>=` rejects the maximum itself. "Too many" means *more than* the max:
```swift
if entry.quantity > entry.item.maxPerOrder {
```

**F. Free-order logic is backwards** (Remainder Operator)
`orderNumber / 5 == 0` is true for 1–4 (integer division). You want the remainder:
```swift
if orderNumber % 5 == 0 {
```

**G. Crash after the 6th order** (Integer Bounds)
`UInt8` holds 0–255. 6 × 50 = 300, which overflows, and Swift stops the app instead
of silently wrapping. Use `Int`:
```swift
@State private var loyaltyPoints = 0
```

**H. Ugly money in the status message.** String interpolation prints the raw `Double`.
Format it the same way the summary rows do:
```swift
order.total.formatted(.currency(code: "USD"))
```

## Fully fixed `placeOrder`
```swift
func placeOrder() {
    do {
        try validate(order)
    } catch OrderError.missingName {
        statusMessage = "Add a name so the barista can call it out."
        return
    } catch OrderError.emptyOrder {
        statusMessage = "Add at least one item first."
        return
    } catch OrderError.tooMany(let itemName) {
        statusMessage = "That's too many of \(itemName) for one order."
        return
    } catch {
        statusMessage = "Couldn't place the order."
        return
    }

    orderNumber += 1
    loyaltyPoints += 50

    // Every 5th order is free
    if orderNumber % 5 == 0 {
        statusMessage = "Order #\(orderNumber) is on the house!"
    } else {
        statusMessage = "Order #\(orderNumber) placed. Total: \(order.total.formatted(.currency(code: "USD")))"
    }

    if order.discount > 0 {
        statusMessage += " You saved \(order.discount.formatted(.currency(code: "USD")))."
    }

    if order.tipPercent == 20 {
        statusMessage += " Thanks for the generous tip!"
    }

    order = CoffeeOrder(customerName: "")
}
```

## Bug map

| # | Bug | Chapter section |
|---|---|---|
| 1 | Unclosed nested comment | Basics: Comments |
| 2 | Wrong type annotation | Basics: Type Annotations |
| 3 | `0` inferred as `Int` | Basics: Type Safety and Type Inference |
| 4, 5 | Mixing `Int` and `Double` | Basics: Integer and Floating-Point Conversion |
| 6 | Variable used before initialized | Basics: Constants and Variables |
| 7 | Ternary branches of different types | Operators: Ternary Conditional |
| 8 | Optional used as non-optional | Basics: Optionals / Optional Binding |
| 9 | Wrong tuple label | Basics: Tuples |
| 10 | Keyword as a name | Basics: Naming Constants and Variables |
| 11 | `Int(String)` returns an optional | Basics: Optionals |
| 12 | Assigning to a `let` | Basics: Constants and Variables |
| 13 | Missing `try` / `catch` | Basics: Error Handling |
| 14 | `++` doesn't exist | Operators: Compound Assignment |
| 15 | Number used as a condition | Basics: Booleans |
| 16 | `=` instead of `==` | Operators: Assignment |
| A | Closed range off-by-one | Operators: Range Operators |
| B | Force unwrap of `nil` | Basics: Forced Unwrapping |
| C | Integer division | Basics: Numeric conversion |
| D | `&&` / `||` precedence | Operators: Logical Operators, Explicit Parentheses |
| E | `>=` vs `>` | Operators: Comparison |
| F | `/` vs `%` | Operators: Remainder |
| G | `UInt8` overflow | Basics: Integer Bounds |
| H | Unformatted `Double` | Basics: String interpolation |
