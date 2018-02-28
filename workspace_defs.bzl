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

def google_common_workspace_rules():
  """Defines WORKSPACE rules for Google open-source libraries.

  Call this once at the top of your WORKSPACE file to load all of the repositories. Note that you
  should not refer to these repositories directly and instead prefer to use the targets defined in
  //third_party.
  """

  native.android_sdk_repository(
      name = "androidsdk",
      api_level = 26,
      build_tools_version = "26.0.2",
  )

  native.maven_jar(
      name = "javax_annotation_jsr250_api",
      artifact = "javax.annotation:jsr250-api:1.0",
      sha1 = "5025422767732a1ab45d93abfea846513d742dcf",
  )

  native.maven_jar(
      name = "com_google_code_findbugs_jsr305",
      artifact = "com.google.code.findbugs:jsr305:3.0.1",
      sha1 = "f7be08ec23c21485b9b5a1cf1654c2ec8c58168d",
  )

  native.maven_jar(
      name = "javax_inject_javax_inject",
      artifact = "javax.inject:javax.inject:1",
      sha1 = "6975da39a7040257bd51d21a231b76c915872d38",
  )

  native.maven_jar(
      name = "javax_inject_javax_inject_tck",
      artifact = "javax.inject:javax.inject-tck:1",
      sha1 = "bb0090d50219c265be40fcc8e034dae37fa7be99",
  )

  native.maven_jar(
      name = "com_google_guava_guava",
      artifact = "com.google.guava:guava:24.0-jre",
      sha1 = "041ac1e74d6b4e1ea1f027139cffeb536c732a81",
  )

  native.maven_jar(
      name = "com_google_guava_guava_testlib",
      artifact = "com.google.guava:guava-testlib:24.0-jre",
      sha1 = "8c960e7ce5d3dd662b456c6d567ee0417512c6c3",
  )

  native.maven_jar(
      name = "com_google_errorprone_javac",
      artifact = "com.google.errorprone:javac-shaded:9-dev-r4023-3",
      sha1 = "72b688efd290280a0afde5f9892b0fde6f362d1d",
  )

  native.maven_jar(
      name = "com_google_googlejavaformat_google_java_format",
      artifact = "com.google.googlejavaformat:google-java-format:1.5",
      sha1 = "fba7f130d29061d2d2ea384b4880c10cae92ef73",
  )

  native.maven_jar(
      name = "com_google_auto_auto_common",
      artifact = "com.google.auto:auto-common:0.10",
      sha1 = "c8f153ebe04a17183480ab4016098055fb474364",
  )

  native.maven_jar(
      name = "com_google_auto_factory_auto_factory",
      artifact = "com.google.auto.factory:auto-factory:1.0-beta5",
      sha1 = "78b93b2334d0e2fb0d65c00127d4dcce261a83fc",
  )

  native.maven_jar(
      name = "com_google_auto_service_auto_service",
      artifact = "com.google.auto.service:auto-service:1.0-rc4",
      sha1 = "44954d465f3b9065388bbd2fc08a3eb8fd07917c",
  )

  native.maven_jar(
      name = "com_google_auto_value_auto_value",
      artifact = "com.google.auto.value:auto-value:1.5.3",
      sha1 = "514df6a7c7938de35c7f68dc8b8f22df86037f38",
  )

  native.maven_jar(
      name = "com_google_errorprone_error_prone_annotations",
      artifact = "com.google.errorprone:error_prone_annotations:2.2.0",
      sha1 = "88e3c593e9b3586e1c6177f89267da6fc6986f0c",
  )

  native.maven_jar(
      name = "junit_junit",
      artifact = "junit:junit:4.11",
      sha1 = "4e031bb61df09069aeb2bffb4019e7a5034a4ee0",
  )

  native.maven_jar(
      name = "com_google_testing_compile_compile_testing",
      artifact = "com.google.testing.compile:compile-testing:0.15",
      sha1 = "d6619b8484ee928fdd7520c0aa6d1c1ffb1d781b",
  )

  native.maven_jar(
      name = "org_mockito_mockito_core",
      artifact = "org.mockito:mockito-core:1.9.5",
      sha1 = "c3264abeea62c4d2f367e21484fbb40c7e256393",
  )

  native.maven_jar(
      name = "org_hamcrest_hamcrest_core",
      artifact = "org.hamcrest:hamcrest-core:1.3",
      sha1 = "42a25dc3219429f0e5d060061f71acb49bf010a0",
  )

  native.maven_jar(
      name = "org_objenesis_objenesis",
      artifact = "org.objenesis:objenesis:1.0",
      sha1 = "9b473564e792c2bdf1449da1f0b1b5bff9805704",
  )

  native.maven_jar(
      name = "com_google_truth_truth",
      artifact = "com.google.truth:truth:0.39",
      sha1 = "bd1bf5706ff34eb7ff80fef8b0c4320f112ef899",
  )

  native.maven_jar(
      name = "com_google_truth_extensions_truth_java8_extension",
      artifact = "com.google.truth.extensions:truth-java8-extension:0.39",
      sha1 = "1499bc88cda9d674afb30da9813b44bcd4512d0d",
  )

  native.maven_jar(
      name = "com_squareup_javapoet",
      artifact = "com.squareup:javapoet:1.10.0",
      sha1 = "712c178d35185d8261295913c9f2a7d6867a6007",
  )

  native.maven_jar(
      name = "io_grpc_grpc_core",
      artifact = "io.grpc:grpc-core:1.2.0",
      sha1 = "f12a213e2b59a0615df2cc9bed35dc15fd2fee37",
  )

  native.maven_jar(
      name = "io_grpc_grpc_netty",
      artifact = "io.grpc:grpc-netty:1.2.0",
      sha1 = "e2682d2dc052898f87433e7a6d03d104ef98df74",
  )

  native.maven_jar(
      name = "io_grpc_grpc_context",
      artifact = "io.grpc:grpc-context:1.2.0",
      sha1 = "1932db544cbb427bc18f902c7ebbb3f7e44991df",
  )

  native.maven_jar(
      name = "io_grpc_grpc_protobuf",
      artifact = "io.grpc:grpc-protobuf:1.2.0",
      sha1 = "2676852d2dbd20155d9b1a940a456eae5b7445f0",
  )

  native.maven_jar(
      name = "io_grpc_grpc_stub",
      artifact = "io.grpc:grpc-stub:1.2.0",
      sha1 = "964dda53b3085bfd17c7aaf51495f9efc8bda36c",
  )

  native.maven_jar(
      name = "io_grpc_grpc_all",
      artifact = "io.grpc:grpc-all:1.2.0",
      sha1 = "f32006a1245dfa2d68bf92a1b4cc01831889c95b",
  )

  native.maven_jar(
      name = "com_google_protobuf_protobuf_java",
      artifact = "com.google.protobuf:protobuf-java:3.5.0",
      sha1 = "200fb936907fbab5e521d148026f6033d4aa539e",
  )

  native.http_archive(
      name = "com_google_protobuf",
      sha256 = "cef7f1b5a7c5fba672bec2a319246e8feba471f04dcebfe362d55930ee7c1c30",
      strip_prefix = "protobuf-3.5.0",
      urls = ["https://github.com/google/protobuf/archive/v3.5.0.zip"],
  )

  native.http_archive(
      name = "com_google_protobuf_java",
      sha256 = "cef7f1b5a7c5fba672bec2a319246e8feba471f04dcebfe362d55930ee7c1c30",
      strip_prefix = "protobuf-3.5.0",
      urls = ["https://github.com/google/protobuf/archive/v3.5.0.zip"],
  )

  native.maven_jar(
      name = "org_checkerframework_checker_compat_qual",
      artifact = "org.checkerframework:checker-compat-qual:2.3.0",
      sha1 = "69cb4fea55a9d89b8827d107f17c985cc1a76052",
  )
