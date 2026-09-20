#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../netbox"

python -m pip install --upgrade pip
python -m pip install -r requirements.txt

configuration="netbox/configuration.py"
if [[ ! -e "$configuration" ]]; then
    cp netbox/configuration_example.py "$configuration"
    secret_key="$(python generate_secret_key.py)"
    cat >> "$configuration" <<EOF

# Codespaces development defaults. This file is ignored by git.
ALLOWED_HOSTS = ['*']
DEBUG = True
DEVELOPER = True
SECRET_KEY = '$secret_key'
DATABASES['default'].update({
    'NAME': 'netbox',
    'USER': 'netbox',
    'PASSWORD': 'netbox',
    'HOST': 'postgres',
    'PORT': 5432,
})
for _redis_config in REDIS.values():
    _redis_config.update({'HOST': 'redis', 'PORT': 6379})
EOF
fi

python manage.py migrate --noinput
