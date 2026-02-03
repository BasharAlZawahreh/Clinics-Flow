#!/bin/bash
# Scaffold a complete Odoo 18 module with modern structure

set -e

MODULE_NAME=$1
TARGET_DIR=${2:-"./custom_addons"}
HUMAN_NAME=${3:-"${MODULE_NAME//_/ }"}

if [ -z "$MODULE_NAME" ]; then
    echo "Usage: $0 <module_name> [target_directory] [human_readable_name]"
    echo "Example: $0 clinic_management /path/to/addons 'Clinic Management'"
    exit 1
fi

# Create directory structure
mkdir -p "$TARGET_DIR/$MODULE_NAME"
cd "$TARGET_DIR/$MODULE_NAME"

mkdir -p {models,views,controllers,report,wizard,static/src/{components,scss,xml},data,demo,security,i18n,tests}

echo "✅ Creating Odoo 18 module: $MODULE_NAME"

# __manifest__.py
cat > __manifest__.py << EOF
{
    'name': '$HUMAN_NAME',
    'version': '18.0.1.0.0',
    'category': 'Custom',
    'summary': 'Complete $HUMAN_NAME solution for Odoo 18',
    'description': """
        $HUMAN_NAME Module
        =================
        
        Features:
        - Complete business workflow
        - Modern OWL 2.0 components
        - REST API integration
        - WhatsApp notifications (Odoo 18 native)
        - Automated actions
        - Comprehensive reporting
    """,
    'author': 'Your Company',
    'website': 'https://yourcompany.com',
    'license': 'LGPL-3',
    
    # Dependencies
    'depends': [
        'base',
        'mail',
        'web',
        'contacts',
    ],
    
    # Data files
    'data': [
        # Security
        'security/ir.model.access.csv',
        'security/security_rules.xml',
        
        # Data
        'data/sequences.xml',
        'data/automated_actions.xml',
        'data/email_templates.xml',
        
        # Views
        'views/main_model_views.xml',
        'views/menu_items.xml',
        'views/templates.xml',
        
        # Reports
        'report/reports.xml',
    ],
    
    # Demo data
    'demo': [
        'demo/demo_data.xml',
    ],
    
    # Assets
    'assets': {
        'web.assets_backend': [
            '$MODULE_NAME/static/src/components/*.js',
            '$MODULE_NAME/static/src/scss/*.scss',
        ],
        'web.assets_qweb': [
            '$MODULE_NAME/static/src/xml/*.xml',
        ],
    },
    
    # Installation
    'installable': True,
    'application': True,
    'auto_install': False,
    
    # Additional metadata
    'images': ['static/description/icon.png'],
    'maintainer': 'Your Company',
    'support': 'support@yourcompany.com',
}
EOF

# __init__.py
cat > __init__.py << EOF
from . import models
from . import controllers
from . import wizard
from . import report
EOF

# models/__init__.py
cat > models/__init__.py << EOF
from . import main_model
EOF

# models/main_model.py - Odoo 18 style
cat > models/main_model.py << EOF
from odoo import models, fields, api, _
from odoo.exceptions import ValidationError, UserError


