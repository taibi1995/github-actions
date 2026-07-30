<div align="center">

# ⚙️ Pipeline CI/CD & Infrastructure as Code sur GCP

### Déploiement automatisé d'une application conteneurisée en production

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![GCP](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)

</div>

---

## 📖 Vue d'ensemble

Application todo-list (Node.js + MySQL) déployée en production sur **Google Cloud Platform**, avec un pipeline CI/CD complet piloté par **GitHub Actions** et une infrastructure entièrement provisionnée en code avec **Terraform**.

## 🏗️ Architecture

```mermaid
flowchart TD
    A[👨‍💻 Développeur] -->|git push main| B[📦 GitHub Repo]
    B -->|déclenche| C{GitHub Actions}
    C --> D[🧪 Test d'intégration<br/>Docker Compose]
    D -->|succès| E[🔨 Build & Push image]
    E -->|publie sur| F[📦 GitHub Container Registry]
    F -->|docker pull| G[☁️ VM GCP]
    G --> H[🖥️ App container]
    G --> I[🗄️ MySQL container]
    H <-->|healthcheck| I

    style A fill:#00ff00,color:#000
    style C fill:#2088FF,color:#fff
    style F fill:#2496ED,color:#fff
    style G fill:#4285F4,color:#fff
```

## 🛠️ Stack technique

| Brique | Outil |
|---|---|
| 🖥️ Application | ![Node.js](https://img.shields.io/badge/-Node.js-339933?style=flat-square&logo=node.js&logoColor=white) ![Express](https://img.shields.io/badge/-Express-000000?style=flat-square&logo=express&logoColor=white) ![MySQL](https://img.shields.io/badge/-MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white) |
| 📦 Conteneurisation | ![Docker](https://img.shields.io/badge/-Docker-2496ED?style=flat-square&logo=docker&logoColor=white) ![Compose](https://img.shields.io/badge/-Docker%20Compose-2496ED?style=flat-square&logo=docker&logoColor=white) |
| 🔄 CI/CD | ![GitHub Actions](https://img.shields.io/badge/-GitHub%20Actions-2088FF?style=flat-square&logo=githubactions&logoColor=white) |
| 📥 Registre d'images | ![GHCR](https://img.shields.io/badge/-GHCR-181717?style=flat-square&logo=github&logoColor=white) |
| 🏗️ Infrastructure as Code | ![Terraform](https://img.shields.io/badge/-Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white) |
| ☁️ Cloud | ![GCP](https://img.shields.io/badge/-Google%20Cloud-4285F4?style=flat-square&logo=google-cloud&logoColor=white) |

---

## 🔄 Pipeline CI/CD

Déclenché à chaque `push` ou `pull_request` vers `main` (`.github/workflows/ci.yml`) :

```mermaid
flowchart LR
    A[🧪 integration-test] -->|needs| B[🔨 build-and-push]

    style A fill:#22c55e,color:#fff
    style B fill:#3b82f6,color:#fff
```

- **`integration-test`** — démarre l'application avec Docker Compose, attend qu'elle réponde via une boucle de retry sur `curl`, affiche les logs en cas d'échec, nettoie toujours les conteneurs.
- **`build-and-push`** — (uniquement sur `push` vers `main`) construit l'image Docker et la publie sur `ghcr.io`.

---

## 🏗️ Infrastructure (Terraform)

Dossier `infra/` :

- 🖥️ `google_compute_instance` — VM Debian 12 hébergeant l'application
- 🔥 `google_compute_firewall` — ouverture du port applicatif
- 📤 `outputs.tf` — expose l'IP externe de la VM après provisionnement

```bash
cd infra
terraform init
terraform plan
terraform apply
```

---

## 🚀 Déploiement sur la VM

Sur la VM, un `compose.yaml` de production utilise directement l'image publiée sur `ghcr.io` (pas de build local) et inclut un **healthcheck MySQL** pour garantir que l'application ne démarre qu'une fois la base de données réellement prête :

```bash
docker compose pull
docker compose up -d
```

---

## 💡 Points techniques notables

> 🔐 **SSH via port 443** — contournement d'un blocage réseau du port 22 en configurant SSH pour transiter par `ssh.github.com:443`.

> 🩺 **Healthcheck MySQL** — résolution d'une race condition où l'application tentait de se connecter à MySQL avant que celui-ci soit prêt à accepter des connexions.

> 🔑 **Gestion des secrets** — authentification au registre via `GITHUB_TOKEN` généré automatiquement, sans identifiants en dur dans le pipeline.

---

<div align="center">

**Fait par [Younes Taibi](https://github.com/taibi1995)** · [Portfolio](https://taibi1995.github.io/portfolio)

</div>
