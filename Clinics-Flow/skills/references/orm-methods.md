# Odoo ORM Methods Reference

## Create Records

### create()
```python
record = model.create({'field': 'value'})
records = model.create([{'field': 'value1'}, {'field': 'value2'}])  # batch
```

### create_multi decorator
```python
@api.model_create_multi
def create(self, vals_list):
    for vals in vals_list:
        vals['computed_field'] = self._compute_something(vals)
    return super().create(vals_list)
```

## Read Records

### browse()
```python
record = model.browse(record_id)  # single
records = model.browse([1, 2, 3])  # multiple
name = record.name  # access field
```

### search()
```python
records = model.search([('state', '=', 'confirmed')])
records = model.search(domain, limit=10, order='create_date desc')
records = model.search_count(domain)  # count only
```

### Common Domains
```python
[('state', '=', 'confirmed')]
[('amount', '>', 100), ('amount', '<=', 1000)]
[('name', 'ilike', 'search_term')]  # case insensitive
[('date', '>=', '2024-01-01'), ('date', '<=', '2024-12-31')]
['|', ('state', '=', 'draft'), ('state', '=', 'confirmed')]  # OR
['&', ('active', '=', True), ('state', '=', 'done')]  # AND (implicit)
```

### search_read()
```python
# Efficient: combines search and read
results = model.search_read(
    domain=[('state', '=', 'confirmed')],
    fields=['name', 'date', 'amount'],
    limit=100
)
# Returns: [{'id': 1, 'name': '...', 'date': '...', 'amount': ...}]
```

### read_group()
```python
# Aggregation
groups = model.read_group(
    domain=[],
    fields=['amount:sum', 'date:month'],
    groupby=['date:month']
)
```

## Update Records

### write()
```python
record.write({'state': 'confirmed', 'date': fields.Date.today()})
records.write({'state': 'done'})  # batch update
```

### Update with context
```python
record.with_context(mail_notrack=True).write({'state': 'done'})
record.with_context(tracking_disable=True).write({'field': 'value'})
```

## Delete Records

### unlink()
```python
record.unlink()  # single
records.unlink()  # multiple
```

## Recordset Operations

### Filtering
```python
records.filtered(lambda r: r.state == 'confirmed')
records.filtered('state')  # truthy values only
```

### Mapping
```python
names = records.mapped('name')
partners = records.mapped('partner_id')  # returns recordset
partner_names = records.mapped('partner_id.name')
```

### Sorting
```python
records.sorted(key=lambda r: r.date)
records.sorted('date', reverse=True)
```

### Set Operations
```python
combined = records1 | records2  # union
common = records1 & records2    # intersection
unique = records1 - records2    # difference
```

## Relations

### Many2one
```python
partner = record.partner_id
partner_name = record.partner_id.name
record.partner_id = new_partner  # assign
record.partner_id = False  # clear
```

### One2many / Many2many
```python
# Create and add
record.line_ids = [(0, 0, {'field': 'value'})]

# Update existing
record.line_ids = [(1, line_id, {'field': 'new_value'})]

# Delete
record.line_ids = [(2, line_id)]

# Remove (unlink but don't delete)
record.line_ids = [(3, line_id)]

# Add existing
record.line_ids = [(4, existing_id)]

# Remove all
record.line_ids = [(5,)]

# Replace all
record.line_ids = [(6, 0, [id1, id2, id3])]
```

## Context and Environment

### with_context()
```python
record.with_context(lang='ar_001').name  # Arabic translation
record.with_context(force_company=company_id)
record.with_context(mail_auto_subscribe=False)
```

### sudo()
```python
record.sudo().write({'field': 'value'})  # bypass access rights
record.with_user(admin_user).write({})  # switch user
```

### with_company()
```python
record.with_company(company_id).do_something()
```

## Computed Fields

### @api.depends
```python
@api.depends('field1', 'field2')
def _compute_total(self):
    for record in self:
        record.total = record.field1 + record.field2

@api.depends('line_ids.amount')
def _compute_sum(self):
    for record in self:
        record.sum_amount = sum(line.amount for line in record.line_ids)
```

### @api.depends_context
```python
@api.depends_context('company')
def _compute_company_currency(self):
    for record in self:
        record.currency_id = self.env.company.currency_id
```

## Onchange

### @api.onchange
```python
@api.onchange('product_id')
def _onchange_product(self):
    if self.product_id:
        self.price = self.product_id.list_price
        return {
            'warning': {
                'title': "Product Changed",
                'message': "Price has been updated."
            }
        }
```

## Constraints

### @api.constrains
```python
@api.constrains('date_start', 'date_end')
def _check_dates(self):
    for record in self:
        if record.date_end < record.date_start:
            raise ValidationError(_("End date must be after start date."))
```

### SQL Constraints
```python
_sql_constraints = [
    ('unique_name', 'UNIQUE(name)', 'Name must be unique!'),
    ('positive_amount', 'CHECK(amount >= 0)', 'Amount must be positive!'),
]
```

## Utility Methods

### exists()
```python
records = model.search([...])
if records.exists():  # check if records still exist
    records.do_something()
```

### ensure_one()
```python
def some_method(self):
    self.ensure_one()  # raises if not single record
    return self.name
```

### copy()
```python
new_record = record.copy()
new_record = record.copy({'name': 'Copy of ' + record.name})
```

### default_get()
```python
defaults = model.default_get(['field1', 'field2'])
```

## Environment

### Accessing other models
```python
self.env['res.partner'].search([...])
self.env['model.name'].browse(id)
self.env.user  # current user
self.env.company  # current company
self.env.companies  # all allowed companies
self.env.lang  # current language
self.env.cr  # database cursor
```

### Checking access rights
```python
model.check_access_rights('read')
model.check_access_rights('write')
model.check_access_rule('unlink')
```

## Transactions

### Savepoint (for error handling)
```python
with self.env.cr.savepoint():
    try:
        record.risky_operation()
    except Exception:
        # Rollback to savepoint
        pass
```

### Manual commit/rollback (rarely needed)
```python
self.env.cr.commit()
self.env.cr.rollback()
```

## Caching

### Invalidate cache
```python
record.invalidate_cache()
model.invalidate_cache(ids=[1, 2, 3])
```

### Clear cache for fields
```python
record._cache.clear()
```
