oss-build-$(OSS_CONFIG_ZLIB) += zlib
ZLIB_RELEASES_URL=https://www.zlib.net
ZLIB_VERSION:=1.3.1

ZLIB_ASSET_NAME:=zlib-1.3.1.tar.gz
ZLIB_ASSET:=$(FETCH_DIR)/$(ZLIB_ASSET_NAME)
ZLIB_ASSET_URL:=$(ZLIB_RELEASES_URL)/$(ZLIB_ASSET_NAME)

ZLIB_DIR:=$(FETCH_DIR)/zlib-1.3.1

ifeq ($(V),1)
ZLIB_BUILD_VERBOSE=--disable-silent-rules
else
ZLIB_BUILD_VERBOSE=--enable-silent-rules
endif

zlib.depend:=

ZLIB_OSS_BUILD:=$(call build_oss,zlib)
ZLIB_OSS_INSTALL:=$(call install_oss,zlib)
ZLIB_OSS_CLEAN:=$(call clean_oss,zlib)
ZLIB_OSS_DISTCLEAN:=$(call distclean_oss,zlib)
.PHONY: $(ZLIB_OSS_BUILD) $(ZLIB_OSS_INSTALL) $(ZLIB_OSS_CLEAN) $(ZLIB_OSS_DISTCLEAN)

$(ZLIB_OSS_BUILD): $(ZLIB_DIR)
	@mkdir -p $(STAGE_DIR)
	cd $(ZLIB_DIR) && CHOST=$(CROSS_COMPILE:-=) CFLAGS="-fPIC" ./configure \
			--prefix=$(STAGE_DIR) \
			--static

	@$(MAKE) -C $(ZLIB_DIR) 
	@$(MAKE) -C $(ZLIB_DIR) install

$(ZLIB_DIR): $(ZLIB_ASSET)
	@echo "Extracting $(ZLIB_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(ZLIB_ASSET)

$(ZLIB_ASSET):
	@rm -f $(ZLIB_ASSET)
	@echo "Fetching $(ZLIB_ASSET)..."
	@wget --quiet --show-progress $(ZLIB_ASSET_URL) -O $(ZLIB_ASSET)

$(ZLIB_OSS_INSTALL):
	@echo "Skipping install for zlib"

$(ZLIB_OSS_CLEAN):
	@rm -rf $(ZLIB_DIR)

$(ZLIB_OSS_DISTCLEAN): $(ZLIB_OSS_CLEAN)
	@rm -rf $(ZLIB_ASSET)