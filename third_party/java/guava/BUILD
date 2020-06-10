# Copyright (C) 2018 The Google Bazel Common Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# BUILD rules for https://github.com/google/guava

load("@rules_java//java:defs.bzl", "java_library", "java_plugin")

package(default_visibility = ["//visibility:public"])

java_library(
    name = "guava",
    exported_plugins = [":beta-checker"],
    exports = [
        "@com_google_guava_failureaccess//jar",
        "@com_google_guava_guava//jar",
    ],
)

java_library(
    name = "testlib",
    testonly = 1,
    exports = ["@com_google_guava_guava_testlib//jar"],
    runtime_deps = [":guava"],
)

java_plugin(
    name = "beta-checker",
    visibility = ["//visibility:private"],
    deps = ["@com_google_guava_guava_beta_checker//jar"],
)
