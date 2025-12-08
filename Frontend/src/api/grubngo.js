import { get, post, put } from "./client";

// AUTHENTICATION
export async function login(email, password) {
  // FastAPI: /api/v1/auth/login
  return post("/auth/login", { email, password });
}

export async function register({ email, password, role, name, phone }) {
  // FastAPI: /api/v1/auth/register
  return post("/auth/register", {
    email,
    password,
    role,
    name,
    phone,
  });
}

// ACCOUNTS
export function fetchAccountById(accountId) {
  // FastAPI: /api/v1/accounts/{account_id}
  return get(`/accounts/${accountId}`);
}

export function updateAccount(accountId, updates) {
  // FastAPI: /api/v1/accounts/{account_id}
  return put(`/accounts/${accountId}`, updates);
}

// CUSTOMERS
export function fetchCustomerById(customerId) {
  // FastAPI: /api/v1/customers/{customer_id}
  return get(`/customers/${customerId}`);
}

export function updateCustomer(customerId, updates) {
  // FastAPI: /api/v1/customers/{customer_id}
  return put(`/customers/${customerId}`, updates);
}

// RESTAURANTS
export function fetchOpenRestaurants() {
  // FastAPI: /api/v1/restaurants/open/
  return get("/restaurants/open/");
}

export function fetchRestaurantById(restaurantId) {
  // FastAPI: /api/v1/restaurants/{restaurant_id}
  return get(`/restaurants/${restaurantId}`);
}

export function updateRestaurant(restaurantId, updates) {
  // FastAPI: /api/v1/restaurants/{restaurant_id}
  return put(`/restaurants/${restaurantId}`, updates);
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
    status: "CREATED",
    subtotal: String(subtotal),
    tax: String(tax),
    total: String(total),
  });
}

export function createOrderItem({
  orderId,
  menuItemId,
  itemName,
  itemDescription,
  quantity,
  unitPrice,
  notes,
}) {
  return post("/order-items/", {
    order_id: orderId,
    menu_item_id: menuItemId,
    item_name: itemName,
    item_description: itemDescription || null,
    quantity,
    unit_price: String(unitPrice),
    notes: notes || null,
  });
}

// PAYMENT METHODS
export function fetchPaymentMethods(customerId) {
  // GET /api/v1/customers/{customer_id}/payment-methods
  return get(`/customers/${customerId}/payment-methods`);
}

export function createPaymentMethod(customerId, data) {
  // POST /api/v1/customers/{customer_id}/payment-methods
  return post(`/customers/${customerId}/payment-methods`, {
    ...data,
    customer_id: customerId,
  });
}

// ORDERS (single + update + status)
export function fetchOrder(orderId) {
  // GET /api/v1/orders/{order_id}
  return get(`/orders/${orderId}`);
}

export function updateOrder(orderId, partial) {
  // PUT /api/v1/orders/{order_id}
  return put(`/orders/${orderId}`, partial);
}

export function updateOrderStatus(orderId, status) {
  // PUT /api/v1/orders/{order_id}/status?status=CONFIRMED
  return put(`/orders/${orderId}/status?status=${status}`, {});
}
