package main

import (
	"encoding/json"
	"log" // Ajout du package log
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/prometheus/client_golang/prometheus/collectors"
)

// Item struct with more details
type Item struct {
	SKU             string    `json:"sku"`
	Name            string    `json:"name"`
	Stock           int       `json:"stock"`
	CreatedAt       time.Time `json:"createdAt"`
	LastStockUpdate time.Time `json:"lastStockUpdate"`
}

// UpdateStockPayload for PUT/PATCH requests
type UpdateStockPayload struct {
	Change int `json:"change"` // Positive to add stock, negative to remove
}

// --- In-memory data store with a Mutex for concurrent access safety ---
var (
	inventory = make(map[string]*Item)
	invMutex  = &sync.RWMutex{}
)

// --- Prometheus Metrics ---
var (
	registry = prometheus.NewRegistry() // Custom registry

	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "inventory_service_http_requests_total",
			Help: "Total number of HTTP requests by path, method, and status code.",
		},
		[]string{"path", "method", "code"},
	)
	httpRequestDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "inventory_service_http_request_duration_seconds",
			Help:    "HTTP request duration in seconds.",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"path", "method"},
	)
	itemsInStockGauge = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Name: "inventory_service_items_stock_level",
			Help: "Current stock level for each item SKU.",
		},
		[]string{"sku", "name"},
	)
	stockUpdatesTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "inventory_service_stock_updates_total",
			Help: "Total number of stock update operations by SKU and type (increment/decrement).",
		},
		[]string{"sku", "type"},
	)
)

func initMetrics() {
	registry.MustRegister(httpRequestsTotal)
	registry.MustRegister(httpRequestDuration)
	registry.MustRegister(itemsInStockGauge)
	registry.MustRegister(stockUpdatesTotal)
	registry.MustRegister(collectors.NewGoCollector())      // Standard Go runtime metrics
	registry.MustRegister(collectors.NewProcessCollector(collectors.ProcessCollectorOpts{})) // Process metrics
}

// Initialize some sample inventory
func initializeInventory() {
	invMutex.Lock()
	defer invMutex.Unlock()

	now := time.Now().UTC()
	sampleItems := []Item{
		{SKU: "SKU-42", Name: "Awesome Gadget", Stock: 100, CreatedAt: now, LastStockUpdate: now},
		{SKU: "SKU-11", Name: "Cool Widget", Stock: 250, CreatedAt: now, LastStockUpdate: now},
		{SKU: "SKU-77", Name: "Shiny Thing", Stock: 50, CreatedAt: now, LastStockUpdate: now},
	}

	for i := range sampleItems { // Itérer sur l'index pour obtenir des pointeurs vers des copies
		itemCopy := sampleItems[i]
		inventory[itemCopy.SKU] = &itemCopy // Stocker le pointeur vers la copie
		itemsInStockGauge.WithLabelValues(itemCopy.SKU, itemCopy.Name).Set(float64(itemCopy.Stock))
	}
}

// --- HTTP Handlers ---

// Middleware for metrics
func metricsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		path := r.URL.Path
		method := r.Method
		timer := prometheus.NewTimer(httpRequestDuration.WithLabelValues(path, method))
		
		// Use a custom response writer to capture status code
		rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK} // Default to 200

		next.ServeHTTP(rw, r) // Serve the request

		statusCode := strconv.Itoa(rw.statusCode)
		httpRequestsTotal.WithLabelValues(path, method, statusCode).Inc()
		timer.ObserveDuration()
	})
}

// Custom responseWriter to capture status code for metrics
type responseWriter struct {
    http.ResponseWriter
    statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
    rw.statusCode = code
    rw.ResponseWriter.WriteHeader(code)
}


