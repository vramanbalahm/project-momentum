import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";

export default function ManageMembers({ onBack }) {
  const { user, apiFetch } = useAuth();
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [addForm, setAddForm] = useState({ name: "", email: "", password: "" });
  const [adding, setAdding] = useState(false);
  const [actionLoading, setActionLoading] = useState(null); // user_id being acted on

  const loadMembers = async () => {
    try {
      const data = await apiFetch("/auth/members");
      setMembers(data);
    } catch (e) {
      setError("Failed to load members.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadMembers(); }, []);

  const handleRoleChange = async (memberId, currentRole) => {
    const newRole = currentRole === "household_admin" ? "household_member" : "household_admin";
    const action = newRole === "household_admin" ? "promote" : "demote";
    if (!confirm(`${action === "promote" ? "Promote" : "Demote"} this member? ${action === "promote" ? "A temporary password will be emailed to them." : ""}`)) return;

    setError(null); setSuccess(null);
    setActionLoading(memberId);
    try {
      const res = await apiFetch("/auth/members/role", {
        method: "PUT",
        body: JSON.stringify({ user_id: memberId, new_role: newRole })
      });
      setSuccess(res.message);
      await loadMembers();
    } catch (e) {
      setError(e.message);
    } finally {
      setActionLoading(null);
    }
  };

  const handleToggleActive = async (memberId, currentActive) => {
    const action = currentActive ? "deactivate" : "activate";
    if (!confirm(`${action.charAt(0).toUpperCase() + action.slice(1)} this member?`)) return;

    setError(null); setSuccess(null);
    setActionLoading(memberId);
    try {
      const res = await apiFetch("/auth/members/deactivate", {
        method: "PUT",
        body: JSON.stringify({ user_id: memberId, is_active: !currentActive })
      });
      setSuccess(res.message);
      await loadMembers();
    } catch (e) {
      setError(e.message);
    } finally {
      setActionLoading(null);
    }
  };

  const handleAddMember = async () => {
    setError(null);
    if (!addForm.name || !addForm.email || !addForm.password) { setError("All fields required."); return; }
    if (addForm.password.length < 8) { setError("Password must be at least 8 characters."); return; }
    setAdding(true);
    try {
      await apiFetch("/auth/members/create", {
        method: "POST",
        body: JSON.stringify(addForm)
      });
      setSuccess(`${addForm.name} added successfully.`);
      setAddForm({ name: "", email: "", password: "" });
      setShowAddForm(false);
      await loadMembers();
    } catch (e) {
      setError(e.message);
    } finally {
      setAdding(false);
    }
  };

  const inputStyle = { width: "100%", padding: "10px 14px", borderRadius: 10, border: "0.5px solid #EDE8E0", fontSize: 13, color: "#2C2C2A", background: "#F1EFE8", outline: "none", boxSizing: "border-box", marginBottom: 10 };

  return (
    <div style={{ minHeight: "100vh", background: "#F7F4EE", fontFamily: "system-ui, sans-serif", maxWidth: 480, margin: "0 auto" }}>

      {/* Header */}
      <div style={{ background: "#1A3A2E", padding: "16px 20px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <span onClick={onBack} style={{ color: "#9FE1CB", fontSize: 20, cursor: "pointer" }}>←</span>
            <div>
              <div style={{ color: "#FDFCF8", fontSize: 17, fontWeight: 500 }}>Manage Members</div>
              <div style={{ color: "#5DCAA5", fontSize: 11, marginTop: 2 }}>{user?.house_name}</div>
            </div>
          </div>
          <button onClick={() => { setShowAddForm(!showAddForm); setError(null); }} style={{ background: "#9FE1CB", color: "#1A3A2E", border: "none", borderRadius: 10, padding: "8px 14px", fontSize: 12, fontWeight: 600, cursor: "pointer" }}>
            {showAddForm ? "Cancel" : "+ Add member"}
          </button>
        </div>
      </div>

      <div style={{ padding: "20px" }}>

        {error && <div style={{ background: "#FAECE7", border: "0.5px solid #F5C4B3", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#712B13" }}>{error}</div>}
        {success && <div style={{ background: "#E1F5EE", border: "0.5px solid #9FE1CB", borderRadius: 10, padding: "10px 14px", marginBottom: 14, fontSize: 12, color: "#1A3A2E" }}>✅ {success}</div>}

        {/* Add member form */}
        {showAddForm && (
          <div style={{ background: "#FFF9F2", borderRadius: 16, padding: "20px 16px", marginBottom: 16, border: "0.5px solid #EDE8E0" }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: "#2C2C2A", marginBottom: 14 }}>New member</div>
            <input type="text" placeholder="Full name *" value={addForm.name} onChange={e => setAddForm(p => ({ ...p, name: e.target.value }))} style={inputStyle} />
            <input type="email" placeholder="Email address *" value={addForm.email} onChange={e => setAddForm(p => ({ ...p, email: e.target.value }))} style={inputStyle} />
            <input type="password" placeholder="Temporary password (min 8 chars) *" value={addForm.password} onChange={e => setAddForm(p => ({ ...p, password: e.target.value }))} style={{ ...inputStyle, marginBottom: 14 }} />
            <button onClick={handleAddMember} disabled={adding} style={{ width: "100%", background: "#1A3A2E", color: "#9FE1CB", border: "none", borderRadius: 12, padding: "12px", fontSize: 14, fontWeight: 500, cursor: adding ? "not-allowed" : "pointer", opacity: adding ? 0.7 : 1 }}>
              {adding ? "Adding..." : "Add member"}
            </button>
          </div>
        )}

        {/* Members list */}
        {loading ? (
          <div style={{ textAlign: "center", color: "#888780", fontSize: 13, padding: 40 }}>Loading...</div>
        ) : (
          members.map(m => {
            const isMe = m.user_id === user?.user_id;
            const isAdmin = m.role === "household_admin";
            const busy = actionLoading === m.user_id;
            return (
              <div key={m.user_id} style={{ background: "#FFF9F2", borderRadius: 16, padding: "16px", marginBottom: 10, border: "0.5px solid #EDE8E0", opacity: m.is_active ? 1 : 0.6 }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                  <div>
                    <div style={{ fontSize: 14, fontWeight: 600, color: "#2C2C2A" }}>
                      {m.name} {isMe && <span style={{ fontSize: 10, color: "#888780" }}>(you)</span>}
                    </div>
                    <div style={{ fontSize: 11, color: "#888780", marginTop: 2 }}>{m.email}</div>
                    <div style={{ display: "flex", gap: 6, marginTop: 8 }}>
                      <span style={{ fontSize: 10, fontWeight: 600, padding: "2px 8px", borderRadius: 8, background: isAdmin ? "#E1F5EE" : "#F1EFE8", color: isAdmin ? "#1A3A2E" : "#888780" }}>
                        {isAdmin ? "Admin" : "Member"}
                      </span>
                      <span style={{ fontSize: 10, fontWeight: 600, padding: "2px 8px", borderRadius: 8, background: m.is_active ? "#E1F5EE" : "#FAECE7", color: m.is_active ? "#1A3A2E" : "#712B13" }}>
                        {m.is_active ? "Active" : "Inactive"}
                      </span>
                    </div>
                  </div>

                  {!isMe && (
                    <div style={{ display: "flex", flexDirection: "column", gap: 6, alignItems: "flex-end" }}>
                      <button
                        onClick={() => handleRoleChange(m.user_id, m.role)}
                        disabled={busy}
                        style={{ fontSize: 11, padding: "5px 10px", borderRadius: 8, border: "0.5px solid #EDE8E0", background: "transparent", color: "#1A3A2E", cursor: busy ? "not-allowed" : "pointer", fontWeight: 500 }}
                      >
                        {busy ? "..." : isAdmin ? "Demote" : "Promote"}
                      </button>
                      <button
                        onClick={() => handleToggleActive(m.user_id, m.is_active)}
                        disabled={busy}
                        style={{ fontSize: 11, padding: "5px 10px", borderRadius: 8, border: "0.5px solid #EDE8E0", background: "transparent", color: m.is_active ? "#C0392B" : "#1A3A2E", cursor: busy ? "not-allowed" : "pointer", fontWeight: 500 }}
                      >
                        {busy ? "..." : m.is_active ? "Deactivate" : "Activate"}
                      </button>
                    </div>
                  )}
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
