#!/usr/bin/env bash
# Render Build Script
# This script runs during the build phase on Render.
set -o errexit

echo "==> Installing Ruby dependencies..."
bundle install

echo "==> Installing Node dependencies..."
yarn install --immutable

echo "==> Precompiling assets..."
bundle exec rails assets:precompile

echo "==> Cleaning old assets..."
bundle exec rails assets:clean

echo "==> Running database migrations..."
bundle exec rails db:migrate

echo "==> Build complete!"
