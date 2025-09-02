import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from twilio.rest import Client

# ------- env -------
PORT = int(os.getenv("PORT", "5000"))
CORS_ORIGINS = [o.strip() for o in os.getenv("CORS_ORIGINS", "").split(",") if o.strip()]
ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID")
AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN")
FROM_NUMBER = os.getenv("TWILIO_FROM")
OWNER_PHONE = os.getenv("OWNER_PHONE")
DRY_RUN = os.getenv("DRY_RUN", "false").lower() == "true"

# ------- app -------
app = Flask(__name__)
cors_origins = CORS_ORIGINS or ["http://localhost:5173", "http://localhost:3000"]
CORS(app, resources={r"/api/*": {"origins": cors_origins}})

twilio_client = None
if ACCOUNT_SID and AUTH_TOKEN:
  twilio_client = Client(ACCOUNT_SID, AUTH_TOKEN)

@app.get("/api/health")
def health():
  return {"ok": True, "dry_run": DRY_RUN}

@app.post("/api/sms/send")
def send_sms():
  data = request.get_json(force=True) or {}
  booking = data.get("booking", {}) or {}
  business_phone = data.get("businessPhone") or OWNER_PHONE

  cust = booking.get("customer", {}) or {}
  service = booking.get("service", {}) or {}
  staff = booking.get("staff", {}) or {}
  date = booking.get("date", "")
  time = booking.get("time", "")

  customer_msg = (
    f"Hi {cust.get('firstName','')}! Your appointment at Glamour Nails "
    f"Studio is confirmed for {date} at {time}. "
    f"Service: {service.get('name','')} with {staff.get('name','')}."
  )
  business_msg = (
    "🆕 NEW BOOKING ALERT 📅\n\n"
    f"Customer: {cust.get('firstName','')} {cust.get('lastName','')}\n"
    f"Phone: {cust.get('phone','')}\n"
    f"Email: {cust.get('email','')}\n"
    f"Service: {service.get('name','')}\n"
    f"Staff: {staff.get('name','')}\n"
    f"Date: {date}\nTime: {time}\nPrice: ${service.get('price',0)}\n"
    + (f"Notes: {cust.get('notes','')}" if cust.get('notes') else "")
  )

  if not FROM_NUMBER or (not DRY_RUN and not twilio_client):
    return jsonify({"ok": False, "error": "Twilio not configured on server"}), 500

  if DRY_RUN:
    print("[DRY_RUN] Would send to customer:", cust.get("phone"), customer_msg)
    print("[DRY_RUN] Would send to business:", business_phone, business_msg)
    return jsonify({"ok": True, "dry_run": True})

  try:
    if cust.get("phone"):
      twilio_client.messages.create(from_=FROM_NUMBER, to=cust["phone"], body=customer_msg)
    if business_phone:
      twilio_client.messages.create(from_=FROM_NUMBER, to=business_phone, body=business_msg)
    return jsonify({"ok": True})
  except Exception as e:
    return jsonify({"ok": False, "error": str(e)}), 500

if __name__ == "__main__":
  app.run(host="0.0.0.0", port=PORT, debug=True)
