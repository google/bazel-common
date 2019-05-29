# Copyright (C) 2019 The Google Bazel Common Authors.
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

# BUILD rules for https://github.com/tbroyer/gradle-incap-helper

licenses(["notice"])  # Apache 2.0 LICENSE at //LICENSE

package(default_visibility = ["//visibility:public"])

java_library(
    name = "incap",
    exported_plugins = [":processor"],
    exports = ["@net_ltgt_gradle_incap_incap//jar"],
)

java_plugin(
    name = "processor",
    processor_class = "net.ltgt.gradle.incap.processor.IncrementalAnnotationProcessorProcessor",
    visibility = ["//visibility:private"],
    deps = [
        "@net_ltgt_gradle_incap_incap//jar",
        "@net_ltgt_gradle_incap_incap_processor//jar",
    ],
)
