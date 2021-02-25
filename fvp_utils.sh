#!/usr/bin/env bash
#
# Copyright (c) 2020-2021, Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

set -u

bl1_addr="${bl1_addr:-0x0}"
bl31_addr="${bl31_addr:-0x04001000}"
bl32_addr="${bl32_addr:-0x04003000}"
bl33_addr="${bl33_addr:-0x88000000}"
dtb_addr="${dtb_addr:-0x82000000}"
fip_addr="${fip_addr:-0x08000000}"
initrd_addr="${initrd_addr:-0x84000000}"
kernel_addr="${kernel_addr:-0x80080000}"
el3_payload_addr="${el3_payload_addr:-0x80000000}"

# SPM requires following addresses for RESET_TO_BL31 case
spm_addr="${spm_addr:-0x6000000}"
spmc_manifest_addr="${spmc_addr:-0x0403f000}"
sp1_addr="${sp1_addr:-0x7000000}"
sp2_addr="${sp2_addr:-0x7100000}"
sp3_addr="${sp3_addr:-0x7200000}"
# SPM out directories
export spm_secure_out_dir="${spm_secure_out_dir:-secure_aem_v8a_fvp_clang}"
export spm_non_secure_out_dir="${spm_non_secure_out_dir:-aem_v8a_fvp_clang}"

ns_bl1u_addr="${ns_bl1u_addr:-0x0beb8000}"
fwu_fip_addr="${fwu_fip_addr:-0x08400000}"
backup_fip_addr="${backup_fip_addr:-0x09000000}"
romlib_addr="${romlib_addr:-0x03ff2000}"

uboot32_fip_url="$linaro_release/fvp32-latest-busybox-uboot/fip.bin"

rootfs_url="$linaro_release/lt-vexpress64-openembedded_minimal-armv8-gcc-5.2_20170127-761.img.gz"

# Default FVP model variables
default_model_dtb="fvp-base-gicv3-psci.dtb"

# FVP containers and model paths
fvp_arm_std_library="fvp:fvp_arm_std_library_${model_version}_${model_build};/opt/model/FVP_ARM_Std_Library/models/${model_flavour}"
fvp_base_revc_2xaemv8a="fvp:fvp_base_revc-2xaemv8a_${model_version}_${model_build};/opt/model/Base_RevC_AEMv8A_pkg/models/${model_flavour}"
foundation_platform="fvp:foundation_platform_${model_version}_${model_build};/opt/model/Foundation_Platformpkg/models/${model_flavour}"

# FVP associate array, run_config are keys and fvp container parameters are the values
#   Container parameters syntax: <model name>;<model dir>;<model bin>
# FIXMEs: fix those ;;; values with real values

