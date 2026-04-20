# Stockage des données (volume Docker monté sur /vault/data)
storage "file" {
  path = "/vault/data"
}

# Listener HTTP (TLS géré par Nginx en dev)
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true   # OK en dev — Nginx gère TLS en staging/prod
}

# Interface UI Vault activée
ui = true

# Adresse de Vault (utilisée pour les redirections)
api_addr = "http://0.0.0.0:8200"
