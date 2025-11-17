import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { fetchMenuItemsForRestaurant } from "../api/grubngo";
import { useCart } from "../context/CartContext";

export default function MenuPage() {
  const { id } = useParams();
  const restaurantId = Number(id);
  const { addToCart } = useCart();

  const [items, setItems] = useState([]);
  // eslint-disable-next-line no-unused-vars
  const [restaurantName, setRestaurantName] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchMenuItemsForRestaurant(restaurantId)
      .then((data) => {
        setItems(data);

        if (data.length > 0) {
          // NOTE: use menu_name, not restaurant_name
          setRestaurantName(data[0].menu_name || "Restaurant");
        }
      })
      .catch((err) => setError(err.message || "Failed to load menu items"))
      .finally(() => setLoading(false));
  }, [restaurantId]);

  if (loading) return <p>Loading menu…</p>;
  if (error) return <p style={{ color: "red" }}>{error}</p>;

  return (
    <div style={{ maxWidth: 700 }}>
      {/* <h2>{restaurantName} – Menu</h2> */}
      <h2>Our Menu</h2>
      <ul style={{ listStyle: "none", padding: 0 }}>
        {items.map((item) => (
          <li
            key={item.menu_item_id}
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
              <div style={{ fontWeight: 600 }}>{item.name}</div>
              {item.description && (
                <div style={{ fontSize: 14, color: "#555" }}>
                  {item.description}
                </div>
              )}
            </div>
            <div style={{ textAlign: "right" }}>
              <div style={{ fontWeight: 600 }}>
                ${Number(item.price).toFixed(2)}
              </div>
              <button
                onClick={() =>
                  addToCart({
                    ...item,
                    restaurant_id: restaurantId, // 👈 add this
                  })
                }
                style={{
                  marginTop: 8,
                  padding: "0.25rem 0.75rem",
                  borderRadius: 999,
                  border: "1px solid #111",
                  background: "#111",
                  color: "#fff",
                  cursor: "pointer",
                }}
              >
                Add
              </button>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
