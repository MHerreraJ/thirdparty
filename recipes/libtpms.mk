LIBTPMS_RELEASES_URL=https://github.com/stefanberger/libtpms/archive/refs/tags/
LIBTPMS_VERSION:=0.9.6


LIBTPMS_ASSET_NAME:=libtpms-0.9.6.tar.gz
LIBTPMS_ASSET:=$(FETCH_DIR)/$(LIBTPMS_ASSET_NAME)
LIBTPMS_ASSET_URL:=$(LIBTPMS_RELEASES_URL)/v0.9.6.tar.gz

LIBTPMS_DIR:=$(FETCH_DIR)/libtpms-0.9.6

ifeq ($(V),1)
LIBTPMS_BUILD_VERBOSE=--disable-silent-rules
else
LIBTPMS_BUILD_VERBOSE=--enable-silent-rules
endif

libtpms.depend:=openssl tpm2tss

LIBTPMS_OSS_BUILD:=$(call build_oss,libtpms)
LIBTPMS_OSS_CLEAN:=$(call clean_oss,libtpms)
LIBTPMS_OSS_DISTCLEAN:=$(call distclean_oss,libtpms)
.PHONY: $(LIBTPMS_OSS_BUILD) $(LIBTPMS_OSS_CLEAN) $(LIBTPMS_OSS_DISTCLEAN)

$(LIBTPMS_OSS_BUILD): $(LIBTPMS_DIR)
	@mkdir -p $(STAGE_DIR)
	@if [ ! -f $(LIBTPMS_DIR)/configure ]; then \
		cd $(LIBTPMS_DIR) && NOCONFIGURE=1 ./autogen.sh; \
	fi

	cd $(LIBTPMS_DIR) && PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(libtpms.depend))" \
			./configure \
			--prefix=$(STAGE_DIR) \
			--host=$(HOST) \
			--enable-debug=no \
			--with-openssl \
			--with-tpm2 \
			--enable-fast-install=yes \
			--enable-shared=yes \
			$(LIBTPMS_BUILD_VERBOSE) \
			CFLAGS="-fPIC" \
			CC="$(CROSS_COMPILE)gcc" \
			AR="$(CROSS_COMPILE)ar" \
			STRIP="$(CROSS_COMPILE)strip" \
			CPPFLAGS="$(call get_deps_cflags,$(libtpms.depend))" \
			LDFLAGS="$(call get_deps_ldflags,$(libtpms.depend))";

	@$(MAKE) -C $(LIBTPMS_DIR) 
	@$(MAKE) -C $(LIBTPMS_DIR) install

$(LIBTPMS_DIR): $(LIBTPMS_ASSET)
	@echo "Extracting $(LIBTPMS_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(LIBTPMS_ASSET)

$(LIBTPMS_ASSET):
	@rm -f $(LIBTPMS_ASSET)
	@echo "Fetching $(LIBTPMS_ASSET)..."
	@wget --quiet --show-progress $(LIBTPMS_ASSET_URL) -O $(LIBTPMS_ASSET)

$(LIBTPMS_OSS_CLEAN):
	@rm -rf $(LIBTPMS_DIR)

$(LIBTPMS_OSS_DISTCLEAN): $(LIBTPMS_OSS_CLEAN)
	@rm -rf $(LIBTPMS_ASSET)