class MainModel(models.Model):
    _name = '${MODULE_NAME}.main_model'
    _description = 'Main Model'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _order = 'create_date desc'
    
    # Fields
    name = fields.Char(
        string='Name',
        required=True,
        index=True,
        tracking=True,
    )
    
    reference = fields.Char(
        string='Reference',
        readonly=True,
        default='New',
        copy=False,
    )
    
    state = fields.Selection([
        ('draft', 'Draft'),
        ('confirmed', 'Confirmed'),
        ('in_progress', 'In Progress'),
        ('done', 'Done'),
        ('cancelled', 'Cancelled'),
    ], default='draft',
        tracking=True,
        index=True,
    )
    
    active = fields.Boolean(
        default=True,
        index=True,
    )
    
    date = fields.Date(
        string='Date',
        default=fields.Date.context_today,
        tracking=True,
    )
    
    partner_id = fields.Many2one(
        'res.partner',
        string='Partner',
        required=True,
        tracking=True,
        index=True,
    )
    
    user_id = fields.Many2one(
        'res.users',
        string='Responsible',
        default=lambda self: self.env.user,
        tracking=True,
    )
    
    company_id = fields.Many2one(
        'res.company',
        string='Company',
        default=lambda self: self.env.company,
        required=True,
    )
    
    amount = fields.Monetary(
        string='Amount',
        currency_field='currency_id',
        tracking=True,
    )
    
    currency_id = fields.Many2one(
        'res.currency',
        related='company_id.currency_id',
        readonly=True,
    )
    
    description = fields.Html(
        string='Description',
        sanitize=True,
    )
    
    line_ids = fields.One2many(
        '${MODULE_NAME}.main_model.line',
        'main_id',
        string='Lines',
    )
    
    total_amount = fields.Monetary(
        string='Total',
        compute='_compute_total',
        store=True,
    )
    
    tag_ids = fields.Many2many(
        '${MODULE_NAME}.tag',
        string='Tags',
    )
    
    # Compute Methods
    @api.depends('line_ids.amount', 'amount')
    def _compute_total(self):
        for record in self:
            lines_total = sum(record.line_ids.mapped('amount'))
            record.total_amount = record.amount + lines_total
    
    # Create Method
    @api.model_create_multi
    def create(self, vals_list):
        for vals in vals_list:
            if vals.get('reference', 'New') == 'New':
                vals['reference'] = self.env['ir.sequence'].next_by_code(
                    '${MODULE_NAME}.main_model'
                ) or 'New'
        return super(MainModel, self).create(vals_list)
    
    # Constraints
    @api.constrains('amount')
    def _check_amount(self):
        for record in self:
            if record.amount < 0:
                raise ValidationError(_('Amount cannot be negative!'))
    
    # Action Methods
    def action_confirm(self):
        for record in self:
            if record.state != 'draft':
                raise UserError(_('Only draft records can be confirmed!'))
        self.write({'state': 'confirmed'})
        self._send_confirmation_notification()
    
    def action_start(self):
        self.write({'state': 'in_progress'})
    
    def action_done(self):
        self.write({'state': 'done'})
    
    def action_cancel(self):
        self.write({'state': 'cancelled'})
    
    def action_draft(self):
        self.write({'state': 'draft'})
    
    def action_send_whatsapp(self):
        """Send WhatsApp notification (Odoo 18 native feature)"""
        self.ensure_one()
        if self.partner_id.mobile:
            # Odoo 18 native WhatsApp integration
            self.env['whatsapp.message'].create({
                'phone': self.partner_id.mobile,
                'body': f'Hello {self.partner_id.name}, your record {self.reference} has been confirmed.',
            })
        return True
    
    def _send_confirmation_notification(self):
        """Send notification on confirmation"""
        for record in self:
            record.message_post(
                body=_('Record confirmed by %s') % record.env.user.name,
                subtype_xmlid='mail.mt_comment',
            )
    
    # Public Method for API
    def get_api_data(self):
        """Return data for REST API"""
        self.ensure_one()
        return {
            'id': self.id,
            'reference': self.reference,
            'name': self.name,
            'state': self.state,
            'date': str(self.date),
            'partner': {
                'id': self.partner_id.id,
                'name': self.partner_id.name,
            },
            'amount': self.amount,
            'total': self.total_amount,
        }


class MainModelLine(models.Model):
    _name = '${MODULE_NAME}.main_model.line'
    _description = 'Main Model Line'
    
    main_id = fields.Many2one(
        '${MODULE_NAME}.main_model',
        string='Main Record',
        required=True,
        ondelete='cascade',
    )
    
    name = fields.Char(
        string='Description',
        required=True,
    )
    
    quantity = fields.Float(
        string='Quantity',
        default=1.0,
    )
    
    price_unit = fields.Monetary(
        string='Unit Price',
        currency_field='currency_id',
    )
    
    amount = fields.Monetary(
        string='Amount',
        currency_field='currency_id',
        compute='_compute_amount',
        store=True,
    )
    
    currency_id = fields.Many2one(
        'res.currency',
        related='main_id.currency_id',
        readonly=True,
    )
    
    @api.depends('quantity', 'price_unit')
    def _compute_amount(self):
        for line in self:
            line.amount = line.quantity * line.price_unit


