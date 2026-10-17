oss-build-$(OSS_CONFIG_BROTLI) += brotli
BROTLI_RELEASES_URL=https://github.com/google/brotli/archive/refs/tags/
BROTLI_VERSION:=1.2.0

BROTLI_ASSET_NAME:=v$(BROTLI_VERSION).tar.gz
BROTLI_ASSET:=$(FETCH_DIR)/$(BROTLI_ASSET_NAME)
BROTLI_ASSET_URL:=$(BROTLI_RELEASES_URL)/$(BROTLI_ASSET_NAME)

BROTLI_DIR:=$(FETCH_DIR)/brotli-$(BROTLI_VERSION)


brotli.depend:=$(call get_host_dep,cmake)

BROTLI_OSS_BUILD:=$(call build_oss,brotli)
BROTLI_OSS_CLEAN:=$(call clean_oss,brotli)
BROTLI_OSS_DISTCLEAN:=$(call distclean_oss,brotli)

HOST_CMAKE=$(call get_host_dep_dir,cmake)/bin/cmake

.PHONY: $(BROTLI_OSS_BUILD) $(BROTLI_OSS_CLEAN) $(BROTLI_OSS_DISTCLEAN)

$(BROTLI_OSS_BUILD): $(BROTLI_DIR)
	@mkdir -p $(BROTLI_DIR)/built
	@mkdir -p $(STAGE_DIR)
	cd $(BROTLI_DIR)/built && \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(brotli.depend))" \
		$(HOST_CMAKE) $(BROTLI_DIR) \
			-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
			-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
			-DCMAKE_VERBOSE_MAKEFILE=$(V)

	@$(MAKE) -C $(BROTLI_DIR)/built
	@$(MAKE) -C $(BROTLI_DIR)/built install
	@rm -rf $(STAGE_DIR)/lib/cmake

$(BROTLI_DIR): $(BROTLI_ASSET)
	@echo "Extracting $(BROTLI_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(BROTLI_ASSET)

$(BROTLI_ASSET):
	@rm -f $(BROTLI_ASSET)
	@echo "Fetching $(BROTLI_ASSET)..."
	@wget --quiet --show-progress $(BROTLI_ASSET_URL) -O $(BROTLI_ASSET)

$(BROTLI_OSS_CLEAN):
	@rm -rf $(BROTLI_DIR)

$(BROTLI_OSS_DISTCLEAN): $(BROTLI_OSS_CLEAN)
	@rm -rf $(BROTLI_ASSET)