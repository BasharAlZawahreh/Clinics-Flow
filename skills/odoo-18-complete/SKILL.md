---
name: odoo-18-complete
description: Comprehensive Odoo 18 development and functional implementation. Use for building custom modules, configuring standard apps, implementing business workflows, integrating third-party systems, and deploying Odoo 18. Covers both technical development (Python, XML, OWL) and functional configuration (Sales, CRM, Inventory, Accounting, Manufacturing, HR, Website, eCommerce).
---

# Odoo 18 Complete Guide

## Quick Reference

### Odoo 18 Key Changes from Odoo 17
- **OWL 2.0**: Improved reactivity and performance
- **Knowledge App**: Native wiki/documentation
- **Dark Mode**: System-wide dark theme
- **Spreadsheet**: Enhanced spreadsheet capabilities
- **WhatsApp Integration**: Built-in WhatsApp Business
- **AI Features**: Integrated AI assistant
- **Improved UX**: Redesigned form views and navigation

---

## PART 1: FUNCTIONAL IMPLEMENTATION

### 1.1 Sales & CRM Configuration

#### Sales App Setup
```yaml
# Configuration checklist
[ ] Pricelists (Settings → Sales → Pricing)
[ ] Discounts (Settings → Sales → Allow discounts)
[ ] Delivery Methods (Settings → Sales → Delivery)
[ ] Online Payment (Settings → Sales → Payment)
[ ] Product Configurator (Settings → Sales)
[ ] Subscriptions (if needed)
```

#### CRM Pipeline Configuration
```
1. Settings → CRM → Enable 'Lead Scoring'
2. Settings → CRM → Enable 'Predictive Lead Scoring'
3. Configure Pipeline Stages:
   - New → Qualified → Proposition → Won/Lost
4. Set up Activity Types:
   - Call, Email, Meeting, Quote
5. Configure Automated Actions:
   - Auto-assign leads
   - Send welcome email
```

#### Sales Team Configuration
```yaml
Sales → Sales Teams → Create:
  Name: "Direct Sales"
  Team Leader: [User]
  Email Alias: sales@company.com
  Accept Emails: Yes
  Auto-assignment: Round Robin or Load Balanced
```

### 1.2 Inventory & Warehouse

#### Warehouse Configuration
```yaml
Settings → Inventory:
  [ ] Storage Locations (multi-warehouse)
  [ ] Multi-step Routes (pick/pack/ship)
  [ ] Packages
  [ ] Storage Categories
  [ ] Forecasted Inventory
  [ ] Reordering Rules
  [ ] Barcode Scanner
```

#### Operation Types Setup
```
Inventory → Configuration → Operation Types:
  - Receipts: Receipt → Stock
  - Delivery Orders: Stock → Customers
  - Internal Transfers: Stock → Stock/Production
  - Manufacturing: Stock → Production → Stock
```

#### Routes Configuration
```python
# Example: Dropship route
Name: Dropship
Applicable On: Products
Rules:
  - Supplier → Customer (buy)
```

### 1.3 Accounting & Finance

#### Chart of Accounts Setup
```yaml
Accounting → Configuration → Chart of Accounts:
  # For Jordan/Arabic countries:
  Install: Jordan - Accounting (l10n_jo)
  
  Or manual setup:
  - Assets (1xxx)
  - Liabilities (2xxx)
  - Equity (3xxx)
  - Revenue (4xxx)
  - Expenses (5xxx)
```

#### Tax Configuration
```yaml
Accounting → Configuration → Taxes:
  Tax Name: VAT 16%
  Tax Type: Sales
  Tax Scope: Goods, Services
  Amount: 16%
  Tax Computation: Percentage of Price
  
  # Repartition:
  Invoices: Base (100%), Tax (16%)
  Refunds: Base (-100%), Tax (-16%)
```

#### Fiscal Year & Periods
```
Accounting → Configuration → Settings:
  Fiscal Year Last Day: 31/12
  # For 2024: 01/01/2024 → 31/12/2024
```

