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
"""Skylark macros to simplify declaring tests."""


def gen_java_tests(
        name,
        srcs,
        deps,
        lib_deps = None,
        test_deps = None,
        plugins = None,
        lib_plugins = None,
        test_plugins = None,
        javacopts = None,
        lib_javacopts = None,
        test_javacopts = None,
        **kwargs):
    """Generates `java_test` rules for each file in `srcs` ending in "Test.java".

    All other files will be compiled in a supporting `java_library` that is passed
    as a dep to each of the generated `java_test` rules.

    The arguments to this macro match those of the `java_library` and `java_test`
    rules. The arguments prefixed with `lib_` will be passed to the generated
    supporting `java_library` and not the tests, and vice versa for arguments
    prefixed with `test_`. For example, passing `deps = [:a], lib_deps = [:b],
    test_deps = [:c]` will result in a `java_library` that has `deps = [:a, :b]`
    and `java_test`s that have `deps = [:a, :c]`.
    """
    _gen_java_tests(
        native.java_library,
        native.java_test,
        name,
        srcs,
        deps,
        javacopts = javacopts,
        lib_deps = lib_deps,
        lib_javacopts = lib_javacopts,
        lib_plugins = lib_plugins,
        plugins = plugins,
        test_deps = test_deps,
        test_javacopts = test_javacopts,
        test_plugins = test_plugins,
        **kwargs
    )

def gen_android_local_tests(
        name,
        srcs,
        deps,
        lib_deps = None,
        test_deps = None,
        plugins = None,
        lib_plugins = None,
        test_plugins = None,
        javacopts = None,
        lib_javacopts = None,
        test_javacopts = None,
        **kwargs):
    """Generates `android_local_test` rules for each file in `srcs` ending in "Test.java".

    All other files will be compiled in a supporting `android_library` that is
    passed as a dep to each of the generated test rules.

    The arguments to this macro match those of the `android_library` and
    `android_local_test` rules. The arguments prefixed with `lib_` will be
    passed to the generated supporting `android_library` and not the tests, and
    vice versa for arguments prefixed with `test_`. For example, passing `deps =
    [:a], lib_deps = [:b], test_deps = [:c]` will result in a `android_library`
    that has `deps = [:a, :b]` and `android_local_test`s that have `deps =
    [:a, :c]`.
    """

    _gen_java_tests(
        android_library,
        android_local_test,
        name,
        srcs,
        deps,
        javacopts = javacopts,
        lib_deps = lib_deps,
        lib_javacopts = lib_javacopts,
        lib_plugins = lib_plugins,
        plugins = plugins,
        test_deps = test_deps,
        test_javacopts = test_javacopts,
        test_plugins = test_plugins,
        **kwargs
    )

def _concat(*lists):
    """Concatenates the items in `lists`, ignoring `None` arguments."""
    concatenated = []
    for list in lists:
        if list:
            concatenated += list
    return concatenated

def _gen_java_tests(
        library_rule_type,
        test_rule_type,
        name,
        srcs,
        deps,
        lib_deps = None,
        test_deps = None,
        plugins = None,
        lib_plugins = None,
        test_plugins = None,
        javacopts = None,
        lib_javacopts = None,
        test_javacopts = None,
        tags = None):
    test_files = []
    supporting_lib_files = []

    for src in srcs:
        if src.endswith("Test.java"):
            test_files.append(src)
        else:
            supporting_lib_files.append(src)

    test_deps = _concat(deps, test_deps)
    if supporting_lib_files:
        supporting_lib_files_name = name + "_lib"
        test_deps.append(":" + supporting_lib_files_name)
        library_rule_type(
            name = supporting_lib_files_name,
            testonly = 1,
            srcs = supporting_lib_files,
            javacopts = _concat(javacopts, lib_javacopts),
            plugins = _concat(plugins, lib_plugins),
            deps = _concat(deps, lib_deps),
        )

    for test_file in test_files:
        test_name = test_file.replace(".java", "")
        prefix_path = "src/test/java/"
        package_name = native.package_name()
        if package_name.find("javatests/") != -1:
            prefix_path = "javatests/"

        # TODO(ronshapiro): Consider supporting a configurable prefix_path
        test_class = (package_name + "/" + test_name).rpartition(prefix_path)[2].replace("/", ".")
        test_rule_type(
            name = test_name,
            srcs = [test_file],
            javacopts = _concat(javacopts, test_javacopts),
            plugins = _concat(plugins, test_plugins),
            tags = _concat(["gen_java_tests"], tags),
            test_class = test_class,
            deps = test_deps,
        )
