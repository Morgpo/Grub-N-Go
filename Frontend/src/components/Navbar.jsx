import { Link } from "react-router-dom";

export default function Navbar() {
  return (
    <header
      style={{
        borderBottom: "1px solid #333",
        marginBottom: "2rem",
        padding: "1rem 2rem",
        background: "transparent",
      }}
    >
      <div
        style={{
          maxWidth: "960px",
          margin: "0 auto",
          display: "flex",
          alignItems: "center",
        }}
      >
        {/* LEFT: Home (fixed width) */}
        <div
          style={{
            width: 120,
            display: "flex",
            justifyContent: "flex-start",
          }}
        >
          <Link
            to="/"
            style={{
              textDecoration: "none",
              color: "#fff",
              fontWeight: 600,
              fontSize: "1rem",
            }}
          >
            Home
          </Link>
        </div>

        {/* CENTER: Title (flexes, truly centered) */}
        <div
          style={{
            flex: 1,
            textAlign: "center",
          }}
        >
          <h1
            style={{
              marginRight: 35,
              fontSize: "1.9rem",
              fontWeight: 700,
              color: "#fff",
            }}
          >
            Grub N Go
          </h1>
        </div>

        {/* RIGHT: Orders / Cart (fixed width, right-aligned) */}
        <nav
          style={{
            width: 160,
            display: "flex",
            justifyContent: "flex-end",
            gap: "0.75rem",
          }}
        >
          <Link
            to="/orders"
            style={{
              padding: "0.4rem 0.9rem",
              borderRadius: 999,
              border: "1px solid #fff",
              background: "transparent",
              color: "#fff",
              textDecoration: "none",
              fontSize: "0.9rem",
              fontWeight: 500,
            }}
          >
            Orders
          </Link>

          <Link
            to="/cart"
            style={{
              padding: "0.4rem 0.9rem",
              borderRadius: 999,
              border: "1px solid #111",
              background: "#fff",
              color: "#111",
              textDecoration: "none",
              fontSize: "0.9rem",
              fontWeight: 600,
            }}
          >
            Cart
          </Link>
        </nav>
      </div>
    </header>
  );
}
