# ecom-stack/reco-service/app.py
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CollectorRegistry, CONTENT_TYPE_LATEST
import time
import datetime

app = Flask(__name__)

# --- Prometheus Metrics ---
registry = CollectorRegistry()

hits = Counter('reco_service_requests_total', 'Total requests to recommendation service by endpoint', ['endpoint', 'method', 'status_code'], registry=registry)
latency = Histogram('reco_service_request_duration_seconds', 'Request latency in seconds', ['endpoint', 'method'], registry=registry)
users_with_recos_gauge = Gauge('reco_service_users_with_custom_recos_total', 'Number of users with custom recommendations', registry=registry)
default_recos_served_counter = Counter('reco_service_default_recos_served_total', 'Number of times default recommendations were served', registry=registry)


# In-memory data store
# Structure: { "user_id": {"recos": ["SKU-A", "SKU-B"], "lastUpdated": "ISO_TIMESTAMP"}, ... }
DATA = {
    "1": {"recos": ["SKU-10", "SKU-42"], "lastUpdated": datetime.datetime.utcnow().isoformat()},
    "2": {"recos": ["SKU-99", "SKU-11"], "lastUpdated": datetime.datetime.utcnow().isoformat()}
}
DEFAULT_RECOS = ["SKU-DEFAULT-01", "SKU-DEFAULT-02", "SKU-POPULAR-A"]

# Update gauge at startup
users_with_recos_gauge.set(len(DATA))

# --- Middleware for Metrics ---
@app.before_request
def before_request_func():
    request.start_time = time.time()

@app.after_request
def after_request_func(response):
    request_latency = time.time() - request.start_time
    endpoint = request.path
    method = request.method
    status_code = response.status_code

    latency.labels(endpoint=endpoint, method=method).observe(request_latency)
    hits.labels(endpoint=endpoint, method=method, status_code=status_code).inc()
    return response

# --- Endpoints ---
@app.route('/')
def all_recos_overview():
    """ Returns an overview of all stored recommendations. """
    return jsonify(DATA)

@app.route('/<user_id>', methods=['GET', 'PUT'])
def user_recos(user_id):
    """
    GET: Returns recommendations for a specific user.
         If user not found, returns default recommendations.
    PUT: Updates or creates recommendations for a specific user.
         Expects JSON: {"reco": ["SKU-X", "SKU-Y"]}
    """
    if request.method == 'GET':
        if user_id in DATA:
            return jsonify(DATA[user_id])
        else:
            default_recos_served_counter.inc()
            return jsonify({"recos": DEFAULT_RECOS, "type": "default", "lastUpdated": None})

    elif request.method == 'PUT':
        if not request.is_json:
            return jsonify({"error": "Request must be JSON"}), 400

        new_reco_data = request.json
        if 'reco' not in new_reco_data or not isinstance(new_reco_data['reco'], list):
            return jsonify({"error": "Payload must contain 'reco' as a list of SKUs"}), 400

        was_existing_user = user_id in DATA
        DATA[user_id] = {
            "recos": [str(sku) for sku in new_reco_data['reco']], # Ensure SKUs are strings
            "lastUpdated": datetime.datetime.utcnow().isoformat()
        }
        if not was_existing_user:
            users_with_recos_gauge.inc() # New user added

        return jsonify(DATA[user_id]), 200 if was_existing_user else 201

@app.route('/metrics')
def metrics():
    return generate_latest(registry), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
