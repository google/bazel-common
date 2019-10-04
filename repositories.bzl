load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def google_common_workspace_dependencies():
    RULES_JVM_EXTERNAL_TAG = "2.8"
    RULES_JVM_EXTERNAL_SHA = "79c9850690d7614ecdb72d68394f994fef7534b292c4867ce5e7dec0aa7bdfad"
    http_archive(
        name = "rules_jvm_external",
        sha256 = RULES_JVM_EXTERNAL_SHA,
        strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
        url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
    )

    skylib_version = "0.9.0"
    http_archive(
        name = "bazel_skylib",
        strip_prefix = "bazel-skylib-{}".format(skylib_version),
        url = "https://github.com/bazelbuild/bazel-skylib/archive/{}.tar.gz".format(skylib_version),
        sha256 = "9245b0549e88e356cd6a25bf79f97aa19332083890b7ac6481a2affb6ada9752",
    )
