# Projet Microservices E-Commerce : Démo Technique

**Auteur : Chakib Heraoui**

Ce projet est une démonstration d'une application e-commerce construite sur une architecture microservices. L'objectif principal est de mettre en pratique et de mieux comprendre **Nginx**, **Docker**, l'orchestration avec **Docker Compose**, et les principes de l'**observabilité** avec Prometheus et Grafana dans un environnement polyglotte.

## ✨ Aperçu Rapide

* **Microservices Backend :**
    * `order-service` (Node.js/Express)
    * `reco-service` (Python/Flask)
    * `inventory-service` (Go)
* **Couche Périphérique :** Nginx (Reverse Proxy, API Gateway, SSL, Cache, Load Balancer)
* **Conteneurisation :** Docker & Docker Compose
* **Observabilité :** Prometheus & Grafana
* **Interface Utilisateur :** Simple UI en HTML, CSS, JS servie par Nginx.

---

## 🔥 Démarrage Rapide (Comment lancer le projet)

Suivez ces étapes pour avoir l'application fonctionnelle sur votre machine locale.

### 1. Prérequis

* **Git :** Pour cloner le projet.
* **Docker :** ([https://www.docker.com/get-started](https://www.docker.com/get-started))
* **Docker Compose :** (Généralement inclus avec Docker Desktop. Sur Linux, installez-le séparément si besoin).

### 2. Installation

a.  **Clonez le dépôt :**
    ```bash
    git clone https://github.com/chakibo004/microservices-ecommerce-nginx
    ```

b.  **(IMPORTANT)** **Générez les certificats SSL pour Nginx (HTTPS local) :**
    Nginx est configuré pour HTTPS. Pour le développement local, nous utilisons des certificats auto-signés.
    ```bash
    mkdir -p nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout nginx/ssl/nginx.key \
      -out nginx/ssl/nginx.crt \
      -subj "/CN=localhost"
    ```
    *Vous devrez accepter un avertissement de sécurité dans votre navigateur lors du premier accès en HTTPS.*
    Sinon utilisez directement les certificats du repo fournis pour les tests.

### 3. Lancez l'Application

Avec Docker Compose, construisez les images et démarrez tous les services :
```bash
docker-compose up --build -d
