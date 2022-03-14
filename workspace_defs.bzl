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
load("@bazel_tools//tools/build_defs/repo:java.bzl", "java_import_external")

_MAVEN_MIRRORS = [
    "http://bazel-mirror.storage.googleapis.com/repo1.maven.org/maven2/",
    "https://repo1.maven.org/maven2/",
    "http://maven.ibiblio.org/maven2/",
]

def maven_import(group_id, artifact_id, version, sha256, licenses, **kwargs):
    """Import a JAR indexed by Maven.

    The target will be tagged so that a pom.xml dependency entry can be
    reconstructed from it.

    Args:
      group_id: (string) Group ID of the Maven JAR.
      artifact_id: (string) Atifact ID of the Maven JAR.
      version: (string) Version number of the Maven JAR.
      sha256: (string) The SHA256 hash of the JAR being imported.
      licenses: (List[string]) License types of the imported project.
      **kwargs: Other args to java_import_external

    Defines:
      <group_id>_<artifact_id>: (java_import_external) The imported library.
    """

    name = "{0}_{1}".format(group_id, artifact_id).replace(".", "_").replace("-", "_")
    url_suffix = "{0}/{1}/{2}/{1}-{2}.jar".format(group_id.replace(".", "/"), artifact_id, version)
    coordinates = "{0}:{1}:{2}".format(group_id, artifact_id, version)

    # TODO(cpovirk): Consider jvm_maven_import_external.
    java_import_external(
        name = name,
        jar_urls = [base + url_suffix for base in _MAVEN_MIRRORS],
        jar_sha256 = sha256,
        licenses = licenses,
        # TODO(cpovirk): Remove after https://github.com/bazelbuild/bazel/issues/10838 is fixed.
        rule_load = """load("@rules_java//java:defs.bzl", "java_import")""",
        tags = ["maven_coordinates=" + coordinates],
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
        api_level = 30,
        build_tools_version = "30.0.2",
    )

    maven_import(
        group_id = "javax.annotation",
        artifact_id = "jsr250-api",
        version = "1.0",
        licenses = ["notice"],
        sha256 = "a1a922d0d9b6d183ed3800dfac01d1e1eb159f0e8c6f94736931c1def54a941f",
    )

    maven_import(
        group_id = "com.google.code.findbugs",
        artifact_id = "jsr305",
        version = "3.0.1",
        licenses = ["notice"],
        sha256 = "c885ce34249682bc0236b4a7d56efcc12048e6135a5baf7a9cde8ad8cda13fcd",
    )

    maven_import(
        group_id = "javax.inject",
        artifact_id = "javax.inject",
        version = "1",
        licenses = ["notice"],
        sha256 = "91c77044a50c481636c32d916fd89c9118a72195390452c81065080f957de7ff",
    )

    maven_import(
        group_id = "javax.inject",
        artifact_id = "javax.inject-tck",
        version = "1",
        licenses = ["notice"],
        sha256 = "4a8058994e3c9ef8711f8aebef1276ff46f751fdd81cebd718a327fbaa19470c",
    )

    maven_import(
        group_id = "com.google.guava",
        artifact_id = "guava",
        version = "31.0.1-jre",
        licenses = ["notice"],
        sha256 = "d5be94d65e87bd219fb3193ad1517baa55a3b88fc91d21cf735826ab5af087b9",
    )

    maven_import(
        group_id = "com.google.guava",
        artifact_id = "guava-testlib",
        version = "31.0.1-jre",
        licenses = ["notice"],
        sha256 = "22b08178b92c540553be9231d74d682cf7d65bce244903e64aca1e8715ec5b87",
    )

    maven_import(
        group_id = "com.google.guava",
        artifact_id = "failureaccess",
        version = "1.0.1",
        licenses = ["notice"],
        sha256 = "a171ee4c734dd2da837e4b16be9df4661afab72a41adaf31eb84dfdaf936ca26",
    )

    maven_import(
        group_id = "com.google.guava",
        artifact_id = "guava-beta-checker",
        version = "1.0",
        licenses = ["notice"],
        sha256 = "9a01eeec0f94553db9464a9b13e072ba6049ab9c3afdd140edef838224bf71f5",
    )

    maven_import(
        group_id = "com.google.errorprone",
        artifact_id = "javac-shaded",
        version = "9-dev-r4023-3",
        licenses = ["notice"],
        sha256 = "65bfccf60986c47fbc17c9ebab0be626afc41741e0a6ec7109e0768817a36f30",
    )

    maven_import(
        group_id = "com.google.googlejavaformat",
        artifact_id = "google-java-format",
        version = "1.5",
        licenses = ["notice"],
        sha256 = "aa19ad7850fb85178aa22f2fddb163b84d6ce4d0035872f30d4408195ca1144e",
    )

    maven_import(
        group_id = "com.google.auto",
        artifact_id = "auto-common",
        version = "1.1.2",
        licenses = ["notice"],
        sha256 = "bfe85e517250fc208afd2b031a2ba80f26529c92536484841b4a60661ca1e3f5",
    )

    maven_import(
        group_id = "com.google.auto.factory",
        artifact_id = "auto-factory",
        version = "1.0",
        licenses = ["notice"],
        sha256 = "2ae46041b49eba3909163d345ac8ad984a9d7da5fa5312cfe3ef872854e8414f",
    )

    maven_import(
        group_id = "com.google.auto.service",
        artifact_id = "auto-service",
        version = "1.0",
        licenses = ["notice"],
        sha256 = "4ae44dd05b49a1109a463c0d2aaf920c24f76d1e996bb89f29481c4ff75ec526",
    )

    maven_import(
        group_id = "com.google.auto.service",
        artifact_id = "auto-service-annotations",
        version = "1.0",
        licenses = ["notice"],
        sha256 = "44752893119fdaf01b4c5ee74e46e5dab86f2dcda18114c562f877355c6ed26e",
    )

    maven_import(
        group_id = "com.google.auto.value",
        artifact_id = "auto-value",
        version = "1.6",
        licenses = ["notice"],
        sha256 = "fd811b92bb59ae8a4cf7eb9dedd208300f4ea2b6275d726e4df52d8334aaae9d",
    )

    maven_import(
        group_id = "com.google.auto.value",
        artifact_id = "auto-value-annotations",
        version = "1.6",
        licenses = ["notice"],
        sha256 = "d095936c432f2afc671beaab67433e7cef50bba4a861b77b9c46561b801fae69",
    )

    ERROR_PRONE_VERSION = "2.3.2"
    maven_import(
        group_id = "com.google.errorprone",
        artifact_id = "error_prone_annotation",
        version = ERROR_PRONE_VERSION,
        licenses = ["notice"],
        sha256 = "af5d197f1a89be14eba9d2e5e9b777ce65b3a29d90ee78ff56e20a6dc3c64c26",
    )

    maven_import(
        group_id = "com.google.errorprone",
        artifact_id = "error_prone_annotations",
        version = ERROR_PRONE_VERSION,
        licenses = ["notice"],
        sha256 = "357cd6cfb067c969226c442451502aee13800a24e950fdfde77bcdb4565a668d",
    )

    maven_import(
        group_id = "com.google.errorprone",
        artifact_id = "error_prone_check_api",
        version = ERROR_PRONE_VERSION,
        licenses = ["notice"],
        sha256 = "b63b7b79b8dd12f8a171f1b65ede614a36565fc9d954601db2f24d2d33a4db46",
    )

    maven_import(
        group_id = "junit",
        artifact_id = "junit",
        version = "4.12",
        licenses = ["notice"],
        sha256 = "59721f0805e223d84b90677887d9ff567dc534d7c502ca903c0c2b17f05c116a",
    )

    maven_import(
        group_id = "com.google.testing.compile",
        artifact_id = "compile-testing",
        version = "0.18",
        licenses = ["notice"],
        sha256 = "92cfbee5ad356a403d36688ab7bae74be65db9a117478ace34ac3ab4d1f9feb9",
    )

    maven_import(
        group_id = "net.bytebuddy",
        artifact_id = "byte-buddy",
        version = "1.9.10",
        licenses = ["notice"],
        sha256 = "2936debc4d7b6c534848d361412e2d0f8bd06f7f27a6f4e728a20e97648d2bf3",
    )

    maven_import(
        group_id = "net.bytebuddy",
        artifact_id = "byte-buddy-agent",
        version = "1.9.10",
        licenses = ["notice"],
        sha256 = "8ed739d29132103250d307d2e8e3c95f07588ef0543ab11d2881d00768a5e182",
    )

    maven_import(
        group_id = "org.mockito",
        artifact_id = "mockito-core",
        version = "2.28.2",
        licenses = ["notice"],
        sha256 = "b0af36fed3a6c2147c0cd9028a1d814fd4f4e8196c539f2befddb61ca6ec9e27",
    )

    maven_import(
        group_id = "org.hamcrest",
        artifact_id = "hamcrest-core",
        version = "1.3",
        licenses = ["notice"],
        sha256 = "66fdef91e9739348df7a096aa384a5685f4e875584cce89386a7a47251c4d8e9",
    )

    maven_import(
        group_id = "org.objenesis",
        artifact_id = "objenesis",
        version = "1.0",
        licenses = ["notice"],
        sha256 = "c5694b55d92527479382f254199b3c6b1d8780f652ad61e9ca59919887f491a8",
    )

    maven_import(
        group_id = "com.google.truth",
        artifact_id = "truth",
        version = "1.1",
        licenses = ["notice"],
        sha256 = "42ae0c8871398c3077eb782cb556490e2a0ce292fd73a9be81f0cc15c013991e",
    )

    maven_import(
        group_id = "com.google.truth.extensions",
        artifact_id = "truth-java8-extension",
        version = "1.1",
        licenses = ["notice"],
        sha256 = "b1d160ca17b9d105f985d24cd255684ed4b59ee016f8dcbcd541dae558a57b1e",
    )

    maven_import(
        group_id = "com.squareup",
        artifact_id = "javapoet",
        version = "1.13.0",
        licenses = ["notice"],
        sha256 = "4c7517e848a71b36d069d12bb3bf46a70fd4cda3105d822b0ed2e19c00b69291",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-core",
        version = "1.2.0",
        licenses = ["notice"],
        sha256 = "4434ffd957dc5ca752d8a8e6e71fa6d598a05bb02b4fc08e48e53d878a004ee5",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-netty",
        version = "1.2.0",
        licenses = ["notice"],
        sha256 = "c9379d17fdec2eae203679495a695b523e01f2541169d28f5b780de298aa17c8",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-context",
        version = "1.2.0",
        licenses = ["notice"],
        sha256 = "4f1fed2735f011ba6f8ab1faa003ef67bade9e773f5a5ec4b69eb2a124500ca6",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-protobuf",
        version = "1.2.0",
        licenses = ["notice"],
        sha256 = "19797fc26192dfcc4570ec26c12ba84583842b0ccbcd7d54982f922d33209383",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-stub",
        version = "1.2.0",
        licenses = ["notice"],
        sha256 = "bf3eae95175ed36eee086d5fb320583fc492b144bd733d6e19515c7568ee2e2b",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-all",
        version = "1.2.0",
        licenses = ["notice"],
        sha256 = "6b697a05b203216b853394d276c429da243cdf50f519688b33f4edbbf5f126d7",
    )

    maven_import(
        group_id = "com.google.protobuf",
        artifact_id = "protobuf-java",
        version = "3.7.0",
        licenses = ["notice"],
        sha256 = "dc7f93e3a3dc2c11be5ba9672af3e26410f0a3289312dbf2260d4d8a0c711a51",
    )

    for protobuf_repo in ("com_google_protobuf", "com_google_protobuf_java"):
        http_archive(
            name = protobuf_repo,
            sha256 = "6b6bf5cd8d0cca442745c4c3c9f527c83ad6ef35a405f64db5215889ac779b42",
            strip_prefix = "protobuf-3.19.3",
            urls = ["https://github.com/protocolbuffers/protobuf/archive/v3.19.3.zip"],
        )

    CHECKER_FRAMEWORK_VERSION = "2.5.3"
    maven_import(
        group_id = "org.checkerframework",
        artifact_id = "checker-compat-qual",
        version = CHECKER_FRAMEWORK_VERSION,
        licenses = ["notice"],
        sha256 = "d76b9afea61c7c082908023f0cbc1427fab9abd2df915c8b8a3e7a509bccbc6d",
    )

    maven_import(
        group_id = "org.checkerframework",
        artifact_id = "checker-qual",
        version = CHECKER_FRAMEWORK_VERSION,
        licenses = ["notice"],
        sha256 = "7be622bd25208ccfbb9b634af8bd37aef54368403a1fdce84d908078330a189d",
    )

    maven_import(
        group_id = "org.checkerframework",
        artifact_id = "javacutil",
        version = CHECKER_FRAMEWORK_VERSION,
        licenses = ["notice"],
        sha256 = "8df14d46faaeaa3cca0b148e5a25f7c2e39b502a6b735793999f4f37d52e1617",
    )

    maven_import(
        group_id = "org.checkerframework",
        artifact_id = "dataflow",
        version = CHECKER_FRAMEWORK_VERSION,
        licenses = ["notice"],
        sha256 = "7c2cd62c7e00af8346d476f478fef55122230a5251ffc9c22930f5c27e49325f",
    )

    ASM_VERSION = "9.2"

    maven_import(
        group_id = "org.ow2.asm",
        artifact_id = "asm",
        version = ASM_VERSION,
        licenses = ["notice"],
        sha256 = "b9d4fe4d71938df38839f0eca42aaaa64cf8b313d678da036f0cb3ca199b47f5",
    )

    maven_import(
        group_id = "org.ow2.asm",
        artifact_id = "asm-tree",
        version = ASM_VERSION,
        licenses = ["notice"],
        sha256 = "aabf9bd23091a4ebfc109c1f3ee7cf3e4b89f6ba2d3f51c5243f16b3cffae011",
    )

    maven_import(
        group_id = "org.ow2.asm",
        artifact_id = "asm-commons",
        version = ASM_VERSION,
        licenses = ["notice"],
        sha256 = "be4ce53138a238bb522cd781cf91f3ba5ce2f6ca93ec62d46a162a127225e0a6",
    )

    maven_import(
        group_id = "org.codehaus.plexus",
        artifact_id = "plexus-utils",
        version = "3.0.20",
        licenses = ["notice"],
        sha256 = "8f3a655545fc5b4cbf12b5eb8a154fccb0c1144423a1450511f44005a3d574a2",
    )

    maven_import(
        group_id = "org.codehaus.plexus",
        artifact_id = "plexus-classworlds",
        version = "2.5.2",
        licenses = ["notice"],
        sha256 = "b2931d41740490a8d931cbe0cfe9ac20deb66cca606e679f52522f7f534c9fd7",
    )

    maven_import(
        group_id = "org.codehaus.plexus",
        artifact_id = "plexus-component-annotations",
        version = "1.5.5",
        licenses = ["notice"],
        sha256 = "4df7a6a7be64b35bbccf60b5c115697f9ea3421d22674ae67135dde375fcca1f",
    )

    maven_import(
        group_id = "org.eclipse.sisu",
        artifact_id = "org.eclipse.sisu.plexus",
        version = "0.3.0",
        licenses = ["reciprocal"],
        sha256 = "807e9bc9e28d57ec0cb6daf04c317b3e13de5899c0282ee0f76c009198739350",
    )

    maven_import(
        group_id = "org.eclipse.sisu",
        artifact_id = "org.eclipse.sisu.inject",
        version = "0.3.0",
        licenses = ["reciprocal"],
        sha256 = "11eec6fcc7a47c50c8d7fb7ac69920c33c70cb8df6b7a0d8eb751c813fb1928a",
    )

    maven_import(
        group_id = "org.apache.maven",
        artifact_id = "maven-artifact",
        version = "3.3.3",
        licenses = ["notice"],
        sha256 = "c5d2db20550a3de4e796493876114c3b7717fe560c414135e2508c57b80e9a02",
    )

    maven_import(
        group_id = "org.apache.maven",
        artifact_id = "maven-model",
        version = "3.3.3",
        licenses = ["notice"],
        sha256 = "a7e386687b962b6064f44115052207fc23a2a997742a156dffd0b434237896d8",
    )

    maven_import(
        group_id = "org.apache.maven",
        artifact_id = "maven-plugin-api",
        version = "3.3.3",
        licenses = ["notice"],
        sha256 = "98585500928c4808d17f476e2554432af13ead1ce4720d72a943c0dedecb1fc0",
    )

    maven_import(
        group_id = "javax.enterprise",
        artifact_id = "cdi-api",
        version = "1.0",
        licenses = ["notice"],
        sha256 = "1f10b2204cc77c919301f20ff90461c3df1b6e6cb148be1c2d22107f4851d423",
    )

    maven_import(
        group_id = "org.pantsbuild",
        artifact_id = "jarjar",
        version = "1.7.2",
        licenses = ["notice"],
        sha256 = "0706a455e17b67718abe212e3a77688bbe8260852fc74e3e836d9f2e76d91c27",
    )

    maven_import(
        group_id = "org.apache.ant",
        artifact_id = "ant",
        version = "1.9.6",
        licenses = ["notice"],
        sha256 = "d74de0bc55631476ba8443c07f43c9c51654ed5a1e0c1942ca015724d633e9bf",
    )

    maven_import(
        group_id = "org.apache.ant",
        artifact_id = "ant-launcher",
        version = "1.9.6",
        licenses = ["notice"],
        sha256 = "f2c66a60fdacf78d6537734ef1c8edb77cf6c4532e705ee3482be1d1006c277a",
    )

    maven_import(
        group_id = "log4j",
        artifact_id = "log4j",
        version = "1.2.15",
        licenses = ["notice"],
        sha256 = "9f5f5799707881451a39c1b2dd22b4e43b97a80698db7daf1c9697f545e24387",
    )

    LOG4J2_VERSION = "2.17.0"

    maven_import(
        group_id = "org.apache.logging.log4j",
        artifact_id = "log4j-api",
        version = LOG4J2_VERSION,
        licenses = ["notice"],
        sha256 = "ab9cadc80e234580e3f3c8c18644314fccd4b3cd3f7085d4e934866cb561b95d",
    )

    maven_import(
        group_id = "org.apache.logging.log4j",
        artifact_id = "log4j-core",
        version = LOG4J2_VERSION,
        licenses = ["notice"],
        sha256 = "65c33dc9b24a5e5f6cacae62680641582894749c7bf16c951032ef92f3e12a60",
    )

    maven_import(
        group_id = "org.apache.bcel",
        artifact_id = "bcel",
        version = "6.1",
        licenses = ["notice"],
        sha256 = "c35697e7ad4bab018156cc3b75e8742f31fd8cad5bb9762f25bbf669ce01abce",
    )

    skylib_version = "0.9.0"
    http_archive(
        name = "bazel_skylib",
        strip_prefix = "bazel-skylib-{}".format(skylib_version),
        url = "https://github.com/bazelbuild/bazel-skylib/archive/{}.tar.gz".format(skylib_version),
        sha256 = "9245b0549e88e356cd6a25bf79f97aa19332083890b7ac6481a2affb6ada9752",
    )

    maven_import(
        group_id = "com.googlecode.java-diff-utils",
        artifact_id = "diffutils",
        version = "1.3.0",
        licenses = ["notice"],
        sha256 = "61ba4dc49adca95243beaa0569adc2a23aedb5292ae78aa01186fa782ebdc5c2",
    )

    maven_import(
        group_id = "org.slf4j",
        artifact_id = "slf4j-api",
        version = "1.7.14",
        licenses = ["notice"],
        sha256 = "b030a29e088dea60b07c7299d25f43cbd120502e10dcae3f382435ecd5de5ddd",
    )

    INCAP_VERSION = "0.2"
    maven_import(
        group_id = "net.ltgt.gradle.incap",
        artifact_id = "incap",
        version = INCAP_VERSION,
        licenses = ["notice"],
        sha256 = "b625b9806b0f1e4bc7a2e3457119488de3cd57ea20feedd513db070a573a4ffd",
    )

    maven_import(
        group_id = "net.ltgt.gradle.incap",
        artifact_id = "incap-processor",
        version = INCAP_VERSION,
        licenses = ["notice"],
        sha256 = "bf596f198825684262ecfead59b17a107f1654051178bd7cf775e2e49b32987d",
    )

    maven_import(
        group_id = "com.google.common.inject",
        artifact_id = "inject-common",
        version = "1.0",
        licenses = ["notice"],
        sha256 = "73fd5e69280220b70dd2bf31af567de8d9e5763db56a0207ba1fd8ed006f7383",
    )
