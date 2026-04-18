# syntax=docker/dockerfile:1
# check=error=true

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.4.9
ARG PNPM_VERSION=10.33.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim-trixie AS base

# Rails app lives here
WORKDIR /enju

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips gnupg \
    build-essential git libpq-dev pkg-config npm libyaml-dev

# Install application gems
COPY Gemfile Gemfile.lock package.json pnpm-lock.yaml ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile && \
    npm install -g pnpm@${PNPM_VERSION} && \
    pnpm install

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 CI=true ./bin/rails assets:precompile


# Final stage for app image
FROM base
ARG UID=1000
ARG GID=1000
ARG http_proxy
ARG https_proxy

# Install packages needed for deployment
RUN apt-get update -qq && apt-get install --no-install-recommends -y curl gnupg \
    libvips postgresql-client npm && \
    npm install -g pnpm@${PNPM_VERSION} && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /enju /enju

# Run and own only the runtime files as a non-root user for security
RUN groupadd --gid ${GID} enju && \
    useradd enju --uid ${UID} --gid ${GID} --create-home --shell /bin/bash && \
    chown -R enju:enju db log storage tmp
USER enju:enju

# Entrypoint prepares the database.
ENTRYPOINT ["/enju/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
