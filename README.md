---
title: "Erid: Unified Hybrid-Cloud Images"
summary: "One Packer pipeline producing identical golden images across on-prem and AWS, plus the mTLS control plane and mesh that run my hybrid cloud in production."
tags: [cloud, sre, infrastructure, reliability]
featured: true
---

# Erid

Erid is the golden-image pipeline and control plane behind my personal hybrid
cloud. One Packer build produces the same AlmaLinux 10 base image for on-prem
KVM/QEMU and for AWS (x86 and ARM), and a small control plane wires the resulting
machines together with a private CA, mutual TLS everywhere, and a mesh network.
It runs in production today, hosting multiple services.

A full write-up is at https://www.bangasser.dev/projects/erid. See `docs/` for
the architecture, the image pipeline, the network and trust model, and the
in-progress Nomad orchestration.
