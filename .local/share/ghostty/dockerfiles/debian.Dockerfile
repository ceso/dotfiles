# syntax=docker/dockerfile:1

# Build Ghostty terminal from source on Debian
# Artifacts are installed to /output (bin/, share/)

ARG DEBIAN_VERSION=trixie
FROM debian:${DEBIAN_VERSION}

ARG GHOSTTY_VERSION
ARG ZIG_VERSION
ARG INSTALL_DIR
ARG ARCH=x86_64

ENV DEBIAN_FRONTEND=noninteractive

# Build dependencies (https://ghostty.org/docs/install/build#debian-and-ubuntu)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgtk-4-dev \
    libgtk4-layer-shell-dev \
    libadwaita-1-dev \
    gettext \
    libxml2-utils \
    curl \
    xz-utils \
    ca-certificates \
    minisign \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

# Zig from official source
ENV PATH=/opt/zig:$PATH
RUN curl -fSL "https://ziglang.org/download/${ZIG_VERSION}/zig-${ARCH}-linux-${ZIG_VERSION}.tar.xz" -o /tmp/zig.tar.xz && \
    tar xf /tmp/zig.tar.xz -C /opt && \
    mv "/opt/zig-${ARCH}-linux-${ZIG_VERSION}" /opt/zig && \
    rm /tmp/zig.tar.xz && \
    zig version

# Download and verify Ghostty source tarball
WORKDIR /build
RUN curl -fSL "https://release.files.ghostty.org/${GHOSTTY_VERSION}/ghostty-${GHOSTTY_VERSION}.tar.gz" -o ghostty.tar.gz && \
    curl -fSL "https://release.files.ghostty.org/${GHOSTTY_VERSION}/ghostty-${GHOSTTY_VERSION}.tar.gz.minisig" -o ghostty.tar.gz.minisig && \
    minisign -Vm ghostty.tar.gz -P RWQlAjJC23149WL2sEpT/l0QKy7hMIFhYdQOFy0Z7z7PbneUgvlsnYcV && \
    tar xf ghostty.tar.gz && \
    rm ghostty.tar.gz ghostty.tar.gz.minisig

# Build with release optimizations
WORKDIR /build/ghostty-${GHOSTTY_VERSION}
RUN zig build --summary all --prefix "${INSTALL_DIR}" \
                        -Doptimize=ReleaseFast \
                        -Dversion-string="${GHOSTTY_VERSION}" \
                        -Dcpu=native \
                        -Dpie=true \
                        -Demit-docs \
                        -Demit-themes=true

# Verify
RUN "${INSTALL_DIR}/bin/ghostty" --version

RUN sed -i 's#/output##g' "${INSTALL_DIR}/share/systemd/user/app-com.mitchellh.ghostty.service"
RUN sed -i 's#/output##g' "${INSTALL_DIR}/share/applications/com.mitchellh.ghostty.desktop"
RUN sed -i 's#/output##g' "${INSTALL_DIR}/share/dbus-1/services/com.mitchellh.ghostty.service"
