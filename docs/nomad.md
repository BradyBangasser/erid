# Nomad

`erid-nomad/` builds the same golden image as a Nomad and Consul node: the Packer
build installs `nomad` and `consul` and enables them, so an Erid machine can join
an orchestration cluster instead of running Compose directly.

## Where it is going

The Nomad variant is the path to higher availability for the services Erid hosts:

- **Canary deployments** - roll a new version to a small slice, verify health,
  then promote, so a bad deploy never takes down a service.
- **Automatic failover** - use Consul health checks and Nomad rescheduling to move
  workloads off an unhealthy node without manual intervention.

This is in progress. The golden image and node bootstrap are in place; the job
specifications and the canary and failover policies are what is being built out.
