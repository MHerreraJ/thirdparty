MOSQUITTO_RELEASES_URL=https://mosquitto.org/files/source
MOSQUITTO_VERSION:=2.0.22

MOSQUITTO_ASSET_NAME:=mosquitto-$(MOSQUITTO_VERSION).tar.gz
MOSQUITTO_ASSET:=$(FETCH_DIR)/$(MOSQUITTO_ASSET_NAME)
MOSQUITTO_ASSET_URL:=$(MOSQUITTO_RELEASES_URL)/$(MOSQUITTO_ASSET_NAME)

MOSQUITTO_DIR:=$(FETCH_DIR)/mosquitto-$(MOSQUITTO_VERSION)

mosquitto.depend:=$(call get_host_dep,cmake) openssl

MOSQUITTO_OSS_BUILD:=$(call build_oss,mosquitto)
MOSQUITTO_OSS_CLEAN:=$(call clean_oss,mosquitto)
MOSQUITTO_OSS_DISTCLEAN:=$(call distclean_oss,mosquitto)

HOST_CMAKE=$(call get_host_dep_dir,cmake)/bin/cmake

.PHONY: $(MOSQUITTO_OSS_BUILD) $(MOSQUITTO_OSS_CLEAN) $(MOSQUITTO_OSS_DISTCLEAN)

$(MOSQUITTO_OSS_BUILD): $(MOSQUITTO_DIR)
	@mkdir -p $(MOSQUITTO_DIR)/built
	@mkdir -p $(STAGE_DIR)
	cd $(MOSQUITTO_DIR)/built && \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(mosquitto.depend))" \
		$(HOST_CMAKE) $(MOSQUITTO_DIR) \
			-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
			-DBUILD_SHARED_LIBS=ON \
			-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
			-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
			-DCMAKE_VERBOSE_MAKEFILE=$(V)
			-DOPENSSL_ROOT_DIR=$(call get_dep_dir,openssl)

	@$(MAKE) -C $(MOSQUITTO_DIR)/built
	@$(MAKE) -C $(MOSQUITTO_DIR)/built install
	@rm -rf $(STAGE_DIR)/lib/cmake

$(MOSQUITTO_DIR): $(MOSQUITTO_ASSET)
	@echo "Extracting $(MOSQUITTO_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(MOSQUITTO_ASSET)

$(MOSQUITTO_ASSET):
	@rm -f $(MOSQUITTO_ASSET)
	@echo "Fetching $(MOSQUITTO_ASSET)..."
	@wget --quiet --show-progress $(MOSQUITTO_ASSET_URL) -O $(MOSQUITTO_ASSET)

$(MOSQUITTO_OSS_CLEAN):
	@rm -rf $(MOSQUITTO_DIR)

$(MOSQUITTO_OSS_DISTCLEAN): $(MOSQUITTO_OSS_CLEAN)
	@rm -rf $(MOSQUITTO_ASSET)