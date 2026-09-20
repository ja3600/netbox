#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

python -m pip install --upgrade pip
python -m pip install -r requirements.txt

configuration="netbox/netbox/configuration.py"
if [[ ! -e "$configuration" ]]; then
    cp netbox/netbox/configuration_example.py "$configuration"
    secret_key="$(python netbox/generate_secret_key.py)"
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

cd netbox
python manage.py migrate --noinput
