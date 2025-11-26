import { useEffect, useState } from "react";
import { fetchCustomerOrders } from "../api/grubngo";

const CURRENT_CUSTOMER_ID = 2;

export default function OrdersPage() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchCustomerOrders(CURRENT_CUSTOMER_ID)
      .then(setOrders)
      .catch((err) => setError(err.message || "Failed to load orders"))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <p>Loading orders…</p>;
  if (error) return <p style={{ color: "red" }}>{error}</p>;
  if (!orders.length) return <p>No orders yet.</p>;

  return (
    <div style={{ maxWidth: 700 }}>
      <h2>Your Orders</h2>
      <ul style={{ listStyle: "none", padding: 0 }}>
        {orders.map((o) => (
          <li
            key={o.order_id}
            style={{
              border: "1px solid #eee",
              borderRadius: 8,
              padding: "0.75rem 1rem",
              marginBottom: "0.75rem",
            }}
          >
            <div>
              <strong>Order #{o.order_id}</strong>{" "}
              <span>
                – {o.restaurant_name || `Restaurant #${o.restaurant_id}`}
              </span>
            </div>
            <div style={{ marginTop: 4 }}>
              <span
                style={{
                  padding: "0.15rem 0.5rem",
                  borderRadius: 999,
                  fontSize: 12,
                  background:
                    o.status === "COMPLETED"
                      ? "#dcfce7"
                      : o.status === "PENDING"
                      ? "#fef9c3"
                      : "#fee2e2",
                  border:
                    o.status === "COMPLETED"
                      ? "1px solid #16a34a"
                      : o.status === "PENDING"
                      ? "1px solid #eab308"
                      : "1px solid #b91c1c",
                  color:
                    o.status === "COMPLETED"
                      ? "#166534"
                      : o.status === "PENDING"
                      ? "#854d0e"
                      : "#7f1d1d",
                }}
              >
                {o.status}
              </span>
            </div>
            <div style={{ marginTop: 4, fontWeight: 600 }}>
              Total: ${Number(o.total).toFixed(2)}
            </div>
            {o.created_at && (
              <div style={{ fontSize: 12, color: "#555" }}>
                Placed at: {new Date(o.created_at).toLocaleString()}
              </div>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
}
