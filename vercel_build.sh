#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
export PATH="$PATH:$PWD/flutter/bin"

# Get dependencies
flutter pub get

# Build web - pass env vars as dart-define so String.fromEnvironment works
# Note: SUPABASE_URL, SUPABASE_ANON_KEY, and GEMINI_API_KEY must be set in Vercel env vars
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
