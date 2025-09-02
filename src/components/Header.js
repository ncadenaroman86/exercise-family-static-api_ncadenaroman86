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
