import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { fetchOpenRestaurants } from "../api/grubngo";

export default function RestaurantListPage() {
  const [restaurants, setRestaurants] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchOpenRestaurants()
      .then(setRestaurants)
      .catch((err) => setError(err.message || "Failed to load restaurants"))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <p>Loading restaurants…</p>;
  if (error) return <p style={{ color: "red" }}>{error}</p>;

  return (
    <div>
      {/* Little hero section */}
      <section style={{ marginBottom: "1.5rem" }}>
        <h2
          style={{
            margin: 0,
            fontSize: "1.6rem",
            fontWeight: 600,
          }}
        >
          What are you craving today?
        </h2>
        <p style={{ marginTop: "0.5rem", color: "#555" }}>
          Choose a restaurant below to start your order.
        </p>
      </section>

      {/* Restaurant cards grid */}
      <section>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(230px, 1fr))",
            gap: "1rem",
          }}
        >
          {restaurants.map((r) => (
            <Link
              key={r.restaurant_id}
              to={`/restaurants/${r.restaurant_id}`}
              style={{
                display: "block",
                textDecoration: "none",
                color: "#111",
                borderRadius: 16,
                border: "1px solid #eee",
                padding: "1rem 1.25rem",
                background: "#fafafa",
                boxShadow: "0 1px 4px rgba(0,0,0,0.04)",
                transition: "transform 0.15s ease, box-shadow 0.15s ease",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.transform = "translateY(-2px)";
                e.currentTarget.style.boxShadow = "0 4px 10px rgba(0,0,0,0.08)";
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.transform = "translateY(0)";
                e.currentTarget.style.boxShadow = "0 1px 4px rgba(0,0,0,0.04)";
              }}
            >
              <h3
                style={{
                  margin: 0,
                  fontSize: "1.1rem",
                  fontWeight: 600,
                }}
              >
                {r.restaurant_name}
              </h3>
              <p
                style={{
                  marginTop: "0.4rem",
                  fontSize: "0.85rem",
                  color: "#666",
                }}
              >
                {r.is_open ? "Open now" : "Currently closed"}
              </p>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
