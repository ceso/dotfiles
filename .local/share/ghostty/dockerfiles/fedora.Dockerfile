# syntax=docker/dockerfile:1

# Build Ghostty terminal from source on Fedora
# Artifacts are installed to /output (bin/, share/)

ARG FEDORA_VERSION=43
FROM fedora:${FEDORA_VERSION}

ARG GHOSTTY_VERSION
ARG ZIG_VERSION
ARG INSTALL_DIR
ARG ARCH=x86_64

# Build dependencies (https://ghostty.org/docs/install/build#fedora)
RUN dnf install -y \
    gtk4-devel \
    gtk4-layer-shell-devel \
    libadwaita-devel \
    gettext \
    curl \
    xz \
    minisign \
    pandoc-cli \
    && dnf clean all

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