# Odoo.sh wait restart action

This action wait restart of odoo.sh instance

# Usage

```yaml
uses: halgandd/odoo-sh-wait-restart@v1
env:
  INSTANCE_NAME: '${{secrets.ODOOSH_INSTANCE_NAME}}'
  PRIVATE_KEY: '${{secrets.SSH_PRIVATE_KEY}}'
``