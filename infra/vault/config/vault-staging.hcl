# =============================================================================
# vault/config/vault-staging.hcl — HashiCorp Vault
# MODE : STAGING / PRODUCTION
# =============================================================================
# IMPORTANT : En mode server (pas -dev) :
#   1. Vault démarre SEALED — il faut l'unseal manuellement au premier démarrage
#   2. Commandes d'init (une seule fois) :
#      docker exec adv-vault vault operator init
#      → Sauvegarde les 5 unseal keys + root token dans un endroit SÉCURISÉ
#      docker exec adv-vault vault operator unseal <key1>
#      docker exec adv-vault vault operator unseal <key2>
#      docker exec adv-vault vault operator unseal <key3>
#   3. À chaque restart du conteneur → répéter les 3 commandes unseal
# =============================================================================

storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true   # TLS géré par Nginx devant Vault
}

ui            = true
api_addr      = "http://0.0.0.0:8200"
cluster_addr  = "http://0.0.0.0:8201"

# Durée max d'un token (24h en staging)
default_lease_ttl = "24h"
max_lease_ttl     = "768h"   # 32 jours max
