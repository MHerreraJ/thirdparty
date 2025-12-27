oss-build-$(OSS_CONFIG_TPM2_TOOLS) += tpm2-tools

TPM2_TOOLS_RELEASES_URL=https://github.com/tpm2-software/tpm2-tools/releases/download
TPM2_TOOLS_VERSION:=5.6

TPM2_TOOLS_ASSET_NAME:=tpm2-tools-5.6.tar.gz
TPM2_TOOLS_ASSET:=$(FETCH_DIR)/$(TPM2_TOOLS_ASSET_NAME)
TPM2_TOOLS_ASSET_URL:=$(TPM2_TOOLS_RELEASES_URL)/$(TPM2_TOOLS_VERSION)/$(TPM2_TOOLS_ASSET_NAME)

TPM2_TOOLS_DIR:=$(FETCH_DIR)/tpm2-tools-5.6

ifeq ($(V),1)
TPM2_TOOLS_BUILD_VERBOSE=--disable-silent-rules
else
TPM2_TOOLS_BUILD_VERBOSE=--enable-silent-rules
endif

tpm2-tools.depend:= tpm2tss curl openssl

TPM2_TOOLS_OSS_BUILD:=$(call build_oss,tpm2-tools)
TPM2_TOOLS_OSS_CLEAN:=$(call clean_oss,tpm2-tools)
TPM2_TOOLS_OSS_DISTCLEAN:=$(call distclean_oss,tpm2-tools)

.PHONY: $(TPM2_TOOLS_OSS_BUILD) $(TPM2_TOOLS_OSS_CLEAN) $(TPM2_TOOLS_OSS_DISTCLEAN)

$(TPM2_TOOLS_OSS_BUILD): $(TPM2_TOOLS_DIR)
	@mkdir -p $(STAGE_DIR)
	cd $(TPM2_TOOLS_DIR) &&  ./configure \
		--prefix=$(STAGE_DIR) \
		--host=$(HOST) \
		--disable-fapi \
		$(TPM2_TOOLS_BUILD_VERBOSE) \
		CC="$(CROSS_COMPILE)gcc" \
		CXX="$(CROSS_COMPILE)g++" \
		AR="$(CROSS_COMPILE)ar" \
		CFLAGS="-Os" \
		CPPFLAGS="$(call get_deps_cflags,$(tpm2-tools.depend))" \
		LDFLAGS="$(call get_deps_ldflags,$(tpm2-tools.depend))" \
		PKG_CONFIG_PATH="$(call get_deps_pkgconfig,$(tpm2-tools.depend))"
		
	@$(MAKE) -C $(TPM2_TOOLS_DIR) 
	@$(MAKE) -C $(TPM2_TOOLS_DIR) install-exec

$(TPM2_TOOLS_DIR): $(TPM2_TOOLS_ASSET)
	@echo "Extracting $(TPM2_TOOLS_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(TPM2_TOOLS_ASSET)

$(TPM2_TOOLS_ASSET):
	@rm -f $(TPM2_TOOLS_ASSET)
	@echo "Fetching $(TPM2_TOOLS_ASSET)..."
	@wget --quiet --show-progress $(TPM2_TOOLS_ASSET_URL) -O $(TPM2_TOOLS_ASSET)

$(TPM2_TOOLS_OSS_CLEAN):
	@rm -rf $(TPM2_TOOLS_DIR)

$(TPM2_TOOLS_OSS_DISTCLEAN): $(TPM2_TOOLS_OSS_CLEAN)
	@rm -rf $(TPM2_TOOLS_ASSET)