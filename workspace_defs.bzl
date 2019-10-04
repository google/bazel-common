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
"""A WORKSPACE macro for Google open-source libraries to use"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@rules_jvm_external//:defs.bzl", "maven_install")

_MAVEN_MIRRORS = [
    "http://bazel-mirror.storage.googleapis.com/repo1.maven.org/maven2/",
    "http://repo1.maven.org/maven2/",
    "http://maven.ibiblio.org/maven2/",
]

_ASM_VERSION = "6.2.1"
_CHECKER_FRAMEWORK_VERSION = "2.5.3"
_ERROR_PRONE_VERSION = "2.3.2"
_GRPC_VERSION = "1.2.0"
_LOG4J2_VERSION = "2.11.2"
_INCAP_VERSION = "0.2"

MAVEN_ARTIFACTS = [
    "javax.annotation:jsr250-api:1.0",
    "com.google.code.findbugs:jsr305:3.0.1",
    "javax.inject:javax.inject:1",
    "javax.inject:javax.inject-tck:1",
    "com.google.guava:guava:27.1-jre",
    "com.google.guava:guava-testlib:27.1-jre",
    "com.google.guava:failureaccess:1.0.1",
    "com.google.guava:guava-beta-checker:1.0",
    "com.google.errorprone:javac-shaded:9-dev-r4023-3",
    "com.google.googlejavaformat:google-java-format:1.5",
    "com.google.auto:auto-common:0.10",
    "com.google.auto.factory:auto-factory:1.0-beta5",
    "com.google.auto.service:auto-service:1.0-rc4",
    "com.google.auto.value:auto-value:1.6",
    "com.google.auto.value:auto-value-annotations:1.6",
    "com.google.errorprone:error_prone_annotation:" + _ERROR_PRONE_VERSION,
    "com.google.errorprone:error_prone_annotations:" + _ERROR_PRONE_VERSION,
    "com.google.errorprone:error_prone_check_api:" + _ERROR_PRONE_VERSION,
    "junit:junit:4.11",
    "com.google.testing.compile:compile-testing:0.18",
    "net.bytebuddy:byte-buddy:1.9.10",
    "net.bytebuddy:byte-buddy-agent:1.9.10",
    "org.mockito:mockito-core:2.28.2",
    "org.hamcrest:hamcrest-core:1.3",
    "org.objenesis:objenesis:1.0",
    "com.google.truth:truth:0.45",
    "com.google.truth.extensions:truth-java8-extension:0.45",
    "com.squareup:javapoet:1.11.1",
    "io.grpc:grpc-core:" + _GRPC_VERSION,
    "io.grpc:grpc-netty:" + _GRPC_VERSION,
    "io.grpc:grpc-context:" + _GRPC_VERSION,
    "io.grpc:grpc-protobuf:" + _GRPC_VERSION,
    "io.grpc:grpc-stub:" + _GRPC_VERSION,
    "io.grpc:grpc-all:" + _GRPC_VERSION,
    "com.google.protobuf:protobuf-java:3.7.0",
    "org.checkerframework:checker-compat-qual:" + _CHECKER_FRAMEWORK_VERSION,
    "org.checkerframework:checker-qual:" + _CHECKER_FRAMEWORK_VERSION,
    "org.checkerframework:javacutil:" + _CHECKER_FRAMEWORK_VERSION,
    "org.checkerframework:dataflow:" + _CHECKER_FRAMEWORK_VERSION,
    "org.ow2.asm:asm:" + _ASM_VERSION,
    "org.ow2.asm:asm-tree:" + _ASM_VERSION,
    "org.ow2.asm:asm-commons:" + _ASM_VERSION,
    "org.codehaus.plexus:plexus-utils:3.0.20",
    "org.codehaus.plexus:plexus-classworlds:2.5.2",
    "org.codehaus.plexus:plexus-component-annotations:1.5.5",
    "org.eclipse.sisu:org.eclipse.sisu.plexus:0.3.0",
    "org.eclipse.sisu:org.eclipse.sisu.inject:0.3.0",
    "org.apache.maven:maven-artifact:3.3.3",
    "org.apache.maven:maven-model:3.3.3",
    "org.apache.maven:maven-plugin-api:3.3.3",
    "javax.enterprise:cdi-api:1.0",
    "org.pantsbuild:jarjar:1.6.3",
    "org.apache.ant:ant:1.9.6",
    "org.apache.ant:ant-launcher:1.9.6",
    "log4j:log4j:1.2.15",
    "org.apache.logging.log4j:log4j-api:" + _LOG4J2_VERSION,
    "org.apache.logging.log4j:log4j-core:" + _LOG4J2_VERSION,
    "org.apache.bcel:bcel:6.1",
    "com.googlecode.java-diff-utils:diffutils:1.3.0",
    "org.slf4j:slf4j-api:1.7.14",
    "net.ltgt.gradle.incap:incap:" + _INCAP_VERSION,
    "net.ltgt.gradle.incap:incap-processor:" + _INCAP_VERSION,
    "com.google.common.inject:inject-common:1.0",
]

def google_common_workspace_rules():
    """Defines WORKSPACE rules for Google open-source libraries.

    Call this once at the top of your WORKSPACE file to load all of the repositories. Note that you
    should not refer to these repositories directly and instead prefer to use the targets defined in
    //third_party.
    """

    native.android_sdk_repository(
        name = "androidsdk",
        api_level = 29,
        build_tools_version = "29.0.2",
    )

    maven_install(
        artifacts = MAVEN_ARTIFACTS,
        repositories = _MAVEN_MIRRORS,
    )

    for protobuf_repo in ("com_google_protobuf", "com_google_protobuf_java"):
        # Based on 3.7.x branch. 3.7.0's tag was missing a fix to build with bazel
        # TODO(user,ronshapiro): update to the next available tagged released when possible
        http_archive(
            name = protobuf_repo,
            sha256 = "64bde341a59bd4abca6bee85cbc5372ee0eff7a20bf07815931096efc2b58a40",
            strip_prefix = "protobuf-57b6597f467c2b614a458051f60ba467c5d697ae",
            urls = ["https://github.com/protocolbuffers/protobuf/archive/57b6597f467c2b614a458051f60ba467c5d697ae.zip"],
        )