#### Bank Accounts & Journals
```yaml
Accounting → Configuration → Journals:
  Type: Bank
  Name: Main Bank Account
  Account Number: [IBAN]
  Currency: JOD/USD
  
  # For each payment method:
  - Cash Journal
  - Bank Journal
  - POS Journal (if applicable)
```

### 1.4 Purchase Management

#### Vendor Configuration
```yaml
Purchase → Orders → Vendors:
  General:
    - Name, Address, Contact
    - Tax ID
  Purchase Tab:
    - Payment Terms: Net 30
    - Delivery Method: Dropship/Standard
    - Currency: USD/JOD
  Accounting Tab:
    - Accounts Payable: 2100
    - Vendor Taxes: VAT 16%
```

#### Purchase Agreements
```
Purchase → Orders → Purchase Agreements:
  Types:
    - Blanket Order: Fixed price, multiple deliveries
    - Call for Tender: Multiple RFQs, choose best
```

### 1.5 Manufacturing (MRP)

#### Manufacturing Setup
```yaml
Settings → Manufacturing:
  [ ] Work Centers
  [ ] Work Orders
  [ ] Quality Control
  [ ] Maintenance
  [ ] PLM (Product Lifecycle)
  [ ] Subcontracting
```

#### Bill of Materials (BoM)
```yaml
Manufacturing → Products → Bills of Materials:
  Product: [Finished Good]
  BoM Type: Manufacture
  Components:
    - Component A: Qty 2
    - Component B: Qty 1
    - Component C: Qty 3
  Operations:
    - Operation: Assembly
      Work Center: Assembly Line 1
      Time: 60 minutes
```

#### Work Centers
```
Manufacturing → Configuration → Work Centers:
  Name: Assembly Line 1
  Code: AL01
  Working Hours: Standard 40h/week
  Capacity: 1 (parallel operations)
  Time Efficiency: 100%
  OEE Target: 85%
  
  Costs:
    - Cost per hour: $50
    - Cost per product cycle: $0
```

### 1.6 Human Resources

#### Employee Setup
```yaml
Employees → Employees → Create:
  Private Information:
    - Name, Address, DOB
    - ID Number, Passport
  HR Settings:
    - Job Position: [Select/Create]
    - Department: [Select/Create]
    - Manager: [Select]
    - Coach: [Select]
    - Working Hours: Standard 40h/week
  Payroll (if installed):
    - Contract Type: Full-time
    - Salary: [Amount]
    - Wage Type: Monthly
```

#### Leave Management
```yaml
Time Off → Configuration → Time Off Types:
  - Annual Leave: 21 days/year
  - Sick Leave: 14 days/year
  - Unpaid Leave: Unlimited
  
Approvers:
  - Time Off Officer
  - Employee's Manager
```

#### Attendance & Time Tracking
```
Settings → Employees:
  [ ] Attendances (Kiosk mode)
  [ ] Time Off
  [ ] Payroll (optional)
  [ ] Expenses
  [ ] Recruitment
  [ ] Appraisals
```

### 1.7 Website & eCommerce

#### Website Builder
```yaml
Website → Configuration → Settings:
  Website Name: My Company
  Domain: www.mycompany.com
  
Features:
  [ ] eCommerce
  [ ] Blog
  [ ] Forum
  [ ] Live Chat
  [ ] Appointment
  [ ] eLearning
```

#### eCommerce Configuration
```yaml
Website → eCommerce → Products:
  # Product setup for online sales:
  - Published: Yes
  - Alternative Products: [Related products]
  - Accessory Products: [Add-ons]
  - eCommerce Categories: [Category tree]
  
Payment Providers:
  - Stripe
  - PayPal
  - Custom (local payment gateway)
  
Shipping Methods:
  - Fixed Price
  - Based on Rules
  - Real-time rates (FedEx, UPS, etc.)
```

### 1.8 Project Management

#### Project Setup
```yaml
Project → Projects → Create:
  Name: Website Redesign
  Customer: [Client]
  Billing Type: Fixed Price / Time & Material
  
Stages:
  - New
  - In Progress
  - Review
  - Done
  - Cancelled
  
Team:
  - Project Manager
  - Team Members
```

#### Task Management
```
Project → Tasks:
  - Assignee
  - Deadline
  - Tags
  - Priority
  - Planned Hours
  - Sub-tasks
```

