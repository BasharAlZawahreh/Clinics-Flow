---
name: odoo-dev
description: Build and customize Odoo ERP modules. Use when creating custom Odoo modules, extending existing functionality, integrating with external systems, or deploying Odoo instances. Covers Odoo 16/17/18 with Python backend, XML views, OWL frontend, and deployment.
---

# Odoo Development

Build custom Odoo ERP modules and customize existing functionality.

## Quick Start

### Module Structure
```
my_module/
├── __manifest__.py          # Module metadata
├── __init__.py              # Python package init
├── models/
│   ├── __init__.py
│   └── model_name.py        # Business logic
├── views/
│   └── view_name.xml        # UI definitions
├── controllers/
│   └── main.py              # Web controllers
├── static/
│   └── src/
│       └── components/      # OWL JS components
├── data/
│   └── demo.xml             # Demo data
├── security/
│   └── ir.model.access.csv  # Access rights
└── i18n/                    # Translations
```

### Creating a New Module

Use the scaffold script:
```bash
./odoo-bin scaffold my_module /path/to/custom_addons
```

Or manually create the structure using templates in `assets/module-template/`.

## Core Development Patterns

### 1. Model Definition
```python
from odoo import models, fields, api

class Patient(models.Model):
    _name = 'clinic.patient'
    _description = 'Patient'
    
    name = fields.Char(string='Name', required=True)
    phone = fields.Char(string='Phone')
    email = fields.Char(string='Email')
    date_of_birth = fields.Date(string='Date of Birth')
    appointment_ids = fields.One2many(
        'clinic.appointment', 'patient_id', string='Appointments'
    )
    state = fields.Selection([
        ('draft', 'Draft'),
        ('confirmed', 'Confirmed'),
        ('done', 'Done'),
        ('cancelled', 'Cancelled'),
    ], default='draft')
    
    @api.model_create_multi
    def create(self, vals_list):
        for vals in vals_list:
            if not vals.get('reference'):
                vals['reference'] = self.env['ir.sequence'].next_by_code('clinic.patient')
        return super(Patient, self).create(vals_list)
    
    def action_confirm(self):
        self.write({'state': 'confirmed'})
```

### 2. Views (XML)
```xml
<!-- Form View -->
<record id="view_patient_form" model="ir.ui.view">
    <field name="name">clinic.patient.form</field>
    <field name="model">clinic.patient</field>
    <field name="arch" type="xml">
        <form>
            <header>
                <button name="action_confirm" type="object" string="Confirm"/>
                <field name="state" widget="statusbar"/>
            </header>
            <sheet>
                <group>
                    <field name="name"/>
                    <field name="phone"/>
                    <field name="email"/>
                </group>
                <notebook>
                    <page string="Appointments">
                        <field name="appointment_ids"/>
                    </page>
                </notebook>
            </sheet>
        </form>
    </field>
</record>

<!-- Tree View -->
<record id="view_patient_tree" model="ir.ui.view">
    <field name="name">clinic.patient.tree</field>
    <field name="model">clinic.patient</field>
    <field name="arch" type="xml">
        <tree>
            <field name="name"/>
            <field name="phone"/>
            <field name="state" decoration-success="state=='done'"/>
        </tree>
    </field>
</record>

<!-- Action -->
<record id="action_patients" model="ir.actions.act_window">
    <field name="name">Patients</field>
    <field name="res_model">clinic.patient</field>
    <field name="view_mode">tree,form</field>
</record>

<!-- Menu -->
<menuitem id="menu_clinic_root" name="Clinic" sequence="10"/>
<menuitem id="menu_patients" name="Patients" parent="menu_clinic_root" action="action_patients"/>
```

### 3. Controllers (REST API)
```python
from odoo import http
from odoo.http import request

class ClinicApi(http.Controller):
    
    @http.route('/api/patients', type='json', auth='api_key', methods=['GET'])
    def get_patients(self, **kwargs):
        patients = request.env['clinic.patient'].search([])
        return {
            'data': [{
                'id': p.id,
                'name': p.name,
                'phone': p.phone,
            } for p in patients]
        }
    
    @http.route('/api/appointments', type='json', auth='api_key', methods=['POST'])
    def create_appointment(self, **kwargs):
        data = request.jsonrequest
        appointment = request.env['clinic.appointment'].create({
            'patient_id': data.get('patient_id'),
            'date': data.get('date'),
            'service': data.get('service'),
        })
        return {'id': appointment.id, 'status': 'created'}
```

