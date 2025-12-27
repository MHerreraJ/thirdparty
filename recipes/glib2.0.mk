oss-build-$(OSS_CONFIG_GLIB2_0) += glib2.0
GLIB2_0_RELEASES_URL=https://download.gnome.org/sources/glib/2.80
GLIB2_0_VERSION:=2.80.0

GLIB2_0_ASSET_NAME:=glib-2.80.0.tar.xz
GLIB2_0_ASSET:=$(FETCH_DIR)/$(GLIB2_0_ASSET_NAME)
GLIB2_0_ASSET_URL:=$(GLIB2_0_RELEASES_URL)/$(GLIB2_0_ASSET_NAME)

GLIB2_0_DIR:=$(FETCH_DIR)/glib-2.80.0

glib2.0.depend:=zlib

GLIB2_0_OSS_BUILD:=$(call build_oss,glib2.0)
GLIB2_0_OSS_INSTALL:=$(call install_oss,glib2.0)
GLIB2_0_OSS_CLEAN:=$(call clean_oss,glib2.0)
GLIB2_0_OSS_DISTCLEAN:=$(call distclean_oss,glib2.0)
.PHONY: $(GLIB2_0_OSS_BUILD) $(GLIB2_0_OSS_INSTALL) $(GLIB2_0_OSS_CLEAN) $(GLIB2_0_OSS_DISTCLEAN)

$(GLIB2_0_OSS_BUILD): $(GLIB2_0_DIR)
	@mkdir -p $(STAGE_DIR)
	@mkdir -p $(GLIB2_0_DIR)/_build/lib
	@mkdir -p $(GLIB2_0_DIR)/_build/include
	@cd  $(GLIB2_0_DIR) && \
		meson setup --cross-file $(MESON_CROSS_FILE) \
		--prefix=$(STAGE_DIR) \
		--default-library=static \
		--prefer-static \
		--pkg-config-path=$(call get_deps_pkgconfig,$(glib2.0.depend)) \
		$(GLIB2_0_DIR)/_build
	@meson compile -C $(GLIB2_0_DIR)/_build
	@meson install -C $(GLIB2_0_DIR)/_build


$(GLIB2_0_DIR): $(GLIB2_0_ASSET)
	@echo "Extracting $(GLIB2_0_ASSET)"
	@tar -C $(FETCH_DIR)/ -xf $(GLIB2_0_ASSET)

$(GLIB2_0_ASSET):
	@rm -f $(GLIB2_0_ASSET)
	@echo "Fetching $(GLIB2_0_ASSET)..."
	@wget --quiet --show-progress $(GLIB2_0_ASSET_URL) -O $(GLIB2_0_ASSET)

$(GLIB2_0_OSS_INSTALL):
	@echo "Skipping install for glib2.0"

$(GLIB2_0_OSS_CLEAN):
	@rm -rf $(GLIB2_0_DIR)

$(GLIB2_0_OSS_DISTCLEAN): $(GLIB2_0_OSS_CLEAN)
	@rm -rf $(GLIB2_0_ASSET)