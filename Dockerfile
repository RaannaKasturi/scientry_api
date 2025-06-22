# ----------- Stage 1: Build -----------
FROM dart:stable AS build

WORKDIR /app

# Copy and resolve dependencies
COPY pubspec.* ./
RUN dart pub get

# Copy all source code
COPY . .

# Compile to a native executable
RUN dart compile exe bin/server.dart -o bin/server

# ----------- Stage 2: Runtime -----------
FROM scratch

# Hugging Face Spaces expose port 7860
EXPOSE 7860

# Copy AOT runtime + compiled server
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server

# Final start command
CMD ["/app/bin/server"]
