#!/bin/bash
#
# Runs all tests, and tests that all libraries build without errors.

readarray -t libraries < <(bazelisk query 'kind(_library, //third_party/...)')

readonly DIR=build_test

mkdir "${DIR}"
trap "rm -r ${DIR}/" EXIT

cat <<BUILD_TEST >> "${DIR}"/BUILD
java_library(
    name = "build_test",
    testonly = True,
    srcs = ["BuildTest.java"],
    deps = [
$(printf '        "%s",\n' "${libraries[@]}")
    ],
)
BUILD_TEST

echo "class BuildTest {}" > "${DIR}"/BuildTest.java

bazelisk build //build_test //third_party/...

bazelisk test //tools/...
