RSYNC_RELEASES_URL=https://github.com/RsyncProject/rsync/releases/download/
RSYNC_VERSION:=v3.4.1

RSYNC_ASSET_NAME:=rsync-3.4.1.tar.gz
RSYNC_ASSET:=$(FETCH_DIR)/$(RSYNC_ASSET_NAME)
RSYNC_ASSET_URL:=$(RSYNC_RELEASES_URL)/$(RSYNC_VERSION)/$(RSYNC_ASSET_NAME)

RSYNC_DIR:=$(FETCH_DIR)/rsync-3.4.1

ifeq ($(V),1)
RSYNC_BUILD_VERBOSE=--disable-silent-rules
else
RSYNC_BUILD_VERBOSE=--enable-silent-rules
endif

rsync.depend:=openssl

RSYNC_OSS_BUILD:=$(call build_oss,rsync)
RSYNC_OSS_CLEAN:=$(call clean_oss,rsync)
RSYNC_OSS_DISTCLEAN:=$(call distclean_oss,rsync)

.PHONY: $(RSYNC_OSS_BUILD) $(RSYNC_OSS_CLEAN) $(RSYNC_OSS_DISTCLEAN)

$(RSYNC_OSS_BUILD): $(RSYNC_DIR)
	@mkdir -p $(STAGE_DIR)
	cd $(RSYNC_DIR) && ./configure \
			--prefix=$(STAGE_DIR) \
			--host=$(HOST) \
			--enable-debug=no \
			--disable-md2man \
			--with-included-popt \
			--with-included-zlib \
			--disable-xxhash \
			--disable-zstd \
			--disable-lz4 \
			--disable-openssl \
			CC="$(CROSS_COMPILE)gcc" \
			AR="$(CROSS_COMPILE)ar" \
			STRIP="$(CROSS_COMPILE)strip" \
			CPPFLAGS="$(call get_deps_cflags,$(rsync.depend))" \
			LDFLAGS="$(call get_deps_ldflags,$(rsync.depend))"

	@$(MAKE) -C $(RSYNC_DIR) 
	@$(MAKE) -C $(RSYNC_DIR) install

$(RSYNC_DIR): $(RSYNC_ASSET)
	@echo "Extracting $(RSYNC_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(RSYNC_ASSET)

$(RSYNC_ASSET):
	@rm -f $(RSYNC_ASSET)
	@echo "Fetching $(RSYNC_ASSET)..."
	@wget --quiet --show-progress $(RSYNC_ASSET_URL) -O $(RSYNC_ASSET)

$(RSYNC_OSS_CLEAN):
	@rm -rf $(RSYNC_DIR)

$(RSYNC_OSS_DISTCLEAN): $(RSYNC_OSS_CLEAN)
	@rm -rf $(RSYNC_ASSET)