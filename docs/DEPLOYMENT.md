# Deployment Guide

This guide explains how to deploy AgentGPT to production.

## Prerequisites

- Docker and Docker Compose installed
- GitHub account with access to the repository
- Domain name (optional but recommended)
- API keys for:
  - OpenAI
  - Google OAuth (optional)
  - GitHub OAuth (optional)
  - Discord OAuth (optional)
  - SERP API (optional)
  - Replicate API (optional)

## Deployment Options

### Option 1: GitHub Container Registry (Recommended)

The repository includes an automated deployment workflow that builds and pushes Docker images to GitHub Container Registry on every merge to `main`.

#### Steps:

1. **Fork or clone the repository**

2. **Set up environment variables**
   ```bash
   cp .env.prod.example .env.prod
   ```
   Edit `.env.prod` with your production values:
   - Generate a secure `NEXTAUTH_SECRET`: `openssl rand -base64 32`
   - Set your domain in `NEXTAUTH_URL` and `NEXT_PUBLIC_BACKEND_URL`
   - Add your API keys

3. **Push to main branch**
   - The GitHub Actions workflow will automatically build and push images
   - Images will be available at:
     - `ghcr.io/balajirajput96/agentgpt-frontend:latest`
     - `ghcr.io/balajirajput96/agentgpt-platform:latest`

4. **Deploy using Docker Compose**
   
   On your production server:
   ```bash
   # Login to GitHub Container Registry
   echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
   
   # Pull and run the images
   docker-compose -f docker-compose.prod.yml up -d
   ```

5. **Access your application**
   - Frontend: http://your-domain.com:3000
   - Backend API: http://your-domain.com:8000
   - API Documentation: http://your-domain.com:8000/api/docs

### Option 2: Build and Deploy Locally

If you prefer to build images locally:

1. **Set up environment**
   ```bash
   cp .env.prod.example .env.prod
   # Edit .env.prod with your values
   ```

2. **Build the images**
   ```bash
   docker-compose -f docker-compose.yml build
   ```

3. **Run in production mode**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

### Option 3: Deploy to Cloud Platforms

#### Docker-based Platforms (Railway, Render, etc.)

1. Connect your GitHub repository
2. Set environment variables in the platform's dashboard
3. Configure build settings:
   - Frontend: Build from `./next/Dockerfile`
   - Platform: Build from `./platform/Dockerfile`
4. Set up database service (MySQL 8.0)
5. Deploy!

#### Vercel (Frontend only)

The frontend can be deployed to Vercel:
```bash
cd next
vercel --prod
```

Note: You'll need to deploy the backend separately.

## Post-Deployment

### 1. Database Migrations

On first deployment, run database migrations:
```bash
docker-compose -f docker-compose.prod.yml exec frontend npx prisma migrate deploy
```

### 2. Health Checks

Verify services are running:
```bash
# Check container status
docker-compose -f docker-compose.prod.yml ps

# Check logs
docker-compose -f docker-compose.prod.yml logs -f
```

### 3. Security Considerations

- [ ] Change default database passwords
- [ ] Use strong `NEXTAUTH_SECRET`
- [ ] Enable HTTPS (use reverse proxy like Nginx)
- [ ] Set up firewall rules
- [ ] Keep Docker images updated
- [ ] Regular backups of database

### 4. SSL/TLS Setup (Optional but Recommended)

Use a reverse proxy like Nginx with Let's Encrypt:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Monitoring

### View Logs

```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f frontend
docker-compose -f docker-compose.prod.yml logs -f platform
docker-compose -f docker-compose.prod.yml logs -f agentgpt_db
```

### Resource Usage

```bash
docker stats
```

## Troubleshooting

### Database Connection Issues

1. Check if database is running:
   ```bash
   docker-compose -f docker-compose.prod.yml ps agentgpt_db
   ```

2. Verify database credentials in `.env.prod`

3. Check database logs:
   ```bash
   docker-compose -f docker-compose.prod.yml logs agentgpt_db
   ```

### Frontend/Backend Communication Issues

1. Verify `NEXT_PUBLIC_BACKEND_URL` matches your backend URL
2. Check CORS settings
3. Verify both services are running

### Out of Memory

Increase Docker memory limits or upgrade server resources.

## Backup and Restore

### Backup Database

```bash
docker-compose -f docker-compose.prod.yml exec agentgpt_db mysqldump -u reworkd_platform -p reworkd_platform > backup.sql
```

### Restore Database

```bash
docker-compose -f docker-compose.prod.yml exec -T agentgpt_db mysql -u reworkd_platform -p reworkd_platform < backup.sql
```

## Scaling

For high-traffic deployments:

1. Use managed database service (AWS RDS, DigitalOcean Managed MySQL)
2. Deploy multiple frontend/backend instances behind a load balancer
3. Use Redis for session storage
4. Implement CDN for static assets

## Support

For issues or questions:
- GitHub Issues: https://github.com/balajirajput96/AgentGPT/issues
- Discord: https://discord.gg/gcmNyAAFfV
