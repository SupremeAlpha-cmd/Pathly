#!/bin/bash

# Install Flutter

git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter

export PATH="$PATH:`pwd`/flutter/bin"

# Get dependencies

flutter pub get

# Build web

flutter build web --release