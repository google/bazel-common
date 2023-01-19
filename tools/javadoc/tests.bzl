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
load("@rules_java//java:defs.bzl", "java_library")
load(":javadoc.bzl", "javadoc_library")

"""
Unit and analysis tests for the javadoc package.
"""

# Verify handing of `attr.deps`.
def _deps_test_impl(ctx):
    env = analysistest.begin(ctx)
    acts = analysistest.target_actions(env)
    asserts.equals(env, 2, len(acts))
    act = acts[0]  # javadoc action

    pathsep = ctx.configuration.host_path_separator

    idx = act.argv.index("-classpath")
    classpath = act.argv[idx + 1]
    asserts.equals(
        env,
        2,
        len(classpath.split(pathsep)),
    )

    return analysistest.end(env)

_deps_test = analysistest.make(_deps_test_impl)

def _deps_test_case(name):
    java_library(
        name = name + "_lib",
        srcs = ["dummy.java"],
        tags = ["manual"],
    )
    java_library(
        name = name + "_lib2",
        srcs = ["dummy.java"],
        tags = ["manual"],
    )
    javadoc_library(
        name = name + "_javadoc",
        srcs = ["dummy.java"],
        deps = [
            ":" + name + "_lib",
            ":" + name + "_lib2",
        ],
        tags = ["manual"],
    )
    _deps_test(
        name = name,
        target_under_test = name + "_javadoc",
    )

# Verify handing of `attr.groups`.
def _group_test_impl(ctx):
    env = analysistest.begin(ctx)
    acts = analysistest.target_actions(env)
    asserts.equals(env, 2, len(acts))
    act = acts[0]  # javadoc action

    pathsep = ctx.configuration.host_path_separator

    idx = act.argv.index("-group")
    asserts.equals(
        env,
        [
            "-group",
            "heading1",
            pathsep.join(["foo", "bar"]),
            "-group",
            "heading2",
            pathsep.join(["bazel", "blaze"]),
        ],
        act.argv[idx:idx + 6],
    )

    return analysistest.end(env)

_group_test = analysistest.make(_group_test_impl)

def _group_test_case(name):
    javadoc_library(
        name = name + "_javadoc",
        srcs = ["dummy.java"],
        groups = {
            "heading1": ["foo", "bar"],
            "heading2": ["bazel", "blaze"],
        },
        tags = ["manual"],
    )
    _group_test(
        name = name,
        target_under_test = name + "_javadoc",
    )

# Verify handling of `attr.external_javadoc_links`.
def _links_test_impl(ctx):
    env = analysistest.begin(ctx)
    acts = analysistest.target_actions(env)
    asserts.equals(env, 2, len(acts))
    act = acts[0]  # javadoc action

    idx = act.argv.index("-linkoffline")
    asserts.equals(
        env,
        ["-linkoffline", "url1", "url1", "-linkoffline", "url2", "url2"],
        act.argv[idx:idx + 6],
    )

    return analysistest.end(env)

_links_test = analysistest.make(_links_test_impl)

def _links_test_case(name):
    javadoc_library(
        name = name + "_javadoc",
        srcs = ["dummy.java"],
        external_javadoc_links = ["url1", "url2"],
        tags = ["manual"],
    )
    _links_test(
        name = name,
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
        name = name,
        target_under_test = name + "_javadoc",
    )

def analysis_test_suite(name = "unused"):
    _deps_test_case(name = "deps_test")
    _group_test_case(name = "group_test")
    _links_test_case(name = "links_test")
    _root_packages_test_case(name = "root_packages_test")

    native.test_suite(
        name = name,
        tests = [
            ":deps_test",
            ":group_test",
            ":links_test",
            ":root_packages_test",
        ],
    )
