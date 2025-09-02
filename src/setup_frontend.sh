#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:-nail-salon}"
ROOT_DIR="$(pwd)"

echo ">>> Ensuring project folder: ${ROOT_DIR}"

# 0) Initialize minimal project if package.json missing
if [ ! -f package.json ]; then
  echo ">>> No package.json found. Creating a minimal Vite React project..."
  npm init -y >/dev/null 2>&1
  # Minimal scripts (works if vite isn't added yet)
  npx --yes vite@latest "${APP_NAME}" --template react >/dev/null 2>&1 || true

  if [ -d "${APP_NAME}" ]; then
    echo ">>> Moving template files up…"
    shopt -s dotglob
    mv "${APP_NAME}"/* .
    rmdir "${APP_NAME}"
  fi
fi

# 1) Install deps
echo ">>> Installing dependencies…"
npm install react react-dom lucide-react --silent
npm install -D vite tailwindcss postcss autoprefixer --silent

# 2) Tailwind init
echo ">>> Initializing Tailwind/PostCSS…"
npx tailwindcss init -p >/dev/null 2>&1 || true

# 3) .env for Vite (API base)
echo ">>> Writing .env …"
cat > .env << 'EOF'
VITE_API_BASE=http://localhost:5000
EOF

# 4) Tailwind + PostCSS configs
echo ">>> Writing tailwind.config.js …"
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,jsx,ts,tsx}"],
  theme: { extend: {} },
  plugins: [],
};
EOF

echo ">>> Writing postcss.config.js …"
cat > postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOF

# 5) index.html (Vite style entry)
mkdir -p src
echo ">>> Writing index.html …"
cat > index.html << 'EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Glamour Nails Studio</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/index.js"></script>
  </body>
</html>
EOF

# 6) index.css
echo ">>> Writing src/index.css …"
cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

html, body, #root { height: 100%; }
EOF

# 7) index.js with ErrorBoundary
echo ">>> Writing src/index.js …"
cat > src/index.js << 'EOF'
import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import "./index.css";

class ErrorBoundary extends React.Component {
  constructor(p){ super(p); this.state = { hasError:false, err:null }; }
  static getDerivedStateFromError(err){ return { hasError:true, err }; }
  componentDidCatch(err, info){ console.error("App crashed:", err, info); }
  render(){
    if (this.state.hasError) {
      return (
        <div style={{ padding: 24, fontFamily: "system-ui" }}>
          <h2>Something went wrong.</h2>
          <pre style={{ whiteSpace: "pre-wrap" }}>{String(this.state.err?.stack || this.state.err)}</pre>
        </div>
      );
    }
    return this.props.children;
  }
}

const root = createRoot(document.getElementById("root"));
root.render(
  <ErrorBoundary>
    <App />
  </ErrorBoundary>
);
EOF

# 8) App.js
echo ">>> Writing src/App.js …"
cat > src/App.js << 'EOF'
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
EOF

# 9) components dir
mkdir -p src/components

# 9a) Header.js
echo ">>> Writing src/components/Header.js …"
cat > src/components/Header.js << 'EOF'
import React from "react";
import { Settings } from "lucide-react";

export default function Header({ currentView, isAdmin, onNav }) {
  return (
    <nav className="bg-pink-600 text-white p-4">
      <div className="max-w-6xl mx-auto flex justify-between items-center">
        <h1 className="text-xl font-bold">💅 Glamour Nails Studio</h1>
        <div className="flex gap-4">
          <button
            onClick={() => onNav("services")}
            className={`px-3 py-1 rounded ${currentView==="services" ? "bg-pink-700" : "hover:bg-pink-700"}`}
          >
            Services
          </button>
          <button
            onClick={() => onNav(isAdmin ? "admin" : "adminLogin")}
            className={`px-3 py-1 rounded ${(currentView==="admin" || currentView==="adminLogin") ? "bg-pink-700" : "hover:bg-pink-700"} flex items-center`}
          >
            <Settings className="w-4 h-4 mr-1" />
            {isAdmin ? "Admin Panel" : "Admin"}
          </button>
        </div>
      </div>
    </nav>
  );
}
EOF

# 9b) CustomerBooking.js
echo ">>> Writing src/components/CustomerBooking.js …"
cat > src/components/CustomerBooking.js << 'EOF'
import React, { useMemo, useState } from "react";
import { Calendar, Clock, Star, Check, MessageSquare } from "lucide-react";

// Config (Vite or CRA)
const API_BASE = (
  (typeof import !== "undefined" &&
    typeof import.meta !== "undefined" &&
    import.meta.env &&
    import.meta.env.VITE_API_BASE) ||
  (typeof process !== "undefined" &&
    process.env &&
    process.env.REACT_APP_API_URL) ||
  ""
).replace(/\/+$/, "");

const LS_KEY = "salonBookings";
const BUSINESS_PHONE = "+17864935524";

export const SERVICES = [
  { id: 1, name: "Classic Manicure", duration: 45, price: 35, description: "Basic nail care with polish" },
  { id: 2, name: "Gel Manicure", duration: 60, price: 50, description: "Long-lasting gel polish application" },
  { id: 3, name: "Classic Pedicure", duration: 60, price: 40, description: "Foot care with polish" },
  { id: 4, name: "Gel Pedicure", duration: 75, price: 55, description: "Long-lasting gel pedicure" },
  { id: 5, name: "Nail Art", duration: 30, price: 25, description: "Custom nail designs" },
  { id: 6, name: "Acrylic Full Set", duration: 90, price: 70, description: "Full acrylic nail extensions" },
  { id: 7, name: "Acrylic Fill", duration: 60, price: 45, description: "Acrylic nail maintenance" },
  { id: 8, name: "Dip Powder", duration: 75, price: 60, description: "Durable dip powder nails" }
];

export const STAFF = [
  { id: 1, name: "Maria Rodriguez", specialties: ["Manicure", "Nail Art"], rating: 4.9, experience: "8 years" },
  { id: 2, name: "Jessica Chen", specialties: ["Pedicure", "Gel Services"], rating: 4.8, experience: "6 years" },
  { id: 3, name: "Ashley Johnson", specialties: ["Acrylics", "Extensions"], rating: 4.9, experience: "10 years" },
  { id: 4, name: "Sofia Martinez", specialties: ["Dip Powder", "Nail Art"], rating: 4.7, experience: "5 years" }
];

export const TIME_SLOTS = [
  "9:00 AM","9:30 AM","10:00 AM","10:30 AM","11:00 AM","11:30 AM",
  "12:00 PM","12:30 PM","1:00 PM","1:30 PM","2:00 PM","2:30 PM",
  "3:00 PM","3:30 PM","4:00 PM","4:30 PM","5:00 PM","5:30 PM"
];

export default function CustomerBooking({ onDone }) {
  const [selectedService, setSelectedService] = useState(null);
  const [selectedStaff, setSelectedStaff] = useState(null);
  const [selectedDate, setSelectedDate] = useState("");
  const [selectedTime, setSelectedTime] = useState("");
  const [smsStatus, setSmsStatus] = useState("");
  const [currentBooking, setCurrentBooking] = useState(null);
  const [customerInfo, setCustomerInfo] = useState({ firstName: "", lastName: "", email: "", phone: "", notes: "" });

  const getAllBookings = () => {
    try { return JSON.parse(localStorage.getItem(LS_KEY) || "[]"); } catch { return []; }
  };
  const saveAllBookings = (arr) => localStorage.setItem(LS_KEY, JSON.stringify(arr));

  const isValidEmail = (s) => /\S+@\S+\.\S+/.test(s);
  const isValidPhone = (s) => /^\+?\d[\d\s\-()]{7,}$/.test(s);

  const isFormValid = !!(selectedService && selectedStaff && selectedDate && selectedTime &&
    customerInfo.firstName.trim() && customerInfo.lastName.trim() &&
    isValidEmail(customerInfo.email) && isValidPhone(customerInfo.phone));

  const getAvailableDates = () => {
    const out = []; const today = new Date();
    for (let i = 1; i <= 14; i++) { const d = new Date(today); d.setDate(today.getDate() + i); out.push(d.toISOString().split("T")[0]); }
    return out;
  };

  const formatDate = (dateString) => {
    if (!dateString) return "";
    const date = new Date(dateString + "T00:00:00");
    return date.toLocaleDateString("en-US", { weekday: "long", year: "numeric", month: "long", day: "numeric" });
  };

  async function sendSMS(booking) {
    setSmsStatus("Sending SMS notifications...");
    try {
      const res = await fetch(`${API_BASE}/api/sms/send`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ businessPhone: "+17864935524", booking })
      });
      if (!res.ok) throw new Error(`SMS API error ${res.status}`);
      setSmsStatus("✅ SMS notifications sent successfully!");
    } catch (e) {
      console.error(e);
      setSmsStatus("❌ SMS sending failed. Check backend/Twilio.");
    } finally {
      setTimeout(() => setSmsStatus(""), 4000);
    }
  }

  const handleBookingSubmit = async () => {
    const newBooking = {
      id: Date.now(),
      service: selectedService,
      staff: selectedStaff,
      date: selectedDate,
      time: selectedTime,
      customer: customerInfo,
      status: "confirmed",
      createdAt: new Date().toISOString()
    };
    const next = [...getAllBookings(), newBooking];
    saveAllBookings(next);
    setCurrentBooking(newBooking);
    await sendSMS(newBooking);
  };

  if (currentBooking) {
    return (
      <div className="max-w-2xl mx-auto p-6 text-center">
        <div className="mb-6">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <Check className="w-8 h-8 text-green-600" />
          </div>
          <h2 className="text-3xl font-bold text-green-800 mb-2">Booking Confirmed!</h2>
          <p className="text-gray-600">Your appointment has been successfully booked.</p>
        </div>

        {smsStatus && (
          <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <div className="flex items-center justify-center">
              <MessageSquare className="w-5 h-5 text-blue-600 mr-2" />
              <span className="text-blue-800">{smsStatus}</span>
            </div>
          </div>
        )}

        <div className="bg-gray-50 rounded-lg p-6 mb-6 text-left">
          <h3 className="text-xl font-semibold mb-4">Appointment Details</h3>
          <div className="space-y-3">
            <div className="flex justify-between"><span className="font-medium">Service:</span><span>{currentBooking.service.name}</span></div>
            <div className="flex justify-between"><span className="font-medium">Technician:</span><span>{currentBooking.staff.name}</span></div>
            <div className="flex justify-between"><span className="font-medium">Date:</span><span>{formatDate(currentBooking.date)}</span></div>
            <div className="flex justify-between"><span className="font-medium">Time:</span><span>{currentBooking.time}</span></div>
            <div className="flex justify-between"><span className="font-medium">Duration:</span><span>{currentBooking.service.duration} minutes</span></div>
            <div className="flex justify-between font-semibold text-lg"><span>Total:</span><span>${currentBooking.service.price}</span></div>
          </div>
        </div>

        <div className="flex gap-4">
          <button
            onClick={() => onDone?.("services")}
            className="flex-1 py-2 border border-pink-600 text-pink-600 rounded-md hover:bg-pink-50"
          >
            Book Another
          </button>
          <button
            onClick={() => onDone?.("admin")}
            className="flex-1 py-2 bg-pink-600 text-white rounded-md hover:bg-pink-700"
          >
            View Admin Panel
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto p-6">
      <div className="text-center mb-8">
        <h1 className="text-4xl font-bold text-pink-800 mb-2">Glamour Nails Studio</h1>
        <p className="text-gray-600">Professional nail care services</p>
      </div>

      <h2 className="text-2xl font-semibold mb-6">Select a Service</h2>
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
        {SERVICES.map(service => (
          <div key={service.id}
               className="border rounded-lg p-6 hover:shadow-lg transition-shadow cursor-pointer"
               onClick={() => setSelectedService(service)}>
            <h3 className="text-xl font-semibold mb-2">{service.name}</h3>
            <p className="text-gray-600 mb-3">{service.description}</p>
            <div className="flex justify-between items-center">
              <span className="text-2xl font-bold text-pink-600">${service.price}</span>
              <span className="text-sm text-gray-500">{service.duration} min</span>
            </div>
          </div>
        ))}
      </div>

      {/* Staff */}
      <div className="mb-6">
        <label className="block text-sm font-medium mb-3">Choose Your Nail Technician</label>
        <div className="grid md:grid-cols-2 gap-4">
          {STAFF.map(staff => (
            <div key={staff.id}
                 className={`border rounded-lg p-4 cursor-pointer transition-colors ${selectedStaff?.id === staff.id ? "border-pink-500 bg-pink-50" : "hover:border-pink-300"}`}
                 onClick={() => setSelectedStaff(staff)}>
              <div className="flex justify-between items-start mb-2">
                <h4 className="font-semibold">{staff.name}</h4>
                <div className="flex items-center">
                  <Star className="w-4 h-4 text-yellow-400 fill-current" />
                  <span className="text-sm ml-1">{staff.rating}</span>
                </div>
              </div>
              <p className="text-sm text-gray-600 mb-1">{staff.experience}</p>
              <p className="text-xs text-gray-500">{staff.specialties.join(", ")}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Date */}
      <div className="mb-6">
        <label className="block text-sm font-medium mb-3">Select Date</label>
        <select
          value={selectedDate}
          onChange={(e) => setSelectedDate(e.target.value)}
          className="w-full p-3 border rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
        >
          <option value="">Choose a date</option>
          {getAvailableDates().map(date => (
            <option key={date} value={date}>{formatDate(date)}</option>
          ))}
        </select>
      </div>

      {/* Time */}
      <div className="mb-6">
        <label className="block text-sm font-medium mb-3">Select Time</label>
        <div className="grid grid-cols-3 gap-2">
          {TIME_SLOTS.map(time => (
            <button key={time} onClick={() => setSelectedTime(time)}
              className={`p-2 text-sm border rounded transition-colors ${selectedTime === time ? "border-pink-500 bg-pink-500 text-white" : "border-gray-300 hover:border-pink-300"}`}>
              {time}
            </button>
          ))}
        </div>
      </div>

      {/* Customer */}
      <div className="mb-6">
        <h3 className="text-lg font-semibold mb-4">Your Information</h3>
        <div className="grid md:grid-cols-2 gap-4 mb-4">
          <input type="text" placeholder="First Name" value={customerInfo.firstName}
                 onChange={(e) => setCustomerInfo(p => ({ ...p, firstName: e.target.value }))}
                 className="p-3 border rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500" autoComplete="given-name" />
          <input type="text" placeholder="Last Name" value={customerInfo.lastName}
                 onChange={(e) => setCustomerInfo(p => ({ ...p, lastName: e.target.value }))}
                 className="p-3 border rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500" autoComplete="family-name" />
        </div>
        <div className="grid md:grid-cols-2 gap-4 mb-4">
          <input type="email" placeholder="Email Address" value={customerInfo.email}
                 onChange={(e) => setCustomerInfo(p => ({ ...p, email: e.target.value }))}
                 className="p-3 border rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500" autoComplete="email" />
          <input type="tel" placeholder="Phone Number (+1 xxx-xxx-xxxx)" value={customerInfo.phone}
                 onChange={(e) => setCustomerInfo(p => ({ ...p, phone: e.target.value }))}
                 className="p-3 border rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500" autoComplete="tel" />
        </div>
        <textarea placeholder="Special requests or notes (optional)" value={customerInfo.notes}
                  onChange={(e) => setCustomerInfo(p => ({ ...p, notes: e.target.value }))}
                  className="w-full p-3 border rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500 h-24 resize-none" autoComplete="off" />
      </div>

      <button
        onClick={handleBookingSubmit}
        disabled={!isFormValid}
        className="w-full py-3 bg-pink-600 text-white rounded-md font-semibold hover:bg-pink-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
      >
        {smsStatus ? (<><MessageSquare className="w-5 h-5 mr-2" />{smsStatus}</>) : "Book Appointment & Send SMS"}
      </button>
    </div>
  );
}
EOF

