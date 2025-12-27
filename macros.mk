empty:=
space:=$(empty) $(empty)

define get_host_dep
$(OSS_FETCH_DIR)/$(1)_$(SYS_ARCH).built
endef

define get_host_dep_dir
$(OSS_TOP_DIR)/stage/$(SYS_ARCH)/$(1)
endef


define get_dep_cflags
-I$(OSS_STAGE_DIR)/$(1)/include
endef

define get_deps_cflags
$(foreach oss,$(1),-I$(OSS_STAGE_DIR)/$(oss)/include $(foreach sub_oss,$($(oss).depend),$(call get_deps_cflags,$(sub_oss))))
endef



define get_dep_ldflags
-L$(OSS_STAGE_DIR)/$(1)/lib
endef

define get_deps_ldflags
$(foreach oss,$(1),-L$(OSS_STAGE_DIR)/$(oss)/lib $(foreach sub_oss,$($(oss).depend),$(call get_deps_ldflags,$(sub_oss))))
endef


define get_dep_pkgconfig
$(OSS_STAGE_DIR)/$(1)/lib/pkgconfig/
endef

define get_deps_pkgconfig
$(patsubst %:,%,$(subst $(space),$(empty),$(foreach oss,$(1),$(OSS_STAGE_DIR)/$(oss)/lib/pkgconfig/:$(foreach sub_oss,$($(oss).depend),$(call get_deps_pkgconfig,$(sub_oss)):))))
endef



define get_dep_dir
$(OSS_STAGE_DIR)/$(1)
endef

define get_deps_dir
$(foreach oss,$(1),$(OSS_STAGE_DIR)/$(oss) $(foreach sub_oss,$($(oss).depend),$(call get_deps_dir,$(sub_oss))))
endef



define build_oss
_$(1).make
endef

define install_oss
_$(1).install
endef

define clean_oss
_$(1).clean
endef

define distclean_oss
_$(1).distclean
endef

#1 - file
#2 - new prefix
#3 - old prefix
define patch_pkg_config_file
([ -e $(1) ] && (\
	grep -q -e '^prefix=' $(1) && sed -i 's:^prefix=.*:prefix=$(2):' $(1); \
	grep -q -e "$(3)" $(1) && sed -i 's:$(3):$(2):' $(1);\
) || true);
endef

define patch_pkg_configs
$(foreach file,$(1),$(call patch_pkg_config_file,$(file),$(2),$(3)))
endef

# $(subst $(space),:,$(foreach oss,$(1),$(OSS_STAGE_DIR)/$(oss)/lib/pkgconfig/))
