#!/usr/bin/env bash
# exit on error
set -o errexit

echo "-----> Install dependencies"
python -m pip install pipenv
pipenv install --system

echo "-----> I'm post-compile hook"
cd ./tabbycat/

# Set Django settings for all commands
export DJANGO_SETTINGS_MODULE=tabbycat.settings.render

echo "-----> Running database migration"
python manage.py migrate --noinput

echo "-----> Running dynamic preferences checks"
echo "-----> Skipping checks"
# python manage.py checkpreferences  # Command doesn't exist

echo "-----> Running static asset compilation"
npm install -g @vue/cli-service-global
npm install
npm run build

echo "-----> Running static files compilation"
python manage.py collectstatic --noinput

echo "-----> Creating superuser"
# Create default superuser if it doesn't exist
python manage.py shell << EOF
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'ChangeMe123!')
    print("✅ Superuser created: username='admin', password='ChangeMe123!'")
    print("⚠️  IMPORTANT: Change this password immediately after login!")
else:
    print("ℹ️  Superuser 'admin' already exists")
EOF

echo "-----> Post-compile done"
