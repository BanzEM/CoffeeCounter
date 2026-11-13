# Hints

Each hint points you in the right direction without giving the answer away.
The section name tells you which part of the Swift book to reread.

## Level 1: compile errors

**CoffeeOrder.swift**

1. *Errors appear about `validate` and `OrderError` not existing, even though they're right there.*
   Look at the colors in the editor near the bottom of the file. What does Swift do when a
   multiline comment contains *another* multiline comment? (The Basics → Comments)
2. *`taxRate`.* What kind of number is `0.08`? What kind did the code promise?
   (The Basics → Type Annotations)
3. *`var total = 0` in `subtotal`.* What type does Swift guess for `0`? What does the
   function return? (The Basics → Type Safety and Type Inference)
4. *`price * quantity`.* Swift never mixes number types for you, even when it seems
   obvious. (The Basics → Integer and Floating-Point Conversion)
5. *`tip`.* Same family of error as hint 4. Be careful: there's a fix that compiles but
   gives the wrong answer. Test it with a $10.00 subtotal. (The Basics → Integer and
   Floating-Point Conversion)

**ContentView.swift**

6. *`greeting`.* What value does `message` have if the name is empty?
   (The Basics → Declaring Constants and Variables)
7. *`itemCountLabel`.* Both sides of `? :` must be the same type. How do you put a number
   inside a string? (Basic Operators → Ternary Conditional Operator; The Basics → Printing)
8. *`discountLabel`.* `discountCode` might be `nil`. You can't glue "maybe a string" onto a
   string. (The Basics → Optionals, Optional Binding)
9. *`lineText`.* Check the tuple's labels in `CoffeeOrder.swift`. (The Basics → Tuples)
10. *`let default`.* Some words already mean something to Swift.
    (The Basics → Naming Constants and Variables)
11. *`Int(quantityText)`.* What happens if the text is `"hello"`? What type does `Int(...)`
    return to handle that? (The Basics → Optionals)
12. *`statusMessage` in `placeOrder`.* There are two things called `statusMessage`. Which
    one is the code changing? (The Basics → Constants and Variables)
13. *`validate(order)`.* This function can fail. Swift makes you deal with that.
    (The Basics → Error Handling)
14. *`orderNumber++`.* That's from other languages. (Basic Operators → Compound Assignment Operators)
15. *`if order.discount`.* An `if` needs a `Bool`, not a number. (The Basics → Booleans)
16. *`if order.tipPercent = 20`.* One symbol stores a value, the other compares.
    (Basic Operators → Assignment Operator)

## Level 2: runtime and logic bugs

- **Crash on launch:** The crash says "Index out of range". How many items are there at
  first, and which numbers does the loop visit? (Basic Operators → Range Operators)
- **Typing letters in the quantity field crashes:** Did you fix hint 11 with `!`?
  (The Basics → Forced Unwrapping)
- **Tip is always $0.00:** Work out `15 / 100` using only whole numbers.
- **Discount applies to a $2.50 order:** Which runs first, `&&` or `||`?
  (Basic Operators → Logical Operators, Explicit Parentheses)
- **Can't order 4 lattes:** Read the comparison in `validate` out loud.
  (Basic Operators → Comparison Operators)
- **Invalid orders still get placed:** After you catch the error, what does the function do next?
- **Orders 1–4 are free, order 5 isn't:** What's `3 / 5` in integer math? Which operator gives
  the *remainder*? (Basic Operators → Remainder Operator)
- **Crash after the 6th order:** What's the biggest number a `UInt8` can hold?
  (The Basics → Integer Bounds, Integers)
- **Weird long decimals in the status message:** The summary rows already format money
  nicely. How?
