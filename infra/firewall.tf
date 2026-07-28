resource "google_compute_firewall" "allow_app_port" {
  name    = "allow-app-3000"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
