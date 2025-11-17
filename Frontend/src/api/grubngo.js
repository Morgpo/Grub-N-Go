import { get, post } from "./client";

// RESTAURANTS
export function fetchOpenRestaurants() {
  // FastAPI: /api/v1/restaurants/open/
  return get("/restaurants/open/");
}

// MENU ITEMS
export function fetchMenuItemsForRestaurant(restaurantId) {
  // /api/v1/restaurants/{restaurant_id}/menu-items/
  return get(`/restaurants/${restaurantId}/menu-items/`);
}

// ORDERS
export function fetchCustomerOrders(customerId) {
  // /api/v1/customers/{customer_id}/orders/
  return get(`/customers/${customerId}/orders/`);
}

export function createOrder({
  customerId,
  restaurantId,
  subtotal,
  tax,
  total,
}) {
  // matches OrderCreate model
  return post("/orders/", {
    customer_id: customerId,
    restaurant_id: restaurantId,
    status: "PENDING",
    subtotal,
    tax,
    total,
  });
}

export function createOrderItem({
  orderId,
  menuItemId,
  quantity,
  unitPrice,
  notes,
}) {
  return post("/order-items/", {
    order_id: orderId,
    menu_item_id: menuItemId,
    quantity,
    unit_price: unitPrice,
    notes: notes || null,
  });
}
