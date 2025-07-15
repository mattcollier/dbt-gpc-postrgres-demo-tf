# dbt-gpc-postrgres-demo-tf

This Terraform module spins up a tiny PostgreSQL 16 instance on Google Cloud immediately after you create a new project.
The database is pre-loaded with the Netflix sample dataset and safely
exposes port 5432 only to the officially documented dbt Cloud
egress IP ranges.
Use it as the data source for the companion dbt project
[mattcollier/dbt-demo1](https://github.com/mattcollier/dbt-demo1).

⸻

## Why run it from Cloud Shell?
- Zero local setup – Cloud Shell already has gcloud, Terraform >1.8, and application credentials.
- Default project context – whatever project you just created in the console will automatically be selected.
- Free tier friendly – the VM uses the e2-micro machine type, which is covered by Google Cloud’s Always-Free allowance in most regions.

⸻

## Prerequisites

Requirement	Notes
A brand-new Google Cloud project with billing enabled	Terraform enables the necessary services for you.
IAM role roles/owner or equivalent on the project	Cloud Shell gives you this by default for freshly created projects.
Terraform ≥ 1.5 (already present in Cloud Shell)	


⸻

Quick-start (copy-paste)

# 1. Open Cloud Shell in your new project
```sh
git clone https://github.com/mattcollier/dbt-gpc-postrgres-demo-tf.git
cd dbt-gpc-postrgres-demo-tf
```

# 2. Create a very small vars file – only two values are required
```sh
cat > terraform.auto.tfvars <<'EOF'
project_id  = "$(gcloud config get-value project)"
db_password = "S3cr3tPassw0rd"
EOF
```

# 3. Deploy (~90 s)
```sh
terraform init
terraform apply -auto-approve
```

After apply finishes, note the pg_public_ip output – you’ll need it in dbt Cloud.

⸻

## What gets deployed

| Resource | Purpose |
|----------|---------|
| **Compute Engine APIs** enabled | Terraform can create VMs. |
| **`e2-micro` VM** named `pg-demo` | Runs PostgreSQL 16 inside Docker. |
| **Startup script** | Installs Docker, starts Postgres, and loads the `netflix.sql` sample. |
| **Firewall rule** `allow-postgres-dbt` | Opens TCP 5432 **only** for dbt Cloud CIDRs. |
| `pg_public_ip` output | Ephemeral external IPv4 address you’ll plug into dbt Cloud. |

<details>
<summary>Default variables</summary>

```hcl
region         = "us-central1"
db_user        = "dbt"
db_name        = "mydb"
dbt_cloud_cidrs = [
  "52.45.144.63/32", "54.81.134.249/32",  # …
]
```

You can override any of these in terraform.auto.tfvars.

</details>

⸻

# Connecting dbt Cloud
In dbt Cloud ➜ Account Settings ➜ Data Platforms ➜ + New Connection

Choose Postgres. [Official Documentation](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-redshift-postgresql-alloydb)

## Fill the form:
- Host – <pg_public_ip>
- Port – 5432
- Database – mydb

Save & test. The models in dbt-demo1 will now run.

# Postges Credenitals
You will be asked for user credentials after setting up the connection:
- Username – dbt
- Password – what you set above

⸻

Customization
	•	Different region / zone – set region = "europe-west1" etc.
	•	Static IP – convert the ephemeral address to a reserved static IP in the console or extend the module.
	•	Larger VM – change machine_type in main.tf (will incur cost).

⸻

Teardown

terraform destroy

Your project will remain intact; only the resources created by this module are removed.

⸻

Cost

Running continuously on an e2-micro VM stays within the Always-Free limits
(≈ $0 / month).
You will be billed for:
	•	Outbound egress traffic from Postgres (tiny for demo work)
	•	Persistent disk if you increase it beyond 30 GB

⸻

Repository layout
```txt
├── main.tf          # Core resources
├── variables.tf     # Minimal inputs
├── outputs.tf       # pg_public_ip
└── README.md
```

Happy querying! 🚀