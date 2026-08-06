# Network and trust

Erid assumes nothing on the network is trusted by default; identity is proven
with certificates.

## Private CA

`step-ca` (smallstep) runs in the control plane as a private certificate
authority, backed by a managed database. It issues the certificates that
services and clients present to each other.

## Mutual TLS everywhere

Both the control-plane Traefik (`mgr/`) and the edge proxy (`proxy/`) require
mutual TLS: `clientAuthType: RequireAndVerifyClientCert` against the CA roots, so
a caller must present a valid client certificate to reach a service. Public-facing
certificates are obtained from Let's Encrypt, while service-to-service trust runs
off the private CA.

## Mesh

A self-hosted Headscale control server (with Headplane) provides the mesh network
that links on-prem and cloud machines into one flat, private network, so services
can reach each other across environments without exposing them publicly.
