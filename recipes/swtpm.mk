SWTPM_RELEASES_URL=https://github.com/stefanberger/swtpm/archive/refs/tags/
SWTPM_VERSION:=0.8.2

SWTPM_ASSET_NAME:=swtpm-0.8.2.tar.gz
SWTPM_ASSET:=$(FETCH_DIR)/$(SWTPM_ASSET_NAME)
SWTPM_ASSET_URL:=$(SWTPM_RELEASES_URL)/v0.8.2.tar.gz

SWTPM_DIR:=$(FETCH_DIR)/swtpm-0.8.2

ifeq ($(V),1)
SWTPM_BUILD_VERBOSE=--disable-silent-rules
else
SWTPM_BUILD_VERBOSE=--enable-silent-rules
endif

SWTPM_WITH_SECCOMP=--with-seccomp=no

swtpm.depend:=libtpms openssl
# swtpm.depend+=glib2.0 json-glib
# swtpm.depend+= json-glib

ifeq ($(ARCH),aarch64)
endif

ifeq ($(ARCH),x86_64)
swtpm.depend+=libtasn1
endif

SWTPM_OSS_BUILD:=$(call build_oss,swtpm)
SWTPM_OSS_CLEAN:=$(call clean_oss,swtpm)
SWTPM_OSS_DISTCLEAN:=$(call distclean_oss,swtpm)
.PHONY: $(SWTPM_OSS_BUILD) $(SWTPM_OSS_CLEAN) $(SWTPM_OSS_DISTCLEAN)

$(SWTPM_OSS_BUILD): $(SWTPM_DIR)
	@mkdir -p $(STAGE_DIR)
	@if [ ! -f $(SWTPM_DIR)/configure ]; then \
		cd $(SWTPM_DIR) && NOCONFIGURE=1 ./autogen.sh; \
	fi

	cd $(SWTPM_DIR) && ./configure \
			--prefix=$(STAGE_DIR) \
			--host=$(HOST) \
			--enable-debug=no \
			--with-openssl \
			--with-gnutls=no \
			--with-cuse=no \
			--with-selinux=no \
			$(SWTPM_WITH_SECCOMP) \
			--enable-fast-install=yes \
			$(SWTPM_BUILD_VERBOSE) \
			CC="$(CROSS_COMPILE)gcc" \
			AR="$(CROSS_COMPILE)ar" \
			STRIP="$(CROSS_COMPILE)strip" \
			CPPFLAGS="$(call get_deps_cflags,$(swtpm.depend))" \
			LDFLAGS="$(call get_deps_ldflags,$(swtpm.depend)) -lcrypto" \
			PKG_CONFIG_PATH=$(call get_deps_pkgconfig,$(swtpm.depend));

	@$(MAKE) -C $(SWTPM_DIR) 
	@$(MAKE) -C $(SWTPM_DIR) install

$(SWTPM_DIR): $(SWTPM_ASSET)
	@echo "Extracting $(SWTPM_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(SWTPM_ASSET)

$(SWTPM_ASSET):
	@rm -f $(SWTPM_ASSET)
	@echo "Fetching $(SWTPM_ASSET)..."
	@wget --quiet --show-progress $(SWTPM_ASSET_URL) -O $(SWTPM_ASSET)


$(SWTPM_OSS_CLEAN):
	@rm -rf $(SWTPM_DIR)

$(SWTPM_OSS_DISTCLEAN): $(SWTPM_OSS_CLEAN)
	@rm -rf $(SWTPM_ASSET)