declare -A fvp_models
fvp_models=(
[base-aemv8a-quad]=";;;"
[base-aemv8a-revb]=";;;"
[base-aemv8a-latest-revb]=";;;"
[base-aemva]=";;;"
[foundationv8]="${foundation_platform};Foundation_Platform"
[base-aemv8a]="${fvp_base_revc_2xaemv8a};FVP_Base_RevC-2xAEMv8A"
[cortex-a32x4]="${fvp_arm_std_library};FVP_Base_Cortex-A32x4"
[cortex-a35x4]="${fvp_arm_std_library};FVP_Base_Cortex-A35x4"
[cortex-a53x4]="${fvp_arm_std_library};FVP_Base_Cortex-A53x4"
[cortex-a55x4-a75x4]="${fvp_arm_std_library};FVP_Base_Cortex-A55x4-A75x4"
[cortex-a55x4-a76x2]="${fvp_arm_std_library};FVP_Base_Cortex-A55x4-A76x2"
[cortex-a57x1-a53x1]="${fvp_arm_std_library};FVP_Base_Cortex-A57x1-A53x1"
[cortex-a57x2-a53x4]="${fvp_arm_std_library};FVP_Base_Cortex-A57x2-A53x4"
[cortex-a57x4]="${fvp_arm_std_library};FVP_Base_Cortex-A57x4"
[cortex-a57x4-a53x4]="${fvp_arm_std_library};FVP_Base_Cortex-A57x4-A53x4"
[cortex-a65aex8]="${fvp_arm_std_library};FVP_Base_Cortex-A65AEx8"
[cortex-a65x4]="${fvp_arm_std_library};FVP_Base_Cortex-A65x4"
[cortex-a72x4]="${fvp_arm_std_library};FVP_Base_Cortex-A72x4"
[cortex-a72x4-a53x4]="${fvp_arm_std_library};FVP_Base_Cortex-A72x4-A53x4"
[cortex-a73x4]="${fvp_arm_std_library};FVP_Base_Cortex-A73x4"
[cortex-a73x4-a53x4]="${fvp_arm_std_library};FVP_Base_Cortex-A73x4-A53x4"
[cortex-a75x4]="${fvp_arm_std_library};FVP_Base_Cortex-A75x4"
[cortex-a76aex4]="${fvp_arm_std_library};FVP_Base_Cortex-A76AEx4"
[cortex-a76aex2]="${fvp_arm_std_library};FVP_Base_Cortex-A76AEx2"
[cortex-a76x4]="${fvp_arm_std_library};FVP_Base_Cortex-A76x4"
[cortex-a77x4]="${fvp_arm_std_library};FVP_Base_Cortex-A77x4"
[cortex-a78x4]="${fvp_arm_std_library};FVP_Base_Cortex-A78x4"
[neoverse_e1x1]="${fvp_arm_std_library};FVP_Base_Neoverse-E1x1"
[neoverse_e1x2]="${fvp_arm_std_library};FVP_Base_Neoverse-E1x2"
[neoverse_e1x4]="${fvp_arm_std_library};FVP_Base_Neoverse-E1x4"
[neoverse_n1]="${fvp_arm_std_library};FVP_Base_Neoverse-N1x1"
[neoverse_n2]=";;;"
[neoverse-v1x4]=";;;"
[css-rdv1]=";;;"
[css-rde1edge]=";;;"
[css-rdn1edge]=";;;"
[css-rdn1edgex2]=";;;"
[css-sgi575]=";;;"
[css-sgm775]=";;;"
[tc0]=";;;"
)


# FVP Kernel URLs
declare -A fvp_kernels
fvp_kernels=(
[fvp-aarch32-zimage]="$linaro_release/fvp32-latest-busybox-uboot/Image"
[fvp-busybox-uboot]="$linaro_release/fvp-latest-busybox-uboot/Image"
[fvp-oe-uboot32]="$linaro_release/fvp32-latest-oe-uboot/Image"
[fvp-oe-uboot]="$linaro_release/fvp-latest-oe-uboot/Image"
[fvp-quad-busybox-uboot]="$tfa_downloads/quad_cluster/Image"
)

# FVP initrd URLs
declare -A fvp_initrd_urls
fvp_initrd_urls=(
[aarch32-ramdisk]="$linaro_release/fvp32-latest-busybox-uboot/ramdisk.img"
[dummy-ramdisk]="$linaro_release/fvp-latest-oe-uboot/ramdisk.img"
[dummy-ramdisk32]="$linaro_release/fvp32-latest-oe-uboot/ramdisk.img"
[default]="$linaro_release/fvp-latest-busybox-uboot/ramdisk.img"
)

get_optee_bin() {
	url="$jenkins_url/job/tf-optee-build/PLATFORM_FLAVOR=fvp,label=arch-dev/lastSuccessfulBuild/artifact/artefacts/tee.bin" \
               saveas="bl32.bin" fetch_file
	archive_file "bl32.bin"
}

