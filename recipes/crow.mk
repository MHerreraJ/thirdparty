
oss-build-$(OSS_CONFIG_CROW) += crow

CROW_RELEASES_URL=https://github.com/CrowCpp/Crow/archive/refs/tags
CROW_VERSION:=1.3.5

CROW_ASSET_NAME:=v$(CROW_VERSION).tar.gz
CROW_ASSET:=$(FETCH_DIR)/$(CROW_ASSET_NAME)
CROW_ASSET_URL:=$(CROW_RELEASES_URL)/$(CROW_ASSET_NAME)

CROW_DIR:=$(FETCH_DIR)/Crow-$(CROW_VERSION)


crow.depend:=$(call get_host_dep,cmake) asio

CROW_OSS_BUILD:=$(call build_oss,crow)
CROW_OSS_CLEAN:=$(call clean_oss,crow)
CROW_OSS_DISTCLEAN:=$(call distclean_oss,crow)

HOST_CMAKE=$(call get_host_dep_dir,cmake)/bin/cmake

.PHONY: $(CROW_OSS_BUILD) $(CROW_OSS_CLEAN) $(CROW_OSS_DISTCLEAN)

$(CROW_OSS_BUILD): $(CROW_DIR)
	@mkdir -p $(CROW_DIR)/built
	@mkdir -p $(STAGE_DIR)
	cd $(CROW_DIR)/built && \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(crow.depend))" \
		$(HOST_CMAKE) $(CROW_DIR) \
			-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
			-DCMAKE_BUILD_TYPE=Release \
			-DASIO_INCLUDE_DIR=$(call get_host_dep_dir,asio)/include \
			-DCROW_BUILD_EXAMPLES=OFF \
			-DCROW_BUILD_TESTS=OFF \
			-DCROW_BUILD_FUZZER=OFF \
			-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
			-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
			-DCMAKE_VERBOSE_MAKEFILE=$(V)

	@$(MAKE) -C $(CROW_DIR)/built
	@$(MAKE) -C $(CROW_DIR)/built install
	@rm -rf $(STAGE_DIR)/lib/cmake

$(CROW_DIR): $(CROW_ASSET)
	@echo "Extracting $(CROW_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(CROW_ASSET)

$(CROW_ASSET):
	@rm -f $(CROW_ASSET)
	@echo "Fetching $(CROW_ASSET)..."
	@wget --quiet --show-progress $(CROW_ASSET_URL) -O $(CROW_ASSET)

$(CROW_OSS_CLEAN):
	@rm -rf $(CROW_DIR)

$(CROW_OSS_DISTCLEAN): $(CROW_OSS_CLEAN)
	@rm -rf $(CROW_ASSET)