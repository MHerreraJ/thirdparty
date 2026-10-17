CMAKE_RELEASES_URL=https://github.com/Kitware/CMake/releases/download
CMAKE_VERSION:=v3.31.5

CMAKE_ASSET_NAME:=cmake-3.31.5.tar.gz
CMAKE_ASSET:=$(FETCH_DIR)/$(CMAKE_ASSET_NAME)
CMAKE_ASSET_URL:=$(CMAKE_RELEASES_URL)/$(CMAKE_VERSION)/$(CMAKE_ASSET_NAME)

CMAKE_DIR:=$(FETCH_DIR)/cmake-3.31.5

ifeq ($(V),1)
CMAKE_BUILD_VERBOSE=--verbose
else
CMAKE_BUILD_VERBOSE=
endif

cmake.depend:=

CMAKE_OSS_BUILD:=$(call build_oss,cmake)
CMAKE_OSS_INSTALL:=$(call install_oss,cmake)
CMAKE_OSS_CLEAN:=$(call clean_oss,cmake)
CMAKE_OSS_DISTCLEAN:=$(call distclean_oss,cmake)
.PHONY: $(CMAKE_OSS_BUILD) $(CMAKE_OSS_INSTALL) $(CMAKE_OSS_CLEAN) $(CMAKE_OSS_DISTCLEAN)

$(CMAKE_OSS_BUILD): $(CMAKE_DIR)
	@mkdir -p $(STAGE_DIR)
	+cd $(CMAKE_DIR) && CHOST=$(CROSS_COMPILE:-=) CFLAGS="-fPIC" \
		./configure \
			--prefix=$(STAGE_DIR) \
			--no-system-libs \
			--no-qt-gui \
			--no-debugger \
			$(CMAKE_BUILD_VERBOSE) \
			CC="$(CROSS_COMPILE)gcc" \
			CXX="$(CROSS_COMPILE)g++" 
	@$(MAKE) -C $(CMAKE_DIR)
	@$(MAKE) -C $(CMAKE_DIR) install

$(CMAKE_DIR): $(CMAKE_ASSET)
	@echo "Extracting $(CMAKE_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(CMAKE_ASSET)

$(CMAKE_ASSET):
	@rm -f $(CMAKE_ASSET)
	@echo "Fetching $(CMAKE_ASSET)..."
	@wget --quiet --show-progress $(CMAKE_ASSET_URL) -O $(CMAKE_ASSET)

$(CMAKE_OSS_INSTALL):
	@echo "Skipping install for cmake"

$(CMAKE_OSS_CLEAN):
	@rm -rf $(CMAKE_DIR)

$(CMAKE_OSS_DISTCLEAN): $(CMAKE_OSS_CLEAN)
	@rm -rf $(CMAKE_ASSET)
