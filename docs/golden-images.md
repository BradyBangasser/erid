# Golden images

`erid-golden/golden.pkr.hcl` builds one base image for three targets from a
single source:

- **On-prem** via QEMU/KVM, producing a `qcow2`.
- **AWS x86** and **AWS ARM** via `amazon-ebs`, producing AMIs in `us-east-2`.

The base is AlmaLinux 10 minimal, installed unattended from a kickstart in
`http/ks.cfg`. Provisioning is intentionally thin: update packages, install
`curl`, `git`, and `cloud-init`, then run `cloud-init clean` so cloud-init
re-runs fresh on first boot. Environment-specific configuration lives in
`cloud-init/99-erid.cfg` and is applied at boot, not baked into the image.

The result is a reproducible, versioned image (`image_version`) that is identical
across on-prem and both AWS architectures, with per-environment differences
handled at boot. This is what makes the hybrid cloud reproducible rather than
hand-built.
