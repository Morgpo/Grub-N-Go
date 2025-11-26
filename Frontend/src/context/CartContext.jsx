import { createContext, useContext, useState } from "react";

const CartContext = createContext();

// eslint-disable-next-line react-refresh/only-export-components
export function useCart() {
  return useContext(CartContext);
}

export function CartProvider({ children }) {
  const [items, setItems] = useState([]); // [{ menuItem, quantity }]

  function addToCart(menuItem) {
    setItems((prev) => {
      const existing = prev.find(
        (i) => i.menuItem.menu_item_id === menuItem.menu_item_id
      );
      if (existing) {
        return prev.map((i) =>
          i.menuItem.menu_item_id === menuItem.menu_item_id
            ? { ...i, quantity: i.quantity + 1 }
            : i
        );
      }
      return [...prev, { menuItem, quantity: 1 }];
    });
  }

  function removeFromCart(menuItemId) {
    setItems((prev) =>
      prev.filter((i) => i.menuItem.menu_item_id !== menuItemId)
    );
  }

  function updateQuantity(menuItemId, quantity) {
    setItems((prev) =>
      prev.map((i) =>
        i.menuItem.menu_item_id === menuItemId
          ? { ...i, quantity: quantity < 1 ? 1 : quantity }
          : i
      )
    );
  }

  function clearCart() {
    setItems([]);
  }

  const subtotal = items.reduce(
    (sum, i) => sum + Number(i.menuItem.price) * i.quantity,
    0
  );
  const tax = subtotal * 0.0825; // example 8.25%
  const total = subtotal + tax;

  return (
    <CartContext.Provider
      value={{
        items,
        addToCart,
        removeFromCart,
        updateQuantity,
        clearCart,
        subtotal,
        tax,
        total,
      }}
    >
      {children}
    </CartContext.Provider>
  );
}
