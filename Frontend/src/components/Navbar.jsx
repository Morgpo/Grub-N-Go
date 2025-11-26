import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Navbar() {
  const { logout, user } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

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
            alignItems: "center",
            gap: "1rem",
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

        {/* RIGHT: Account / Orders / Cart / Logout (fixed width, right-aligned) */}
        <nav
          style={{
            width: 320,
            display: "flex",
            justifyContent: "flex-end",
            gap: "0.75rem",
            alignItems: "center",
          }}
        >
          <Link
            to="/account"
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
            Account
          </Link>

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

          <button
            onClick={handleLogout}
            style={{
              padding: "0.4rem 0.9rem",
              borderRadius: 999,
              border: "1px solid #fff",
              background: "transparent",
              color: "#fff",
              fontSize: "0.9rem",
              fontWeight: 500,
              cursor: "pointer",
            }}
          >
            Logout
          </button>
        </nav>
      </div>
    </header>
  );
}
