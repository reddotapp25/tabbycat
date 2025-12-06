#!/usr/bin/env bash
# exit on error
set -o errexit

echo "-----> Install dependencies"
python -m pip install pipenv
pipenv install --system

echo "-----> I'm post-compile hook"
cd ./tabbycat/

echo "-----> Running database migration"
DJANGO_SETTINGS_MODULE=tabbycat.settings.render python manage.py migrate --noinput

echo "-----> Running dynamic preferences checks"
echo "-----> Skipping checks"
# python manage.py checkpreferences  # Command doesn't exist

echo "-----> Running static asset compilation"
npm install -g @vue/cli-service-global
npm install
npm run build

echo "-----> Running static files compilation"
DJANGO_SETTINGS_MODULE=tabbycat.settings.render python manage.py collectstatic --noinput

echo "-----> Post-compile done"
