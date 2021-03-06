#!/usr/bin/env bash
#
# Copyright (c) 2019-2020 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

# model_version, model_build set in post_fetch_tf_resource
set_model_path "$warehouse/SysGen/Models/$model_version/$model_build/models/$model_flavour/FVP_Base_Cortex-A32x4"

source "$ci_root/model/fvp_common.sh"

cat <<EOF >>"$model_param_file"

${reset_to_spmin+-C cluster0.cpu0.RVBARADDR=${bl32_addr:?}}
${reset_to_spmin+-C cluster0.cpu1.RVBARADDR=${bl32_addr:?}}
${reset_to_spmin+-C cluster0.cpu2.RVBARADDR=${bl32_addr:?}}
${reset_to_spmin+-C cluster0.cpu3.RVBARADDR=${bl32_addr:?}}

EOF
