// ecom-stack/order-service/server.js
const express = require("express");
const prom = require("prom-client");
const app = express();
app.use(express.json());

// In-memory store for orders
let orders = [
  // Example initial order
  // { id: 1, item: "SKU-42", qty: 2, status: "NEW", createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }
];
let nextOrderId =
  orders.length > 0 ? Math.max(...orders.map((o) => o.id)) + 1 : 1;

// --- Prometheus Metrics ---
const register = new prom.Registry();
prom.collectDefaultMetrics({ register }); // Collects default Node.js metrics

const hits = new prom.Counter({
  name: "order_service_requests_total",
  help: "Total number of requests to the order service by path and method",
  labelNames: ["path", "method", "status_code"],
  registers: [register],
});

const duration = new prom.Histogram({
  name: "order_service_request_duration_seconds",
  help: "Request duration in seconds for the order service",
  labelNames: ["path", "method"],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10], // Adjusted buckets
  registers: [register],
});

const totalOrdersGauge = new prom.Gauge({
  name: "order_service_orders_total_count",
  help: "Total number of orders currently in the system",
  registers: [register],
});

const ordersByStatusCounter = new prom.Counter({
  name: "order_service_orders_by_status_total",
  help: "Total number of orders processed, categorized by status",
  labelNames: ["status"],
  registers: [register],
});

// Middleware to record metrics for all requests
app.use((req, res, next) => {
  const end = duration.startTimer({ path: req.path, method: req.method });
  res.on("finish", () => {
    hits.inc({
      path: req.path,
      method: req.method,
      status_code: res.statusCode,
    });
    end(); // End the timer and record duration
  });
  next();
});

// --- Endpoints ---
app.get("/metrics", async (_, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

// GET all orders
app.get("/", (req, res) => {
  res.json(orders);
});

// GET order by ID
app.get("/:id", (req, res) => {
  const orderId = parseInt(req.params.id);
  const order = orders.find((o) => o.id === orderId);

  if (order) {
    res.json(order);
  } else {
    res.status(404).json({ error: "Order not found" });
  }
});

// POST a new order
app.post("/", (req, res) => {
  const { item, qty } = req.body;

  if (!item || typeof qty !== "number" || qty <= 0) {
    return res.status(400).json({
      error:
        "Invalid input: 'item' (string) and 'qty' (positive number) are required.",
    });
  }

  const now = new Date().toISOString();
  const newOrder = {
    id: nextOrderId++,
    item,
    qty,
    status: "NEW",
    createdAt: now,
    updatedAt: now,
  };
  orders.push(newOrder);
  totalOrdersGauge.inc(); // Increment total orders gauge
  ordersByStatusCounter.inc({ status: "NEW" }); // Increment status counter

  res.status(201).json(newOrder);
});

// PUT - Update order status
app.put("/:id/status", (req, res) => {
  const orderId = parseInt(req.params.id);
  const { status } = req.body;

  if (!status) {
    return res
      .status(400)
      .json({ error: "Invalid input: 'status' is required." });
  }

  const orderIndex = orders.findIndex((o) => o.id === orderId);

  if (orderIndex === -1) {
    return res.status(404).json({ error: "Order not found" });
  }

  const oldStatus = orders[orderIndex].status;
  orders[orderIndex].status = status.toUpperCase();
  orders[orderIndex].updatedAt = new Date().toISOString();

  // If you were decrementing old status and incrementing new for a gauge, do it here.
  // For a counter of processed statuses, just increment the new one.
  ordersByStatusCounter.inc({ status: orders[orderIndex].status });

  res.json(orders[orderIndex]);
});

// DELETE an order by ID
app.delete("/:id", (req, res) => {
  const orderId = parseInt(req.params.id);
  const orderIndex = orders.findIndex((o) => o.id === orderId);

  if (orderIndex === -1) {
    return res.status(404).json({ error: "Order not found" });
  }

  const deletedOrder = orders.splice(orderIndex, 1)[0];
  totalOrdersGauge.dec(); // Decrement total orders gauge
  // Optionally, you could have a counter for deleted orders.

  res.status(204).send(); // No content
});

// Initialize gauge with current order count at startup
totalOrdersGauge.set(orders.length);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Order-service running on port ${PORT}`);
  console.log(`View metrics at http://localhost:${PORT}/metrics`);
});