# 9c) AdminDashboard.js
echo ">>> Writing src/components/AdminDashboard.js …"
cat > src/components/AdminDashboard.js << 'EOF'
import React, { useMemo, useState } from "react";
import { Calendar, Clock, ChevronLeft, ChevronRight, Search, Filter, Trash2, MessageSquare, Star, Scissors } from "lucide-react";

const API_BASE = (
  (typeof import !== "undefined" &&
    typeof import.meta !== "undefined" &&
    import.meta.env &&
    import.meta.env.VITE_API_BASE) ||
  (typeof process !== "undefined" &&
    process.env &&
    process.env.REACT_APP_API_URL) ||
  ""
).replace(/\/+$/, "");

const LS_KEY = "salonBookings";

export default function AdminDashboard({ onLogout, onNewBooking }) {
  const [adminViewMode, setAdminViewMode] = useState("day");
  const [adminCurrentDate, setAdminCurrentDate] = useState(new Date());
  const [searchTerm, setSearchTerm] = useState("");
  const [filterStatus, setFilterStatus] = useState("all");

  const bookings = useMemo(() => {
    try { return JSON.parse(localStorage.getItem(LS_KEY) || "[]"); } catch { return []; }
  }, []);

  const saveBookings = (arr) => localStorage.setItem(LS_KEY, JSON.stringify(arr));

  const compareByDateTime = (a, b) => {
    if (a.date !== b.date) return a.date < b.date ? -1 : 1;
    const toMin = (t) => { const [time, p] = t.split(" "); const [h,m]=time.split(":").map(Number); const hh=(p==="PM"? (h%12)+12 : (h%12)); return hh*60+(m||0); };
    return toMin(a.time) - toMin(b.time);
  };

  const getFilteredBookings = () => {
    let filtered = [...bookings];
    const d = adminCurrentDate;
    const dStr = d.toISOString().split("T")[0];

    if (adminViewMode === "day") {
      filtered = filtered.filter(b => b.date === dStr);
    } else if (adminViewMode === "week") {
      const start = new Date(d); start.setDate(d.getDate() - d.getDay());
      const end = new Date(start); end.setDate(start.getDate() + 6);
      filtered = filtered.filter(b => { const dt = new Date(b.date + "T00:00:00"); return dt >= start && dt <= end; });
    } else {
      const start = new Date(d.getFullYear(), d.getMonth(), 1);
      const end = new Date(d.getFullYear(), d.getMonth() + 1, 0);
      filtered = filtered.filter(b => { const dt = new Date(b.date + "T00:00:00"); return dt >= start && dt <= end; });
    }

    if (filterStatus !== "all") filtered = filtered.filter(b => b.status === filterStatus);

    if (searchTerm) {
      const t = searchTerm.toLowerCase();
      filtered = filtered.filter(b =>
        b.customer.firstName.toLowerCase().includes(t) ||
        b.customer.lastName.toLowerCase().includes(t) ||
        (b.customer.phone || "").toLowerCase().includes(t) ||
        b.service.name.toLowerCase().includes(t) ||
        b.staff.name.toLowerCase().includes(t)
      );
    }

    return filtered.sort(compareByDateTime);
  };

  const filtered = getFilteredBookings();
  const totalRevenue = filtered.reduce((s,b)=> s + (b?.service?.price || 0), 0);

  const getDateRangeText = () => {
    const d = adminCurrentDate;
    if (adminViewMode === "day")
      return d.toLocaleDateString("en-US", { weekday:"long", year:"numeric", month:"long", day:"numeric" });
    if (adminViewMode === "week") {
      const start = new Date(d); start.setDate(d.getDate()-d.getDay());
      const end = new Date(start); end.setDate(start.getDate()+6);
      return `${start.toLocaleDateString("en-US",{month:"short",day:"numeric"})} - ${end.toLocaleDateString("en-US",{month:"short",day:"numeric",year:"numeric"})}`;
    }
    return d.toLocaleDateString("en-US", { year:"numeric", month:"long" });
  };

  const navigateDate = (dir) => {
    const d = new Date(adminCurrentDate);
    if (adminViewMode === "day") d.setDate(d.getDate() + dir);
    else if (adminViewMode === "week") d.setDate(d.getDate() + (dir * 7));
    else d.setMonth(d.getMonth() + dir);
    setAdminCurrentDate(d);
  };

  const updateStatus = (id, status) => {
    const next = bookings.map(b => b.id === id ? { ...b, status } : b);
    saveBookings(next);
    window.location.reload();
  };

  const deleteBooking = (id) => {
    if (!window.confirm("Delete this appointment?")) return;
    const next = bookings.filter(b => b.id !== id);
    saveBookings(next);
    window.location.reload();
  };

  async function resendSMS(booking) {
    try {
      await fetch(`${API_BASE}/api/sms/send`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ businessPhone: "+17864935524", booking })
      });
      alert("SMS sent.");
    } catch(e) { alert("SMS failed. Check backend."); }
  }

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-2xl font-semibold">💅 Admin Panel</h2>
          <p className="text-gray-600">Manage all salon appointments</p>
        </div>
        <div className="flex gap-2">
          <button onClick={onNewBooking} className="px-4 py-2 bg-pink-600 text-white rounded-md hover:bg-pink-700">New Booking</button>
          <button onClick={onLogout} className="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600">Logout</button>
        </div>
      </div>

      <div className="bg-white border rounded-lg p-4 mb-6">
        <div className="flex justify-between items-center mb-4">
          <div className="flex gap-2">
            {["day","week","month"].map(m => (
              <button key={m} onClick={()=>setAdminViewMode(m)} className={`px-4 py-2 rounded-lg capitalize ${adminViewMode===m ? "bg-pink-600 text-white":"bg-gray-200 hover:bg-gray-300"}`}>{m} View</button>
            ))}
          </div>
          <button onClick={()=>setAdminCurrentDate(new Date())} className="px-3 py-1 text-sm bg-blue-100 text-blue-800 rounded hover:bg-blue-200">Today</button>
        </div>
        <div className="flex items-center justify-between">
          <button onClick={()=>navigateDate(-1)} className="p-2 rounded-lg hover:bg-gray-100 text-gray-600"><ChevronLeft className="w-5 h-5"/></button>
          <div className="text-center">
            <h3 className="text-lg font-semibold">{getDateRangeText()}</h3>
            <p className="text-sm text-gray-500">{filtered.length} appointment{filtered.length!==1?"s":""}</p>
          </div>
          <button onClick={()=>navigateDate(1)} className="p-2 rounded-lg hover:bg-gray-100 text-gray-600"><ChevronRight className="w-5 h-5"/></button>
        </div>
      </div>

      <div className="grid md:grid-cols-4 gap-6 mb-8">
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <h3 className="font-semibold text-blue-800">{adminViewMode==="day"?"Today":adminViewMode==="week"?"This Week":"This Month"}</h3>
          <div className="text-2xl font-bold text-blue-600">{filtered.length}</div>
          <div className="text-xs text-blue-600">appointments</div>
        </div>
        <div className="bg-green-50 border border-green-200 rounded-lg p-4">
          <h3 className="font-semibold text-green-800">Confirmed</h3>
          <div className="text-2xl font-bold text-green-600">{filtered.filter(b=>b.status==="confirmed").length}</div>
          <div className="text-xs text-green-600">appointments</div>
        </div>
        <div className="bg-purple-50 border border-purple-200 rounded-lg p-4">
          <h3 className="font-semibold text-purple-800">Revenue</h3>
          <div className="text-2xl font-bold text-purple-600">${totalRevenue}</div>
          <div className="text-xs text-purple-600">total earnings</div>
        </div>
        <div className="bg-orange-50 border border-orange-200 rounded-lg p-4">
          <h3 className="font-semibold text-orange-800">Avg. Booking</h3>
          <div className="text-2xl font-bold text-orange-600">${filtered.length>0 ? Math.round(totalRevenue/filtered.length):0}</div>
          <div className="text-xs text-orange-600">per appointment</div>
        </div>
      </div>

      <div className="bg-white border rounded-lg p-4 mb-6">
        <div className="flex gap-4 items-center">
          <div className="flex-1 relative">
            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input type="text" placeholder="Search appointments..." value={searchTerm}
              onChange={(e)=>setSearchTerm(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500" autoComplete="off" />
          </div>
          <div className="flex items-center gap-2">
            <Filter className="w-5 h-5 text-gray-400" />
            <select value={filterStatus} onChange={(e)=>setFilterStatus(e.target.value)} className="p-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500">
              <option value="all">All Status</option>
              <option value="confirmed">Confirmed</option>
              <option value="pending">Pending</option>
              <option value="cancelled">Cancelled</option>
              <option value="completed">Completed</option>
            </select>
          </div>
        </div>
      </div>

      <div className="bg-white border rounded-lg overflow-hidden">
        <div className="p-4 bg-gray-50 border-b"><h3 className="font-semibold">Appointments ({filtered.length})</h3></div>
        {filtered.length===0 ? (
          <div className="p-8 text-center text-gray-500">
            <Calendar className="w-16 h-16 mx-auto mb-4 text-gray-300" />
            <p className="text-lg mb-2">No appointments found</p>
            <button onClick={onNewBooking} className="mt-4 px-6 py-2 bg-pink-600 text-white rounded-md hover:bg-pink-700">Book First Appointment</button>
          </div>
        ) : (
          <div className="divide-y">
            {filtered.map(booking => (
              <div key={booking.id} className="p-4 hover:bg-gray-50">
                <div className="flex justify-between items-start mb-3">
                  <div>
                    <h4 className="font-semibold text-lg">{booking.customer.firstName} {booking.customer.lastName}</h4>
                    <div className="text-sm text-gray-600 flex items-center gap-4">
                      <span>📧 {booking.customer.email}</span>
                      <span>📱 {(booking.customer.phone||"").trim()}</span>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-xl font-bold text-green-600 mb-2">${booking.service.price}</div>
                    <select value={booking.status} onChange={(e)=>updateStatus(booking.id, e.target.value)}
                      className={`px-3 py-1 rounded-full text-xs border-0 ${
                        booking.status==="confirmed" ? "bg-green-100 text-green-800" :
                        booking.status==="pending" ? "bg-yellow-100 text-yellow-800" :
                        booking.status==="cancelled" ? "bg-red-100 text-red-800" :
                        "bg-blue-100 text-blue-800"}`}>
                      <option value="confirmed">Confirmed</option>
                      <option value="pending">Pending</option>
                      <option value="cancelled">Cancelled</option>
                      <option value="completed">Completed</option>
                    </select>
                  </div>
                </div>

                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-4 text-sm mb-3">
                  <div className="flex items-center"><Calendar className="w-4 h-4 text-gray-400 mr-2" /><div><span className="font-medium">Date:</span><div>{new Date(booking.date+"T00:00:00").toLocaleDateString("en-US",{weekday:"long", month:"long", day:"numeric", year:"numeric"})}</div></div></div>
                  <div className="flex items-center"><Clock className="w-4 h-4 text-gray-400 mr-2" /><div><span className="font-medium">Time:</span><div>{booking.time}</div></div></div>
                  <div className="flex items-center"><Scissors className="w-4 h-4 text-gray-400 mr-2" /><div><span className="font-medium">Service:</span><div>{booking.service.name}</div></div></div>
                  <div className="flex items-center"><Star className="w-4 h-4 text-gray-400 mr-2" /><div><span className="font-medium">Technician:</span><div>{booking.staff.name}</div></div></div>
                </div>

                {booking.customer.notes && (
                  <div className="text-sm bg-gray-100 p-2 rounded mb-3"><span className="font-medium">Notes:</span> {booking.customer.notes}</div>
                )}

                <div className="flex gap-2">
                  <button onClick={()=>resendSMS(booking)} className="px-3 py-1 text-sm bg-green-100 text-green-800 rounded hover:bg-green-200"><MessageSquare className="w-4 h-4 inline mr-1" />Send SMS</button>
                  <button onClick={()=>deleteBooking(booking.id)} className="px-3 py-1 text-sm bg-red-100 text-red-800 rounded hover:bg-red-200"><Trash2 className="w-4 h-4 inline mr-1" />Delete</button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
EOF

# 10) Ensure scripts in package.json
echo ">>> Ensuring package.json has Vite scripts …"
node - <<'EOF'
const fs = require('fs');
const pj = JSON.parse(fs.readFileSync('package.json','utf8'));
pj.scripts = pj.scripts || {};
pj.scripts.dev = pj.scripts.dev || "vite";
pj.scripts.build = pj.scripts.build || "vite build";
pj.scripts.preview = pj.scripts.preview || "vite preview --port 5173";
fs.writeFileSync('package.json', JSON.stringify(pj, null, 2));
console.log("package.json updated.");
EOF

echo ">>> Done! Run:  npm run dev"
