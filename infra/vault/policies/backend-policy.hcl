path "secret/data/adv/*" {
  capabilities = ["read"]
}

# Lister les chemins disponibles (pour debug uniquement)
path "secret/metadata/adv/*" {
  capabilities = ["list"]
}

# Renouveler son propre token
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Vérifier sa propre identité
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
