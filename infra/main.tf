terraform {

  required_providers {

    google = {

      source  = "hashicorp/google"

      version = "~> 6.0"

    }

  }

}

provider "google" {

  project = "firstproject-503615"

  region  = "europe-west1"

  zone    = "europe-west1-b"

}
