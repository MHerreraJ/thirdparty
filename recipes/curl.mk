CURL_RELEASES_URL=https://github.com/curl/curl/releases/download
CURL_VERSION:=curl-8_7_1

CURL_ASSET_NAME:=curl-8.7.1.tar.gz
CURL_ASSET:=$(FETCH_DIR)/$(CURL_ASSET_NAME)
CURL_ASSET_URL:=$(CURL_RELEASES_URL)/$(CURL_VERSION)/$(CURL_ASSET_NAME)

CURL_DIR:=$(FETCH_DIR)/curl-8.7.1

ifeq ($(V),1)
CURL_BUILD_VERBOSE=--disable-silent-rules
else
CURL_BUILD_VERBOSE=--enable-silent-rules
endif

curl.depend:=openssl

CURL_OSS_BUILD:=$(call build_oss,curl)
CURL_OSS_CLEAN:=$(call clean_oss,curl)
CURL_OSS_DISTCLEAN:=$(call distclean_oss,curl)

.PHONY: $(CURL_OSS_BUILD) $(CURL_OSS_CLEAN) $(CURL_OSS_DISTCLEAN)

$(CURL_OSS_BUILD): $(CURL_DIR)
	@mkdir -p $(STAGE_DIR)
	cd $(CURL_DIR) && PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(curl.depend))" ./configure \
			--prefix=$(STAGE_DIR) \
			--host=$(HOST) \
			--enable-debug=no \
			--enable-shared=yes \
			--enable-static=no \
			--disable-manual \
			--disable-curldebug \
			--disable-rtsp \
			--enable-telnet \
			--disable-ldap \
			--disable-docs \
			--with-pic \
			--with-openssl=$(call get_dep_dir,openssl) \
			$(CURL_BUILD_VERBOSE) \
			CC="$(CROSS_COMPILE)gcc" \
			AR="$(CROSS_COMPILE)ar" \
			CFLAGS="-Os" \
			STRIP="$(CROSS_COMPILE)strip" \
			LDFLAGS="$(call get_deps_ldflags,$(curl.depend)) -l:libssl.so.3 -l:libcrypto.so.3 -ldl -lpthread -Wl,-rpath,$(STAGE_DIR)/lib"

	@$(MAKE) -C $(CURL_DIR) 
	@$(MAKE) -C $(CURL_DIR) install

$(CURL_DIR): $(CURL_ASSET)
	@echo "Extracting $(CURL_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(CURL_ASSET)

$(CURL_ASSET):
	@rm -f $(CURL_ASSET)
	@echo "Fetching $(CURL_ASSET)..."
	@wget --quiet --show-progress $(CURL_ASSET_URL) -O $(CURL_ASSET)

$(CURL_OSS_CLEAN):
	@rm -rf $(CURL_DIR)

$(CURL_OSS_DISTCLEAN): $(CURL_OSS_CLEAN)
	@rm -rf $(CURL_ASSET)