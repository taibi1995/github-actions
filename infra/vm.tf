resource "google_compute_instance" "app_vm" {
  name         = "app-vm"
  machine_type = "e2-small"
  zone         = "europe-west1-b"
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Bloc vide = attribue une IP externe éphémère automatiquement
    }
  }
}
