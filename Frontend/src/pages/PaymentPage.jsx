import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  fetchOrder,
  createPaymentMethod,
  updateOrderStatus,
} from "../api/grubngo";

export default function PaymentPage() {
  const { orderId } = useParams();
  const navigate = useNavigate();

  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  // Mock card form fields
  const [cardNumber, setCardNumber] = useState("");
  const [cardName, setCardName] = useState("");
  const [expiryMonth, setExpiryMonth] = useState("");
  const [expiryYear, setExpiryYear] = useState("");
  const [cvc, setCvc] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState("");

  useEffect(() => {
    async function loadOrder() {
      try {
        const data = await fetchOrder(orderId);
        setOrder(data);
      } catch (err) {
        setError(err.message || "Failed to load order");
      } finally {
        setLoading(false);
      }
    }

    loadOrder();
  }, [orderId]);

  async function handlePay() {
    if (!order) return;

    // super basic validation for demo purposes
    if (!cardNumber || !cardName || !expiryMonth || !expiryYear || !cvc) {
      setError("Please fill in all payment fields.");
      return;
    }

    setError("");
    setSuccess("");
    setSubmitting(true);

    try {
      const last4 = cardNumber.replace(/\s+/g, "").slice(-4) || null;

      // 1) Create a mock payment method for this customer (DB write ✅)
      const paymentType = "CREDIT_CARD"; // PaymentTypeEnum
      const paymentToken = `mock-token-${Date.now()}`; // never real card data

      const pmResponse = await createPaymentMethod(order.customer_id, {
        payment_type: paymentType,
        payment_token: paymentToken,
        card_last_four: last4,
        card_brand: "VISA",
        expiry_month: Number(expiryMonth) || null,
        expiry_year: Number(expiryYear) || null,
        is_default: true,
      });

      console.log("Created payment method:", pmResponse);

      // 2) (Optional) try to move order status forward
      try {
        await updateOrderStatus(order.order_id, "CONFIRMED");
      } catch (e) {
        console.warn("Could not update order status:", e);
      }

      setSuccess("Payment successful! Your order is confirmed (mock).");

      // For demo: go back to orders after a small delay
      setTimeout(() => {
        navigate("/orders");
      }, 1200);
    } catch (err) {
      setError(err.message || "Payment failed (mock).");
    } finally {
      setSubmitting(false);
    }
  }

  if (loading) return <p>Loading order…</p>;
  if (error && !order) return <p style={{ color: "red" }}>{error}</p>;
  if (!order) return <p>Order not found.</p>;

  return (
    <div style={{ maxWidth: 600 }}>
      <h2>Payment for Order #{order.order_id}</h2>

      {/* Order summary */}
      <div
        style={{
          border: "1px solid #eee",
          borderRadius: 8,
          padding: "0.75rem 1rem",
          marginBottom: "1rem",
        }}
      >
        <div>
          <strong>
            {order.restaurant_name || `Restaurant #${order.restaurant_id}`}
          </strong>
        </div>
        <div>Status: {order.status}</div>
        <div>Subtotal: ${Number(order.subtotal).toFixed(2)}</div>
        <div>Tax: ${Number(order.tax).toFixed(2)}</div>
        <div style={{ fontWeight: 600 }}>
          Total: ${Number(order.total).toFixed(2)}
        </div>
      </div>

      {/* Payment form */}
      {error && <p style={{ color: "red" }}>{error}</p>}
      {success && <p style={{ color: "green" }}>{success}</p>}

      <div
        style={{
          border: "1px solid #eee",
          borderRadius: 8,
          padding: "0.75rem 1rem",
        }}
      >
        <h3 style={{ marginTop: 0 }}>Payment details (Mock)</h3>

        <label style={{ display: "block", marginBottom: 8 }}>
          Name on card
          <input
            type="text"
            value={cardName}
            onChange={(e) => setCardName(e.target.value)}
            style={{ width: "100%", padding: 8, marginTop: 4 }}
          />
        </label>

        <label style={{ display: "block", marginBottom: 8 }}>
          Card number
          <input
            type="text"
            value={cardNumber}
            onChange={(e) => setCardNumber(e.target.value)}
            placeholder="4242 4242 4242 4242"
            style={{ width: "100%", padding: 8, marginTop: 4 }}
          />
        </label>

        <div style={{ display: "flex", gap: 8 }}>
          <label style={{ flex: 1 }}>
            Expiry month
            <input
              type="text"
              value={expiryMonth}
              onChange={(e) => setExpiryMonth(e.target.value)}
              placeholder="MM"
              style={{ width: "100%", padding: 8, marginTop: 4 }}
            />
          </label>
          <label style={{ flex: 1 }}>
            Expiry year
            <input
              type="text"
              value={expiryYear}
              onChange={(e) => setExpiryYear(e.target.value)}
              placeholder="YYYY"
              style={{ width: "100%", padding: 8, marginTop: 4 }}
            />
          </label>
          <label style={{ flex: 1 }}>
            CVC
            <input
              type="password"
              value={cvc}
              onChange={(e) => setCvc(e.target.value)}
              style={{ width: "100%", padding: 8, marginTop: 4 }}
            />
          </label>
        </div>

        <button
          onClick={handlePay}
          disabled={submitting}
          style={{
            marginTop: 16,
            padding: "0.5rem 1.5rem",
            borderRadius: 999,
            border: "none",
            background: "#111",
            color: "#fff",
            cursor: "pointer",
          }}
        >
          {submitting ? "Processing…" : "Pay Now"}
        </button>
      </div>
    </div>
  );
}
