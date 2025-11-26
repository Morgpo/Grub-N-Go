import { Routes, Route, Link } from "react-router-dom";
import RestaurantListPage from "./pages/RestaurantListPage";
import MenuPage from "./pages/MenuPage";
import CartPage from "./pages/CartPage";
import OrdersPage from "./pages/OrdersPage";
import { CartProvider } from "./context/CartContext";
import Navbar from "./components/Navbar";

export default function App() {
  return (
    <CartProvider>
      <div style={{ fontFamily: "system-ui", minHeight: "100vh" }}>
        {/* Header */}
        <Navbar />
        {/* Main content */}
        <main
          style={{
            padding: "0 2rem 2rem",
          }}
        >
          <div
            style={{
              maxWidth: "960px",
              margin: "0 auto",
            }}
          >
            <Routes>
              <Route path="/" element={<RestaurantListPage />} />
              <Route path="/restaurants/:id" element={<MenuPage />} />
              <Route path="/cart" element={<CartPage />} />
              <Route path="/orders" element={<OrdersPage />} />
            </Routes>
          </div>
        </main>
      </div>
    </CartProvider>
  );
}