# For Measured Boot tests using a TA based on OPTEE, it is necessary to use a
# specific build rather than the default one generated by Jenkins.
get_ftpm_optee_bin() {
	url="$tfa_downloads/ftpm/optee/tee-header_v2.bin" \
		saveas="bl32.bin" fetch_file
	archive_file "bl32.bin"

	url="$tfa_downloads/ftpm/optee/tee-pager_v2.bin" \
		saveas="bl32_extra1.bin" fetch_file
	archive_file "bl32_extra1.bin"

	url="$tfa_downloads/ftpm/optee/tee-pageable_v2.bin" \
		saveas="bl32_extra2.bin" fetch_file
	archive_file "bl32_extra2.bin"
}

get_uboot32_bin() {
	local tmpdir="$(mktempdir)"

	pushd "$tmpdir"
	extract_fip "$uboot32_fip_url"
	mv "nt-fw.bin" "uboot.bin"
	archive_file "uboot.bin"
	popd
}

get_uboot_bin() {
	local uboot_url="$linaro_release/fvp-latest-busybox-uboot/bl33-uboot.bin"

	url="$uboot_url" saveas="uboot.bin" fetch_file
	archive_file "uboot.bin"
}

get_uefi_bin() {
	uefi_downloads="${uefi_downloads:-http://files.oss.arm.com/downloads/uefi}"
	uefi_ci_bin_url="${uefi_ci_bin_url:-$uefi_downloads/Artifacts/Linux/github/fvp/static/DEBUG_GCC5/FVP_AARCH64_EFI.fd}"

	url=$uefi_ci_bin_url saveas="uefi.bin" fetch_file
	archive_file "uefi.bin"
}

get_kernel() {
	local kernel_type="${kernel_type:?}"
	local url="${fvp_kernels[$kernel_type]}"

	url="${url:?}" saveas="kernel.bin" fetch_file
	archive_file "kernel.bin"
}

get_initrd() {
	local initrd_type="${initrd_type:?}"
	local url="${fvp_initrd_urls[$initrd_type]}"

	url="${url:?}" saveas="initrd.bin" fetch_file
	archive_file "initrd.bin"
}

get_dtb() {
	local dtb_type="${dtb_type:?}"
	local dtb_url
	local dtb_saveas="$workspace/dtb.bin"
	local cc="$(get_tf_opt CROSS_COMPILE)"
	local pp_flags="-P -nostdinc -undef -x assembler-with-cpp"

	case "$dtb_type" in
		"fvp-base-quad-cluster-gicv3-psci")
			# Get the quad-cluster FDT from pdsw area
			dtb_url="$tfa_downloads/quad_cluster/fvp-base-quad-cluster-gicv3-psci.dtb"
			url="$dtb_url" saveas="$dtb_saveas" fetch_file
			;;
		"sgm775")
			# Get the SGM775 FDT from pdsw area
			dtb_url="$sgm_prebuilts/sgm775.dtb"
			url="$dtb_url" saveas="$dtb_saveas" fetch_file
			;;
		*)
			# Preprocess DTS file
			${cc}gcc -E ${pp_flags} -I"$tf_root/fdts" -I"$tf_root/include" \
				-o "$workspace/${dtb_type}.pre.dts" \
				"$tf_root/fdts/${dtb_type}.dts"
			# Generate DTB file from DTS
			dtc -I dts -O dtb \
				"$workspace/${dtb_type}.pre.dts" -o "$dtb_saveas"
	esac

	archive_file "$dtb_saveas"
}

get_rootfs() {
	local tmpdir
	local fs_base="$(echo $(basename $rootfs_url) | sed 's/\.gz$//')"
	local cached="$project_filer/ci-files/$fs_base"

	if upon "$jenkins_run" && [ -f "$cached" ]; then
		# Job workspace is limited in size, and the root file system is
		# quite large. This means, parallel runs of root file system
		# tests could fail. So, for Jenkins runs, copy and use the root
		# file system image from the $CI_SCRATCH location
		local private="$CI_SCRATCH/$JOB_NAME-$BUILD_NUMBER"
		mkdir -p "$private"
		rm -f "$private/rootfs.bin"
		url="$cached" saveas="$private/rootfs.bin" fetch_file
		ln -s "$private/rootfs.bin" "$archive/rootfs.bin"
		return
	fi

	tmpdir="$(mktempdir)"
	pushd "$tmpdir"
	url="$rootfs_url" saveas="rootfs.bin" fetch_file

	# Possibly, the filesystem image we just downloaded is compressed.
	# Decompress it if required.
	if file "rootfs.bin" | grep -iq 'gzip compressed data'; then
		echo "Decompressing root file system image rootfs.bin ..."
		gunzip --stdout "rootfs.bin" > uncompressed_fs.bin
		mv uncompressed_fs.bin "rootfs.bin"
	fi

	archive_file "rootfs.bin"
	popd
}

