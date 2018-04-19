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

# Skylark rules for using jarjar

licenses(["notice"])  # Apache 2.0 LICENSE at //LICENSE

java_binary(
    name = "jarjar",
    main_class = "org.pantsbuild.jarjar.Main",
    visibility = ["//visibility:public"],
    runtime_deps = [
        "//third_party/java/asm",
        "//third_party/java/asm:asm-commons",
        "//third_party/java/asm:asm-tree",
        "//third_party/java/jsr250_annotations",
        "//third_party/java/jsr330_inject",
        "@javax_enterprise_cdi_api//jar",
        "@org_apache_ant_ant//jar",
        "@org_apache_ant_ant_launcher//jar",
        "@org_apache_maven_maven_artifact//jar",
        "@org_apache_maven_maven_model//jar",
        "@org_apache_maven_maven_plugin_api//jar",
        "@org_codehaus_plexus_plexus_classworlds//jar",
        "@org_codehaus_plexus_plexus_component_annotations//jar",
        "@org_codehaus_plexus_plexus_utils//jar",
        "@org_eclipse_sisu_org_eclipse_sisu_inject//jar",
        "@org_eclipse_sisu_org_eclipse_sisu_plexus//jar",
        "@org_pantsbuild_jarjar//jar",
    ],
)