### 4. OWL Component (Frontend)
```javascript
/** @odoo-module **/
import { Component, useState } from "@odoo/owl";
import { registry } from "@web/core/registry";

export class PatientDashboard extends Component {
    static template = "clinic.PatientDashboard";
    
    setup() {
        this.state = useState({
            patients: [],
            loading: false,
        });
    }
    
    async loadPatients() {
        this.state.loading = true;
        const result = await this.env.services.orm.searchRead(
            "clinic.patient",
            [],
            ["name", "phone", "state"]
        );
        this.state.patients = result;
        this.state.loading = false;
    }
}

registry.category("actions").add("clinic.patient_dashboard", PatientDashboard);
```

## Common Patterns

### Inherit and Extend
```python
# Inherit from existing model
class ResPartner(models.Model):
    _inherit = 'res.partner'
    
    is_patient = fields.Boolean(string='Is Patient')
    medical_history = fields.Text(string='Medical History')
```

### Automated Actions
```xml
<record id="ir_cron_appointment_reminder" model="ir.cron">
    <field name="name">Send Appointment Reminders</field>
    <field name="model_id" ref="model_clinic_appointment"/>
    <field name="state">code</field>
    <field name="code">model.send_reminders()</field>
    <field name="interval_number">1</field>
    <field name="interval_type">days</field>
</record>
```

### Report Generation
```python
from odoo import models, api

class AppointmentReport(models.AbstractModel):
    _name = 'report.clinic.appointment_report'
    _description = 'Appointment Report'
    
    @api.model
    def _get_report_values(self, docids, data=None):
        appointments = self.env['clinic.appointment'].browse(docids)
        return {
            'docs': appointments,
            'company': self.env.company,
        }
```

## Integration Patterns

### WhatsApp Integration (similar to Clinics-Flow)
```python
def send_whatsapp_message(self, phone, message):
    import requests
    
    url = "https://graph.facebook.com/v18.0/{}/messages".format(
        self.env['ir.config_parameter'].get_param('whatsapp.phone_id')
    )
    headers = {
        'Authorization': 'Bearer {}'.format(
            self.env['ir.config_parameter'].get_param('whatsapp.token')
        ),
        'Content-Type': 'application/json',
    }
    data = {
        'messaging_product': 'whatsapp',
        'to': phone,
        'type': 'text',
        'text': {'body': message},
    }
    
    response = requests.post(url, headers=headers, json=data)
    return response.json()
```

## Deployment

### Docker Setup
```yaml
# See references/docker-deployment.md for complete setup
version: '3.8'
services:
  odoo:
    image: odoo:17.0
    depends_on:
      - db
    ports:
      - "8069:8069"
    environment:
      - HOST=db
      - USER=odoo
      - PASSWORD=myodoo
    volumes:
      - ./custom_addons:/mnt/extra-addons
      - ./odoo-data:/var/lib/odoo
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=myodoo
      - POSTGRES_USER=odoo
```

## Security

### Access Rights
```csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_clinic_patient_user,Clinic Patient User,model_clinic_patient,clinic.group_clinic_user,1,1,1,0
access_clinic_patient_admin,Clinic Patient Admin,model_clinic_patient,clinic.group_clinic_admin,1,1,1,1
```

### Record Rules
```xml
<record id="patient_own_rule" model="ir.rule">
    <field name="name">Own Patients Only</field>
    <field name="model_id" ref="model_clinic_patient"/>
    <field name="domain_force">[('user_id', '=', user.id)]</field>
    <field name="groups" eval="[(4, ref('clinic.group_clinic_user'))]"/>
</record>
```

## Testing

### Python Tests
```python
from odoo.tests import TransactionCase, tagged

@tagged('post_install', '-at_install')
class TestPatient(TransactionCase):
    
    def setUp(self):
        super(TestPatient, self).setUp()
        self.Patient = self.env['clinic.patient']
    
    def test_create_patient(self):
        patient = self.Patient.create({
            'name': 'Test Patient',
            'phone': '+1234567890',
        })
        self.assertEqual(patient.state, 'draft')
        self.assertTrue(patient.reference)
```

## Useful Resources

- **Odoo ORM Methods**: See `references/orm-methods.md`
- **View Widgets**: See `references/view-widgets.md`
- **Deployment Guide**: See `references/docker-deployment.md`
- **API Integration**: See `references/api-integration.md`

## Scripts

Use scripts in `scripts/` directory:
- `scripts/scaffold-module.sh` - Create new module structure
- `scripts/update-module.sh` - Update module in running instance
- `scripts/run-tests.sh` - Run Odoo tests
