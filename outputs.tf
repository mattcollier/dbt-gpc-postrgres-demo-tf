###############################################################################
# Output: Public (ephemeral) IPv4 address of the Postgres VM
###############################################################################

output "pg_public_ip" {
  description = "Ephemeral external IP address for the pg VM"
  value       = google_compute_instance.pg.network_interface[0].access_config[0].nat_ip
}