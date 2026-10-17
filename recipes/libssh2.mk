LIBSSH2_RELEASE_URL=https://libssh2.org/download/
LIBSSH2_VERSION:=libssh2-1.11.1

LIBSSH2_ASSET_BASE_NAME=libssh2-1.11.1
LIBSSH2_ASSET_NAME=$(LIBSSH2_ASSET_BASE_NAME).tar.gz
LIBSSH2_ASSET=$(FETCH_DIR)/$(LIBSSH2_ASSET_NAME)
LIBSSH2_ASSET_URL:=$(LIBSSH2_RELEASE_URL)/$(LIBSSH2_ASSET_NAME)

LIBSSH2_DIR=$(FETCH_DIR)/$(LIBSSH2_VERSION)

libssh2.depend:=openssl

LIBSSH2_OSS_BUILD:=$(call build_oss,libssh2)
LIBSSH2_OSS_CLEAN:=$(call clean_oss,libssh2)
LIBSSH2_OSS_DISTCLEAN:=$(call distclean_oss,libssh2)
.PHONY: $(LIBSSH2_OSS_BUILD) $(LIBSSH2_OSS_CLEAN) $(LIBSSH2_OSS_DISTCLEAN)

$(LIBSSH2_OSS_BUILD): $(LIBSSH2_DIR)
	@mkdir -p $(STAGE_DIR)
	cd $(LIBSSH2_DIR) && ./configure \
 		--prefix=$(STAGE_DIR) \
 		--host=$(HOST) \
		--enable-static=no \
		--enable-shared=yes \
		--with-crypto=openssl \
		--with-libssl-prefix=$(call get_dep_dir,openssl)
	@$(MAKE) -C $(LIBSSH2_DIR)
	@$(MAKE) -C $(LIBSSH2_DIR) install

$(LIBSSH2_DIR): $(LIBSSH2_ASSET)
	@echo "Extracting $(LIBSSH2_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(LIBSSH2_ASSET)

$(LIBSSH2_ASSET):
	@rm -f $(LIBSSH2_ASSET)
	@echo "Fetching $(LIBSSH2_ASSET)..."
	@wget --quiet --show-progress $(LIBSSH2_ASSET_URL) -O $(LIBSSH2_ASSET)


$(LIBSSH2_OSS_CLEAN):
	@rm -rf $(LIBSSH2_DIR)

$(LIBSSH2_OSS_DISTCLEAN): $(LIBSSH2_OSS_CLEAN)
	@rm -rf $(LIBSSH2_ASSET)

