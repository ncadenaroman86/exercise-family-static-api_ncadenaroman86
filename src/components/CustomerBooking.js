import React, { useMemo, useState } from "react";


{/* Services */}
<h3 className="text-lg font-semibold mb-3">Select a Service</h3>
<div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-6">
{SERVICES.map(s => (
<div key={s.id} className={`border rounded-lg p-4 cursor-pointer ${selectedService?.id===s.id?"border-pink-500 bg-pink-50":"hover:border-pink-300"}`}
onClick={()=>setSelectedService(s)}>
<div className="flex justify-between items-start mb-2">
<div>
<h4 className="font-semibold">{s.name}</h4>
<p className="text-sm text-gray-600">{s.description}</p>
</div>
<div className="text-pink-600 font-bold">${s.price}</div>
</div>
<div className="text-xs text-gray-500">{s.duration} min</div>
</div>
))}
</div>


{/* Staff */}
<h3 className="text-lg font-semibold mb-3">Choose Your Nail Technician</h3>
<div className="grid md:grid-cols-2 gap-4 mb-6">
{STAFF.map(st => (
<div key={st.id} className={`border rounded-lg p-4 cursor-pointer ${selectedStaff?.id===st.id?"border-pink-500 bg-pink-50":"hover:border-pink-300"}`}
onClick={()=>setSelectedStaff(st)}>
<div className="flex justify-between items-start">
<span className="font-semibold">{st.name}</span>
<span className="flex items-center text-sm"><Star className="w-4 h-4 text-yellow-400 mr-1"/>{st.rating}</span>
</div>
<div className="text-xs text-gray-500">{st.specialties.join(", ")}</div>
</div>
))}
</div>


{/* Date */}
<h3 className="text-lg font-semibold mb-3">Select Date</h3>
<select value={selectedDate} onChange={(e)=>setSelectedDate(e.target.value)} className="w-full p-3 border rounded-md mb-6 focus:ring-2 focus:ring-pink-500">
<option value="">Choose a date</option>
{getAvailableDates().map(d => <option key={d} value={d}>{formatDate(d)}</option>)}
</select>


{/* Time */}
<h3 className="text-lg font-semibold mb-3">Select Time</h3>
<div className="grid grid-cols-3 gap-2 mb-6">
{TIME_SLOTS.map(t => (
<button key={t} onClick={()=>setSelectedTime(t)} className={`p-2 text-sm border rounded ${selectedTime===t?"bg-pink-500 text-white border-pink-500":"hover:border-pink-300"}`}>{t}</button>
))}
</div>


{/* Payment */}
<h3 className="text-lg font-semibold mb-3">Payment Method</h3>
<div className="flex gap-4 mb-6">
{(["card","cash"]).map(m => (
<label key={m} className={`px-4 py-2 border rounded cursor-pointer ${paymentMethod===m?"border-pink-500 bg-pink-50":"hover:border-pink-300"}`}>
<input type="radio" name="pay" value={m} className="mr-2" checked={paymentMethod===m} onChange={()=>setPaymentMethod(m)}/>
{m === "card" ? "Card" : "Cash"}
</label>
))}
</div>


{/* Customer info */}
<h3 className="text-lg font-semibold mb-3">Your Information</h3>
<div className="grid md:grid-cols-2 gap-4 mb-4">
<input className="p-3 border rounded-md" placeholder="First Name" value={customerInfo.firstName} onChange={e=>setCustomerInfo(p=>({...p, firstName:e.target.value}))}/>
<input className="p-3 border rounded-md" placeholder="Last Name" value={customerInfo.lastName} onChange={e=>setCustomerInfo(p=>({...p, lastName:e.target.value}))}/>
</div>
<div className="grid md:grid-cols-2 gap-4 mb-4">
<input className="p-3 border rounded-md" placeholder="Email" value={customerInfo.email} onChange={e=>setCustomerInfo(p=>({...p, email:e.target.value}))}/>
<input className="p-3 border rounded-md" placeholder="Phone (+1 xxx-xxx-xxxx)" value={customerInfo.phone} onChange={e=>setCustomerInfo(p=>({...p, phone:e.target.value}))}/>
</div>
<textarea className="w-full p-3 border rounded-md mb-4" placeholder="Notes (optional)" value={customerInfo.notes} onChange={e=>setCustomerInfo(p=>({...p, notes:e.target.value}))}/>


<button disabled={!isFormValid} onClick={handleSubmit}
className="w-full py-3 bg-pink-600 text-white rounded-md font-semibold hover:bg-pink-700 disabled:opacity-50 flex items-center justify-center">
{smsStatus ? (<><MessageSquare className="w-5 h-5 mr-2"/>{smsStatus}</>) : "Book Appointment & Send SMS"}
</button>
</div>
);
}