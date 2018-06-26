#!/bin/sh
EXITCODE=`omd status -b ${CMK_SITE} | grep -q -- "OVERALL 0"`
exit $EXITCODE
