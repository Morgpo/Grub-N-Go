import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import {
  fetchAccountById,
  fetchCustomerById,
  // fetchRestaurantById, // RESTAURANT FUNCTIONALITY - COMMENTED OUT FOR FUTURE USE
  updateAccount,
  updateCustomer,
  // updateRestaurant, // RESTAURANT FUNCTIONALITY - COMMENTED OUT FOR FUTURE USE
} from "../api/grubngo";

export default function AccountPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [editing, setEditing] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  // Account data
  const [accountData, setAccountData] = useState(null);
  const [profileData, setProfileData] = useState(null);

  // Editable fields
  const [email, setEmail] = useState("");
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");

  /* RESTAURANT FUNCTIONALITY - COMMENTED OUT FOR FUTURE USE
  // Restaurant-specific fields
  const [contactEmail, setContactEmail] = useState("");
  const [operatingStatus, setOperatingStatus] = useState("OPEN");
  const [streetAddress, setStreetAddress] = useState("");
  const [city, setCity] = useState("");
  const [state, setState] = useState("");
  const [postalCode, setPostalCode] = useState("");
  */

  useEffect(() => {
    loadAccountData();
  }, [user]);

  const loadAccountData = async () => {
    if (!user) return;

    setLoading(true);
    setError("");

    try {
      // Fetch account data
      const account = await fetchAccountById(user.id);
      setAccountData(account);
      setEmail(account.email);

      // Fetch profile data based on role
      if (user.role === "CUSTOMER") {
        const customer = await fetchCustomerById(user.id);
        setProfileData(customer);
        setName(customer.customer_name);
        setPhone(customer.phone || "");
      }
      /* RESTAURANT FUNCTIONALITY - COMMENTED OUT FOR FUTURE USE
      else if (user.role === "RESTAURANT") {
        const restaurant = await fetchRestaurantById(user.id);
        setProfileData(restaurant);
        setName(restaurant.restaurant_name);
        setPhone(restaurant.contact_phone);
        setContactEmail(restaurant.contact_email || "");
        setOperatingStatus(restaurant.operating_status);
        setStreetAddress(restaurant.street_address || "");
        setCity(restaurant.city || "");
        setState(restaurant.state || "");
        setPostalCode(restaurant.postal_code || "");
      }
      */
    } catch (err) {
      setError(err.message || "Failed to load account data");
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    setError("");
    setSuccess("");

    try {
      // Update account email if changed
      if (email !== accountData.email) {
        await updateAccount(user.id, { email });
      }

      // Update profile based on role
      if (user.role === "CUSTOMER") {
        const updates = {};
        if (name !== profileData.customer_name) updates.customer_name = name;
        if (phone !== profileData.phone) updates.phone = phone;

        if (Object.keys(updates).length > 0) {
          await updateCustomer(user.id, updates);
        }
      }
      /* RESTAURANT FUNCTIONALITY - COMMENTED OUT FOR FUTURE USE
      else if (user.role === "RESTAURANT") {
        const updates = {};
        if (name !== profileData.restaurant_name)
          updates.restaurant_name = name;
        if (phone !== profileData.contact_phone) updates.contact_phone = phone;
        if (contactEmail !== profileData.contact_email)
          updates.contact_email = contactEmail;
        if (operatingStatus !== profileData.operating_status)
          updates.operating_status = operatingStatus;
        if (streetAddress !== profileData.street_address)
          updates.street_address = streetAddress;
        if (city !== profileData.city) updates.city = city;
        if (state !== profileData.state) updates.state = state;
        if (postalCode !== profileData.postal_code)
          updates.postal_code = postalCode;

        if (Object.keys(updates).length > 0) {
          await updateRestaurant(user.id, updates);
        }
      }
      */

      setSuccess("Account updated successfully!");
      setEditing(false);
      await loadAccountData();
    } catch (err) {
      setError(err.message || "Failed to update account");
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = () => {
    setEditing(false);
    setError("");
    setSuccess("");
    // Reset to original values
    if (accountData) setEmail(accountData.email);
    if (profileData) {
      if (user.role === "CUSTOMER") {
        setName(profileData.customer_name);
        setPhone(profileData.phone || "");
      }
      /* RESTAURANT FUNCTIONALITY - COMMENTED OUT FOR FUTURE USE
      else if (user.role === "RESTAURANT") {
        setName(profileData.restaurant_name);
        setPhone(profileData.contact_phone);
        setContactEmail(profileData.contact_email || "");
        setOperatingStatus(profileData.operating_status);
        setStreetAddress(profileData.street_address || "");
        setCity(profileData.city || "");
        setState(profileData.state || "");
        setPostalCode(profileData.postal_code || "");
      }
      */
    }
  };

  if (loading) {
    return (
      <div style={{ textAlign: "center", padding: "3rem" }}>
        <h2>Loading account data...</h2>
      </div>
    );
  }

  return (
    <div style={{ maxWidth: "800px", margin: "0 auto", padding: "2rem" }}>
      <div
        style={{
          background: "#fff",
          borderRadius: "12px",
          boxShadow: "0 2px 8px rgba(0,0,0,0.1)",
          padding: "2rem",
        }}
      >
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "2rem",
          }}
        >
          <h1 style={{ margin: 0 }}>Account Settings</h1>
          {!editing && (
            <button
              onClick={() => setEditing(true)}
              style={{
                padding: "0.75rem 1.5rem",
                background: "#667eea",
                color: "white",
                border: "none",
                borderRadius: "8px",
                fontSize: "1rem",
                cursor: "pointer",
                fontWeight: "600",
              }}
            >
              Edit
            </button>
          )}
        </div>

        {error && (
          <div
            style={{
              background: "#fee",
              color: "#c33",
              padding: "1rem",
              borderRadius: "8px",
              marginBottom: "1.5rem",
            }}
          >
            {error}
          </div>
        )}

        {success && (
          <div
            style={{
              background: "#efe",
              color: "#3c3",
              padding: "1rem",
              borderRadius: "8px",
              marginBottom: "1.5rem",
            }}
          >
            {success}
          </div>
        )}

        {/* Account Information */}
        <div style={{ marginBottom: "2rem" }}>
          <h2
            style={{
              fontSize: "1.3rem",
              marginBottom: "1rem",
              color: "#333",
            }}
          >
            Account Information
          </h2>

          <div style={{ marginBottom: "1.5rem" }}>
            <label
              style={{
                display: "block",
                marginBottom: "0.5rem",
                fontWeight: "500",
                color: "#555",
              }}
            >
              Account ID
            </label>
            <input
              type="text"
              value={accountData?.account_id || ""}
              disabled
              style={{
                width: "100%",
                padding: "0.75rem",
                border: "2px solid #e0e0e0",
                borderRadius: "8px",
                fontSize: "1rem",
                background: "#f5f5f5",
                color: "#666",
              }}
            />
          </div>

          <div style={{ marginBottom: "1.5rem" }}>
            <label
              style={{
                display: "block",
                marginBottom: "0.5rem",
                fontWeight: "500",
                color: "#555",
              }}
            >
              Email
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              disabled={!editing}
              style={{
                width: "100%",
                padding: "0.75rem",
                border: editing ? "2px solid #667eea" : "2px solid #e0e0e0",
                borderRadius: "8px",
                fontSize: "1rem",
                background: editing ? "#fff" : "#f5f5f5",
                color: editing ? "#333" : "#666",
              }}
            />
          </div>

          <div style={{ marginBottom: "1.5rem" }}>
            <label
              style={{
                display: "block",
                marginBottom: "0.5rem",
                fontWeight: "500",
                color: "#555",
              }}
            >
              Role
            </label>
            <input
              type="text"
              value={accountData?.role || ""}
              disabled
              style={{
                width: "100%",
                padding: "0.75rem",
                border: "2px solid #e0e0e0",
                borderRadius: "8px",
                fontSize: "1rem",
                background: "#f5f5f5",
                color: "#666",
              }}
            />
          </div>

          <div style={{ marginBottom: "1.5rem" }}>
            <label
              style={{
                display: "block",
                marginBottom: "0.5rem",
                fontWeight: "500",
                color: "#555",
              }}
            >
              Status
            </label>
            <input
              type="text"
              value={accountData?.status || ""}
              disabled
              style={{
                width: "100%",
                padding: "0.75rem",
                border: "2px solid #e0e0e0",
                borderRadius: "8px",
                fontSize: "1rem",
                background: "#f5f5f5",
                color: "#666",
              }}
            />
          </div>
        </div>

        {/* Profile Information */}
        <div style={{ marginBottom: "2rem" }}>
          <h2
            style={{
              fontSize: "1.3rem",
              marginBottom: "1rem",
              color: "#333",
            }}
          >
            Profile Information
          </h2>

          <div style={{ marginBottom: "1.5rem" }}>
            <label
              style={{
                display: "block",
                marginBottom: "0.5rem",
                fontWeight: "500",
                color: "#555",
              }}
            >
              Full Name
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              disabled={!editing}
              style={{
                width: "100%",
                padding: "0.75rem",
                border: editing ? "2px solid #667eea" : "2px solid #e0e0e0",
                borderRadius: "8px",
                fontSize: "1rem",
                background: editing ? "#fff" : "#f5f5f5",
                color: editing ? "#333" : "#666",
              }}
            />
          </div>

          <div style={{ marginBottom: "1.5rem" }}>
            <label
              style={{
                display: "block",
                marginBottom: "0.5rem",
                fontWeight: "500",
                color: "#555",
              }}
            >
              Phone
            </label>
            <input
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              disabled={!editing}
              style={{
                width: "100%",
                padding: "0.75rem",
                border: editing ? "2px solid #667eea" : "2px solid #e0e0e0",
                borderRadius: "8px",
                fontSize: "1rem",
                background: editing ? "#fff" : "#f5f5f5",
                color: editing ? "#333" : "#666",
              }}
            />
          </div>

          {/* RESTAURANT FUNCTIONALITY - COMMENTED OUT FOR FUTURE USE
          {user.role === "RESTAURANT" && (
            <>
              <div style={{ marginBottom: "1.5rem" }}>
                <label
                  style={{
                    display: "block",
                    marginBottom: "0.5rem",
                    fontWeight: "500",
                    color: "#555",
                  }}
                >
                  Contact Email
                </label>
                <input
                  type="email"
                  value={contactEmail}
                  onChange={(e) => setContactEmail(e.target.value)}
                  disabled={!editing}
                  style={{
                    width: "100%",
                    padding: "0.75rem",
                    border: editing ? "2px solid #667eea" : "2px solid #e0e0e0",
                    borderRadius: "8px",
                    fontSize: "1rem",
                    background: editing ? "#fff" : "#f5f5f5",
                    color: editing ? "#333" : "#666",
                  }}
                />
              </div>

              <div style={{ marginBottom: "1.5rem" }}>
                <label
                  style={{
                    display: "block",
                    marginBottom: "0.5rem",
                    fontWeight: "500",
                    color: "#555",
                  }}
                >
                  Operating Status
                </label>
                <select
                  value={operatingStatus}
                  onChange={(e) => setOperatingStatus(e.target.value)}
                  disabled={!editing}
                  style={{
                    width: "100%",
                    padding: "0.75rem",
                    border: editing ? "2px solid #667eea" : "2px solid #e0e0e0",
                    borderRadius: "8px",
                    fontSize: "1rem",
                    background: editing ? "#fff" : "#f5f5f5",
                    color: editing ? "#333" : "#666",
                    cursor: editing ? "pointer" : "default",
                  }}
                >
                  <option value="OPEN">Open</option>
                  <option value="TEMPORARILY_CLOSED">Temporarily Closed</option>
                  <option value="PERMANENTLY_CLOSED">Permanently Closed</option>
                </select>
              </div>

              <div style={{ marginBottom: "1.5rem" }}>
                <label
                  style={{
                    display: "block",
                    marginBottom: "0.5rem",
                    fontWeight: "500",
                    color: "#555",
                  }}
                >
                  Street Address
                </label>
                <input
                  type="text"
                  value={streetAddress}
                  onChange={(e) => setStreetAddress(e.target.value)}
                  disabled={!editing}
                  style={{
                    width: "100%",
                    padding: "0.75rem",
                    border: editing ? "2px solid #667eea" : "2px solid #e0e0e0",
                    borderRadius: "8px",
                    fontSize: "1rem",
                    background: editing ? "#fff" : "#f5f5f5",
                    color: editing ? "#333" : "#666",
                  }}
                />
              </div>

              <div
                style={{
                  display: "grid",
                  gridTemplateColumns: "1fr 1fr 1fr",
                  gap: "1rem",
                  marginBottom: "1.5rem",
                }}
              >
                <div>
                  <label
                    style={{
                      display: "block",
                      marginBottom: "0.5rem",
                      fontWeight: "500",
                      color: "#555",
                    }}
                  >
                    City
                  </label>
                  <input
                    type="text"
                    value={city}
                    onChange={(e) => setCity(e.target.value)}
                    disabled={!editing}
                    style={{
                      width: "100%",
                      padding: "0.75rem",
                      border: editing
                        ? "2px solid #667eea"
                        : "2px solid #e0e0e0",
                      borderRadius: "8px",
                      fontSize: "1rem",
                      background: editing ? "#fff" : "#f5f5f5",
                      color: editing ? "#333" : "#666",
                    }}
                  />
                </div>

                <div>
                  <label
                    style={{
                      display: "block",
                      marginBottom: "0.5rem",
                      fontWeight: "500",
                      color: "#555",
                    }}
                  >
                    State
                  </label>
                  <input
                    type="text"
                    value={state}
                    onChange={(e) => setState(e.target.value)}
                    disabled={!editing}
                    style={{
                      width: "100%",
                      padding: "0.75rem",
                      border: editing
                        ? "2px solid #667eea"
                        : "2px solid #e0e0e0",
                      borderRadius: "8px",
                      fontSize: "1rem",
                      background: editing ? "#fff" : "#f5f5f5",
                      color: editing ? "#333" : "#666",
                    }}
                  />
                </div>

                <div>
                  <label
                    style={{
                      display: "block",
                      marginBottom: "0.5rem",
                      fontWeight: "500",
                      color: "#555",
                    }}
                  >
                    Postal Code
                  </label>
                  <input
                    type="text"
                    value={postalCode}
                    onChange={(e) => setPostalCode(e.target.value)}
                    disabled={!editing}
                    style={{
                      width: "100%",
                      padding: "0.75rem",
                      border: editing
                        ? "2px solid #667eea"
                        : "2px solid #e0e0e0",
                      borderRadius: "8px",
                      fontSize: "1rem",
                      background: editing ? "#fff" : "#f5f5f5",
                      color: editing ? "#333" : "#666",
                    }}
                  />
                </div>
              </div>
            </>
          )}
          */}
        </div>

        {/* Action buttons when editing */}
        {editing && (
          <div
            style={{
              display: "flex",
              gap: "1rem",
              justifyContent: "flex-end",
            }}
          >
            <button
              onClick={handleCancel}
              disabled={saving}
              style={{
                padding: "0.75rem 1.5rem",
                background: "#fff",
                color: "#666",
                border: "2px solid #e0e0e0",
                borderRadius: "8px",
                fontSize: "1rem",
                cursor: saving ? "not-allowed" : "pointer",
                fontWeight: "600",
              }}
            >
              Cancel
            </button>
            <button
              onClick={handleSave}
              disabled={saving}
              style={{
                padding: "0.75rem 1.5rem",
                background: saving ? "#ccc" : "#667eea",
                color: "white",
                border: "none",
                borderRadius: "8px",
                fontSize: "1rem",
                cursor: saving ? "not-allowed" : "pointer",
                fontWeight: "600",
              }}
            >
              {saving ? "Saving..." : "Save Changes"}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
