oss-build-$(OSS_CONFIG_POCO) += poco

POCO_RELEASES_URL=https://github.com/pocoproject/poco/archive/refs/tags
POCO_VERSION:=1.14.1

POCO_ASSET_NAME:=poco-1.14.1-release.tar.gz
POCO_ASSET:=$(FETCH_DIR)/$(POCO_ASSET_NAME)
POCO_ASSET_URL:=$(POCO_RELEASES_URL)/$(POCO_ASSET_NAME)

POCO_DIR:=$(FETCH_DIR)/poco-poco-1.14.1-release

ifeq ($(V),1)
POCO_BUILD_VERBOSE=--disable-silent-rules
else
POCO_BUILD_VERBOSE=--enable-silent-rules
endif

poco.depend:=$(call get_host_dep,cmake) openssl

POCO_OSS_BUILD:=$(call build_oss,poco)
POCO_OSS_CLEAN:=$(call clean_oss,poco)
POCO_OSS_DISTCLEAN:=$(call distclean_oss,poco)

HOST_CMAKE=$(call get_host_dep_dir,cmake)/bin/cmake

.PHONY: $(POCO_OSS_BUILD) $(POCO_OSS_CLEAN) $(POCO_OSS_DISTCLEAN)

$(POCO_OSS_BUILD): $(POCO_DIR)
	@mkdir -p $(POCO_DIR)/built
	@mkdir -p $(STAGE_DIR)
	cd $(POCO_DIR)/built && \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(poco.depend))" \
		$(HOST_CMAKE) $(POCO_DIR) \
			-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
			-DBUILD_SHARED_LIBS=ON \
			-DBUILD_EXAMPLES=OFF \
			-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
			-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
			-DCMAKE_C_FLAGS="-Os" \
			-DCMAKE_CXX_FLAGS="-Os" \
			-DCMAKE_VERBOSE_MAKEFILE=$(V)
			-DOPENSSL_ROOT_DIR=$(call get_dep_dir,openssl)

	@$(MAKE) -C $(POCO_DIR)/built
	@$(MAKE) -C $(POCO_DIR)/built install
	@rm -rf $(STAGE_DIR)/lib/cmake

$(POCO_DIR): $(POCO_ASSET)
	@echo "Extracting $(POCO_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(POCO_ASSET)

$(POCO_ASSET):
	@rm -f $(POCO_ASSET)
	@echo "Fetching $(POCO_ASSET)..."
	@wget --quiet --show-progress $(POCO_ASSET_URL) -O $(POCO_ASSET)

$(POCO_OSS_CLEAN):
	@rm -rf $(POCO_DIR)

$(POCO_OSS_DISTCLEAN): $(POCO_OSS_CLEAN)
	@rm -rf $(POCO_ASSET)