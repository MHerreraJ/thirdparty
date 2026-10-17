TPM2TSS_RELEASES_URL=https://github.com/tpm2-software/tpm2-tss/releases/download
TPM2TSS_VERSION:=4.0.1

TPM2TSS_ASSET_NAME:=tpm2-tss-4.0.1.tar.gz
TPM2TSS_ASSET:=$(FETCH_DIR)/$(TPM2TSS_ASSET_NAME)
TPM2TSS_ASSET_URL:=$(TPM2TSS_RELEASES_URL)/$(TPM2TSS_VERSION)/$(TPM2TSS_ASSET_NAME)
TPM2TSS_ASSET_SHA256:=532a70133910b6bd842289915b3f9423c0205c0ea009d65294ca18a74087c950

TPM2TSS_DIR:=$(FETCH_DIR)/tpm2-tss-4.0.1

ifeq ($(V),1)
TPM2TSS_BUILD_VERBOSE=--disable-silent-rules
else
TPM2TSS_BUILD_VERBOSE=--enable-silent-rules
endif

tpm2tss.depend:=openssl

TPM2TSS_OSS_BUILD:=$(call build_oss,tpm2tss)
TPM2TSS_OSS_INSTALL:=$(call install_oss,tpm2tss)
TPM2TSS_OSS_CLEAN:=$(call clean_oss,tpm2tss)
TPM2TSS_OSS_DISTCLEAN:=$(call distclean_oss,tpm2tss)
.PHONY: $(TPM2TSS_OSS_BUILD) $(TPM2TSS_OSS_INSTALL) $(TPM2TSS_OSS_CLEAN) $(TPM2TSS_OSS_DISTCLEAN)

$(TPM2TSS_OSS_BUILD): $(TPM2TSS_DIR)
	@mkdir -p $(STAGE_DIR)
	cd $(TPM2TSS_DIR) && ./configure \
			--prefix=$(STAGE_DIR) \
			--host=$(HOST) \
			--enable-debug=no \
			--enable-fapi=no \
			--enable-policy=no \
			--enable-unit=no \
			--disable-tcti-mssim \
			--disable-tcti-swtpm \
			--disable-tcti-pcap \
			--disable-tcti-libtpms \
			--disable-tcti-spi-helper \
			--enable-nodl \
			--enable-shared=false \
			--enable-static=true \
			--disable-log-file \
			--with-maxloglevel=none \
			$(TPM2TSS_BUILD_VERBOSE) \
			CC="$(CROSS_COMPILE)gcc" \
			AR="$(CROSS_COMPILE)ar" \
			STRIP="$(CROSS_COMPILE)strip" \
			CRYPTO_CFLAGS="$(call get_deps_cflags,$(tpm2tss.depend))" \
			CRYPTO_LIBS="$(call get_deps_ldflags,$(tpm2tss.depend)) -lcrypto -lssl -ldl -lpthread";

	@$(MAKE) -C $(TPM2TSS_DIR) 
	@$(MAKE) -C $(TPM2TSS_DIR) install

$(TPM2TSS_DIR): $(TPM2TSS_ASSET)
	@echo "Extracting $(TPM2TSS_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(TPM2TSS_ASSET)

$(TPM2TSS_ASSET):
	@rm -f $(TPM2TSS_ASSET)
	@echo "Fetching $(TPM2TSS_ASSET)..."
	@wget --quiet --show-progress $(TPM2TSS_ASSET_URL) -O $(TPM2TSS_ASSET)
	@echo "$(TPM2TSS_ASSET_SHA256) $(TPM2TSS_ASSET)" | sha256sum -c --quiet

$(TPM2TSS_OSS_INSTALL):
	@echo "Skipping install for tpm2tss"

$(TPM2TSS_OSS_CLEAN):
	@rm -rf $(TPM2TSS_DIR)

$(TPM2TSS_OSS_DISTCLEAN): $(TPM2TSS_OSS_CLEAN)
	@rm -rf $(TPM2TSS_ASSET)