class Tag(models.Model):
    _name = '${MODULE_NAME}.tag'
    _description = 'Tag'
    
    name = fields.Char(required=True)
    color = fields.Integer(string='Color Index')
EOF

# controllers/main.py - REST API
cat > controllers/main.py << EOF
from odoo import http
from odoo.http import request


class ${MODULE_NAME}Controller(http.Controller):
    
    @http.route('/api/v1/${MODULE_NAME}/records', type='json', auth='api_key', methods=['GET'])
    def get_records(self, **kwargs):
        """Get all records"""
        domain = []
        if kwargs.get('state'):
            domain.append(('state', '=', kwargs['state']))
        
        records = request.env['${MODULE_NAME}.main_model'].search(domain)
        return {
            'status': 'success',
            'count': len(records),
            'data': [r.get_api_data() for r in records]
        }
    
    @http.route('/api/v1/${MODULE_NAME}/records/<int:record_id>', type='json', auth='api_key', methods=['GET'])
    def get_record(self, record_id, **kwargs):
        """Get single record"""
        record = request.env['${MODULE_NAME}.main_model'].browse(record_id)
        if not record.exists():
            return {'status': 'error', 'message': 'Record not found'}
        return {
            'status': 'success',
            'data': record.get_api_data()
        }
    
    @http.route('/api/v1/${MODULE_NAME}/records', type='json', auth='api_key', methods=['POST'])
    def create_record(self, **kwargs):
        """Create new record"""
        data = request.jsonrequest
        try:
            record = request.env['${MODULE_NAME}.main_model'].create({
                'name': data.get('name'),
                'partner_id': data.get('partner_id'),
                'amount': data.get('amount', 0),
                'date': data.get('date'),
            })
            return {
                'status': 'success',
                'data': record.get_api_data()
            }
        except Exception as e:
            return {'status': 'error', 'message': str(e)}
    
    @http.route('/${MODULE_NAME}/hello', type='http', auth='public', website=True)
    def hello_page(self, **kwargs):
        """Public web page"""
        return request.render('${MODULE_NAME}.hello_template', {})
EOF

