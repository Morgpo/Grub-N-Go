# Business Rules

## A. Account & Identity

- **BR-001 - Single-account-per-party**: Every Account belongs to exactly one party: either a Customer or a Restaurant. Each Customer or Restaurant is backed by exactly one Account.

- **BR-002 - Account uniqueness**: Account.email must be unique across all accounts.

- **BR-003 - Account status**: Accounts have statuses {Active, Suspended, Closed}. Only Active accounts may place/receive new orders.

- **BR-004 - Authentication data**: Passwords are stored hashed; login attempts are rate-limited. (Security rule; impacts application logic.)

- **BR-005 - Account creation audit**: Creating, deactivating, and deleting accounts must be auditable with time and actor recorded.

## B. Customers

- **BR-006 - Customer contact**: A Customer must have at least one contact method (email or phone).

- **BR-007 - Addressing**: Customers may have zero or more saved delivery addresses. Addresses are address records; each order stores the chosen delivery address as a snapshot.

- **BR-008 - Payment methods**: Customers may register zero or more payment methods; payment tokens are stored, not raw card numbers.

- **BR-009 - Permissions**: Customers can perform actions only for their own accounts and orders.

## C. Restaurants

- **BR-010 - Restaurant account link**: Each Restaurant must have an Account and contact info for order issues.

- **BR-011 - Ownership of menus**: A Restaurant owns one or more Menus. A Menu cannot exist without a restaurant.

- **BR-012 - Restaurant status & hours**: Restaurants have an operating status {Open, Temporarily Closed, Permanently Closed} and business hours per day; menu availability and accepting orders depend on open status and menu-specific availability windows.

- **BR-013 - Location**: Each Restaurant has a location.

## D. Menus & MenuItems

- **BR-014 - Menu → restaurant cardinality**: Each Menu belongs to exactly one Restaurant; a restaurant may have multiple menus (e.g., Dinner, Breakfast, Specials).

- **BR-015 - Menu lifecycle**: Menus can be {Active, Inactive}. Inactive menus are not shown to customers and cannot receive new orders.

- **BR-016 - MenuItem → menu cardinality**: Each MenuItem belongs to exactly one Menu. A menu may have zero or many menu items.

- **BR-017 - Item active flag**: Menu items have availability flags and optional time-based availability (e.g., only available 11:00–14:00).

- **BR-018 - Item snapshot at order time**: When an order is placed, the order stores a snapshot of the MenuItem name, description, and price to preserve historical accuracy. Price or name changes later do not affect past orders.

- **BR-019 - Item uniqueness**: Within a single Menu, MenuItem.name must be unique (or use MenuItemSKU for uniqueness).

- **BR-020 - Modifiers**: Menu items may have zero or more sizes. Each modifier option has a price delta. Constraints on modifiers (min/max selections) must be stored.

## E. Orders & OrderItems

- **BR-021 - Order ownership**: Each Order is placed by exactly one Customer.

- **BR-022 - Restaurant target**: Each Order targets exactly one Restaurant.

- **BR-023 - Order items required**: An Order must contain at least one OrderItem.

- **BR-024 - OrderItem → MenuItem reference**: Each OrderItem references exactly one MenuItem (by id) and also stores the snapshot of the item (name, unit price, modifiers, etc.).

- **BR-025 - Quantity**: Each OrderItem has a positive integer quantity (quantity >= 1).

- **BR-026 - Order totals computed**: Order totals are computed from sum(orderItem.unit_price * quantity) + fees + taxes + tip - discounts. Totals are stored on the order once finalized.

- **BR-027 - Immutable finalized orders**: Once an order has status Completed or Cancelled (after refund processed), its line items and totals are immutable.

- **BR-028 - Referential integrity**: If a MenuItem is deleted or inactive, existing OrderItems referencing it remain intact because they use snapshots. Deleting a MenuItem should not cascade delete OrderItems.

- **BR-029 - Order timestamps**: Orders record key timestamps: created_at, confirmed_at, prepared_at, picked_up_at, delivered_at, cancelled_at.

## F. Order lifecycle & statuses

- **BR-030 - Status values**: Orders have statuses such as {Created, Confirmed, Preparing, Ready, OutForDelivery, Delivered, Cancelled, Failed}.

- **BR-031 - Allowed transitions**: Only certain transitions are allowed. Example canonical flow: Created → Confirmed → Preparing → Ready → OutForDelivery → Delivered. Created or Confirmed may transition to Cancelled. Any final state ({Delivered, Cancelled, Failed}) is terminal. Implementation must enforce allowed transitions.

- **BR-032 - Refunds**: Refunds are triggered based on cancellation timing, payment method constraints, or restaurant inability to fulfill. Refunds are recorded as financial transactions and reference the original order.

## G. Pricing, taxes, fees & discounts

- **BR-033 - Price source & history**: Menu item prices are the current price on the menu, but orders store the price snapshot at time of order for historical accuracy. Price history must be auditable.

- **BR-034 - Taxes**: Taxes are calculated per order based on restaurant jurisdiction and stored on the order. Tax rates used must be recorded on the order for audit.

- **BR-035 - Tip handling**: Tips are customer-specified and stored on the order; tip distribution (to restaurant, delivery partner) is a separate accounting rule recorded for payouts.

- **BR-036 - Rounding**: Currency rounding rules must be defined (e.g., round to cents using bankers/round half up) and applied consistently.

## H. Payments & Transactions

- **BR-037 - Payment methods**: Acceptable payment methods: saved card, one-time card, gift card, wallet balance. Payment tokens are used; raw card numbers are not stored.

- **BR-038 - Payment audit trail**: All payment transactions (authorization, capture, refund, void) must be stored with timestamps, amounts, and external payment provider ids.

## I. Reporting, auditing & logging

- **BR-039 - Audit logs**: All critical state changes (account creation, order status changes, payment events) must be logged with user id, timestamp, and previous/new value.

- **BR-040 - Business reports**: The system supports reports by restaurant (sales, refunds, average order value), by time window, and by item popularity. Order data used for reports must use stored snapshots to avoid historical distortion.
