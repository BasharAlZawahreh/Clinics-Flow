# odoo-dev Skill

Complete Odoo development skill for OpenClaw.

## What's Included

### SKILL.md
Main skill file with:
- Quick start guide
- Module structure
- Core development patterns (models, views, controllers, OWL)
- Common patterns (inheritance, automated actions, reports)
- Integration patterns (REST API, WhatsApp)
- Security and access rights
- Testing

### Scripts
- `scaffold-module.sh` - Create new module structure
- `update-module.sh` - Update module in running instance

### References
- `orm-methods.md` - Complete ORM methods reference
- `docker-deployment.md` - Production Docker deployment

## Usage

The skill triggers when you mention:
- "Build an Odoo module"
- "Create custom Odoo functionality"
- "Odoo development"
- "Extend Odoo"
- "Odoo ERP customization"

## Installation

```bash
# Package the skill
./package.sh

# Install in OpenClaw
openclaw skills install odoo-dev.skill
```

## Example Prompts

```
"Create an Odoo module for clinic management with patients, appointments, and billing"

"Build a custom Odoo module for inventory management with barcode support"

"Extend the sales module in Odoo to add custom fields and automated workflows"

"Create a REST API in Odoo for mobile app integration"

"Build an OWL component for a custom dashboard in Odoo"
```
