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

# BUILD rules for https://github.com/google/auto

load("@rules_java//java:defs.bzl", "java_library", "java_plugin")

package(default_visibility = ["//visibility:public"])

java_library(
    name = "common",
    exports = ["@google_bazel_common_maven//:com_google_auto_auto_common"],
)

java_plugin(
    name = "auto_value_processor",
    processor_class = "com.google.auto.value.processor.AutoValueProcessor",
    visibility = ["//visibility:private"],
    deps = [
        ":common",
        ":service",
        "//third_party/java/guava",
        "@google_bazel_common_maven//:com_google_auto_value_auto_value",
    ],
)

java_plugin(
    name = "auto_annotation_processor",
    processor_class = "com.google.auto.value.processor.AutoAnnotationProcessor",
    visibility = ["//visibility:private"],
    deps = [
        ":common",
        ":service",
        "//third_party/java/guava",
        "@google_bazel_common_maven//:com_google_auto_value_auto_value",
    ],
)

java_plugin(
    name = "auto_oneof_processor",
    processor_class = "com.google.auto.value.processor.AutoOneOfProcessor",
    visibility = ["//visibility:private"],
    deps = [
        ":common",
        ":service",
        "//third_party/java/guava",
        "@google_bazel_common_maven//:com_google_auto_value_auto_value",
    ],
)

java_plugin(
    name = "auto_builder_processor",
    processor_class = "com.google.auto.value.processor.AutoBuilderProcessor",
    visibility = ["//visibility:private"],
    deps = [
        ":common",
        ":service",
        "//third_party/java/guava",
        "@google_bazel_common_maven//:com_google_auto_value_auto_value",
    ],
)

java_library(
    name = "value",
    exported_plugins = [
        ":auto_annotation_processor",
        ":auto_oneof_processor",
        ":auto_value_processor",
        ":auto_builder_processor",
    ],
    tags = ["maven:compile_only"],
    exports = [
        "//third_party/java/jsr250_annotations",  # TODO(ronshapiro) Can this be removed?
        "@google_bazel_common_maven//:com_google_auto_value_auto_value_annotations",
    ],
)

java_plugin(
    name = "auto_factory_processor",
    generates_api = True,
    processor_class = "com.google.auto.factory.processor.AutoFactoryProcessor",
    visibility = ["//visibility:private"],
    deps = [
        ":common",
        ":service",
        "//third_party/java/google_java_format",
        "//third_party/java/guava",
        "//third_party/java/javapoet",
        "@google_bazel_common_maven//:com_google_auto_factory_auto_factory",
    ],
)

java_library(
    name = "factory",
    exported_plugins = [":auto_factory_processor"],
    exports = ["@google_bazel_common_maven//:com_google_auto_factory_auto_factory"],
)

java_plugin(
    name = "auto_service_processor",
    processor_class = "com.google.auto.service.processor.AutoServiceProcessor",
    visibility = ["//visibility:private"],
    deps = [
        ":common",
        "//third_party/java/guava",
        "@google_bazel_common_maven//:com_google_auto_service_auto_service",
        "@google_bazel_common_maven//:com_google_auto_service_auto_service_annotations",
    ],
)

java_library(
    name = "service",
    exported_plugins = [":auto_service_processor"],
    tags = ["maven:compile_only"],
    exports = ["@google_bazel_common_maven//:com_google_auto_service_auto_service_annotations"],
)