fvp_romlib_jmptbl_backup="$(mktempdir)/jmptbl.i"

fvp_romlib_runtime() {
	local tmpdir="$(mktempdir)"

	# Save BL1 and romlib binaries from original build
	mv "${tf_build_root:?}/${plat:?}/${mode:?}/romlib/romlib.bin" "$tmpdir/romlib.bin"
	mv "${tf_build_root:?}/${plat:?}/${mode:?}/bl1.bin" "$tmpdir/bl1.bin"

	# Patch index file
	cp "${tf_root:?}/plat/arm/board/fvp/jmptbl.i" "$fvp_romlib_jmptbl_backup"
	sed -i '/fdt/ s/.$/&\ patch/' ${tf_root:?}/plat/arm/board/fvp/jmptbl.i

	# Rebuild with patched file
	echo "Building patched romlib:"
	build_tf

	# Retrieve original BL1 and romlib binaries
	mv "$tmpdir/romlib.bin" "${tf_build_root:?}/${plat:?}/${mode:?}/romlib/romlib.bin"
	mv "$tmpdir/bl1.bin" "${tf_build_root:?}/${plat:?}/${mode:?}/bl1.bin"
}

fvp_romlib_cleanup() {
	# Restore original index
	mv "$fvp_romlib_jmptbl_backup" "${tf_root:?}/plat/arm/board/fvp/jmptbl.i"
}


fvp_gen_bin_url() {
    local bin_mode="${bin_mode:?}"
    local bin="${1:?}"

    if upon "$jenkins_run"; then
        echo "$jenkins_url/job/$JOB_NAME/$BUILD_NUMBER/artifact/artefacts/$bin_mode/$bin"
    else
        echo "file://$workspace/artefacts/$bin_mode/$bin"
    fi
}

gen_fvp_yaml_template() {
    local yaml_template_file="$workspace/fvp_template.yaml"

    # must parameters for yaml generation
    local payload_type="${payload_type:?}"

    "$ci_root/script/gen_fvp_${payload_type}_yaml.sh" > "$yaml_template_file"

    archive_file "$yaml_template_file"
}

