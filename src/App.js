import React, { useState } from "react";
import Header from "./components/Header";
import CustomerBooking from "./components/CustomerBooking";
import AdminDashboard from "./components/AdminDashboard";

export default function App(){
  const [currentView, setCurrentView] = useState("services");
  const [isAdmin, setIsAdmin] = useState(false);
  const [adminPassword, setAdminPassword] = useState("");

  const handleNav = (view) => setCurrentView(view);

  const handleAdminLogin = () => {
    if (adminPassword === "admin123") {
      setIsAdmin(true);
      setCurrentView("admin");
      setAdminPassword("");
    } else {
      alert("Incorrect password!");
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Header currentView={currentView} isAdmin={isAdmin} onNav={handleNav} />

      {currentView === "services" && (
        <CustomerBooking onDone={(next)=>setCurrentView(next)} />
      )}

      {currentView === "adminLogin" && (
        <div className="max-w-md mx-auto mt-16 p-6 bg-white border rounded-lg shadow-lg">
          <div className="text-center mb-6">
            <h2 className="text-2xl font-semibold">Admin Access</h2>
            <p className="text-gray-600">Enter password to access admin panel</p>
          </div>
          <input
            type="password"
            placeholder="Admin Password"
            value={adminPassword}
            onChange={(e)=>setAdminPassword(e.target.value)}
            onKeyDown={(e)=>{ if(e.key==="Enter"){ e.preventDefault(); handleAdminLogin(); } }}
            className="w-full p-3 border rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500 mb-3"
          />
          <button
            onClick={handleAdminLogin}
            className="w-full py-3 bg-pink-600 text-white rounded-md font-semibold hover:bg-pink-700"
          >
            Access Admin Panel
          </button>
          <div className="mt-4 text-center">
            <button onClick={()=>setCurrentView("services")} className="text-pink-600 hover:text-pink-800">
              ← Back to Services
            </button>
          </div>
        </div>
      )}

      {currentView === "admin" && isAdmin && (
        <AdminDashboard
          onLogout={()=>{ setIsAdmin(false); setCurrentView("services"); }}
          onNewBooking={()=>setCurrentView("services")}
        />
      )}
    </div>
  );
}
