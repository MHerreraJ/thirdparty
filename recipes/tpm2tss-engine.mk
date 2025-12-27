oss-build-$(OSS_CONFIG_TPM2TSS_ENGINE) += tpm2tss-engine

#https://github.com/tpm2-software/tpm2-tss-engine/archive/refs/tags/1.2.0.tar.gz

TPM2TSS_ENGINE_RELEASES_URL=https://github.com/tpm2-software/tpm2-tss-engine/archive/refs/tags
TPM2TSS_ENGINE_VERSION:=v1.2.0

TPM2TSS_ENGINE_ASSET_NAME:=tpm2-tss-engine-1.2.0.tar.gz
TPM2TSS_ENGINE_ASSET:=$(FETCH_DIR)/$(TPM2TSS_ENGINE_ASSET_NAME)
TPM2TSS_ENGINE_ASSET_URL:=$(TPM2TSS_ENGINE_RELEASES_URL)/1.2.0.tar.gz

TPM2TSS_ENGINE_DIR:=$(FETCH_DIR)/tpm2-tss-engine-1.2.0

ifeq ($(V),1)
TPM2TSS_ENGINE_BUILD_VERBOSE=--disable-silent-rules
else
TPM2TSS_ENGINE_BUILD_VERBOSE=--enable-silent-rules
endif

tpm2tss-engine.depend:= tpm2tss openssl

TPM2TSS_ENGINE_OSS_BUILD:=$(call build_oss,tpm2tss-engine)
TPM2TSS_ENGINE_OSS_CLEAN:=$(call clean_oss,tpm2tss-engine)
TPM2TSS_ENGINE_OSS_DISTCLEAN:=$(call distclean_oss,tpm2tss-engine)

.PHONY: $(TPM2TSS_ENGINE_OSS_BUILD)  $(TPM2TSS_ENGINE_OSS_CLEAN) $(TPM2TSS_ENGINE_OSS_DISTCLEAN)

$(TPM2TSS_ENGINE_OSS_BUILD): $(TPM2TSS_ENGINE_DIR)
	@mkdir -p $(STAGE_DIR)
	@mkdir -p $(STAGE_DIR)/bin
	@mkdir -p $(STAGE_DIR)/lib/engines-3
	cd $(TPM2TSS_ENGINE_DIR) && autoreconf -i && automake && \
		./configure \
		--prefix=$(STAGE_DIR) \
		--host=$(HOST) \
		--enable-debug=no \
		$(TPM2TSS_ENGINE_BUILD_VERBOSE) \
		--enable-shared=yes \
		--enable-static=no \
		--with-enginesdir=$(STAGE_DIR)/lib/engines-3 \
		CC="$(CROSS_COMPILE)gcc" \
		CXX="$(CROSS_COMPILE)g++" \
		CFLAGS="-Wno-error=deprecated-declarations -Wno-error=unused-parameter" \
		CPPFLAGS="$(call get_deps_cflags,$(tpm2tss-engine.depend))" \
		LDFLAGS="$(call get_deps_ldflags,$(tpm2tss-engine.depend))" \
		CRYPTO_CFLAGS="$(call get_dep_cflags,openssl)" \
		CRYPTO_LIBS="$(call get_dep_ldflags,openssl) -lcrypto -ldl -lpthread" \
		TSS2_MU_CFLAGS="$(call get_dep_ldflags,tpm2tss)" \
		TSS2_ESYS_CFLAGS="$(call get_dep_ldflags,tpm2tss)" \
		TSS2_TCTILDR_CFLAGS="$(call get_dep_ldflags,tpm2tss)" \
		TSS2_MU_LIBS="-ltss2-mu" \
		TSS2_ESYS_LIBS="-ltss2-esys -ltss2-sys" \
		TSS2_TCTILDR_LIBS="-ltss2-tctildr -ltss2-tcti-device"
		
	@$(MAKE) -C $(TPM2TSS_ENGINE_DIR) 
	@$(MAKE) -C $(TPM2TSS_ENGINE_DIR) install-exec

$(TPM2TSS_ENGINE_DIR): $(TPM2TSS_ENGINE_ASSET)
	@echo "Extracting $(TPM2TSS_ENGINE_ASSET)"
	@tar -C $(FETCH_DIR)/ -xzf $(TPM2TSS_ENGINE_ASSET)

$(TPM2TSS_ENGINE_ASSET):
	@rm -f $(TPM2TSS_ENGINE_ASSET)
	@echo "Fetching $(TPM2TSS_ENGINE_ASSET)..."
	@wget --quiet --show-progress $(TPM2TSS_ENGINE_ASSET_URL) -O $(TPM2TSS_ENGINE_ASSET)


$(TPM2TSS_ENGINE_OSS_CLEAN):
	@rm -rf $(TPM2TSS_ENGINE_DIR)

$(TPM2TSS_ENGINE_OSS_DISTCLEAN): $(TPM2TSS_ENGINE_OSS_CLEAN)
	@rm -rf $(TPM2TSS_ENGINE_ASSET)