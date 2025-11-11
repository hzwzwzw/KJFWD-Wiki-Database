# KJFWD Wiki Database - A git-based Wiki page 

For best reading experience, please visit our website <http://wiki.kjfwd.com>. 


## What is KJFWD Wiki?

In order to let those people find useful PC using tips and troubleshooting easily, KJFWD Wiki (formerly named *PC1stAid*) was established on Wiki.js in September, 2022. 

As a freedom site, primarily focusing on PC bug fix, KJFWD Wiki also introduces knowledge, techniques and tips of computer.

## Issues

Post confirmed bugs [here](https://github.com/THU-KJFWD/KJFWD-Wiki-Database/issues). 

## Contributing

The KJFWD Wiki welcomes contributions from anyone.

Regarding new changes, please submit a Suggestion Issue to the Tracker before you write a single line of code. Keeping everyone on the same page saves time and effort and reduces negative experiences all around when a change turns out to be controversial.

## Deployment

### Quick Start with Docker Compose

The easiest way to deploy KJFWD Wiki is using Docker Compose:

```bash
# Clone the repository
git clone https://github.com/errorfg/KJFWD-Wiki-Database.git
cd KJFWD-Wiki-Database

# Run the setup script
./scripts/setup.sh

# Or manually start services
docker compose up -d
```

Visit `http://localhost:3000` to complete the initial setup.

### Detailed Deployment Guide

For detailed deployment instructions, including:
- Environment configuration
- Cloudflare Tunnel setup for domain access
- Backup and restore procedures
- Troubleshooting guide

Please refer to [DEPLOYMENT.md](./DEPLOYMENT.md).

### Management Scripts

- `scripts/setup.sh` - Initial deployment and setup
- `scripts/backup.sh` - Create backups of database and data volumes
- `scripts/restore.sh` - Restore from backups

## License

KJFWD Wiki is made available under the terms of Creative Commons BY-SA 4.0.

See the [LICENSE file](./LICENSE) that accompanies this distribution for the full text of the license.
