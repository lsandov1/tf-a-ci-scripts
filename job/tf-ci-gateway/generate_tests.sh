#!/bin/bash
#
# Copyright (c) 2019, Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

set -e

# Generate test descriptions
"$CI_ROOT/script/gen_test_desc.py"
