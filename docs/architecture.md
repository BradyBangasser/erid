# Architecture

Erid has three parts: a golden image, a control plane that runs it, and the
network that ties everything together.

- **Golden image (`erid-golden/`)** - one Packer configuration that builds the
  same AlmaLinux 10 base for on-prem (KVM/QEMU, qcow2) and AWS (x86 and ARM
  AMIs). Environment-specific setup is deferred to cloud-init at first boot
  rather than baked in, so a single image is portable across every target.
- **Control plane (`mgr/`)** - a small stack that issues trust and fronts
  services: a `step-ca` private certificate authority, Traefik as an mTLS ingress
  with Let's Encrypt for public certs, a hostname/provisioning API, and a
  Headscale mesh control server.
- **Edge proxy (`proxy/`)** - a Traefik proxy that terminates and enforces mutual
  TLS at the edge.
- **Nomad variant (`erid-nomad/`)** - the same golden image provisioned as a
  Nomad and Consul node for orchestration.
