#!/bin/bash
#
# Tests that all libraries in bazel-common can build correctly

libraries=""
for library in $(bazel query --output=label_kind //... | \
      grep -v "//tools/maven:" | \
      grep _library | \
      awk '{print $3}'); do
  if [[ -z "${libraries}" ]]; then
    libraries="        \"${library}\","
  else
    printf -v libraries '%s\n        "%s",' "${libraries}" "${library}"
  fi
done

readonly DIR=build_test

mkdir "${DIR}"

cat <<BUILD_TEST >> "${DIR}"/BUILD
java_library(
    name = "build_test",
    srcs = ["BuildTest.java"],
    deps = [
${libraries}
    ],
    testonly = 1,
)
BUILD_TEST

echo "class BuildTest {}" > "${DIR}"/BuildTest.java

trap "rm -rf ${DIR}/" EXIT

bazel build //build_test
