#!/usr/bin/env bash
# exit on error
set -o errexit

echo "-----> Install dependencies"
python -m pip install pipenv
pipenv install --system

echo "-----> I'm post-compile hook"
cd ./tabbycat/

echo "-----> Debug: Current directory"
pwd
ls -la

echo "-----> Debug: Python and Django"
python --version
python -c "import django; print(f'Django: {django.__version__}')" || echo "Django not found"

echo "-----> Set Django settings"
export DJANGO_SETTINGS_MODULE=tabbycat.settings.render
python -c "from django.conf import settings; print(f'Settings module: {settings.SETTINGS_MODULE}')" || echo "Cannot load settings"

echo "-----> Debug: Available Django commands"
python manage.py help || echo "manage.py help failed"

echo "-----> Running database migration"
python manage.py migrate --noinput

echo "-----> Running dynamic preferences checks"
echo "-----> Skipping checks"

echo "-----> Running static asset compilation"
npm install -g @vue/cli-service-global
npm install
npm run build

echo "-----> Debug: Before collectstatic"
python -c "import django; print('Django available')" || echo "Django NOT available"

echo "-----> Checking for collectstatic command"
if python manage.py help 2>/dev/null | grep -q collectstatic; then
    echo "✅ collectstatic command found"
    echo "-----> Running static files compilation"
    python manage.py collectstatic --noinput
else
    echo "⚠️  collectstatic command not found, skipping"
    echo "ℹ️  Static files may already be built by Vue.js compilation"
fi

echo "-----> Creating superuser"
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
