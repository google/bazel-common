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

# BUILD rules for javax.inject (https://www.jcp.org/en/jsr/detail?id=330)

licenses(["notice"])  # Apache 2.0 LICENSE at //LICENSE

package(default_visibility = ["//visibility:public"])

java_library(
    name = "jsr330_inject",
    exports = ["@maven//:javax_inject_javax_inject"],
)

java_library(
    name = "tck",
    exports = ["@maven//:javax_inject_javax_inject_tck"],
)
