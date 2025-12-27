export OSS_TOP_DIR:=$(shell pwd)

# Opensource build
oss-build-y:=

ifeq ($(CONFIG),)
# If not .config file found, use default simulator_config
ifeq ($(wildcard $(OSS_TOP_DIR)/.config),)
$(error No .config file found in '$(OSS_TOP_DIR)/.config'. Please provide one or set CONFIG variable)
endif
else
# If CONFIG variable is set, use it if exists
# First test if file exist in local directory
ifneq ($(wildcard $(CONFIG)),)
$(shell cp -af $(CONFIG) $(OSS_TOP_DIR)/.config)
else
# If not, test if file exist in configs directory
ifeq ($(wildcard $(OSS_TOP_DIR)/configs/$(CONFIG)),)
$(error CONFIG file '$(OSS_TOP_DIR)/configs/$(CONFIG)' not found)
else
$(shell cp -af $(OSS_TOP_DIR)/configs/$(CONFIG) $(OSS_TOP_DIR)/.config)
endif
endif
endif

include $(OSS_TOP_DIR)/.config

export SYS_ARCH:=$(shell uname -m)

ifeq ($(ARCH),)
ARCH:=x86_64
endif

ifeq ($(HOST),)
unexport HOST
ifneq ($(CROSS_COMPILE),)
HOST=$(shell basename $(CROSS_COMPILE:-=))
endif
ifeq ($(HOST),)
ifeq ($(ARCH),x86_64)
HOST:=x86_64-linux-gnu
else ifeq ($(ARCH),aarch64)
HOST:=aarch64-linux-gnu
else
$(error HOST is not set)
endif
endif
endif


BUILD_ENV_CHANGED?=0
OLD_BUILD_ENV=$(OSS_TOP_DIR)/.buildenv
ifeq ($(BUILD_ENV_CHANGED), 0)
ifneq ($(wildcard $(OLD_BUILD_ENV)),)
include $(OLD_BUILD_ENV)
ifneq ($(OLD_HOST),$(HOST))
BUILD_ENV_CHANGED=1
endif
ifneq ($(OLD_ARCH),$(ARCH))
BUILD_ENV_CHANGED=1
endif
ifneq ($(OLD_CROSS_COMPILE),$(CROSS_COMPILE))
BUILD_ENV_CHANGED=1
endif
endif

ifeq ($(BUILD_ENV_CHANGED), 1)
$(shell echo "OLD_HOST=$(HOST)" > $(OLD_BUILD_ENV))
$(shell echo "OLD_ARCH=$(ARCH)" >> $(OLD_BUILD_ENV))
$(shell echo "OLD_CROSS_COMPILE=$(CROSS_COMPILE)" >> $(OLD_BUILD_ENV))
endif
endif

export HOST
export ARCH

export OSS_FETCH_DIR:=$(OSS_TOP_DIR)/fetch
export OSS_BUILD_DIR:=$(OSS_TOP_DIR)/build
export OSS_STAGE_BASE_DIR:=$(OSS_TOP_DIR)/stage
export OSS_STAGE_DIR:=$(OSS_STAGE_BASE_DIR)/$(ARCH)
export OSS_CFG_DIR:=$(OSS_TOP_DIR)/config


OSS_INSTALL_PREFIX?=$(OSS_TOP_DIR)/out/$(ARCH)
include macros.mk



