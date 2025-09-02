import React, { useMemo, useState } from "react";
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


<div className="grid md:grid-cols-2 lg:grid-cols-5 gap-4 text-sm mb-3">
<div className="flex items-center"><Calendar className="w-4 h-4 text-gray-400 mr-2" /><div><span className="font-medium">Date:</span><div>{new Date(booking.date+"T00:00:00").toLocaleDateString("en-US",{weekday:"long", month:"long", day:"numeric", year:"numeric"})}</div></div></div>
<div className="flex items-center"><Clock className="w-4 h-4 text-gray-400 mr-2" /><div><span className="font-medium">Time:</span><div>{booking.time}</div></div></div>
<div className="flex items-center"><Scissors className="w-4 h-4 text-gray-400 mr-2" /><div><span className="font-medium">Service:</span><div>{booking.service.name}</div></div></div>
<div className="flex items-center"><Star className="w-4 h-4 text-gray-400 mr-2" /><div><span className="font-medium">Technician:</span><div>{booking.staff.name}</div></div></div>
<div className="flex items-center"><span className="font-medium mr-2">Payment:</span><div className="text-gray-700 capitalize">{booking?.payment?.method || "—"}</div></div>
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