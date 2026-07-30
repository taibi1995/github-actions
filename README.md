# Pipeline CI/CD & Infrastructure as Code — Todo App sur GCP

Application todo-list (Node.js + MySQL) déployée en production sur Google Cloud Platform, avec un pipeline CI/CD complet et une infrastructure entièrement provisionnée en code.

## Architecture

```
┌─────────────┐    push     ┌──────────────────┐
│  Développeur │ ──────────▶ │  GitHub (main)    │
└─────────────┘             └────────┬──────────┘
                                     │ déclenche
                                     ▼
                        ┌────────────────────────┐
                        │   GitHub Actions CI     │
                        │  1. Test d'intégration  │
                        │     (Docker Compose)    │
                        │  2. Build & push image  │
                        └────────────┬────────────┘
                                     │ publie
                                     ▼
                        ┌────────────────────────┐
                        │  GitHub Container       │
                        │  Registry (ghcr.io)     │
                        └────────────┬────────────┘
                                     │ pull
                                     ▼
                        ┌────────────────────────┐
                        │   VM GCP (Compute       │
                        │   Engine)               │
                        │  ┌──────┐   ┌─────────┐ │
                        │  │ App  │──▶│  MySQL  │ │
                        │  └──────┘   └─────────┘ │
                        └────────────────────────┘
                        Infra provisionnée par Terraform
```

## Stack technique

| Brique | Outil |
|---|---|
| Application | Node.js, Express, MySQL |
| Conteneurisation | Docker, Docker Compose |
| CI/CD | GitHub Actions |
| Registre d'images | GitHub Container Registry (ghcr.io) |
| Infrastructure as Code | Terraform |
| Cloud | Google Cloud Platform (Compute Engine) |

## Pipeline CI/CD

Déclenché à chaque `push` ou `pull_request` vers `main` (`.github/workflows/ci.yml`) :

1. **`integration-test`** — démarre l'application avec Docker Compose, attend qu'elle réponde (retry sur `curl`), affiche les logs en cas d'échec.
2. **`build-and-push`** — (uniquement sur `push` vers `main`) construit l'image Docker et la publie sur `ghcr.io`.

## Infrastructure (Terraform)

Dossier `infra/` :
- `google_compute_instance` — VM Debian 12 hébergeant l'application.
- `google_compute_firewall` — ouverture du port applicatif.
- `outputs.tf` — expose l'IP externe de la VM après provisionnement.

```bash
cd infra
terraform init
terraform plan
terraform apply
```

## Déploiement sur la VM

Sur la VM, un `compose.yaml` de production utilise directement l'image publiée sur `ghcr.io` (pas de build local) et inclut un healthcheck MySQL pour garantir que l'application ne démarre qu'une fois la base de données réellement prête :

```bash
docker compose pull
docker compose up -d
```

## Points techniques notables

- **SSH via port 443** — contournement d'un blocage réseau du port 22 en configurant SSH pour transiter par `ssh.github.com:443`.
- **Healthcheck MySQL** — résolution d'une race condition où l'application tentait de se connecter à MySQL avant que celui-ci soit prêt à accepter des connexions.
- **Gestion des secrets** — authentification au registre via `GITHUB_TOKEN` généré automatiquement, sans identifiants en dur dans le pipeline.
