
JSONCPP_RELEASES_URL=https://github.com/open-source-parsers/jsoncpp/archive/refs/tags
JSONCPP_VERSION:=1.9.8

JSONCPP_ASSET_NAME:=$(JSONCPP_VERSION).tar.gz
JSONCPP_ASSET:=$(FETCH_DIR)/$(JSONCPP_ASSET_NAME)
JSONCPP_ASSET_URL:=$(JSONCPP_RELEASES_URL)/$(JSONCPP_ASSET_NAME)

JSONCPP_DIR:=$(FETCH_DIR)/jsoncpp-$(JSONCPP_VERSION)


jsoncpp.depend:=$(call get_host_dep,cmake)

JSONCPP_OSS_BUILD:=$(call build_oss,jsoncpp)
JSONCPP_OSS_CLEAN:=$(call clean_oss,jsoncpp)
JSONCPP_OSS_DISTCLEAN:=$(call distclean_oss,jsoncpp)

HOST_CMAKE=$(call get_host_dep_dir,cmake)/bin/cmake

.PHONY: $(JSONCPP_OSS_BUILD) $(JSONCPP_OSS_CLEAN) $(JSONCPP_OSS_DISTCLEAN)

$(JSONCPP_OSS_BUILD): $(JSONCPP_DIR)
	@mkdir -p $(JSONCPP_DIR)/built
	@mkdir -p $(STAGE_DIR)
	cd $(JSONCPP_DIR)/built && \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(jsoncpp.depend))" \
		$(HOST_CMAKE) $(JSONCPP_DIR) \
			-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
			-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
			-DCMAKE_VERBOSE_MAKEFILE=$(V)

	@$(MAKE) -C $(JSONCPP_DIR)/built
	@$(MAKE) -C $(JSONCPP_DIR)/built install
	@rm -rf $(STAGE_DIR)/lib/cmake

$(JSONCPP_DIR): $(JSONCPP_ASSET)
	@echo "Extracting $(JSONCPP_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(JSONCPP_ASSET)

$(JSONCPP_ASSET):
	@rm -f $(JSONCPP_ASSET)
	@echo "Fetching $(JSONCPP_ASSET)..."
	@wget --quiet --show-progress $(JSONCPP_ASSET_URL) -O $(JSONCPP_ASSET)

$(JSONCPP_OSS_CLEAN):
	@rm -rf $(JSONCPP_DIR)

$(JSONCPP_OSS_DISTCLEAN): $(JSONCPP_OSS_CLEAN)
	@rm -rf $(JSONCPP_ASSET)