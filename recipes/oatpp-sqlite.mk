
oss-build-$(OSS_CONFIG_OATPP_SQLITE) += oatpp_sqlite
OATPP_SQLITE_RELEASES_URL=https://github.com/oatpp/oatpp-sqlite/archive/refs/tags
OATPP_SQLITE_VERSION:=1.3.0

OATPP_SQLITE_ASSET_NAME:=$(OATPP_SQLITE_VERSION).tar.gz
OATPP_SQLITE_ASSET:=$(FETCH_DIR)/oatpp-sqlite-$(OATPP_SQLITE_ASSET_NAME)
OATPP_SQLITE_ASSET_URL:=$(OATPP_SQLITE_RELEASES_URL)/$(OATPP_SQLITE_ASSET_NAME)

OATPP_SQLITE_DIR:=$(FETCH_DIR)/oatpp-sqlite-$(OATPP_SQLITE_VERSION)


oatpp_sqlite.depend:=$(call get_host_dep,cmake) oatpp sqlite

OATPP_SQLITE_OSS_BUILD:=$(call build_oss,oatpp_sqlite)
OATPP_SQLITE_OSS_CLEAN:=$(call clean_oss,oatpp_sqlite)
OATPP_SQLITE_OSS_DISTCLEAN:=$(call distclean_oss,oatpp_sqlite)

HOST_CMAKE=$(call get_host_dep_dir,cmake)/bin/cmake

.PHONY: $(OATPP_SQLITE_OSS_BUILD) $(OATPP_SQLITE_OSS_CLEAN) $(OATPP_SQLITE_OSS_DISTCLEAN)

$(OATPP_SQLITE_OSS_BUILD): $(OATPP_SQLITE_DIR)
	@mkdir -p $(OATPP_SQLITE_DIR)/built
	@mkdir -p $(STAGE_DIR)
	cd $(OATPP_SQLITE_DIR)/built && \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(oatpp_sqlite.depend))" \
		$(HOST_CMAKE) $(OATPP_SQLITE_DIR) \
			-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
			-DCMAKE_PREFIX_PATH=$(OSS_STAGE_DIR)/oatpp \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
			-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
			-DCMAKE_VERBOSE_MAKEFILE=$(V) \
			-DSQLite3_INCLUDE_DIR=$(call get_dep_dir,sqlite)/include \
			-DSQLite3_LIBRARY=$(call get_dep_dir,sqlite)/lib/libsqlite3.a

	@$(MAKE) -C $(OATPP_SQLITE_DIR)/built
	@$(MAKE) -C $(OATPP_SQLITE_DIR)/built install

	@cp -ar $(STAGE_DIR)/include/oatpp-1.3.0/oatpp-sqlite/oatpp-sqlite $(STAGE_DIR)/include/

	@rm -rf $(STAGE_DIR)/include/oatpp-1.3.0

	@mv $(STAGE_DIR)/lib/oatpp-1.3.0/* $(STAGE_DIR)/lib/
	@rm -rf $(STAGE_DIR)/lib/oatpp-1.3.0

	@rm -rf $(STAGE_DIR)/lib/cmake

$(OATPP_SQLITE_DIR): $(OATPP_SQLITE_ASSET)
	@echo "Extracting $(OATPP_SQLITE_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(OATPP_SQLITE_ASSET)

$(OATPP_SQLITE_ASSET):
	@rm -f $(OATPP_SQLITE_ASSET)
	@echo "Fetching $(OATPP_SQLITE_ASSET)..."
	@wget --quiet --show-progress $(OATPP_SQLITE_ASSET_URL) -O $(OATPP_SQLITE_ASSET)

$(OATPP_SQLITE_OSS_CLEAN):
	@rm -rf $(OATPP_SQLITE_DIR)

$(OATPP_SQLITE_OSS_DISTCLEAN): $(OATPP_SQLITE_OSS_CLEAN)
	@rm -rf $(OATPP_SQLITE_ASSET)