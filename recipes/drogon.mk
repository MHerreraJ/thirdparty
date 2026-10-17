oss-build-$(OSS_CONFIG_DROGON) += drogon
DROGON_URL=https://github.com/drogonframework/drogon.git
DROGON_VERSION:=1.9.14

DROGON_DIR:=$(FETCH_DIR)/drogon-$(DROGON_VERSION)

drogon.depend:=$(call get_host_dep,cmake) jsoncpp openssl brotli

DROGON_OSS_BUILD:=$(call build_oss,drogon)
DROGON_OSS_CLEAN:=$(call clean_oss,drogon)
DROGON_OSS_DISTCLEAN:=$(call distclean_oss,drogon)

HOST_CMAKE=$(call get_host_dep_dir,cmake)/bin/cmake

.PHONY: $(DROGON_OSS_BUILD) $(DROGON_OSS_CLEAN) $(DROGON_OSS_DISTCLEAN)

$(DROGON_OSS_BUILD): $(DROGON_DIR)
	@mkdir -p $(DROGON_DIR)/built
	@mkdir -p $(STAGE_DIR)
	cd $(DROGON_DIR)/built && \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(drogon.depend))" \
		$(HOST_CMAKE) $(DROGON_DIR) \
			-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
			-DCMAKE_BUILD_TYPE=Release \
			-DBUILD_EXAMPLES=OFF \
			-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
			-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
			-DCMAKE_VERBOSE_MAKEFILE=$(V) \
			-DJSONCPP_INCLUDE_DIRS=$(call get_dep_dir,jsoncpp)/include \
			-DJSONCPP_LIBRARIES=$(call get_dep_dir,jsoncpp)/lib/libjsoncpp.a

	@$(MAKE) -C $(DROGON_DIR)/built
	@$(MAKE) -C $(DROGON_DIR)/built install
	@rm -rf $(STAGE_DIR)/lib/cmake

$(DROGON_DIR): $(DROGON_DIR)/.git

$(DROGON_DIR)/.git:
	@echo "Cloning $(DROGON_URL)..."
	@git clone --recurse-submodules --branch v$(DROGON_VERSION) --depth 1 $(DROGON_URL) $(DROGON_DIR)

$(DROGON_OSS_CLEAN):
	@rm -rf $(DROGON_DIR)

$(DROGON_OSS_DISTCLEAN): $(DROGON_OSS_CLEAN)
	@rm -rf $(DROGON_ASSET)