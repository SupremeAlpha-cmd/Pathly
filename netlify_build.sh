#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
export PATH="$PATH:`pwd`/flutter/bin"

# Generate .env file from Netlify environment variables
echo "SUPABASE_URL=$SUPABASE_URL" > .env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env
echo "GEMINI_API_KEY=$GEMINI_API_KEY" >> .env

# Get dependencies
flutter pub get

# Build web
flutter build web --release