oss-build-$(OSS_CONFIG_ASIO) += asio
ASIO_VERSION:=1.38.2
ASIO_RELEASE_URL=https://sourceforge.net/projects/asio/files/asio/$(ASIO_VERSION)%20%28Stable%29/

ASIO_ASSET_BASE_NAME=asio-$(ASIO_VERSION)
ASIO_ASSET_NAME=$(ASIO_ASSET_BASE_NAME).tar.gz
ASIO_ASSET=$(FETCH_DIR)/$(ASIO_ASSET_NAME)
ASIO_ASSET_URL:=$(ASIO_RELEASE_URL)/$(ASIO_ASSET_NAME)

ASIO_DIR=$(FETCH_DIR)/$(ASIO_ASSET_BASE_NAME)

asio.depend:=

ASIO_OSS_BUILD:=$(call build_oss,asio)
ASIO_OSS_CLEAN:=$(call clean_oss,asio)
ASIO_OSS_DISTCLEAN:=$(call distclean_oss,asio)
.PHONY: $(ASIO_OSS_BUILD) $(ASIO_OSS_CLEAN) $(ASIO_OSS_DISTCLEAN)

$(ASIO_OSS_BUILD): $(ASIO_DIR)
	@mkdir -p $(STAGE_DIR)
	cd $(ASIO_DIR) && ./configure \
 		--prefix=$(STAGE_DIR) \
 		--host=$(HOST) \
		--enable-static=no \
		--enable-shared=yes 

	@$(MAKE) -C $(ASIO_DIR)
	@$(MAKE) -C $(ASIO_DIR) install

$(ASIO_DIR): $(ASIO_ASSET)
	@echo "Extracting $(ASIO_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(ASIO_ASSET)

$(ASIO_ASSET):
	@rm -f $(ASIO_ASSET)
	@echo "Fetching $(ASIO_ASSET)..."
	@wget --quiet --show-progress $(ASIO_ASSET_URL) -O $(ASIO_ASSET)


$(ASIO_OSS_CLEAN):
	@rm -rf $(ASIO_DIR)

$(ASIO_OSS_DISTCLEAN): $(ASIO_OSS_CLEAN)
	@rm -rf $(ASIO_ASSET)

