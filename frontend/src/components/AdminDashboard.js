import React from "react";
export default function AdminDashboard({ onLogout }) {
  return (
    <div className="p-6">
      <h2 className="text-xl font-bold">Admin Dashboard</h2>
      <button onClick={onLogout} className="mt-4 px-4 py-2 bg-red-600 text-white">Logout</button>
    </div>
  );
}
