# Optional Bonus: Amazon ElastiCache

## Architecture
- Engine: Valkey 7.2, Redis-compatible.
- Replication group: aws-kubernetes-project-cache.
- Cluster mode: disabled; one cache node, no automatic failover.
- Endpoint: master.aws-kubernetes-project-cache.z4tnko.use1.cache.amazonaws.com
- Port: 6379.
- Network: private cache subnets in the project VPC.
- Access: cache security group allows TCP 6379 from the Kubernetes worker security group.
- Transport encryption: TLS enabled.
- Authentication: enabled using an authentication token stored outside Git and supplied to Kubernetes through Secret `elasticache-redis-config`.
- Application: Flask reads REDIS_URL from the Kubernetes Secret.

## Verification evidence
- `evidence/original-redis-pvc.txt`: original Redis PVC and PV.
- `evidence/elasticache-verification.txt`: Flask readiness, counter and pod status.
- `evidence/elasticache-persistence.txt`: counter before and after Flask restart.

The observed counter increased from 3 before the restart to 4 afterwards.
`/ready` returned HTTP 200 with PostgreSQL and Redis marked ready.

## Backup, eviction and recovery limitations
- ElastiCache does not use a Kubernetes PVC.
- This configuration has one cache node and no automatic failover. A node replacement or cache recreation can interrupt service and may lose cached data.
- No scheduled snapshot/backup policy is configured by this Terraform resource. Configure and test snapshots separately if recovery of cache contents is required.
- Cache data is not durable application storage. Memory pressure and the engine's eviction policy can remove keys; confirm the effective parameter-group policy before relying on counter retention.
- The counter persistence test proves survival across Flask pod restarts, not cache-node failure or data recovery.

## Cleanup
Keep the cache while a live evaluation is required. ElastiCache incurs AWS charges while running.

After evaluation, from the Terraform working directory and with the correct AWS credentials and state:
1. Review `terraform plan` and confirm the intended cache resources.
2. Destroy `aws_elasticache_replication_group.barq` first.
3. After it is deleted, destroy `aws_security_group.elasticache` and `aws_elasticache_subnet_group.barq`.
4. Review the plan before each operation; do not destroy the shared VPC, EC2 instances, RDS database, or other project resources.
5. Remove Kubernetes Secret `elasticache-redis-config` after the deployment no longer references it.
6. Verify the cache resources are gone and retain the Terraform configuration and evidence for submission.

Never commit authentication tokens, Terraform state, plan files or other secrets.
