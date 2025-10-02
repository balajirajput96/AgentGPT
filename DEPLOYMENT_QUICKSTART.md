# 🚀 Quick Start Deployment Guide

## For First-Time Deployers

### 1. Prerequisites
- ✅ Docker installed
- ✅ docker-compose installed
- ✅ OpenAI API key
- ✅ Domain name (optional)

### 2. Quick Deploy

```bash
# Clone the repository (if not already done)
git clone https://github.com/balajirajput96/AgentGPT.git
cd AgentGPT

# Run the deployment script
./deploy.sh
```

That's it! The script will guide you through the rest.

### 3. Access Your Application

After deployment:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/api/docs

---

## Manual Deployment

If you prefer manual control:

```bash
# 1. Create production environment file
cp .env.prod.example .env.prod

# 2. Edit with your values
nano .env.prod  # or use your preferred editor

# 3. Deploy
docker-compose -f docker-compose.prod.yml up -d

# 4. Check status
docker-compose -f docker-compose.prod.yml ps

# 5. View logs
docker-compose -f docker-compose.prod.yml logs -f
```

---

## Important Environment Variables

Edit `.env.prod` and set:

```bash
# Required
NEXTAUTH_SECRET=<generate with: openssl rand -base64 32>
NEXTAUTH_URL=http://your-domain.com:3000
REWORKD_PLATFORM_OPENAI_API_KEY=sk-your-api-key

# Database (change default passwords!)
DATABASE_PASSWORD=<strong-password>
REWORKD_PLATFORM_DATABASE_PASSWORD=<strong-password>

# Optional OAuth providers
GOOGLE_CLIENT_ID=<your-client-id>
GOOGLE_CLIENT_SECRET=<your-client-secret>
```

---

## Common Commands

### Start Services
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Stop Services
```bash
docker-compose -f docker-compose.prod.yml down
```

### Restart Services
```bash
docker-compose -f docker-compose.prod.yml restart
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f frontend
docker-compose -f docker-compose.prod.yml logs -f platform
```

### Update to Latest Version
```bash
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

---

## Troubleshooting

### Services won't start?
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs

# Check if ports are already in use
sudo netstat -tulpn | grep -E '3000|8000|3308'
```

### Database connection errors?
1. Check database is running: `docker-compose -f docker-compose.prod.yml ps`
2. Verify credentials in `.env.prod`
3. Check database logs: `docker-compose -f docker-compose.prod.yml logs agentgpt_db`

### Can't access from outside?
1. Check firewall rules
2. Ensure ports are exposed: 3000, 8000
3. Update `NEXTAUTH_URL` with your actual domain

---

## Security Checklist

- [ ] Changed default database passwords
- [ ] Generated unique `NEXTAUTH_SECRET`
- [ ] Set up HTTPS (see `docs/DEPLOYMENT.md` for Nginx config)
- [ ] Configured firewall rules
- [ ] Regular backups scheduled
- [ ] Monitoring in place

---

## Need More Help?

📚 **Full Guide**: See [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) for comprehensive instructions

🐛 **Issues**: https://github.com/balajirajput96/AgentGPT/issues

💬 **Discord**: https://discord.gg/gcmNyAAFfV

---

## Production Deployment via GitHub Actions

When you merge to `main`, GitHub Actions automatically:
1. Builds Docker images
2. Pushes to GitHub Container Registry
3. Images available at:
   - `ghcr.io/balajirajput96/agentgpt-frontend:latest`
   - `ghcr.io/balajirajput96/agentgpt-platform:latest`

To use these images, just run:
```bash
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```
