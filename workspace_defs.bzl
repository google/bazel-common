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

load("@bazel_tools//tools/build_defs/repo:java.bzl", "java_import_external")

_MAVEN_MIRRORS = [
    "http://bazel-mirror.storage.googleapis.com/repo1.maven.org/maven2/",
    "http://repo1.maven.org/maven2/",
    "http://maven.ibiblio.org/maven2/",
]

def _maven_import(artifact, sha256, licenses, **kwargs):
  parts = artifact.split(":")
  group_id = parts[0]
  artifact_id = parts[1]
  version = parts[2]
  name = ("%s_%s" %(group_id, artifact_id)).replace(".", "_").replace("-", "_")
  url_suffix = "{0}/{1}/{2}/{1}-{2}.jar".format(group_id.replace(".", "/"), artifact_id, version)

  java_import_external(
      name = name,
      jar_urls = [base + url_suffix for base in _MAVEN_MIRRORS],
      jar_sha256 = sha256,
      licenses = licenses,
      tags = ["maven_coordinates=" + artifact],
      **kwargs
  )

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

  _maven_import(
      artifact = "javax.annotation:jsr250-api:1.0",
      sha256 = "a1a922d0d9b6d183ed3800dfac01d1e1eb159f0e8c6f94736931c1def54a941f",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.code.findbugs:jsr305:3.0.1",
      sha256 = "c885ce34249682bc0236b4a7d56efcc12048e6135a5baf7a9cde8ad8cda13fcd",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "javax.inject:javax.inject:1",
      sha256 = "91c77044a50c481636c32d916fd89c9118a72195390452c81065080f957de7ff",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "javax.inject:javax.inject-tck:1",
      sha256 = "4a8058994e3c9ef8711f8aebef1276ff46f751fdd81cebd718a327fbaa19470c",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.guava:guava:25.0-jre",
      sha256 = "3fd4341776428c7e0e5c18a7c10de129475b69ab9d30aeafbb5c277bb6074fa9",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.guava:guava-testlib:25.0-jre",
      sha256 = "777159901c2a859497fc24b392bbfd9ad3c527d435a735d20aa159c6cf487553",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.guava:guava-beta-checker:1.0",
      sha256 = "9a01eeec0f94553db9464a9b13e072ba6049ab9c3afdd140edef838224bf71f5",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.errorprone:javac-shaded:9-dev-r4023-3",
      sha256 = "65bfccf60986c47fbc17c9ebab0be626afc41741e0a6ec7109e0768817a36f30",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.googlejavaformat:google-java-format:1.5",
      sha256 = "aa19ad7850fb85178aa22f2fddb163b84d6ce4d0035872f30d4408195ca1144e",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.auto:auto-common:0.10",
      sha256 = "b876b5fddaceeba7d359667f6c4fb8c6f8658da1ab902ffb79ec9a415deede5f",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.auto.factory:auto-factory:1.0-beta5",
      sha256 = "e6bed6aaa879f568449d735561a6a26a5a06f7662ed96ca88d27d2200a8dc6cf",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.auto.service:auto-service:1.0-rc4",
      sha256 = "e422d49c312fd2031222e7306e8108c1b4118eb9c049f1b51eca280bed87e924",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.auto.value:auto-value:1.6",
      sha256 = "fd811b92bb59ae8a4cf7eb9dedd208300f4ea2b6275d726e4df52d8334aaae9d",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.auto.value:auto-value-annotations:1.6",
      sha256 = "d095936c432f2afc671beaab67433e7cef50bba4a861b77b9c46561b801fae69",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.errorprone:error_prone_annotations:2.3.1",
      sha256 = "10a5949aa0f95c8de4fd47edfe20534d2acefd8c224f8afea1f607e112816120",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "junit:junit:4.11",
      sha256 = "90a8e1603eeca48e7e879f3afbc9560715322985f39a274f6f6070b43f9d06fe",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.testing.compile:compile-testing:0.15",
      sha256 = "f741c21d44ddf4580e99cfc537e76d1760d864637aec1e21d5341f672a165d4c",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.mockito:mockito-core:1.9.5",
      sha256 = "f97483ba0944b9fa133aa29638764ddbeadb51ec3dbc02074c58fa2caecd07fa",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.hamcrest:hamcrest-core:1.3",
      sha256 = "66fdef91e9739348df7a096aa384a5685f4e875584cce89386a7a47251c4d8e9",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.objenesis:objenesis:1.0",
      sha256 = "c5694b55d92527479382f254199b3c6b1d8780f652ad61e9ca59919887f491a8",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.truth:truth:0.40",
      sha256 = "4868998229b155dcbe68416803975d491704f7cdb6847346cf9a49f65067d6fd",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.truth.extensions:truth-java8-extension:0.40",
      sha256 = "86bf9eddcdfbd39ebfae1f782dc8702f9a6bb8829860c87970adca4ead5f326f",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.squareup:javapoet:1.11.0",
      sha256 = "1fae529a9a66042cae707f53a00cd9970064a9db873f2e8d3d0cf3f3a3d05257",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "io.grpc:grpc-core:1.2.0",
      sha256 = "4434ffd957dc5ca752d8a8e6e71fa6d598a05bb02b4fc08e48e53d878a004ee5",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "io.grpc:grpc-netty:1.2.0",
      sha256 = "c9379d17fdec2eae203679495a695b523e01f2541169d28f5b780de298aa17c8",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "io.grpc:grpc-context:1.2.0",
      sha256 = "4f1fed2735f011ba6f8ab1faa003ef67bade9e773f5a5ec4b69eb2a124500ca6",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "io.grpc:grpc-protobuf:1.2.0",
      sha256 = "19797fc26192dfcc4570ec26c12ba84583842b0ccbcd7d54982f922d33209383",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "io.grpc:grpc-stub:1.2.0",
      sha256 = "bf3eae95175ed36eee086d5fb320583fc492b144bd733d6e19515c7568ee2e2b",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "io.grpc:grpc-all:1.2.0",
      sha256 = "6b697a05b203216b853394d276c429da243cdf50f519688b33f4edbbf5f126d7",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "com.google.protobuf:protobuf-java:3.5.0",
      sha256 = "49a3c7b3781d4b7b2d15063e125824260c9b46bdb62494b63b367b661fdb2b26",
      licenses = ["notice"],
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

  _maven_import(
      artifact = "org.checkerframework:checker-compat-qual:2.3.0",
      sha256 = "7b2ebd4c746231525a93912fd66055639fc6a8a9dc28392bc1e0ae239011d5fc",
      licenses = ["notice"],
  )

  ASM_VERSION = "6.1"

  _maven_import(
      artifact = "org.ow2.asm:asm:%s" % ASM_VERSION,
      sha256 = "db788a985a2359666aa29a9a638f03bb67254e4bd5f453a32717593de887b6b1",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.ow2.asm:asm-tree:%s" % ASM_VERSION,
      sha256 = "0f875aebe39dab46ac6588509f3f9e9a55a74ff172cf683a29090a75b7ae5416",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.ow2.asm:asm-commons:%s" % ASM_VERSION,
      sha256 = "303ab9b4484f99f082f6abbf855a28c813400602ef8b8e97e4e75bd36103f399",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.codehaus.plexus:plexus-utils:3.0.20",
      sha256 = "8f3a655545fc5b4cbf12b5eb8a154fccb0c1144423a1450511f44005a3d574a2",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.codehaus.plexus:plexus-classworlds:2.5.2",
      sha256 = "b2931d41740490a8d931cbe0cfe9ac20deb66cca606e679f52522f7f534c9fd7",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.codehaus.plexus:plexus-component-annotations:1.5.5",
      sha256 = "4df7a6a7be64b35bbccf60b5c115697f9ea3421d22674ae67135dde375fcca1f",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.eclipse.sisu:org.eclipse.sisu.plexus:0.3.0",
      sha256 = "807e9bc9e28d57ec0cb6daf04c317b3e13de5899c0282ee0f76c009198739350",
      licenses = ["reciprocal"],
  )

  _maven_import(
      artifact = "org.eclipse.sisu:org.eclipse.sisu.inject:0.3.0",
      sha256 = "11eec6fcc7a47c50c8d7fb7ac69920c33c70cb8df6b7a0d8eb751c813fb1928a",
      licenses = ["reciprocal"],
  )

  _maven_import(
      artifact = "org.apache.maven:maven-artifact:3.3.3",
      sha256 = "c5d2db20550a3de4e796493876114c3b7717fe560c414135e2508c57b80e9a02",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.apache.maven:maven-model:3.3.3",
      sha256 = "a7e386687b962b6064f44115052207fc23a2a997742a156dffd0b434237896d8",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.apache.maven:maven-plugin-api:3.3.3",
      sha256 = "98585500928c4808d17f476e2554432af13ead1ce4720d72a943c0dedecb1fc0",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "javax.enterprise:cdi-api:1.0",
      sha256 = "1f10b2204cc77c919301f20ff90461c3df1b6e6cb148be1c2d22107f4851d423",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.pantsbuild:jarjar:1.6.3",
      sha256 = "dbcc085f6db9dc8fc71cb18ff0e6f87ecade1dd9ad3a9b85bdc8da3fef76c018",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.apache.ant:ant:1.9.6",
      sha256 = "d74de0bc55631476ba8443c07f43c9c51654ed5a1e0c1942ca015724d633e9bf",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "org.apache.ant:ant-launcher:1.9.6",
      sha256 = "f2c66a60fdacf78d6537734ef1c8edb77cf6c4532e705ee3482be1d1006c277a",
      licenses = ["notice"],
  )

  _maven_import(
      artifact = "log4j:log4j:1.2.15",
      sha256 = "9f5f5799707881451a39c1b2dd22b4e43b97a80698db7daf1c9697f545e24387",
      licenses = ["notice"],
  )
