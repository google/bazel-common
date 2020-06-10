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

# BUILD rules for https://github.com/google/error-prone. Note that Bazel already
# applies the Error Prone compiler to all java compilations - this package exports
# dependencies for Error Prone's libraries

load("@rules_java//java:defs.bzl", "java_library")

package(default_visibility = ["//visibility:public"])

java_library(
    name = "annotations",
    tags = ["maven:compile_only"],
    exports = ["@com_google_errorprone_error_prone_annotations//jar"],
)

java_library(
    name = "error_prone_javac",
    exports = ["@com_google_errorprone_javac_shaded//jar"],
)

java_library(
    name = "check_api",
    exports = [
        "@com_google_errorprone_error_prone_annotation//jar",
        "@com_google_errorprone_error_prone_check_api//jar",
    ],
    runtime_deps = [
        ":annotations",
        ":error_prone_javac",
        "//third_party/java/checker_framework:dataflow",
        "//third_party/java/jsr305_annotations",
        "@com_googlecode_java_diff_utils_diffutils",
    ],
)
