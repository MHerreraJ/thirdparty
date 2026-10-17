OATPP_SWAGGER_RELEASES_URL=https://github.com/oatpp/oatpp-swagger/archive/refs/tags
OATPP_SWAGGER_VERSION:=1.3.1

OATPP_SWAGGER_ASSET_NAME:=$(OATPP_SWAGGER_VERSION).tar.gz
OATPP_SWAGGER_ASSET:=$(FETCH_DIR)/oatpp-swagger-$(OATPP_SWAGGER_ASSET_NAME)
OATPP_SWAGGER_ASSET_URL:=$(OATPP_SWAGGER_RELEASES_URL)/$(OATPP_SWAGGER_ASSET_NAME)

OATPP_SWAGGER_DIR:=$(FETCH_DIR)/oatpp-swagger-$(OATPP_SWAGGER_VERSION)


oatpp-swagger.depend:=$(call get_host_dep,cmake) oatpp

OATPP_SWAGGER_OSS_BUILD:=$(call build_oss,oatpp-swagger)
OATPP_SWAGGER_OSS_CLEAN:=$(call clean_oss,oatpp-swagger)
OATPP_SWAGGER_OSS_DISTCLEAN:=$(call distclean_oss,oatpp-swagger)

HOST_CMAKE=$(call get_host_dep_dir,cmake)/bin/cmake

.PHONY: $(OATPP_SWAGGER_OSS_BUILD) $(OATPP_SWAGGER_OSS_CLEAN) $(OATPP_SWAGGER_OSS_DISTCLEAN)

$(OATPP_SWAGGER_OSS_BUILD): $(OATPP_SWAGGER_DIR)
	@mkdir -p $(OATPP_SWAGGER_DIR)/built
	@mkdir -p $(STAGE_DIR)
	cd $(OATPP_SWAGGER_DIR)/built && \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(oatpp-swagger.depend))" \
		$(HOST_CMAKE) $(OATPP_SWAGGER_DIR) \
			-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
			-DCMAKE_PREFIX_PATH=$(OSS_STAGE_DIR)/oatpp \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
			-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
			-DCMAKE_VERBOSE_MAKEFILE=$(V)

	@$(MAKE) -C $(OATPP_SWAGGER_DIR)/built
	@$(MAKE) -C $(OATPP_SWAGGER_DIR)/built install

	@cp -ar $(STAGE_DIR)/include/oatpp-1.3.0/oatpp-swagger/oatpp-swagger $(STAGE_DIR)/include/
	@cp -ar $(STAGE_DIR)/include/oatpp-1.3.0/bin/oatpp-swagger/res $(STAGE_DIR)/

	@rm -rf $(STAGE_DIR)/include/oatpp-1.3.0

	@mv $(STAGE_DIR)/lib/oatpp-1.3.0/* $(STAGE_DIR)/lib/
	@rm -rf $(STAGE_DIR)/lib/oatpp-1.3.0

	@rm -rf $(STAGE_DIR)/lib/cmake

$(OATPP_SWAGGER_DIR): $(OATPP_SWAGGER_ASSET)
	@echo "Extracting $(OATPP_SWAGGER_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(OATPP_SWAGGER_ASSET)

$(OATPP_SWAGGER_ASSET):
	@rm -f $(OATPP_SWAGGER_ASSET)
	@echo "Fetching $(OATPP_SWAGGER_ASSET)..."
	@wget --quiet --show-progress $(OATPP_SWAGGER_ASSET_URL) -O $(OATPP_SWAGGER_ASSET)

$(OATPP_SWAGGER_OSS_CLEAN):
	@rm -rf $(OATPP_SWAGGER_DIR)

$(OATPP_SWAGGER_OSS_DISTCLEAN): $(OATPP_SWAGGER_OSS_CLEAN)
	@rm -rf $(OATPP_SWAGGER_ASSET)