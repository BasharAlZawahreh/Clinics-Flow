#!/bin/bash
# Scaffold a new Odoo module with complete structure

set -e

MODULE_NAME=$1
TARGET_DIR=${2:-"./custom_addons"}

if [ -z "$MODULE_NAME" ]; then
    echo "Usage: $0 <module_name> [target_directory]"
    echo "Example: $0 clinic_management /path/to/addons"
    exit 1
fi

mkdir -p "$TARGET_DIR/$MODULE_NAME"
cd "$TARGET_DIR/$MODULE_NAME"

# Create directories
mkdir -p {models,views,controllers,static/src/{components,scss},data,security,i18n,wizard,report}

# __manifest__.py
cat > __manifest__.py << 'EOF'
{
    'name': '{{MODULE_NAME}}',
    'version': '1.0.0',
    'category': 'Custom',
    'summary': '{{MODULE_DESCRIPTION}}',
    'description': """
        {{MODULE_DESCRIPTION}}
    """,
    'author': 'Your Company',
    'website': 'https://yourcompany.com',
    'depends': ['base', 'web'],
    'data': [
        'security/ir.model.access.csv',
        'views/views.xml',
        'data/data.xml',
    ],
    'demo': [
        'data/demo.xml',
    ],
    'assets': {
        'web.assets_backend': [
            '{{MODULE_NAME}}/static/src/components/*.js',
            '{{MODULE_NAME}}/static/src/scss/*.scss',
        ],
    },
    'installable': True,
    'application': True,
    'auto_install': False,
    'license': 'LGPL-3',
}
EOF

sed -i "s/{{MODULE_NAME}}/$MODULE_NAME/g" __manifest__.py
sed -i "s/{{MODULE_DESCRIPTION}}/Custom module for $MODULE_NAME/g" __manifest__.py

# __init__.py
cat > __init__.py << 'EOF'
from . import models
from . import controllers
from . import wizard
EOF

# models/__init__.py
cat > models/__init__.py << 'EOF'
from . import main_model
EOF

# models/main_model.py
cat > models/main_model.py << 'EOF'
from odoo import models, fields, api


class MainModel(models.Model):
    _name = '{{MODULE_NAME}}.main_model'
    _description = 'Main Model'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    
    name = fields.Char(string='Name', required=True, tracking=True)
    state = fields.Selection([
        ('draft', 'Draft'),
        ('confirmed', 'Confirmed'),
        ('done', 'Done'),
    ], default='draft', tracking=True)
    active = fields.Boolean(default=True)
    create_date = fields.Datetime(string='Created On', readonly=True)
    write_date = fields.Datetime(string='Updated On', readonly=True)
    
    def action_confirm(self):
        self.write({'state': 'confirmed'})
    
    def action_done(self):
        self.write({'state': 'done'})
    
    def action_draft(self):
        self.write({'state': 'draft'})
EOF

sed -i "s/{{MODULE_NAME}}/$MODULE_NAME/g" models/main_model.py

# views/views.xml
cat > views/views.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<odoo>
    <!-- Form View -->
    <record id="view_main_model_form" model="ir.ui.view">
        <field name="name">{{MODULE_NAME}}.main_model.form</field>
        <field name="model">{{MODULE_NAME}}.main_model</field>
        <field name="arch" type="xml">
            <form>
                <header>
                    <button name="action_confirm" type="object" string="Confirm" 
                            class="oe_highlight" invisible="state != 'draft'"/>
                    <button name="action_done" type="object" string="Done" 
                            class="oe_highlight" invisible="state != 'confirmed'"/>
                    <button name="action_draft" type="object" string="Reset to Draft" 
                            invisible="state == 'draft'"/>
                    <field name="state" widget="statusbar" statusbar_visible="draft,confirmed,done"/>
                </header>
                <sheet>
                    <div class="oe_title">
                        <h1>
                            <field name="name" placeholder="Name..."/>
                        </h1>
                    </div>
                    <group>
                        <group>
                            <field name="create_date"/>
                            <field name="write_date"/>
                        </group>
                    </group>
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
        <field name="name">{{MODULE_NAME}}.main_model.tree</field>
        <field name="model">{{MODULE_NAME}}.main_model</field>
        <field name="arch" type="xml">
            <tree>
                <field name="name"/>
                <field name="state" decoration-success="state == 'done'" 
                       decoration-info="state == 'confirmed'"/>
                <field name="create_date"/>
            </tree>
        </field>
    </record>

    <!-- Search View -->
    <record id="view_main_model_search" model="ir.ui.view">
        <field name="name">{{MODULE_NAME}}.main_model.search</field>
        <field name="model">{{MODULE_NAME}}.main_model</field>
        <field name="arch" type="xml">
            <search>
                <field name="name"/>
                <filter name="filter_draft" string="Draft" domain="[('state', '=', 'draft')]"/>
                <filter name="filter_confirmed" string="Confirmed" domain="[('state', '=', 'confirmed')]"/>
                <filter name="filter_done" string="Done" domain="[('state', '=', 'done')]"/>
            </search>
        </field>
    </record>

    <!-- Action -->
    <record id="action_main_model" model="ir.actions.act_window">
        <field name="name">Main Models</field>
        <field name="res_model">{{MODULE_NAME}}.main_model</field>
        <field name="view_mode">tree,form</field>
        <field name="search_view_id" ref="view_main_model_search"/>
        <field name="help" type="html">
            <p class="o_view_nocontent_smiling_face">
                Create your first record!
            </p>
        </field>
    </record>

    <!-- Menu -->
    <menuitem id="menu_root" name="{{MODULE_TITLE}}" sequence="10"/>
    <menuitem id="menu_main" name="Main Models" parent="menu_root" action="action_main_model"/>