# views/main_model_views.xml
cat > views/main_model_views.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<odoo>
    <!-- Form View -->
    <record id="view_main_model_form" model="ir.ui.view">
        <field name="name">${MODULE_NAME}.main_model.form</field>
        <field name="model">${MODULE_NAME}.main_model</field>
        <field name="arch" type="xml">
            <form>
                <header>
                    <button name="action_confirm" type="object" string="Confirm"
                            class="oe_highlight" invisible="state != 'draft'"/>
                    <button name="action_start" type="object" string="Start"
                            class="oe_highlight" invisible="state != 'confirmed'"/>
                    <button name="action_done" type="object" string="Mark Done"
                            class="oe_highlight" invisible="state != 'in_progress'"/>
                    <button name="action_cancel" type="object" string="Cancel"
                            invisible="state in ('done', 'cancelled')"/>
                    <button name="action_draft" type="object" string="Reset to Draft"
                            invisible="state == 'draft'"/>
                    <button name="action_send_whatsapp" type="object" string="Send WhatsApp"
                            icon="fa-whatsapp"/>
                    <field name="state" widget="statusbar" 
                           statusbar_visible="draft,confirmed,in_progress,done"/>
                </header>
                <sheet>
                    <div class="oe_title">
                        <h1>
                            <field name="reference" readonly="1"/>
                        </h1>
                        <h2>
                            <field name="name" placeholder="Name..."/>
                        </h2>
                    </div>
                    <group>
                        <group>
                            <field name="partner_id"/>
                            <field name="date"/>
                            <field name="user_id"/>
                        </group>
                        <group>
                            <field name="amount"/>
                            <field name="currency_id" invisible="1"/>
                            <field name="total_amount"/>
                            <field name="company_id" groups="base.group_multi_company"/>
                            <field name="tag_ids" widget="many2many_tags"/>
                        </group>
                    </group>
                    <notebook>
                        <page string="Lines">
                            <field name="line_ids">
                                <list editable="bottom">
                                    <field name="name"/>
                                    <field name="quantity"/>
                                    <field name="price_unit"/>
                                    <field name="amount"/>
                                </list>
                            </field>
                        </page>
                        <page string="Description">
                            <field name="description"/>
                        </page>
                    </notebook>
                </sheet>
                <div class="oe_chatter">
                    <field name="message_follower_ids"/>
                    <field name="activity_ids"/>
                    <field name="message_ids"/>
                </div>
            </form>
        </field>
    </record>

    <!-- Tree View -->
    <record id="view_main_model_tree" model="ir.ui.view">
        <field name="name">${MODULE_NAME}.main_model.tree</field>
        <field name="model">${MODULE_NAME}.main_model</field>
        <field name="arch" type="xml">
            <list>
                <field name="reference"/>
                <field name="name"/>
                <field name="partner_id"/>
                <field name="date"/>
                <field name="amount"/>
                <field name="state" decoration-success="state == 'done'" 
                       decoration-info="state == 'in_progress'"
                       decoration-warning="state == 'draft'"
                       decoration-danger="state == 'cancelled'"/>
            </list>
        </field>
    </record>

    <!-- Search View -->
    <record id="view_main_model_search" model="ir.ui.view">
        <field name="name">${MODULE_NAME}.main_model.search</field>
        <field name="model">${MODULE_NAME}.main_model</field>
        <field name="arch" type="xml">
            <search>
                <field name="name"/>
                <field name="reference"/>
                <field name="partner_id"/>
                <filter name="draft" string="Draft" domain="[('state', '=', 'draft')]"/>
                <filter name="confirmed" string="Confirmed" domain="[('state', '=', 'confirmed')]"/>
                <filter name="in_progress" string="In Progress" domain="[('state', '=', 'in_progress')]"/>
                <filter name="done" string="Done" domain="[('state', '=', 'done')]"/>
                <group expand="0" string="Group By">
                    <filter name="group_by_state" string="State" context="{'group_by': 'state'}"/>
                    <filter name="group_by_date" string="Date" context="{'group_by': 'date:month'}"/>
                    <filter name="group_by_partner" string="Partner" context="{'group_by': 'partner_id'}"/>
                </group>
            </search>
        </field>
    </record>

    <!-- Kanban View -->
    <record id="view_main_model_kanban" model="ir.ui.view">
        <field name="name">${MODULE_NAME}.main_model.kanban</field>
        <field name="model">${MODULE_NAME}.main_model</field>
        <field name="arch" type="xml">
            <kanban default_group_by="state">
                <templates>
                    <t t-name="kanban-box">
                        <div class="oe_kanban_card">
                            <div class="oe_kanban_content">
                                <div class="o_kanban_record_title">
                                    <field name="reference"/>
                                </div>
                                <div>
                                    <field name="name"/>
                                </div>
                                <div>
                                    <field name="partner_id"/>
                                </div>
                                <div>
                                    <field name="amount" widget="monetary"/>
                                </div>
                            </div>
                        </div>
                    </t>
                </templates>
            </kanban>
        </field>
    </record>

    <!-- Action -->
    <record id="action_main_model" model="ir.actions.act_window">
        <field name="name">Main Records</field>
        <field name="res_model">${MODULE_NAME}.main_model</field>
        <field name="view_mode">list,form,kanban</field>
        <field name="search_view_id" ref="view_main_model_search"/>
        <field name="help" type="html">
            <p class="o_view_nocontent_smiling_face">
                Create your first record!
            </p>
        </field>
    </record>
</odoo>
EOF

