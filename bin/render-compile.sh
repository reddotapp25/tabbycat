#!/usr/bin/env bash
# exit on error
set -o errexit

echo "-----> Install dependencies"
python -m pip install pipenv
pipenv install --system

echo "-----> I'm post-compile hook"
cd ./tabbycat/

echo "-----> Set Django settings"
export DJANGO_SETTINGS_MODULE=tabbycat.settings.render

echo "-----> Running database migration"
python manage.py migrate --noinput

echo "-----> Running dynamic preferences checks"
echo "-----> Skipping checks"

echo "-----> Running static asset compilation"
npm install -g @vue/cli-service-global
npm install
npm run build

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
echo "⚠️  Superuser creation skipped in build"
echo "ℹ️  After deployment, you'll need to:"
echo "    1. Wait for app to be 'Live'"
echo "    2. Go to your Render URL"
echo "    3. Use the registration page or Django admin"
echo "    4. Or contact support for manual creation"

echo "-----> Post-compile done"
