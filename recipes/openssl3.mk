OPENSSL3_RELEASES_URL=https://github.com/openssl/openssl/releases/download
OPENSSL3_VERSION:=openssl-3.0.13

OPENSSL3_ASSET_NAME:=$(OPENSSL3_VERSION).tar.gz
OPENSSL3_ASSET:=$(FETCH_DIR)/$(OPENSSL3_ASSET_NAME)
OPENSSL3_ASSET_URL:=$(OPENSSL3_RELEASES_URL)/$(OPENSSL3_VERSION)/$(OPENSSL3_ASSET_NAME)
OPENSSL3_ASSET_SHA256:=88525753f79d3bec27d2fa7c66aa0b92b3aa9498dafd93d7cfa4b3780cdae313

OPENSSL3_DIR:=$(FETCH_DIR)/$(OPENSSL3_VERSION)

openssl3.depend:=

OPENSSL3_OSS_BUILD:=$(call build_oss,openssl3)
OPENSSL3_OSS_INSTALL:=$(call install_oss,openssl3)
OPENSSL3_OSS_CLEAN:=$(call clean_oss,openssl3)
OPENSSL3_OSS_DISTCLEAN:=$(call distclean_oss,openssl3)

OPENSSL3_BUILD_SHARED_FLAG?=shared

ifeq ($(OSS_CONFIG_PREFER_STATIC_LIB),y)
OPENSSL3_BUILD_SHARED_FLAG=no-pic
endif


.PHONY: $(OPENSSL3_OSS_BUILD) $(OPENSSL3_OSS_CLEAN) $(OPENSSL3_OSS_DISTCLEAN)

$(OPENSSL3_OSS_BUILD): $(OPENSSL3_DIR)
	@mkdir -p $(STAGE_DIR)
	cd $(OPENSSL3_DIR) && ./Configure linux-$(ARCH) \
		$(OPENSSL3_BUILD_SHARED_FLAG) \
		--prefix=/ \
		--openssldir=/etc/ssl \
		--libdir=lib \
		--cross-compile-prefix=$(CROSS_COMPILE) \
		--release \
		-Os \
		no-tests
	@sed -i 's:INSTALLTOP=/:INSTALLTOP=:' $(OPENSSL3_DIR)/Makefile
	@$(MAKE) -C $(OPENSSL3_DIR)
	@$(MAKE) -C $(OPENSSL3_DIR) install_sw  INSTALLTOP="$(STAGE_DIR)"

$(OPENSSL3_DIR): $(OPENSSL3_ASSET)
	@echo "Extracting $(OPENSSL3_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(OPENSSL3_ASSET)

$(OPENSSL3_ASSET):
	@rm -f $(OPENSSL3_ASSET)
	@echo "Fetching $(OPENSSL3_ASSET)..."
	@wget --quiet --show-progress $(OPENSSL3_ASSET_URL) -O $(OPENSSL3_ASSET)
	@echo "$(OPENSSL3_ASSET_SHA256) $(OPENSSL3_ASSET)" | sha256sum -c --quiet

$(OPENSSL3_OSS_CLEAN):
	@echo "Cleaning $(OPENSSL3_DIR)"
	@rm -rf $(OPENSSL3_DIR)

$(OPENSSL3_OSS_DISTCLEAN): $(OPENSSL3_OSS_CLEAN)
	@rm -rf $(OPENSSL3_ASSET)