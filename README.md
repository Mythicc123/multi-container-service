# Multi-Container Todo API

A production-ready Node.js Todo API containerized with Docker and deployed to AWS EC2 via Terraform, Ansible, and GitHub Actions CI/CD.

## Architecture

```
Browser
   │
   ▼
Nginx (reverse proxy, port 80)
   │
   ▼
Node.js API (Express + Mongoose, port 3000)
   │
   ▼
MongoDB (port 27017)
```

## Tech Stack

| Layer        | Technology                          |
|--------------|-------------------------------------|
| API          | Node.js, Express, Mongoose          |
| Database     | MongoDB 7                           |
| Containers   | Docker, Docker Compose              |
| Reverse Proxy| Nginx Alpine                        |
| IaC          | Terraform (AWS EC2, Elastic IP, SG) |
| Config Mgmt  | Ansible                             |
| CI/CD        | GitHub Actions                      |
| Cloud        | AWS (EC2, Elastic IP)               |

## Quick Start (Local Development)

```bash
docker compose up --build
```

API available at `http://localhost:3000`. Health check at `http://localhost:3000/health`.

## API Endpoints

| Method | Endpoint      | Description          |
|--------|---------------|----------------------|
| GET    | /todos       | List all todos       |
| POST   | /todos       | Create a todo        |
| GET    | /todos/:id   | Get a single todo    |
| PUT    | /todos/:id   | Update a todo        |
| DELETE | /todos/:id   | Delete a todo        |
| GET    | /health      | Health check         |

## Project Structure

```
.
├── app/                    # Node.js application
│   ├── src/
│   │   ├── index.js       # Entry point, Express server
│   │   ├── config.js      # Environment config
│   │   ├── models/Todo.js # Mongoose schema
│   │   └── routes/todos.js # Todo API routes
│   ├── tests/             # Jest integration tests
│   ├── Dockerfile         # Multi-stage production build
│   └── package.json
├── docker-compose.yml      # Local dev (api + mongo)
├── docker-compose.prod.yml # Production (api + mongo + nginx)
├── nginx/nginx.conf        # Nginx reverse proxy config
├── terraform/              # AWS infrastructure (EC2 + EIP + SG)
├── ansible/                # Server provisioning & deployment
│   ├── playbook.yml
│   ├── inventory.ini
│   └── ansible.cfg
└── .github/workflows/
    ├── ci.yml             # Test + build + push Docker image
    └── deploy.yml         # Terraform + Ansible deployment
```

## Deployment

### Prerequisites

- AWS account with programmatic access
- Docker Hub account
- Terraform >= 1.5 installed locally (for manual deploys)
- Ansible installed locally (for manual deploys)

### Secrets & Variables Required

Set these in **GitHub Settings → Secrets and Variables → Actions**:

| Secret / Variable      | Description                                      |
|------------------------|--------------------------------------------------|
| `AWS_ACCESS_KEY_ID`    | AWS access key                                   |
| `AWS_SECRET_ACCESS_KEY`| AWS secret key                                   |
| `AWS_REGION`           | AWS region (e.g. `ap-southeast-2`)              |
| `DOCKER_USERNAME`      | Docker Hub username                              |
| `DOCKER_PASSWORD`      | Docker Hub access token                          |
| `AMI_ID`               | Ubuntu 22.04 LTS AMI ID for your region         |
| `KEY_PAIR_NAME`        | Name of an existing EC2 key pair in your account |

### Automated Deploy (GitHub Actions)

Push to `main` → CI runs tests + builds + pushes image → Deploy job provisions AWS infra + runs Ansible.

### Manual Deploy

```bash
# 1. Provision infrastructure
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Fill in ami_id and key_pair_name in terraform.tfvars
terraform init && terraform apply

# 2. Get the EC2 public IP from terraform output
# Update inventory.ini with the IP

# 3. Run Ansible
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml
```

## CI/CD Pipeline

```
Push to main
    │
    ▼
┌─────────────────────────┐
│  ci.yml                 │
│  ├─ Test (Jest + Mongo) │
│  └─ Build & Push Docker  │
└─────────────────────────┘
    │
    ▼ (only on main push)
┌─────────────────────────┐
│  deploy.yml             │
│  ├─ Terraform init/plan │
│  ├─ Terraform apply     │
│  ├─ Ansible provision   │
│  │   ├─ Docker + Nginx   │
│  │   ├─ Copy compose file│
│  │   └─ docker compose up│
│  └─ Health check         │
└─────────────────────────┘
```

## Environment Variables

| Variable     | Default                              | Description              |
|--------------|--------------------------------------|--------------------------|
| `PORT`       | `3000`                               | API server port          |
| `MONGO_URL`  | `mongodb://localhost:27017/todos`    | MongoDB connection string|

In Docker Compose, `MONGO_URL` is set to `mongodb://mongo:27017/todos` where `mongo` is the Docker service name.
