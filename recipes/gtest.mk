GTEST_RELEASES_URL=https://github.com/google/googletest/archive/refs/tags
GTEST_VERSION:=1.12.0

GTEST_ASSET_NAME:=release-1.12.0.tar.gz
GTEST_ASSET:=$(FETCH_DIR)/$(GTEST_ASSET_NAME)
GTEST_ASSET_URL:=$(GTEST_RELEASES_URL)/$(GTEST_ASSET_NAME)

GTEST_DIR:=$(FETCH_DIR)/googletest-release-1.12.0

ifeq ($(V),1)
GTEST_BUILD_VERBOSE=--disable-silent-rules
else
GTEST_BUILD_VERBOSE=--enable-silent-rules
endif

gtest.depend:=

GTEST_OSS_BUILD:=$(call build_oss,gtest)
GTEST_OSS_CLEAN:=$(call clean_oss,gtest)
GTEST_OSS_DISTCLEAN:=$(call distclean_oss,gtest)

.PHONY: $(GTEST_OSS_BUILD) $(GTEST_OSS_CLEAN) $(GTEST_OSS_DISTCLEAN)

$(GTEST_OSS_BUILD): $(GTEST_DIR)
	@mkdir -p $(GTEST_DIR)/built
	@mkdir -p $(STAGE_DIR)
	cd $(GTEST_DIR)/built && \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(gtest.depend))" \
		cmake $(GTEST_DIR) \
			-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
			-DBUILD_SHARED_LIBS=OFF \
			-DBUILD_GMOCK=OFF \
			-DBUILD_GTEST=ON \
			-DBUILD_EXAMPLES=OFF \
			-DBUILD_TESTING=ON \
			-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
			-DCMAKE_CXX_COMPILER=$(CROSS_COMPILE)g++ \
			-DCMAKE_C_FLAGS="-Os" \
			-DCMAKE_CXX_FLAGS="-Os" \
			-DCMAKE_VERBOSE_MAKEFILE=$(V)

	@$(MAKE) -C $(GTEST_DIR)/built
	@$(MAKE) -C $(GTEST_DIR)/built install
#Patch pkg-configs 
	
	@rm -rf $(STAGE_DIR)/lib/cmake

$(GTEST_DIR): $(GTEST_ASSET)
	@echo "Extracting $(GTEST_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(GTEST_ASSET)

$(GTEST_ASSET):
	@rm -f $(GTEST_ASSET)
	@echo "Fetching $(GTEST_ASSET)..."
	@wget --quiet --show-progress $(GTEST_ASSET_URL) -O $(GTEST_ASSET)

$(GTEST_OSS_CLEAN):
	@rm -rf $(GTEST_DIR)

$(GTEST_OSS_DISTCLEAN): $(GTEST_OSS_CLEAN)
	@rm -rf $(GTEST_ASSET)