gen_fvp_yaml() {
    local model="${model:?}"

    local yaml_template_file="$workspace/fvp_template.yaml"
    local yaml_file="$workspace/fvp.yaml"
    local yaml_job_file="$workspace/job.yaml"
    local lava_model_params="$workspace/lava_model_params"

    # this function expects a template, quit if it is not present
    if [ ! -f "$yaml_template_file" ]; then
	return
    fi

    local model_params="${fvp_models[$model]}"
    local model_name="$(echo "${model_params}" | awk -F ';' '{print $1}')"
    local model_dir="$(echo "${model_params}"  | awk -F ';' '{print $2}')"
    local model_bin="$(echo "${model_params}"  | awk -F ';' '{print $3}')"

    # model params are required for correct yaml creation, quit if empty
    if [ -z "${model_name}" ]; then
       echo "FVP model param 'model_name' variable empty, yaml not produced"
       return
    elif [ -z "${model_dir}" ]; then
       echo "FVP model param 'model_dir' variable empty, yaml not produced"
       return
    elif [ -z "${model_bin}"  ]; then
       echo "FVP model param 'model_bin' variable empty, yaml not produced"
       return
    fi

    echo "FVP model params: model_name=$model_name model_dir=$model_dir model_bin=$model_bin"

    # FIXME: Foundation plaforms (model=foundationv8) are failing because LAVA [1]
    # should read two ports, 5000 and 5002, but LAVA does not support this
    # feature, so for the moment avoid creating any LAVA test job definition
    # for this model until a solution is found.
    # [1] https://tf.validation.linaro.org/scheduler/job/33871
    if ! is_arm_jenkins_env; then
     if [ "${model}" = "foundationv8" ]; then
         return
     fi
    fi

    # optional parameters, defaults to globals
    local model_dtb="${model_dtb:-$default_model_dtb}"

    # general artefacts
    bl1="$(fvp_gen_bin_url bl1.bin)"
    fip="$(fvp_gen_bin_url fip.bin)"

    dtb="$(fvp_gen_bin_url ${model_dtb})"
    image="$(fvp_gen_bin_url kernel.bin)"
    ramdisk="$(fvp_gen_bin_url initrd.bin)"

    # tftf's ns_bl[1|2]u.bin and el3_payload artefacts
    ns_bl1u="$(fvp_gen_bin_url ns_bl1u.bin)"
    ns_bl2u="$(fvp_gen_bin_url ns_bl2u.bin)"
    el3_payload="$(fvp_gen_bin_url el3_payload.bin)"

    docker_registry="${docker_registry:-}"
    docker_registry="$(docker_registry_append)"

    docker_name="${docker_registry}$model_name"

    # generic version string
    local version_string="\"Fast Models"' [^\\n]+'"\""

    sed -e "s|\${ARMLMD_LICENSE_FILE}|${armlmd_license_file}|" \
	-e "s|\${ACTIONS_DEPLOY_IMAGES_BL1}|${bl1}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_FIP}|${fip}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_DTB}|${dtb}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_IMAGE}|${image}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_RAMDISK}|${ramdisk}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_NS_BL1U}|${ns_bl1u}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_NS_BL2U}|${ns_bl2u}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_EL3_PAYLOAD}|${el3_payload}|" \
        -e "s|\${BOOT_DOCKER_NAME}|${docker_name}|" \
        -e "s|\${BOOT_IMAGE_DIR}|${model_dir}|" \
        -e "s|\${BOOT_IMAGE_BIN}|${model_bin}|" \
        -e "s|\${BOOT_VERSION_STRING}|${version_string}|" \
        -e "s|\${MODEL}|${model}|" \
        < "$yaml_template_file" \
        > "$yaml_file"

    # LAVA expects 'macro' names for binaries, so replace them
    sed -e "s|bl1.bin|{BL1}|" \
	-e "s|fip.bin|{FIP}|" \
	-e "s|ns_bl1u.bin|{NS_BL1U}|" \
	-e "s|ns_bl2u.bin|{NS_BL2U}|" \
	-e "s|el3_payload.bin|{EL3_PAYLOAD}|" \
	-e "s|kernel.bin|{IMAGE}|" \
	-e "s|initrd.bin|{RAMDISK}|" \
	< "$archive/model_params" \
	> "$lava_model_params"


    # include the model parameters
    while read -r line; do
        if [ -n "$line" ]; then
	    yaml_line="- \"${line}\""
            sed -i -e "/\${BOOT_ARGUMENTS}/i \ \ \ \ $yaml_line" "$yaml_file"
        fi
    done < "$lava_model_params"

    sed -i -e '/\${BOOT_ARGUMENTS}/d' "$yaml_file"
    cp "$yaml_file" "$yaml_job_file"

    archive_file "$yaml_file"
    archive_file "$yaml_job_file"
}

docker_registry_append() {
    # if docker_registry is empty, just use local docker registry
    [ -z "$docker_registry" ] && return

    local last=-1
    local last_char="${docker_registry:last}"

    if [ "$last_char" != '/' ]; then
        docker_registry="${docker_registry}/";
    fi
    echo "$docker_registry"
}

set +u