define OSS_INSTALL_SCRIPT
	@for oss in $(1); do \
		exclude_static="--exclude *.a --exclude *.la"; \
		if [[ $(oss-install-static-y) =~ (^|[[:space:]])$$oss($$|[[:space:]]) ]]; then \
			exclude_static=""; \
		fi; \
		printf "\033[1;32mInstalling $$oss...\033[0m\n"; \
		if [ ! -d $(OSS_STAGE_DIR)/$$oss ]; then \
			printf "Skipping $$oss, nothing to install\n\n"; \
			continue; \
		fi; \
		if [ -f $(OSS_STAGE_DIR)/$$oss/.noinstall ]; then \
			printf "Skipping $$oss (.noinstall file found)\n"; \
			continue; \
		fi; \
		dirs=$$(find $(OSS_STAGE_DIR)/$$oss/ -mindepth 1 -maxdepth 1 -type d); \
		for dir in $$dirs; do \
			if [ ! -z "$$dir" ]; then \
				case $$dir in \
					*/*.no-install*) ;; \
					*/doc) ;; \
					*) printf "Install $$dir -> $(OSS_INSTALL_PREFIX)/\n" && rsync -av $$dir $(OSS_INSTALL_PREFIX)/ $$exclude_static --exclude pkgconfig* && printf "\n"; echo $(1) ;; \
				esac; \
			fi; \
		done; \
	done
	@for oss in $(1); do \
		if [ -d $(OSS_CFG_DIR)/$$oss ]; then \
			printf "\033[1;32mInstalling $$oss config...\033[0m\n"; \
			rsync -av $(OSS_CFG_DIR)/$$oss/ $(OSS_INSTALL_PREFIX)/; \
		fi; \
	done
endef


