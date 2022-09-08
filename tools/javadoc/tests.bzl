# Copyright (C) 2022 The Google Bazel Common Authors.
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

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load(":javadoc.bzl", "javadoc_library")

"""
Unit and analysis tests for the javadoc package.
"""

# Verify handing of `attr.groups`.
def _group_test_impl(ctx):
    env = analysistest.begin(ctx)
    acts = analysistest.target_actions(env)
    asserts.equals(env, 2, len(acts))
    act = acts[0]  # javadoc action

    idx = act.argv.index("-group")
    asserts.equals(
        env,
        ["-group", "myheading", "build.bazel.pkg1:build.bazel.pkg2"],
        act.argv[idx:idx + 3],
    )

    return analysistest.end(env)

_group_test = analysistest.make(_group_test_impl)

def _group_test_case(name):
    javadoc_library(
        name = name + "_javadoc",
        srcs = ["dummy.java"],
        groups = {"myheading": ["build.bazel.pkg1", "build.bazel.pkg2"]},
        tags = ["manual"],
    )
    _group_test(
        name = name + "_test",
        target_under_test = name + "_javadoc",
    )

# Verify handling of `attr.root_packages`.
def _root_packages_test_impl(ctx):
    env = analysistest.begin(ctx)
    acts = analysistest.target_actions(env)
    asserts.equals(env, 2, len(acts))
    act = acts[0]  # javadoc action

    idx = act.argv.index("bazel.build.foo")
    asserts.equals(env, ["bazel.build.foo", "bazel.build.bar"], act.argv[idx:idx + 2])

    idx = act.argv.index("-subpackages")
    asserts.equals(
        env,
        ["-subpackages", "bazel.build.foo:bazel.build.bar"],
        act.argv[idx:idx + 2],
    )

    # root_packages is a filter/allowlist which `.java` files contradict.
    # (These should be accessible to `javadoc` via the dynamic `-sourcepath`
    # arg.)
    asserts.equals(
        env,
        [],
        [
            x
            for x in act.argv
            if x.endswith(".java")
        ],
        "Expecting only Java packages, not .java source files",
    )

    return analysistest.end(env)

_root_packages_test = analysistest.make(_root_packages_test_impl)

def _root_packages_test_case(name):
    javadoc_library(
        name = name + "_javadoc",
        srcs = ["dummy.java"],
        root_packages = ["bazel.build.foo", "bazel.build.bar"],
        tags = ["manual"],
    )
    _root_packages_test(
        name = name + "_test",
        target_under_test = name + "_javadoc",
    )

def analysis_test_suite(name):
    _group_test_case(name = name + "_group")
    _root_packages_test_case(name = name + "_root_packages")

    native.test_suite(
        name = name,
        tests = [
            ":%s_group_test" % name,
            ":%s_root_packages_test" % name,
        ]
    )
