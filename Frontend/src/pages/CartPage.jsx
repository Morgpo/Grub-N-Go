import { useState } from "react";
import { useCart } from "../context/CartContext";
import { createOrder, createOrderItem } from "../api/grubngo";

const CURRENT_CUSTOMER_ID = 2; // TODO: replace with real auth later

export default function CartPage() {
  const {
    items,
    subtotal,
    tax,
    total,
    updateQuantity,
    removeFromCart,
    clearCart,
  } = useCart();
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const restaurantId =
    items.length > 0 ? items[0].menuItem.restaurant_id : null;

  async function handleCheckout() {
    if (!items.length || !restaurantId) return;

    setSubmitting(true);
    setError("");
    setSuccess("");

    try {
      const orderRes = await createOrder({
        customerId: CURRENT_CUSTOMER_ID,
        restaurantId,
        subtotal: subtotal.toFixed(2),
        tax: tax.toFixed(2),
        total: total.toFixed(2),
      });

      const orderId = orderRes.order_id;

      for (const cartItem of items) {
        await createOrderItem({
          orderId,
          menuItemId: cartItem.menuItem.menu_item_id,
          itemName: cartItem.menuItem.name,
          itemDescription: cartItem.menuItem.description,
          quantity: cartItem.quantity,
          unitPrice: Number(cartItem.menuItem.price).toFixed(2),
        });
      }

      clearCart();
      setSuccess(`Order #${orderId} placed successfully!`);
    } catch (err) {
      setError(err.message || "Failed to place order");
    } finally {
      setSubmitting(false);
    }
  }

  if (!items.length) {
    return <p>Your cart is empty.</p>;
  }

  return (
    <div style={{ maxWidth: 700 }}>
      <h2>Your Cart</h2>
      {error && <p style={{ color: "red" }}>{error}</p>}
      {success && <p style={{ color: "green" }}>{success}</p>}

      <ul style={{ listStyle: "none", padding: 0 }}>
        {items.map((item) => (
          <li
            key={item.menuItem.menu_item_id}
            style={{
              border: "1px solid #eee",
              borderRadius: 8,
              padding: "0.75rem 1rem",
              marginBottom: "0.75rem",
              display: "flex",
              justifyContent: "space-between",
              gap: "1rem",
            }}
          >
            <div>
              <div style={{ fontWeight: 600 }}>{item.menuItem.name}</div>
              <div style={{ fontSize: 14, color: "#555" }}>
                ${Number(item.menuItem.price).toFixed(2)} each
              </div>
            </div>
            <div style={{ textAlign: "right" }}>
              <input
                type="number"
                min="1"
                value={item.quantity}
                onChange={(e) =>
                  updateQuantity(
                    item.menuItem.menu_item_id,
                    Number(e.target.value) || 1
                  )
                }
                style={{ width: 60, marginBottom: 8 }}
              />
              <div style={{ fontWeight: 600 }}>
                {(Number(item.menuItem.price) * item.quantity).toFixed(2)}
              </div>
              <button
                onClick={() => removeFromCart(item.menuItem.menu_item_id)}
                style={{
                  marginTop: 4,
                  padding: "0.25rem 0.75rem",
                  borderRadius: 999,
                  border: "1px solid #aaa",
                  background: "#fff",
                  cursor: "pointer",
                }}
              >
                Remove
              </button>
            </div>
          </li>
        ))}
      </ul>

      <div style={{ marginTop: "1rem", textAlign: "right" }}>
        <div>Subtotal: ${subtotal.toFixed(2)}</div>
        <div>Tax: ${tax.toFixed(2)}</div>
        <div style={{ fontWeight: 600 }}>Total: ${total.toFixed(2)}</div>
        <button
          onClick={handleCheckout}
          disabled={submitting}
          style={{
            marginTop: 12,
            padding: "0.5rem 1.5rem",
            borderRadius: 999,
            border: "none",
            background: "#111",
            color: "#fff",
            cursor: "pointer",
          }}
        >
          {submitting ? "Placing order..." : "Place Order"}
        </button>
      </div>
    </div>
  );
}