</odoo>
EOF

sed -i "s/{{MODULE_NAME}}/$MODULE_NAME/g" views/views.xml
sed -i "s/{{MODULE_TITLE}}/${MODULE_NAME//_/ }/g" views/views.xml

# controllers/__init__.py
cat > controllers/__init__.py << 'EOF'
from . import main
EOF

# controllers/main.py
cat > controllers/main.py << 'EOF'
from odoo import http
from odoo.http import request


class MainController(http.Controller):
    
    @http.route('/{{MODULE_NAME}}/hello', type='http', auth='public')
    def hello(self, **kw):
        return "Hello from {{MODULE_NAME}}!"
    
    @http.route('/api/{{MODULE_NAME}}/data', type='json', auth='user')
    def get_data(self, **kw):
        records = request.env['{{MODULE_NAME}}.main_model'].search([])
        return {
            'status': 'success',
            'data': [{'id': r.id, 'name': r.name} for r in records]
        }
EOF

sed -i "s/{{MODULE_NAME}}/$MODULE_NAME/g" controllers/main.py

# security/ir.model.access.csv
cat > security/ir.model.access.csv << 'EOF'
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_main_model_user,Main Model User,model_{{MODULE_NAME}}_main_model,base.group_user,1,1,1,0
access_main_model_admin,Main Model Admin,model_{{MODULE_NAME}}_main_model,base.group_system,1,1,1,1
EOF

sed -i "s/{{MODULE_NAME}}/$MODULE_NAME/g" security/ir.model.access.csv

# data/data.xml
cat > data/data.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<odoo>
    <data noupdate="1">
        <!-- Sequences -->
        <record id="seq_main_model" model="ir.sequence">
            <field name="name">{{MODULE_NAME}} Sequence</field>
            <field name="code">{{MODULE_NAME}}.main_model</field>
            <field name="prefix">REC-</field>
            <field name="padding">5</field>
        </record>
    </data>
</odoo>
EOF

sed -i "s/{{MODULE_NAME}}/$MODULE_NAME/g" data/data.xml

# data/demo.xml
cat > data/demo.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<odoo>
    <data noupdate="1">
        <record id="demo_record_1" model="{{MODULE_NAME}}.main_model">
            <field name="name">Demo Record 1</field>
        </record>
    </data>
</odoo>
EOF

sed -i "s/{{MODULE_NAME}}/$MODULE_NAME/g" data/demo.xml

# static/src/components/.gitkeep
touch static/src/components/.gitkeep

# static/src/scss/style.scss
cat > static/src/scss/style.scss << 'EOF'
.{{MODULE_NAME}}-custom {
    // Custom styles here
}
EOF

sed -i "s/{{MODULE_NAME}}/$MODULE_NAME/g" static/src/scss/style.scss

echo "✅ Module '$MODULE_NAME' created successfully in $TARGET_DIR/$MODULE_NAME"
echo ""
echo "Structure:"
tree -L 2 "$TARGET_DIR/$MODULE_NAME" 2>/dev/null || find "$TARGET_DIR/$MODULE_NAME" -type f | head -20
echo ""
echo "Next steps:"
echo "1. Review and customize __manifest__.py"
echo "2. Add your business logic to models/"
echo "3. Customize views in views/"
echo "4. Restart Odoo and update apps list"
echo "5. Install your module"