.PHONY: all
all: $(OSS_FETCH_DIR)
	@$(foreach oss, $(oss-build-y), \
		$(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory $(oss) && \
	) true

CONFIGS_PATH=$(wildcard $(OSS_TOP_DIR)/configs/*)
CONFIGS=$(patsubst $(OSS_TOP_DIR)/configs/%,%,$(CONFIGS_PATH))
$(CONFIGS):
	@echo "CONFIG: $@"
	@cp $(OSS_TOP_DIR)/configs/$@ $(OSS_TOP_DIR)/.config

.PHONY: install
install: all
	@mkdir -p $(OSS_INSTALL_PREFIX)
	@printf "Installing all...\n"
	@$(foreach oss, $(oss-build-y), \
		$(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory $(oss).install; \
	)
	@printf "\033[1;32mDone\033[0m\n"

.PHONY: clean
clean:
	@$(foreach oss, $(oss-build-y), \
		$(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory $(oss).clean &&\
	) true
	@rm -rf $(OSS_STAGE_BASE_DIR)
	@printf "\033[1;32mDone\033[0m\n"

.PHONY: distclean
distclean: clean
	@$(foreach oss, $(oss-build-y), \
		$(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory $(oss).distclean && \
	) true
	@rm -rf $(OSS_FETCH_DIR)
	@printf "\033[1;32mDone\033[0m\n"

$(OSS_FETCH_DIR):
	@mkdir -p $(OSS_FETCH_DIR)


export MESON_CROSS_FILE=$(OSS_FETCH_DIR)/cross_$(ARCH).meson.txt

include recipes/*.mk

$(MESON_CROSS_FILE):
	@mkdir -p $(OSS_FETCH_DIR)
	@cp $(OSS_TOP_DIR)/recipes/_toolchain.meson.in $(MESON_CROSS_FILE)
	@sed -i 's/@ARCH@/$(ARCH)/g' $(MESON_CROSS_FILE)
	@sed -i 's%@CROSS_COMPILE@%$(CROSS_COMPILE)%g' $(MESON_CROSS_FILE)


.PHONY: $(oss-build-y)
ifeq ($(FORCE),1)
$(oss-build-y): %: $(OSS_FETCH_DIR)/%_$(ARCH).built.force 
else
$(oss-build-y): %: $(OSS_FETCH_DIR)/%_$(ARCH).built
endif

ifeq ($(FORCE),1)
$(OSS_FETCH_DIR)/%_$(ARCH).built.force:
	$(eval $@_oss:=$(patsubst $(OSS_FETCH_DIR)/%_$(ARCH).built.force,%,$@))
else
$(OSS_FETCH_DIR)/%_$(ARCH).built:
	$(eval $@_oss:=$(patsubst $(OSS_FETCH_DIR)/%_$(ARCH).built,%,$@))
endif
ifeq ($(BUILD_ENV_CHANGED),1)
	@($(MAKE) -q $(call clean_oss,$($@_oss)) 2>&1 | grep --quiet "No rule to clean target") || \
		$(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory FETCH_DIR=$(OSS_FETCH_DIR) STAGE_DIR=$(OSS_STAGE_DIR)/$($@_oss) DEST_DIR="" $(call clean_oss,$($@_oss)) || \
		( printf "\033[1;34mSkipping clean '$($@_oss)'\033[0m\n" )	
endif
	@if [ ! -f $(MESON_CROSS_FILE) ]; then \
		$(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory $(MESON_CROSS_FILE); \
	fi

	@$(foreach dep,$($($@_oss).depend), \
		($(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory $(dep) || ( printf "\033[1;31mFailed while building dependency '$(dep)' for '$($@_oss)'\033[0m\n" && false )) && \
	) true
	@printf "\033[1;32mBuilding '$($@_oss)'...\033[0m\n"
	@($(MAKE) -q $(call build_oss,$($@_oss)) 2>&1 | grep --quiet "No rule to make target") || \
		$(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory FETCH_DIR=$(OSS_FETCH_DIR) STAGE_DIR=$(OSS_STAGE_DIR)/$($@_oss) DEST_DIR="" $(call build_oss,$($@_oss)) || \
		( printf "\033[1;31mFailed to build '$($@_oss)'\033[0m\n" && false )

	@if [ -d $(OSS_STAGE_DIR)/$($@_oss) ]; then \
		find $(OSS_STAGE_DIR)/$($@_oss) -type f -not \( -name "*.h" -o -name "*.pc" -o -name "*.a" -o -name "*.la" \) \
			-exec sh -c "$(CROSS_COMPILE)strip -s {} 2>/dev/null && echo Stripped \$$(basename {}); " \; ;\
	fi

	$(eval $@_pkgconfigs:=$(wildcard $(OSS_STAGE_DIR)/$($@_oss)/lib/pkgconfig/*.pc))
	@$(call patch_pkg_configs,$($@_pkgconfigs),$(OSS_STAGE_DIR)/$($@_oss),$(OSS_STAGE_DIR)/$($@_oss))

	@touch $(OSS_FETCH_DIR)/$($@_oss)_$(ARCH).built

.PHONY: $(patsubst %,%.install,$(oss-build-y))
$(patsubst %,%.install,$(oss-build-y)): %.install: $(OSS_FETCH_DIR)/%_$(ARCH).built
	@printf "\nInstalling $*...\n"
	@mkdir -p $(OSS_INSTALL_PREFIX)
	$(eval $@_oss:=$(patsubst %.install,%,$@))
	$(eval $@_pkgconfigs:=$(patsubst $(OSS_STAGE_DIR)/$($@_oss)/lib/pkgconfig/%.pc,$(OSS_INSTALL_PREFIX)/lib/pkgconfig/%.pc,$(wildcard $(OSS_STAGE_DIR)/$($@_oss)/lib/pkgconfig/*.pc)))

	@($(MAKE) -q $(call install_oss,$($@_oss)) 2>&1 | grep --quiet "No rule to make target") || (printf "Installing $($@_oss)...\n" && \
		($(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory FETCH_DIR=$(OSS_FETCH_DIR) STAGE_DIR=$(OSS_STAGE_DIR)/$($@_oss) DEST_DIR=$(OSS_INSTALL_PREFIX) $(call install_oss,$($@_oss)) && printf "\033[1;32mInstalled $($@_oss)\033[0m\n") || \
		( printf "\033[1;31mFailed to install '$($@_oss)'\033[0m\n" && false ))

	@($(MAKE) -q $(call install_oss,$($@_oss)) 2>&1 | grep --quiet "No rule to make target") && \
		( [ -d $(OSS_STAGE_DIR)/$($@_oss) ] && rsync -av $(OSS_STAGE_DIR)/$($@_oss)/* $(OSS_INSTALL_PREFIX)/ && printf "\033[1;32mInstalled $($@_oss)\033[0m\n" ) || true

	@($(MAKE) -q $(call install_oss,$($@_oss)) 2>&1 | grep --quiet "No rule to make target") && \
		( [ ! -d $(OSS_STAGE_DIR)/$($@_oss) ] && printf "\033[1;33mNothing to install for $($@_oss)\033[0m\n" ) || true

	@$(call patch_pkg_configs,$($@_pkgconfigs),$(OSS_INSTALL_PREFIX),$(OSS_STAGE_DIR)/$($@_oss))


.PHONY: $(patsubst %,%.clean,$(oss-build-y))
$(patsubst %,%.clean,$(oss-build-y)): %.clean:
	$(eval $@_oss:=$(patsubst %.clean,%,$@))
	@printf "\033[1;32mCleaning '$($@_oss)'...\033[0m\n"
	@rm -f $(OSS_FETCH_DIR)/$($@_oss)_$(ARCH).built
	@rm -rf $(OSS_STAGE_DIR)/$($@_oss)
	@($(MAKE) -q $(call clean_oss,$($@_oss)) 2>&1 | grep --quiet "No rule to make target") || \
		$(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory FETCH_DIR=$(OSS_FETCH_DIR) STAGE_DIR=$(OSS_STAGE_DIR)/$($@_oss) DEST_DIR="" $(call clean_oss,$($@_oss)) || \
		( printf "\033[1;31mFailed to clean '$($@_oss))'\033[0m\n" && false )


.PHONY: $(patsubst %,%.distclean,$(oss-build-y))
$(patsubst %,%.distclean,$(oss-build-y)): %.distclean:
	$(eval $@_oss:=$(patsubst %.distclean,%,$@))
	@printf "\033[1;32mDist cleaning '$($@_oss)'...\033[0m\n"
	@rm -f $(OSS_FETCH_DIR)/$($@_oss)_$(ARCH).built
	@rm -rf $(OSS_STAGE_DIR)/$($@_oss)
	@($(MAKE) -q $(call distclean_oss,$($@_oss)) 2>&1 | grep --quiet "No rule to make target") || \
		$(MAKE) BUILD_ENV_CHANGED=$(BUILD_ENV_CHANGED) --no-print-directory FETCH_DIR=$(OSS_FETCH_DIR) STAGE_DIR=$(OSS_STAGE_DIR)/$($@_oss) DEST_DIR="" $(call distclean_oss,$($@_oss)) || \
		( printf "\033[1;31mFailed to distclean '$($@_oss))'\033[0m\n" && false )

tool-export:
	@printf "\033[1;32mExporting tools...\033[0m\n"
	@mkdir -p /tmp/opensource-builder
ifdef TOOL_INSTALL_TO_HOST
	@rsync -chavzP $(OSS_TOP_DIR)/recipes $(OSS_TOP_DIR)/configs $(OSS_TOP_DIR)/Makefile $(OSS_TOP_DIR)/macros.mk $(TOOL_INSTALL_TO_HOST)
#	@cp -rf $(OSS_TOP_DIR)/recipes /tmp/opensource-builder/
#	@cp -rf $(OSS_TOP_DIR)/configs /tmp/opensource-builder/
#	@cp -rf $(OSS_TOP_DIR)/Makefile /tmp/opensource-builder/
#	@cp -rf $(OSS_TOP_DIR)/macros.mk /tmp/opensource-builder/
endif

# pip3 install meson ninja
# sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 5
# python3.8 -m pip install meson ninja packaging
# apt install libglib2.0-dev expect gawk socat libseccomp-devel autoconf-archive autoconf-dickey automake-1.15 dh-autoreconf