func handleInventory(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	// Correction: le SKU est la partie du chemin APRÈS le premier '/'
	// Par exemple, pour /SKU-123, sku sera "SKU-123"
	// Pour /, sku sera ""
	pathParts := strings.Split(strings.Trim(r.URL.Path, "/"), "/")
	sku := ""
	if len(pathParts) > 0 {
		sku = pathParts[0]
	}


	invMutex.RLock() // Read Lock
	
	if sku == "" && r.Method == http.MethodGet { // Get all inventory items only for GET /
		var allItems []*Item
		for _, item := range inventory {
			allItems = append(allItems, item)
		}
		invMutex.RUnlock() // Unlock before JSON encoding
		json.NewEncoder(w).Encode(allItems)
		return
	}
	invMutex.RUnlock() // Unlock if not getting all items or not GET /

	// Si sku est vide ici, cela signifie que ce n'est pas GET / et que le chemin est juste "/"
	// ce qui n'est pas un SKU valide pour les opérations individuelles.
	if sku == "" {
		http.Error(w, `{"error": "SKU must be provided for this operation"}`, http.StatusBadRequest)
		return
	}


	invMutex.RLock() // Re-lock for individual item access
	item, exists := inventory[sku]
	invMutex.RUnlock() // Unlock after map access

	if !exists {
		// Mettre à jour le code de statut dans le writer personnalisé avant d'appeler http.Error
		// Bien que http.Error le fasse aussi, c'est une bonne pratique si on n'utilise pas http.Error
		// rw := w.(*responseWriter) // Ceci ne fonctionnera pas si w n'est pas déjà notre type.
		// Il faut s'assurer que le middleware est appliqué correctement.
		// Pour simplifier, on va supposer que http.Error met à jour le statut correctement pour le middleware.
		http.Error(w, `{"error": "SKU not found"}`, http.StatusNotFound)
		return
	}

	if r.Method == http.MethodGet {
		json.NewEncoder(w).Encode(item)
	} else if r.Method == http.MethodPut || r.Method == http.MethodPatch { // Treat PUT and PATCH similarly for stock change
		invMutex.Lock() // Full Lock for modification
		defer invMutex.Unlock()

		// Re-check existence inside the full lock in case it was deleted between RUnlock and Lock
		item, exists = inventory[sku] // item est redéclaré ici, ce qui est bien
		if !exists {
			http.Error(w, `{"error": "SKU not found, possibly deleted during request"}`, http.StatusNotFound)
			return
		}

		var payload UpdateStockPayload
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			http.Error(w, `{"error": "Invalid request body: `+err.Error()+`"}`, http.StatusBadRequest)
			return
		}

		if item.Stock+payload.Change < 0 {
			http.Error(w, `{"error": "Stock cannot be negative"}`, http.StatusBadRequest)
			return
		}

		item.Stock += payload.Change
		item.LastStockUpdate = time.Now().UTC()
		// inventory[sku] = item // Pas besoin de réassigner si item est un pointeur et qu'on modifie ses champs

		// Update Prometheus Gauge
		itemsInStockGauge.WithLabelValues(item.SKU, item.Name).Set(float64(item.Stock))
		updateType := "increment"
		if payload.Change < 0 {
			updateType = "decrement"
		}
		stockUpdatesTotal.WithLabelValues(item.SKU, updateType).Add(float64(abs(payload.Change)))


		json.NewEncoder(w).Encode(item)
	} else {
		http.Error(w, `{"error": "Method not allowed"}`, http.StatusMethodNotAllowed)
	}
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func main() {
	initMetrics()
	initializeInventory()

	mux := http.NewServeMux()
	
	inventoryHandler := http.HandlerFunc(handleInventory)
	// Le middleware doit envelopper le handler qui sera effectivement appelé.
	mux.Handle("/", metricsMiddleware(inventoryHandler)) 

	// Expose the registered metrics via HTTP.
	mux.Handle("/metrics", promhttp.HandlerFor(registry, promhttp.HandlerOpts{}))

	port := ":8000"
	// Déclaration du serveur personnalisé
	server := &http.Server{
		Addr:    port,
		Handler: mux, // Utiliser notre mux avec le middleware de métriques
	}

	
	go func() { // Goroutine pour mettre à jour les niveaux de stock périodiquement pour la démonstration
		ticker := time.NewTicker(30 * time.Second)
		defer ticker.Stop()
		for range ticker.C {
			invMutex.Lock()
			for sku, item := range inventory {
				if sku == "SKU-42" && item.Stock > 5 { // Simuler une diminution de stock
					change := -5
					item.Stock += change
					item.LastStockUpdate = time.Now().UTC()
					itemsInStockGauge.WithLabelValues(item.SKU, item.Name).Set(float64(item.Stock))
					stockUpdatesTotal.WithLabelValues(item.SKU, "decrement_auto").Add(float64(abs(change)))
				}
			}
			invMutex.Unlock()
		}
	}()
	

	// Utiliser la variable server pour démarrer le serveur
	log.Printf("Inventory service starting on port %s", port)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("ListenAndServe Error: %s", err)
	}
}
