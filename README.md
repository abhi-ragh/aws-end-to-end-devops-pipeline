# End-to-End DevOps Pipeline – Node React E-Commerce (MySQL Edition)

This project implements a production-grade, end-to-end DevOps pipeline for a modified version of the Node-React E-Commerce application originally sourced from:

> https://github.com/basir/node-react-ecommerce

The application has been customized to use **MySQL (Amazon RDS)** instead of MongoDB, in alignment with project requirements.

---

## Project Overview

### Capstone Project:

- Build a production-ready, scalable, observable deployment with CI/CD:
- **App**: Containerized microservice (frontend + backend)
- **Infra**: Terraform — VPC, EKS/ECS, RDS, ALB, ASG
- **CI/CD**:
    - GitHub Actions → Build + Test + Push to ECR
    - ArgoCD → Deploy to EKS via GitOps (staging & prod)
- **Monitoring**: Prometheus, Grafana, Loki dashboards & alerts
- **Serverless**: Lambda triggered by S3 (e.g., send email, log event)
- **Rollback**: Via ArgoCD or GitHub Actions + versioning

### **Deliverables:**

- Working cloud-native infrastructure on AWS
- GitHub repo with:
    - Dockerfiles
    - Terraform/IaC code
    - CI/CD workflows
    - K8s manifests (for GitOps)
- Final **demo/presentation** on architecture and DevOps pipeline