### 1.9 Automation & Workflows

#### Automated Actions
```python
# Example: Auto-assign leads based on country
Model: CRM Lead
Trigger: On Creation
Filter: Country = "Jordan"
Action: Update Record
Values:
  - Sales Team: Jordan Team
  - Salesperson: [Auto-assign]
```

#### Scheduled Actions (Cron)
```python
# Example: Daily backup reminder
Name: Daily Backup Check
Model: Ir.actions.server
Interval: 1 day
Next Call: 2024-01-01 00:00:00
Number of Calls: -1 (unlimited)
Code: env['res.backup'].create_backup_reminder()
```

#### Email Templates
```xml
<record id="email_template_welcome" model="mail.template">
    <field name="name">Welcome Email</field>
    <field name="model_id" ref="base.model_res_partner"/>
    <field name="subject">Welcome ${object.name}!</field>
    <field name="body_html">
        <![CDATA[
            <p>Dear ${object.name},</p>
            <p>Welcome to our platform...</p>
        ]]>
    </field>
</record>
```

---

## PART 2: TECHNICAL DEVELOPMENT

### 2.1 Module Development

See `references/module-development.md` for complete technical guide.

Quick scaffold:
```bash
# Use the scaffold script
./scripts/scaffold-odoo18-module.sh my_module /path/to/addons
```

### 2.2 Odoo 18 Specific Features

#### OWL 2.0 Components
```javascript
/** @odoo-module **/
import { Component, useState, onMounted } from "@odoo/owl";
import { registry } from "@web/core/registry";

export class MyComponent extends Component {
    static template = "module.MyComponent";
    static props = {
        record: Object,
    };
    
    setup() {
        this.state = useState({
            count: 0,
            loading: false,
        });
        
        onMounted(() => {
            this.loadData();
        });
    }
    
    async loadData() {
        this.state.loading = true;
        const result = await this.env.services.orm.searchRead(
            "model.name",
            [],
            ["field1", "field2"]
        );
        this.state.data = result;
        this.state.loading = false;
    }
}

registry.category("actions").add("my_action", MyComponent);
```

#### New in Odoo 18: Spreadsheet Integration
```python
# Add spreadsheet to your module
from odoo import models, fields

class MySpreadsheet(models.Model):
    _name = 'my.module.spreadsheet'
    _inherit = 'spreadsheet.mixin'
    
    name = fields.Char()
    spreadsheet_data = fields.Binary()
```

#### Knowledge Integration
```python
# Create knowledge article programmatically
article = self.env['knowledge.article'].create({
    'name': 'SOP: Sales Process',
    'body': '<h1>Sales Process</h1><p>Step 1...</p>',
    'category': 'workspace',
})
```

### 2.3 API Development

#### REST API Controllers
```python
from odoo import http
from odoo.http import request

class MyApi(http.Controller):
    
    @http.route('/api/v2/customers', type='json', auth='api_key')
    def get_customers(self, **kwargs):
        customers = request.env['res.partner'].search([
            ('customer_rank', '>', 0)
        ])
        return {
            'data': [{
                'id': c.id,
                'name': c.name,
                'email': c.email,
                'phone': c.phone,
            } for c in customers]
        }
    
    @http.route('/api/v2/orders', type='json', auth='api_key', methods=['POST'])
    def create_order(self, **kwargs):
        data = request.jsonrequest
        order = request.env['sale.order'].create({
            'partner_id': data['customer_id'],
            'order_line': [(0, 0, {
                'product_id': line['product_id'],
                'product_uom_qty': line['quantity'],
            }) for line in data['lines']]
        })
        return {'id': order.id, 'name': order.name}
```

### 2.4 Integration Patterns

#### WhatsApp Business API (Odoo 18 Native)
```python
# Odoo 18 has built-in WhatsApp integration
# Configuration:
Settings → WhatsApp → Connect Account

# Usage in code:
partner.message_post(
    body="Your appointment is confirmed!",
    whatsapp_number=partner.mobile
)
```

