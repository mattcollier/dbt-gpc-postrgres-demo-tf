provider "google" {
  project = var.project_id
  region  = var.region
  zone    = "${var.region}-b"
}

# Enable both APIs in a single, DRY block
resource "google_project_service" "essential_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])

  project             = var.project_id
  service             = each.key
  disable_on_destroy  = false
}

resource "google_compute_firewall" "allow_postgres" {
  name    = "allow-postgres-dbt"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  source_ranges = var.dbt_cloud_cidrs   # limit exposure to dbt Cloud

  depends_on = [google_project_service.essential_apis]    
}

resource "google_compute_instance" "pg" {
  name         = "pg-demo"
  machine_type = "e2-micro"            # free-tier size  [oai_citation:4‡Google Cloud](https://cloud.google.com/free/docs/compute-getting-started?utm_source=chatgpt.com)
  zone         = "${var.region}-b"
  tags         = ["postgres"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 20                       # still within 30 GB free allotment
    }
  }

  network_interface {
    network       = "default"
    access_config {}                  # ephemeral external IP
  }

  metadata_startup_script = <<-EOF
    #!/usr/bin/env bash
    apt-get update -y && apt-get install -y docker.io curl postgresql-client
    systemctl enable --now docker

    # Launch Postgres in a container
    docker run -d --name pg \
      -e POSTGRES_USER=${var.db_user} \
      -e POSTGRES_PASSWORD=${var.db_password} \
      -e POSTGRES_DB=${var.db_name} \
      -p 5432:5432 \
      postgres:16

    # Wait until Postgres responds
    until docker exec pg pg_isready -U ${var.db_user}; do sleep 2; done

    # Load the Jaffle Shop sample data
    curl -sL https://raw.githubusercontent.com/dbt-labs/jaffle-shop-data/main/postgres/load_postgres.sql \
      -o /tmp/load.sql
    PGPASSWORD=${var.db_password} psql -h localhost -U ${var.db_user} -d ${var.db_name} -f /tmp/load.sql
  EOF

  depends_on = [google_project_service.essential_apis]  
}