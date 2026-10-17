LIBTASN1_RELEASES_URL=https://mirrors.ocf.berkeley.edu/gnu/libtasn1/
LIBTASN1_VERSION:=4.19.0

LIBTASN1_ASSET_NAME:=libtasn1-4.19.0.tar.gz
LIBTASN1_ASSET:=$(FETCH_DIR)/$(LIBTASN1_ASSET_NAME)
LIBTASN1_ASSET_URL:=$(LIBTASN1_RELEASES_URL)/$(LIBTASN1_ASSET_NAME)

LIBTASN1_DIR:=$(FETCH_DIR)/libtasn1-4.19.0


libtasn1.depend:=

LIBTASN1_OSS_BUILD:=$(call build_oss,libtasn1)
LIBTASN1_OSS_INSTALL:=$(call install_oss,libtasn1)
LIBTASN1_OSS_CLEAN:=$(call clean_oss,libtasn1)
LIBTASN1_OSS_DISTCLEAN:=$(call distclean_oss,libtasn1)
.PHONY: $(LIBTASN1_OSS_BUILD) $(LIBTASN1_OSS_INSTALL) $(LIBTASN1_OSS_CLEAN) $(LIBTASN1_OSS_DISTCLEAN)

$(LIBTASN1_OSS_BUILD): $(LIBTASN1_DIR)
	@mkdir -p $(STAGE_DIR)
	@cd  $(LIBTASN1_DIR) && \
		./configure \
		--prefix=$(STAGE_DIR) \
		--host=$(HOST) \
		--enable-static \
		--enable-shared=no \
		--disable-doc \
		--enable-gtk-doc-html=no
	@$(MAKE) -C $(LIBTASN1_DIR) 
	@$(MAKE) -C $(LIBTASN1_DIR) install


$(LIBTASN1_DIR): $(LIBTASN1_ASSET)
	@echo "Extracting $(LIBTASN1_ASSET)"
	@tar -C $(FETCH_DIR)/ -xf $(LIBTASN1_ASSET)

$(LIBTASN1_ASSET):
	@rm -f $(LIBTASN1_ASSET)
	@echo "Fetching $(LIBTASN1_ASSET)..."
	@wget --quiet --show-progress $(LIBTASN1_ASSET_URL) -O $(LIBTASN1_ASSET)

$(LIBTASN1_OSS_INSTALL):
	@echo "Skipping install for libtasn1"

$(LIBTASN1_OSS_CLEAN):
	@rm -rf $(LIBTASN1_DIR)

$(LIBTASN1_OSS_DISTCLEAN): $(LIBTASN1_OSS_CLEAN)
	@rm -rf $(LIBTASN1_ASSET)