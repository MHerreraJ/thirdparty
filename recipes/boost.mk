oss-build-$(OSS_CONFIG_BOOST) += boost
BOOST_VERSION:=1.92.0
BOOST_RELEASE_URL=https://archives.boost.io/release/$(BOOST_VERSION)/source

BOOST_ASSET_BASE_NAME=boost_$(subst .,_,$(BOOST_VERSION))
BOOST_ASSET_NAME=$(BOOST_ASSET_BASE_NAME).tar.gz
BOOST_ASSET=$(FETCH_DIR)/$(BOOST_ASSET_NAME)
BOOST_ASSET_URL:=$(BOOST_RELEASE_URL)/$(BOOST_ASSET_NAME)

BOOST_DIR=$(FETCH_DIR)/$(BOOST_ASSET_BASE_NAME)

boost.depend:=

BOOST_OSS_BUILD:=$(call build_oss,boost)
BOOST_OSS_CLEAN:=$(call clean_oss,boost)
BOOST_OSS_DISTCLEAN:=$(call distclean_oss,boost)
.PHONY: $(BOOST_OSS_BUILD) $(BOOST_OSS_CLEAN) $(BOOST_OSS_DISTCLEAN)

$(BOOST_OSS_BUILD): $(BOOST_DIR)
	@mkdir -p $(STAGE_DIR)
	@echo "using gcc : : $(CROSS_COMPILE)g++ ;" > $(BOOST_DIR)/user-config.jam
	cd $(BOOST_DIR) && ./bootstrap.sh \
 		--prefix=$(STAGE_DIR) && \
		./b2 install

$(BOOST_DIR): $(BOOST_ASSET)
	@echo "Extracting $(BOOST_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(BOOST_ASSET)

$(BOOST_ASSET):
	@rm -f $(BOOST_ASSET)
	@echo "Fetching $(BOOST_ASSET)..."
	@wget --quiet --show-progress $(BOOST_ASSET_URL) -O $(BOOST_ASSET)


$(BOOST_OSS_CLEAN):
	@rm -rf $(BOOST_DIR)

$(BOOST_OSS_DISTCLEAN): $(BOOST_OSS_CLEAN)
	@rm -rf $(BOOST_ASSET)

