# Multi-Container Todo API

**Live at:** http://13.236.205.122

A production-ready Node.js Todo API containerized with Docker and deployed to AWS EC2 via Terraform, Ansible, and GitHub Actions CI/CD.

## Try It Out

```bash
# Health check
curl http://13.236.205.122/health

# List all todos
curl http://13.236.205.122/todos

# Create a todo
curl -X POST http://13.236.205.122/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Build something cool", "completed": false}'

# Update a todo
curl -X PUT http://13.236.205.122/todos/<id> \
  -H "Content-Type: application/json" \
  -d '{"title": "Build something cooler", "completed": true}'

# Delete a todo
curl -X DELETE http://13.236.205.122/todos/<id>
```

## Architecture

```
Browser
   │
   ▼
Nginx Alpine (reverse proxy, port 80) ─── Docker container
   │
   ▼
Node.js API (Express + Mongoose, port 3000) ─── Docker container
   │
   ▼
MongoDB 7 (port 27017) ─── Docker container
```

## Tech Stack

| Layer         | Technology                                      |
|---------------|------------------------------------------------|
| API           | Node.js, Express, Mongoose                    |
| Database      | MongoDB 7                                      |
| Containers    | Docker, Docker Compose                          |
| Reverse Proxy | Nginx Alpine (Docker)                          |
| IaC           | Terraform (AWS EC2, Elastic IP, Security Groups)|
| Config Mgmt   | Ansible (server provisioning + deployment)        |
| CI/CD         | GitHub Actions                                  |
| Cloud         | AWS (EC2, Elastic IP)                          |

## Local Development

```bash
docker compose up --build
```

API available at `http://localhost:3000` (via nginx at `http://localhost:80` in production).

## API Endpoints

| Method | Endpoint     | Description          |
|--------|--------------|----------------------|
| GET    | /health      | Health check         |
| GET    | /todos       | List all todos       |
| POST   | /todos       | Create a todo       |
| GET    | /todos/:id   | Get a single todo    |
| PUT    | /todos/:id   | Update a todo       |
| DELETE | /todos/:id   | Delete a todo        |

## Project Structure

```
.
├── app/                       # Node.js application
│   ├── src/
│   │   ├── index.js          # Express server entry point
│   │   ├── config.js         # Environment config
│   │   ├── models/Todo.js     # Mongoose schema
│   │   └── routes/todos.js   # Todo API routes
│   ├── tests/                # Jest integration tests
│   ├── Dockerfile            # Multi-stage production build
│   └── package.json
├── docker-compose.yml         # Local dev (api + mongo)
├── docker-compose.prod.yml     # Production (api + mongo + nginx)
├── nginx/nginx.conf           # Nginx reverse proxy config
├── terraform/                # AWS infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── ansible/                  # Server provisioning & deployment
│   ├── playbook.yml
│   ├── inventory.ini
│   └── ansible.cfg
└── .github/workflows/
    ├── ci.yml                # Test + build + push Docker image
    └── deploy.yml            # Terraform init → apply → Ansible deploy
```

## CI/CD Pipeline

```
Push to master
    │
    ├────────────────────────────────────────────┐
    ▼                                          ▼
┌──────────────────────┐          ┌──────────────────────────┐
│  ci.yml (parallel)   │          │  deploy.yml (parallel)   │
│  ├─ Jest + MongoDB   │          │  ├─ Terraform init/plan  │
│  └─ Push Docker image│          │  ├─ Terraform apply       │
└──────────────────────┘          │  ├─ Import existing infra │
                                   │  ├─ Ansible playbook       │
                                   │  │   ├─ Ensure Docker up  │
                                   │  │   ├─ Copy compose file │
                                   │  │   └─ docker compose up │
                                   │  └─ Health check          │
                                   └──────────────────────────┘
```

Both CI and deploy workflows trigger on every push to `master`. They run in parallel.

## Deployment

### GitHub Actions Secrets Required

Set these under **GitHub → Settings → Secrets and Variables → Actions**:

| Secret / Variable      | Description                                              |
|------------------------|----------------------------------------------------------|
| `AWS_ACCESS_KEY_ID`    | AWS access key ID                                        |
| `AWS_SECRET_ACCESS_KEY`| AWS secret access key                                    |
| `AWS_REGION` *(var)*  | AWS region, e.g. `ap-southeast-2`                      |
| `DOCKER_USERNAME`      | Docker Hub username                                      |
| `DOCKER_PASSWORD`      | Docker Hub access token                                  |
| `AMI_ID`               | Ubuntu 22.04 LTS AMI ID for your region                 |
| `KEY_PAIR_NAME`        | Name of an existing EC2 key pair                         |
| `SUBNET_ID`            | Public subnet ID in your VPC (find in AWS EC2 → Subnets)|
| `SSH_PRIVATE_KEY`      | Base64-encoded private key matching `KEY_PAIR_NAME`     |

To encode your SSH key for `SSH_PRIVATE_KEY`:
```bash
# Linux/Mac
cat ~/.ssh/id_rsa | base64 -w0

# Windows PowerShell
[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$env:USERPROFILE\.ssh\id_rsa"))
```

### Terraform Variables (tfvars)

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Fill in: ami_id, key_pair_name, subnet_id
```

### What Gets Provisioned

- EC2 instance (t3.micro) with Docker pre-installed via user_data
- Elastic IP (static public IP)
- Security group (SSH port 22, HTTP port 80, HTTPS port 443)
- All infra managed by Terraform — safe to re-run, handles existing resources

## Environment Variables

| Variable     | Default                           | Description              |
|--------------|-----------------------------------|--------------------------|
| `PORT`      | `3000`                            | API server port           |
| `MONGO_URL` | `mongodb://localhost:27017/todos` | MongoDB connection string |

In Docker Compose, `MONGO_URL` is set to `mongodb://mongo:27017/todos` where `mongo` is the Docker service name.