#### Payment Gateway Integration
```python
from odoo.addons.payment.models.payment_provider import PaymentProvider

class MyPaymentProvider(models.Model):
    _inherit = 'payment.provider'
    
    code = fields.Char(default='my_gateway')
    
    def _get_default_payment_method_ids(self):
        default_methods = super()._get_default_payment_method_ids()
        # Add custom payment methods
        return default_methods
```

---

## PART 3: DEPLOYMENT & DEVOPS

### 3.1 Docker Deployment

See `references/docker-deployment.md` for complete setup.

Quick start:
```bash
# Production deployment
docker-compose -f docker-compose.prod.yml up -d

# With Odoo 18 specific config
docker-compose exec odoo odoo -u all -d mydb --stop-after-init
```

### 3.2 Performance Optimization

#### PostgreSQL Tuning
```conf
# /etc/postgresql/15/main/postgresql.conf
shared_buffers = 512MB
effective_cache_size = 1536MB
work_mem = 32MB
maintenance_work_mem = 128MB
wal_buffers = 16MB
max_connections = 200
```

#### Odoo Configuration
```ini
[options]
workers = 4
max_cron_threads = 2
limit_memory_hard = 2684354560
limit_memory_soft = 2147483648
limit_request = 8192
limit_time_cpu = 120
limit_time_real = 240
db_maxconn = 64
```

### 3.3 Security Best Practices

```yaml
# Always implement:
[ ] HTTPS only (nginx/ssl)
[ ] Strong admin password
[ ] API key authentication for external systems
[ ] Rate limiting on controllers
[ ] Input validation
[ ] CSRF tokens on forms
[ ] Regular backups (automated)
[ ] Update security patches
```

---

## PART 4: COMMON RECIPES

### Recipe 1: Clinic Management (like Clinics-Flow)
```bash
# Create complete clinic module
./scripts/scaffold-clinic-module.sh /path/to/addons
```

Features:
- Patient management
- Appointment scheduling
- Doctor availability
- WhatsApp reminders
- Billing & Invoicing
- Reports

### Recipe 2: eCommerce with Custom Payment
```bash
# Extend website_sale with local payment
./scripts/add-payment-gateway.sh my_payment_module
```

### Recipe 3: Multi-Company Setup
```yaml
Settings → General Settings:
  [ ] Multi-company
  
Companies:
  - Parent Company
  - Branch 1
  - Branch 2
  
Inter-company transactions:
  - Auto-generate invoices
  - Consolidated reporting
```

### Recipe 4: Manufacturing with Quality
```yaml
Manufacturing → Quality → Quality Points:
  - Check raw materials on receipt
  - In-process quality checks
  - Final inspection before delivery
  
Automated Actions:
  - Block production if quality fails
  - Alert quality manager
  - Generate NCR (Non-Conformance Report)
```

---

## Scripts & Tools

### Available Scripts
- `scaffold-odoo18-module.sh` - Create new module
- `update-module.sh` - Update module in instance
- `backup-database.sh` - Backup with filestore
- `restore-database.sh` - Restore from backup

### Quick Commands
```bash
# Update all modules
./odoo-bin -u all -d mydb --stop-after-init

# Shell access
./odoo-bin shell -d mydb

# Test module
./odoo-bin -u my_module --test-enable --stop-after-init

# Database dump
pg_dump -U odoo mydb > backup.sql

# Database restore
psql -U odoo mydb < backup.sql
```

---

## Resources

### Documentation
- `references/odoo18-new-features.md`
- `references/orm-methods.md`
- `references/view-patterns.md`
- `references/docker-deployment.md`
- `references/api-integration.md`

### External References
- Odoo 18 Documentation: https://www.odoo.com/documentation/18.0/
- Odoo Community Association: https://github.com/OCA
- Odoo Apps Store: https://apps.odoo.com

---

## Usage Examples

```
"Build an Odoo 18 module for clinic management with appointments and WhatsApp"
"Configure Odoo 18 for manufacturing with quality control"
"Set up multi-company in Odoo 18 with inter-company transactions"
"Create custom payment gateway in Odoo 18"
"Migrate from Odoo 16 to Odoo 18"
"Build REST API for Odoo 18 mobile app"
"Configure Odoo 18 eCommerce with local payment methods"
```
