OPENSSL_VERSION?=openssl3
openssl.depend:=$(OPENSSL_VERSION)

OPENSSL_OSS_BUILD:=$(call build_oss,openssl)
OPENSSL_OSS_INSTALL:=$(call install_oss,openssl)
OPENSSL_OSS_CLEAN=$(call clean_oss,openssl)
OPENSSL_OSS_DISTCLEAN=$(call distclean_oss,openssl)

.PHONY: $(OPENSSL_OSS_BUILD) $(OPENSSL_OSS_CLEAN) $(OPENSSL_OSS_DISTCLEAN) $(OPENSSL_OSS_INSTALL)


$(OPENSSL_OSS_BUILD):$(OPENSSL_VERSION)
	@rm -f $(STAGE_DIR)
	@[ ! -e $(STAGE_DIR) ] &&  ln -sf $(call get_dep_dir,$(OPENSSL_VERSION)) $(STAGE_DIR) || true

$(OPENSSL_OSS_INSTALL):$(OPENSSL_VERSION).install

$(OPENSSL_OSS_CLEAN):$(OPENSSL_VERSION).clean

$(OPENSSL_OSS_DISTCLEAN):$(OPENSSL_VERSION).distclean