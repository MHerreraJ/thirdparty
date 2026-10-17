OATPP_RELEASES_URL=https://github.com/oatpp/oatpp/archive/refs/tags
OATPP_VERSION:=1.3.1

OATPP_ASSET_NAME:=$(OATPP_VERSION).tar.gz
OATPP_ASSET:=$(FETCH_DIR)/oatpp-$(OATPP_ASSET_NAME)
OATPP_ASSET_URL:=$(OATPP_RELEASES_URL)/$(OATPP_ASSET_NAME)

OATPP_DIR:=$(FETCH_DIR)/oatpp-$(OATPP_VERSION)


oatpp.depend:=$(call get_host_dep,cmake)

OATPP_OSS_BUILD:=$(call build_oss,oatpp)
OATPP_OSS_CLEAN:=$(call clean_oss,oatpp)
OATPP_OSS_DISTCLEAN:=$(call distclean_oss,oatpp)

HOST_CMAKE=$(call get_host_dep_dir,cmake)/bin/cmake

.PHONY: $(OATPP_OSS_BUILD) $(OATPP_OSS_CLEAN) $(OATPP_OSS_DISTCLEAN)

$(OATPP_OSS_BUILD): $(OATPP_DIR)
	@mkdir -p $(OATPP_DIR)/built
	@mkdir -p $(STAGE_DIR)
	cd $(OATPP_DIR)/built && \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(oatpp.depend))" \
		$(HOST_CMAKE) $(OATPP_DIR) \
			-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
			-DCMAKE_BUILD_TYPE=Release \
			-DOATPP_BUILD_TESTS=OFF \
			-DOATPP_SQLITE_AMALGAMATION=ON \
			-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
			-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
			-DCMAKE_VERBOSE_MAKEFILE=$(V)

	@$(MAKE) -C $(OATPP_DIR)/built
	@$(MAKE) -C $(OATPP_DIR)/built install
	@cp -ar $(STAGE_DIR)/include/oatpp-1.3.0/oatpp/oatpp $(STAGE_DIR)/include/
	@cp -ar $(STAGE_DIR)/include/oatpp-1.3.0/oatpp/oatpp-test $(STAGE_DIR)/include/
	@rm -rf $(STAGE_DIR)/include/oatpp-1.3.0

	@mv $(STAGE_DIR)/lib/oatpp-1.3.0/* $(STAGE_DIR)/lib/
	@rm -rf $(STAGE_DIR)/lib/oatpp-1.3.0

	@sed -i "s|include/oatpp-1.3.0/oatpp|include|g" $(STAGE_DIR)/lib/cmake/oatpp-1.3.0/*.cmake
	@sed -i "s|lib/oatpp-1.3.0/|lib/|g" $(STAGE_DIR)/lib/cmake/oatpp-1.3.0/*.cmake

$(OATPP_DIR): $(OATPP_ASSET)
	@echo "Extracting $(OATPP_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(OATPP_ASSET)

$(OATPP_ASSET):
	@rm -f $(OATPP_ASSET)
	@echo "Fetching $(OATPP_ASSET)..."
	@wget --quiet --show-progress $(OATPP_ASSET_URL) -O $(OATPP_ASSET)

$(OATPP_OSS_CLEAN):
	@rm -rf $(OATPP_DIR)

$(OATPP_OSS_DISTCLEAN): $(OATPP_OSS_CLEAN)
	@rm -rf $(OATPP_ASSET)