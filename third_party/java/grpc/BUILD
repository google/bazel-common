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

# BUILD rules for https://github.com/grpc/grpc-java

load("@rules_java//java:defs.bzl", "java_library")

package(default_visibility = ["//visibility:public"])

java_library(
    name = "grpc",
    exports = ["@maven//:io_grpc_grpc_all"],
)

java_library(
    name = "api",
    exports = ["@maven//:io_grpc_grpc_api"],
)

java_library(
    name = "core",
    exports = ["@maven//:io_grpc_grpc_core"],
)

java_library(
    name = "netty",
    exports = ["@maven//:io_grpc_grpc_netty"],
)

java_library(
    name = "context",
    exports = [":api"],  # why not @maven//:io_grpc_grpc_context?
)

java_library(
    name = "protobuf",
    exports = ["@maven//:io_grpc_grpc_protobuf"],
)

java_library(
    name = "stub",
    exports = ["@maven//:io_grpc_grpc_stub"],
)