# views/menu_items.xml
cat > views/menu_items.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<odoo>
    <!-- Main Menu -->
    <menuitem id="menu_${MODULE_NAME}_root" 
              name="$HUMAN_NAME" 
              sequence="10"
              web_icon="${MODULE_NAME},static/description/icon.png"/>
    
    <!-- Dashboard -->
    <menuitem id="menu_${MODULE_NAME}_dashboard" 
              name="Dashboard" 
              parent="menu_${MODULE_NAME}_root"
              sequence="1"/>
    
    <!-- Operations -->
    <menuitem id="menu_${MODULE_NAME}_operations" 
              name="Operations" 
              parent="menu_${MODULE_NAME}_root"
              sequence="10"/>
    
    <menuitem id="menu_main_records" 
              name="Main Records" 
              parent="menu_${MODULE_NAME}_operations"
              action="action_main_model"
              sequence="10"/>
    
    <!-- Configuration -->
    <menuitem id="menu_${MODULE_NAME}_config" 
              name="Configuration" 
              parent="menu_${MODULE_NAME}_root"
              sequence="100"
              groups="base.group_system"/>
    
    <menuitem id="menu_tags" 
              name="Tags" 
              parent="menu_${MODULE_NAME}_config"
              sequence="10"/>
</odoo>
EOF

# security/ir.model.access.csv
cat > security/ir.model.access.csv << EOF
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_main_model_user,Main Model User,model_${MODULE_NAME}_main_model,base.group_user,1,1,1,0
access_main_model_manager,Main Model Manager,model_${MODULE_NAME}_main_model,base.group_system,1,1,1,1
access_main_model_line_user,Main Model Line User,model_${MODULE_NAME}_main_model_line,base.group_user,1,1,1,1
access_tag_user,Tag User,model_${MODULE_NAME}_tag,base.group_user,1,1,1,0
access_tag_manager,Tag Manager,model_${MODULE_NAME}_tag,base.group_system,1,1,1,1
EOF

# data/sequences.xml
cat > data/sequences.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<odoo>
    <data noupdate="1">
        <record id="seq_main_model" model="ir.sequence">
            <field name="name">Main Model Sequence</field>
            <field name="code">${MODULE_NAME}.main_model</field>
            <field name="prefix">REF-</field>
            <field name="padding">5</field>
            <field name="company_id" eval="False"/>
        </record>
    </data>
</odoo>
EOF

# data/email_templates.xml
cat > data/email_templates.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<odoo>
    <data noupdate="1">
        <record id="email_template_notification" model="mail.template">
            <field name="name">Record Notification</field>
            <field name="model_id" ref="model_${MODULE_NAME}_main_model"/>
            <field name="subject">Record \${object.reference} - \${object.state}</field>
            <field name="email_from">\${object.user_id.email_formatted | safe}</field>
            <field name="partner_to">\${object.partner_id.id}</field>
            <field name="body_html" type="html">
                <![CDATA[
                    <p>Dear \${object.partner_id.name},</p>
                    <p>Your record <strong>\${object.reference}</strong> is now \${object.state}.</p>
                    <p>Amount: \${object.amount} \${object.currency_id.symbol}</p>
                ]]>
            </field>
        </record>
    </data>
</odoo>
EOF

# static/description/icon.png placeholder
touch static/description/icon.png

echo ""
echo "✅ Odoo 18 module '$MODULE_NAME' created successfully!"
echo ""
echo "📁 Location: $TARGET_DIR/$MODULE_NAME"
echo ""
echo "📊 Structure:"
echo "  📂 models/           # Python models"
echo "  📂 views/            # XML views"
echo "  📂 controllers/      # REST API"
echo "  📂 static/src/       # OWL components, SCSS"
echo "  📂 data/             # Sequences, templates"
echo "  📂 security/         # Access rights"
echo "  📂 tests/            # Unit tests"
echo ""
echo "🚀 Next steps:"
echo "  1. cd $TARGET_DIR/$MODULE_NAME"
echo "  2. Review and customize the code"
echo "  3. Add icon: static/description/icon.png (128x128)"
echo "  4. Test: ./odoo-bin -u $MODULE_NAME -d your_db --stop-after-init"
echo "  5. Install in Odoo 18!"
echo ""
