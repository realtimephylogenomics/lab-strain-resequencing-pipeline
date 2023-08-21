####
#
# Verify installation
# V0.1
# Joe Parker @lonelyjoeparker
#
# This is an MVP minimum viable product script.
# It is intended to test the basecalling (guppy), assembly (flye),
# and metagenomics classification (kraken) software is correctly installed.
#
# It assumes the install script has already run.
#
# USAGE
#   bash verify_installation.#!/bin/sh
#
# output
#   <to be decided>
#

# get test data
get https://s3.console.aws.amazon.com/s3/object/genomics-2023-test-data?region=eu-west-1&prefix=AMP551_14a1252d_289f5c8f_0.fast5

# run guppy to basecall

# run flye to assemble

# run kraken to classify
