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
        api_level = 32,
        build_tools_version = "32.0.0",
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

    GUAVA_VERSION = "32.1.3-jre"
    maven_import(
        group_id = "com.google.guava",
        artifact_id = "guava",
        version = GUAVA_VERSION,
        licenses = ["notice"],
        sha256 = "6d4e2b5a118aab62e6e5e29d185a0224eed82c85c40ac3d33cf04a270c3b3744",
    )

    maven_import(
        group_id = "com.google.guava",
        artifact_id = "guava-testlib",
        version = GUAVA_VERSION,
        licenses = ["notice"],
        sha256 = "58aca6a4f287ae73e5fd610212bdcdc78d677c4475695009ba1656349dad9079",
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
        version = "1.18.1",
        licenses = ["notice"],
        sha256 = "ebbe63a3dbc0dc2efafaad1df6408f0b510239ccc5e4595bf499ba479e0ae4a9",
    )

    maven_import(
        group_id = "com.google.auto",
        artifact_id = "auto-common",
        version = "1.2.2",
        licenses = ["notice"],
        sha256 = "f50b1ce8a41fad31a8a819c052f8ffa362ea0a3dbe9ef8f7c7dc9a36d4738a59",
    )

    maven_import(
        group_id = "com.google.auto.factory",
        artifact_id = "auto-factory",
        version = "1.0.1",
        licenses = ["notice"],
        sha256 = "d59fb7ada5962a480abf0b81d4d2a14a2952f17c026732359af8b585e531c16c",
    )

    AUTO_SERVICE_VERSION = "1.1.1"
    maven_import(
        group_id = "com.google.auto.service",
        artifact_id = "auto-service",
        version = AUTO_SERVICE_VERSION,
        licenses = ["notice"],
        sha256 = "1f48f451503e623daba7d9ed368cca0f81e1e3815653a4560113e12c0129ebd5",
    )

    maven_import(
        group_id = "com.google.auto.service",
        artifact_id = "auto-service-annotations",
        version = AUTO_SERVICE_VERSION,
        licenses = ["notice"],
        sha256 = "16a76dd00a2650568447f5d6e3a9e2c809d9a42367d56b45215cfb89731f4d24",
    )

    AUTO_VALUE_VERSION = "1.10.4"
    maven_import(
        group_id = "com.google.auto.value",
        artifact_id = "auto-value",
        version = AUTO_VALUE_VERSION,
        licenses = ["notice"],
        sha256 = "f3c438d1f82904bbcb452084d488b660f3c7488e9274c3a58f049e121632d434",
    )

    maven_import(
        group_id = "com.google.auto.value",
        artifact_id = "auto-value-annotations",
        version = AUTO_VALUE_VERSION,
        licenses = ["notice"],
        sha256 = "e1c45e6beadaef9797cb0d9afd5a45621ad061cd8632012f85582853a3887825",
    )

    ERROR_PRONE_VERSION = "2.22.0"
    maven_import(
        group_id = "com.google.errorprone",
        artifact_id = "error_prone_annotation",
        version = ERROR_PRONE_VERSION,
        licenses = ["notice"],
        sha256 = "554c42449c9920ea1f6baec1d1b8aaac404a88be653f7cb441ee059316f8a1d1",
    )

    maven_import(
        group_id = "com.google.errorprone",
        artifact_id = "error_prone_annotations",
        version = ERROR_PRONE_VERSION,
        licenses = ["notice"],
        sha256 = "82a027b86541f58d1f9ee020cdf6bebe82acc7a267d3c53a2ea5cd6335932bbd",
    )

    maven_import(
        group_id = "com.google.errorprone",
        artifact_id = "error_prone_check_api",
        version = ERROR_PRONE_VERSION,
        licenses = ["notice"],
        sha256 = "1717bbf65757b8e1a83f3b0aa78c5ac25a6493008bc730091d404cf798fc0639",
    )

    maven_import(
        group_id = "junit",
        artifact_id = "junit",
        version = "4.13.2",
        licenses = ["notice"],
        sha256 = "8e495b634469d64fb8acfa3495a065cbacc8a0fff55ce1e31007be4c16dc57d3",
    )

    maven_import(
        group_id = "com.google.testing.compile",
        artifact_id = "compile-testing",
        version = "0.21.0",
        licenses = ["notice"],
        sha256 = "da42c0b350c0e5717df91a7e554ee5acbf07f4b87d4d2240589521070b4bce72",
    )

    BYTE_BUDDY_VERSION = "1.14.9"
    maven_import(
        group_id = "net.bytebuddy",
        artifact_id = "byte-buddy",
        version = BYTE_BUDDY_VERSION,
        licenses = ["notice"],
        sha256 = "377352e253282bf86f731ac90ed88348e8f40a63ce033c00a85982de7e790e6f",
    )

    maven_import(
        group_id = "net.bytebuddy",
        artifact_id = "byte-buddy-agent",
        version = BYTE_BUDDY_VERSION,
        licenses = ["notice"],
        sha256 = "11ed107d4b78e55f8c3d34250494375081a29bc125a1f5c56db582ccdd48835f",
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

    TRUTH_VERSION = "1.1.5"
    maven_import(
        group_id = "com.google.truth",
        artifact_id = "truth",
        version = TRUTH_VERSION,
        licenses = ["notice"],
        sha256 = "7f6d50d6f43a102942ef2c5a05f37a84f77788bb448cf33cceebf86d34e575c0",
    )

    maven_import(
        group_id = "com.google.truth.extensions",
        artifact_id = "truth-java8-extension",
        version = TRUTH_VERSION,
        licenses = ["notice"],
        sha256 = "9e3c437ef76c0028d1c87d9f81d599301459333cfb3b50e5bf815ed712745140",
    )

    maven_import(
        group_id = "com.squareup",
        artifact_id = "javapoet",
        version = "1.13.0",
        licenses = ["notice"],
        sha256 = "4c7517e848a71b36d069d12bb3bf46a70fd4cda3105d822b0ed2e19c00b69291",
    )

    GRPC_VERSION = "1.58.0"
    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-core",
        version = GRPC_VERSION,
        licenses = ["notice"],
        sha256 = "93c8880824ee124b91c31f0f1052f86372719d6ece6e4be1c591b7d6dc639f5f",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-netty",
        version = GRPC_VERSION,
        licenses = ["notice"],
        sha256 = "31ffea0cf52351657c34cd476050cea41f61cb2d15863d3424fe457e7d7cac0a",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-context",
        version = GRPC_VERSION,
        licenses = ["notice"],
        sha256 = "3a7626d13084958bcdeab59412e4ec873f07c8315ff2510d363856fac7fadc51",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-protobuf",
        version = GRPC_VERSION,
        licenses = ["notice"],
        sha256 = "77f16774992d5802cfeef7a9d00b3a3f9a82d324ce1cab7f84c6f1a0df5a39c3",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-stub",
        version = GRPC_VERSION,
        licenses = ["notice"],
        sha256 = "1af7bbc56be7b1131c1322ba183126dd050306f91128193f4b9bd5ea71ac8c88",
    )

    maven_import(
        group_id = "io.grpc",
        artifact_id = "grpc-all",
        version = GRPC_VERSION,
        licenses = ["notice"],
        sha256 = "772c347a698c20d6033537b740de01d15610fc49a48878c778965b8e10d39898",
    )

    maven_import(
        group_id = "com.google.protobuf",
        artifact_id = "protobuf-java",
        version = "3.24.4",
        licenses = ["notice"],
        sha256 = "dc7f93e3a3dc2c11be5ba9672af3e26410f0a3289312dbf2260d4d8a0c711a51",
    )

    for protobuf_repo in ("com_google_protobuf", "com_google_protobuf_java"):
        http_archive(
            name = protobuf_repo,
            sha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            strip_prefix = "protobuf-24.4",
            urls = ["https://github.com/protocolbuffers/protobuf/archive/v24.4.zip"],
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

    ASM_VERSION = "9.4"
    maven_import(
        group_id = "org.ow2.asm",
        artifact_id = "asm",
        version = ASM_VERSION,
        licenses = ["notice"],
        sha256 = "39d0e2b3dc45af65a09b097945750a94a126e052e124f93468443a1d0e15f381",
    )

    maven_import(
        group_id = "org.ow2.asm",
        artifact_id = "asm-tree",
        version = ASM_VERSION,
        licenses = ["notice"],
        sha256 = "c42d479cf24566a21eb20af7eeaeef4e86bdb4a886306cf72f483b65e75b2acf",
    )

    maven_import(
        group_id = "org.ow2.asm",
        artifact_id = "asm-commons",
        version = ASM_VERSION,
        licenses = ["notice"],
        sha256 = "0c128a9ec3f33c98959272f6d16cf14247b508f58951574bcdbd2b56d6326364",
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

    LOG4J2_VERSION = "2.17.2"

    maven_import(
        group_id = "org.apache.logging.log4j",
        artifact_id = "log4j-api",
        version = LOG4J2_VERSION,
        licenses = ["notice"],
        sha256 = "09351b5a03828f369cdcff76f4ed39e6a6fc20f24f046935d0b28ef5152f8ce4",
    )

    maven_import(
        group_id = "org.apache.logging.log4j",
        artifact_id = "log4j-core",
        version = LOG4J2_VERSION,
        licenses = ["notice"],
        sha256 = "5adb34ff4197cd16a8d24f63035856a933cb59562a6888dde86e9450fcfef646",
    )

    maven_import(
        group_id = "org.apache.bcel",
        artifact_id = "bcel",
        version = "6.7.0",
        licenses = ["notice"],
        sha256 = "e4a3c54b422efa954c8549caaea993655e59911759206702885e78e6b7fe9c84",
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
