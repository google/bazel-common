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

def _maven_import(artifact, sha256, licenses, **kwargs):
    parts = artifact.split(":")
    group_id = parts[0]
    artifact_id = parts[1]
    version = parts[2]
    name = ("%s_%s" % (group_id, artifact_id)).replace(".", "_").replace("-", "_")
    url_suffix = "{0}/{1}/{2}/{1}-{2}.jar".format(group_id.replace(".", "/"), artifact_id, version)

    # TODO(cpovirk): Consider jvm_maven_import_external.
    java_import_external(
        name = name,
        jar_urls = [base + url_suffix for base in _MAVEN_MIRRORS],
        jar_sha256 = sha256,
        licenses = licenses,
        # TODO(cpovirk): Remove after https://github.com/bazelbuild/bazel/issues/10838 is fixed.
        rule_load = """load("@rules_java//java:defs.bzl", "java_import")""",
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
        api_level = 29,
        build_tools_version = "29.0.2",
    )

    _maven_import(
        artifact = "javax.annotation:jsr250-api:1.0",
        licenses = ["notice"],
        sha256 = "a1a922d0d9b6d183ed3800dfac01d1e1eb159f0e8c6f94736931c1def54a941f",
    )

    _maven_import(
        artifact = "com.google.code.findbugs:jsr305:3.0.1",
        licenses = ["notice"],
        sha256 = "c885ce34249682bc0236b4a7d56efcc12048e6135a5baf7a9cde8ad8cda13fcd",
    )

    _maven_import(
        artifact = "javax.inject:javax.inject:1",
        licenses = ["notice"],
        sha256 = "91c77044a50c481636c32d916fd89c9118a72195390452c81065080f957de7ff",
    )

    _maven_import(
        artifact = "javax.inject:javax.inject-tck:1",
        licenses = ["notice"],
        sha256 = "4a8058994e3c9ef8711f8aebef1276ff46f751fdd81cebd718a327fbaa19470c",
    )

    _maven_import(
        artifact = "com.google.guava:guava:27.1-jre",
        licenses = ["notice"],
        sha256 = "4a5aa70cc968a4d137e599ad37553e5cfeed2265e8c193476d7119036c536fe7",
    )

    _maven_import(
        artifact = "com.google.guava:guava-testlib:27.1-jre",
        licenses = ["notice"],
        sha256 = "d04c99c926b9e8117685801c16a2d44f89f9e3ca6bbe6d668b65987f164c55c8",
    )

    _maven_import(
        artifact = "com.google.guava:failureaccess:1.0.1",
        licenses = ["notice"],
        sha256 = "a171ee4c734dd2da837e4b16be9df4661afab72a41adaf31eb84dfdaf936ca26",
    )

    _maven_import(
        artifact = "com.google.guava:guava-beta-checker:1.0",
        licenses = ["notice"],
        sha256 = "9a01eeec0f94553db9464a9b13e072ba6049ab9c3afdd140edef838224bf71f5",
    )

    _maven_import(
        artifact = "com.google.errorprone:javac-shaded:9-dev-r4023-3",
        licenses = ["notice"],
        sha256 = "65bfccf60986c47fbc17c9ebab0be626afc41741e0a6ec7109e0768817a36f30",
    )

    _maven_import(
        artifact = "com.google.googlejavaformat:google-java-format:1.5",
        licenses = ["notice"],
        sha256 = "aa19ad7850fb85178aa22f2fddb163b84d6ce4d0035872f30d4408195ca1144e",
    )

    _maven_import(
        artifact = "com.google.auto:auto-common:0.10",
        licenses = ["notice"],
        sha256 = "b876b5fddaceeba7d359667f6c4fb8c6f8658da1ab902ffb79ec9a415deede5f",
    )

    _maven_import(
        artifact = "com.google.auto.factory:auto-factory:1.0-beta5",
        licenses = ["notice"],
        sha256 = "e6bed6aaa879f568449d735561a6a26a5a06f7662ed96ca88d27d2200a8dc6cf",
    )

    _maven_import(
        artifact = "com.google.auto.service:auto-service:1.0-rc4",
        licenses = ["notice"],
        sha256 = "e422d49c312fd2031222e7306e8108c1b4118eb9c049f1b51eca280bed87e924",
    )

    _maven_import(
        artifact = "com.google.auto.value:auto-value:1.6",
        licenses = ["notice"],
        sha256 = "fd811b92bb59ae8a4cf7eb9dedd208300f4ea2b6275d726e4df52d8334aaae9d",
    )

    _maven_import(
        artifact = "com.google.auto.value:auto-value-annotations:1.6",
        licenses = ["notice"],
        sha256 = "d095936c432f2afc671beaab67433e7cef50bba4a861b77b9c46561b801fae69",
    )

    ERROR_PRONE_VERSION = "2.3.2"
    _maven_import(
        artifact = "com.google.errorprone:error_prone_annotation:" + ERROR_PRONE_VERSION,
        licenses = ["notice"],
        sha256 = "af5d197f1a89be14eba9d2e5e9b777ce65b3a29d90ee78ff56e20a6dc3c64c26",
    )

    _maven_import(
        artifact = "com.google.errorprone:error_prone_annotations:" + ERROR_PRONE_VERSION,
        licenses = ["notice"],
        sha256 = "357cd6cfb067c969226c442451502aee13800a24e950fdfde77bcdb4565a668d",
    )

    _maven_import(
        artifact = "com.google.errorprone:error_prone_check_api:" + ERROR_PRONE_VERSION,
        licenses = ["notice"],
        sha256 = "b63b7b79b8dd12f8a171f1b65ede614a36565fc9d954601db2f24d2d33a4db46",
    )

    _maven_import(
        artifact = "junit:junit:4.11",
        licenses = ["notice"],
        sha256 = "90a8e1603eeca48e7e879f3afbc9560715322985f39a274f6f6070b43f9d06fe",
    )

    _maven_import(
        artifact = "com.google.testing.compile:compile-testing:0.18",
        licenses = ["notice"],
        sha256 = "92cfbee5ad356a403d36688ab7bae74be65db9a117478ace34ac3ab4d1f9feb9",
    )

    _maven_import(
        artifact = "net.bytebuddy:byte-buddy:1.9.10",
        licenses = ["notice"],
        sha256 = "2936debc4d7b6c534848d361412e2d0f8bd06f7f27a6f4e728a20e97648d2bf3",
    )

    _maven_import(
        artifact = "net.bytebuddy:byte-buddy-agent:1.9.10",
        licenses = ["notice"],
        sha256 = "8ed739d29132103250d307d2e8e3c95f07588ef0543ab11d2881d00768a5e182",
    )

    _maven_import(
        artifact = "org.mockito:mockito-core:2.28.2",
        licenses = ["notice"],
        sha256 = "b0af36fed3a6c2147c0cd9028a1d814fd4f4e8196c539f2befddb61ca6ec9e27",
    )

    _maven_import(
        artifact = "org.hamcrest:hamcrest-core:1.3",
        licenses = ["notice"],
        sha256 = "66fdef91e9739348df7a096aa384a5685f4e875584cce89386a7a47251c4d8e9",
    )

    _maven_import(
        artifact = "org.objenesis:objenesis:1.0",
        licenses = ["notice"],
        sha256 = "c5694b55d92527479382f254199b3c6b1d8780f652ad61e9ca59919887f491a8",
    )

    _maven_import(
        artifact = "com.google.truth:truth:0.45",
        licenses = ["notice"],
        sha256 = "0f7dced2a16e55a77e44fc3ff9c5be98d4bf4bb30abc18d78ffd735df950a69f",
    )

    _maven_import(
        artifact = "com.google.truth.extensions:truth-java8-extension:0.45",
        licenses = ["notice"],
        sha256 = "dc1fedf6c13b1b1a4c4fa3e810f11df070ea4701765f05176f8bdcb5520c7de4",
    )

    _maven_import(
        artifact = "com.squareup:javapoet:1.13.0",
        licenses = ["notice"],
        sha256 = "4c7517e848a71b36d069d12bb3bf46a70fd4cda3105d822b0ed2e19c00b69291",
    )

    _maven_import(
        artifact = "io.grpc:grpc-core:1.2.0",
        licenses = ["notice"],
        sha256 = "4434ffd957dc5ca752d8a8e6e71fa6d598a05bb02b4fc08e48e53d878a004ee5",
    )

    _maven_import(
        artifact = "io.grpc:grpc-netty:1.2.0",
        licenses = ["notice"],
        sha256 = "c9379d17fdec2eae203679495a695b523e01f2541169d28f5b780de298aa17c8",
    )

    _maven_import(
        artifact = "io.grpc:grpc-context:1.2.0",
        licenses = ["notice"],
        sha256 = "4f1fed2735f011ba6f8ab1faa003ef67bade9e773f5a5ec4b69eb2a124500ca6",
    )

    _maven_import(
        artifact = "io.grpc:grpc-protobuf:1.2.0",
        licenses = ["notice"],
        sha256 = "19797fc26192dfcc4570ec26c12ba84583842b0ccbcd7d54982f922d33209383",
    )

    _maven_import(
        artifact = "io.grpc:grpc-stub:1.2.0",
        licenses = ["notice"],
        sha256 = "bf3eae95175ed36eee086d5fb320583fc492b144bd733d6e19515c7568ee2e2b",
    )

    _maven_import(
        artifact = "io.grpc:grpc-all:1.2.0",
        licenses = ["notice"],
        sha256 = "6b697a05b203216b853394d276c429da243cdf50f519688b33f4edbbf5f126d7",
    )

    _maven_import(
        artifact = "com.google.protobuf:protobuf-java:3.7.0",
        licenses = ["notice"],
        sha256 = "dc7f93e3a3dc2c11be5ba9672af3e26410f0a3289312dbf2260d4d8a0c711a51",
    )

    for protobuf_repo in ("com_google_protobuf", "com_google_protobuf_java"):
        http_archive(
            name = protobuf_repo,
            sha256 = "9748c0d90e54ea09e5e75fb7fac16edce15d2028d4356f32211cfa3c0e956564",
            strip_prefix = "protobuf-3.11.4",
            urls = ["https://github.com/protocolbuffers/protobuf/archive/v3.11.4.zip"],
        )

    CHECKER_FRAMEWORK_VERSION = "2.5.3"
    _maven_import(
        artifact = "org.checkerframework:checker-compat-qual:" + CHECKER_FRAMEWORK_VERSION,
        licenses = ["notice"],
        sha256 = "d76b9afea61c7c082908023f0cbc1427fab9abd2df915c8b8a3e7a509bccbc6d",
    )

    _maven_import(
        artifact = "org.checkerframework:checker-qual:" + CHECKER_FRAMEWORK_VERSION,
        licenses = ["notice"],
        sha256 = "7be622bd25208ccfbb9b634af8bd37aef54368403a1fdce84d908078330a189d",
    )

    _maven_import(
        artifact = "org.checkerframework:javacutil:" + CHECKER_FRAMEWORK_VERSION,
        licenses = ["notice"],
        sha256 = "8df14d46faaeaa3cca0b148e5a25f7c2e39b502a6b735793999f4f37d52e1617",
    )

    _maven_import(
        artifact = "org.checkerframework:dataflow:" + CHECKER_FRAMEWORK_VERSION,
        licenses = ["notice"],
        sha256 = "7c2cd62c7e00af8346d476f478fef55122230a5251ffc9c22930f5c27e49325f",
    )

    ASM_VERSION = "7.2"

    _maven_import(
        artifact = "org.ow2.asm:asm:%s" % ASM_VERSION,
        licenses = ["notice"],
        sha256 = "7e6cc9e92eb94d04e39356c6d8144ca058cda961c344a7f62166a405f3206672",
    )

    _maven_import(
        artifact = "org.ow2.asm:asm-tree:%s" % ASM_VERSION,
        licenses = ["notice"],
        sha256 = "c063f5a67fa03cdc9bd79fd1c2ea6816cc4a19473ecdfbd9e9153b408c6f2656",
    )

    _maven_import(
        artifact = "org.ow2.asm:asm-commons:%s" % ASM_VERSION,
        licenses = ["notice"],
        sha256 = "0e86b8b179c5fb223d1a880a0ff4960b6978223984b94e62e71135f2d8ea3558",
    )

    _maven_import(
        artifact = "org.codehaus.plexus:plexus-utils:3.0.20",
        licenses = ["notice"],
        sha256 = "8f3a655545fc5b4cbf12b5eb8a154fccb0c1144423a1450511f44005a3d574a2",
    )

    _maven_import(
        artifact = "org.codehaus.plexus:plexus-classworlds:2.5.2",
        licenses = ["notice"],
        sha256 = "b2931d41740490a8d931cbe0cfe9ac20deb66cca606e679f52522f7f534c9fd7",
    )

    _maven_import(
        artifact = "org.codehaus.plexus:plexus-component-annotations:1.5.5",
        licenses = ["notice"],
        sha256 = "4df7a6a7be64b35bbccf60b5c115697f9ea3421d22674ae67135dde375fcca1f",
    )

    _maven_import(
        artifact = "org.eclipse.sisu:org.eclipse.sisu.plexus:0.3.0",
        licenses = ["reciprocal"],
        sha256 = "807e9bc9e28d57ec0cb6daf04c317b3e13de5899c0282ee0f76c009198739350",
    )

    _maven_import(
        artifact = "org.eclipse.sisu:org.eclipse.sisu.inject:0.3.0",
        licenses = ["reciprocal"],
        sha256 = "11eec6fcc7a47c50c8d7fb7ac69920c33c70cb8df6b7a0d8eb751c813fb1928a",
    )

    _maven_import(
        artifact = "org.apache.maven:maven-artifact:3.3.3",
        licenses = ["notice"],
        sha256 = "c5d2db20550a3de4e796493876114c3b7717fe560c414135e2508c57b80e9a02",
    )

    _maven_import(
        artifact = "org.apache.maven:maven-model:3.3.3",
        licenses = ["notice"],
        sha256 = "a7e386687b962b6064f44115052207fc23a2a997742a156dffd0b434237896d8",
    )

    _maven_import(
        artifact = "org.apache.maven:maven-plugin-api:3.3.3",
        licenses = ["notice"],
        sha256 = "98585500928c4808d17f476e2554432af13ead1ce4720d72a943c0dedecb1fc0",
    )

    _maven_import(
        artifact = "javax.enterprise:cdi-api:1.0",
        licenses = ["notice"],
        sha256 = "1f10b2204cc77c919301f20ff90461c3df1b6e6cb148be1c2d22107f4851d423",
    )

    _maven_import(
        artifact = "org.pantsbuild:jarjar:1.7.2",
        licenses = ["notice"],
        sha256 = "0706a455e17b67718abe212e3a77688bbe8260852fc74e3e836d9f2e76d91c27",
    )

    _maven_import(
        artifact = "org.apache.ant:ant:1.9.6",
        licenses = ["notice"],
        sha256 = "d74de0bc55631476ba8443c07f43c9c51654ed5a1e0c1942ca015724d633e9bf",
    )

    _maven_import(
        artifact = "org.apache.ant:ant-launcher:1.9.6",
        licenses = ["notice"],
        sha256 = "f2c66a60fdacf78d6537734ef1c8edb77cf6c4532e705ee3482be1d1006c277a",
    )

    _maven_import(
        artifact = "log4j:log4j:1.2.15",
        licenses = ["notice"],
        sha256 = "9f5f5799707881451a39c1b2dd22b4e43b97a80698db7daf1c9697f545e24387",
    )

    LOG4J2_VERSION = "2.11.2"

    _maven_import(
        artifact = "org.apache.logging.log4j:log4j-api:" + LOG4J2_VERSION,
        licenses = ["notice"],
        sha256 = "09b8ce1740491deefdb3c336855822b64609b457c2966d806348456c0da261d2",
    )

    _maven_import(
        artifact = "org.apache.logging.log4j:log4j-core:" + LOG4J2_VERSION,
        licenses = ["notice"],
        sha256 = "d4748cd5d8d67f513de7634fa202740490d7e0ab546f4bf94e5c4d4a11e3edbc",
    )

    _maven_import(
        artifact = "org.apache.bcel:bcel:6.1",
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

    _maven_import(
        artifact = "com.googlecode.java-diff-utils:diffutils:1.3.0",
        licenses = ["notice"],
        sha256 = "61ba4dc49adca95243beaa0569adc2a23aedb5292ae78aa01186fa782ebdc5c2",
    )

    _maven_import(
        artifact = "org.slf4j:slf4j-api:1.7.14",
        licenses = ["notice"],
        sha256 = "b030a29e088dea60b07c7299d25f43cbd120502e10dcae3f382435ecd5de5ddd",
    )

    INCAP_VERSION = "0.2"
    _maven_import(
        artifact = "net.ltgt.gradle.incap:incap:" + INCAP_VERSION,
        licenses = ["notice"],
        sha256 = "b625b9806b0f1e4bc7a2e3457119488de3cd57ea20feedd513db070a573a4ffd",
    )

    _maven_import(
        artifact = "net.ltgt.gradle.incap:incap-processor:" + INCAP_VERSION,
        licenses = ["notice"],
        sha256 = "bf596f198825684262ecfead59b17a107f1654051178bd7cf775e2e49b32987d",
    )

    _maven_import(
        artifact = "com.google.common.inject:inject-common:1.0",
        licenses = ["notice"],
        sha256 = "73fd5e69280220b70dd2bf31af567de8d9e5763db56a0207ba1fd8ed006f7383",
    )
