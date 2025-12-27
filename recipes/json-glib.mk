oss-build-$(OSS_CONFIG_JSON_GLIB) += json-glib
JSON_GLIB_RELEASES_URL=https://download.gnome.org/sources/json-glib/1.6
JSON_GLIB_VERSION:=1.6.6

JSON_GLIB_ASSET_NAME:=json-glib-1.6.6.tar.xz
JSON_GLIB_ASSET:=$(FETCH_DIR)/$(JSON_GLIB_ASSET_NAME)
JSON_GLIB_ASSET_URL:=$(JSON_GLIB_RELEASES_URL)/$(JSON_GLIB_ASSET_NAME)

JSON_GLIB_DIR:=$(FETCH_DIR)/json-glib-1.6.6

# json-glib.depend:=glib2.0

JSON_GLIB_OSS_BUILD:=$(call build_oss,json-glib)
JSON_GLIB_OSS_INSTALL:=$(call install_oss,json-glib)
JSON_GLIB_OSS_CLEAN:=$(call clean_oss,json-glib)
JSON_GLIB_OSS_DISTCLEAN:=$(call distclean_oss,json-glib)
.PHONY: $(JSON_GLIB_OSS_BUILD) $(JSON_GLIB_OSS_INSTALL) $(JSON_GLIB_OSS_CLEAN) $(JSON_GLIB_OSS_DISTCLEAN)

$(JSON_GLIB_OSS_BUILD): $(JSON_GLIB_DIR)
	@mkdir -p $(JSON_GLIB_DIR)/built
	@mkdir -p $(JSON_GLIB_DIR)/_build/lib
	@mkdir -p $(JSON_GLIB_DIR)/_build/include
	cd  $(JSON_GLIB_DIR) && \
		meson setup --cross-file $(MESON_CROSS_FILE) \
		--prefix=$(JSON_GLIB_DIR)/built \
		--default-library=static \
		--prefer-static \
		--pkg-config-path="$(call get_deps_pkgconfig,$(json-glib.depend))" \
		$(JSON_GLIB_DIR)/_build
	@meson compile -C $(JSON_GLIB_DIR)/_build
	@meson install -C $(JSON_GLIB_DIR)/_build


$(JSON_GLIB_DIR): $(JSON_GLIB_ASSET)
	@echo "Extracting $(JSON_GLIB_ASSET)"
	@tar -C $(FETCH_DIR)/ -xf $(JSON_GLIB_ASSET)

$(JSON_GLIB_ASSET):
	@rm -f $(JSON_GLIB_ASSET)
	@echo "Fetching $(JSON_GLIB_ASSET)..."
	@wget --quiet --show-progress $(JSON_GLIB_ASSET_URL) -O $(JSON_GLIB_ASSET)

$(JSON_GLIB_OSS_INSTALL):
	@mkdir -p $(DEST_DIR)/lib
	@mkdir -p $(DEST_DIR)/include

	@rsync -a $(JSON_GLIB_DIR)/built/lib $(DEST_DIR)/
	@rsync -a $(JSON_GLIB_DIR)/built/include $(DEST_DIR)/
	@touch $(DEST_DIR)/.noinstall

$(JSON_GLIB_OSS_CLEAN):
	@rm -rf $(JSON_GLIB_DIR)

$(JSON_GLIB_OSS_DISTCLEAN): $(JSON_GLIB_OSS_CLEAN)
	@rm -rf $(JSON_GLIB_ASSET)