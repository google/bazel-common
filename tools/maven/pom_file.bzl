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
"""Skylark rules to make publishing Maven artifacts simpler.
"""

load("@bazel_skylib//:lib.bzl", "asserts", "unittest")

MavenInfo = provider(
    fields = {
        "maven_artifacts": """
        The Maven coordinates for the artifacts that are exported by this target: i.e. the target
        itself and its transitively exported targets.
        """,
        "maven_dependencies": """
        The Maven coordinates of the direct dependencies, and the transitively exported targets, of
        this target.
        """,
    },
)

_EMPTY_MAVEN_INFO = MavenInfo(
    maven_artifacts = depset(),
    maven_dependencies = depset(),
)

_MAVEN_COORDINATES_PREFIX = "maven_coordinates="

def _maven_artifacts(targets):
    return [target[MavenInfo].maven_artifacts for target in targets if MavenInfo in target]

def _collect_maven_info_impl(_target, ctx):
    tags = getattr(ctx.rule.attr, "tags", [])
    deps = getattr(ctx.rule.attr, "deps", [])
    exports = getattr(ctx.rule.attr, "exports", [])

    maven_artifacts = []
    for tag in tags:
        if tag in ("maven:compile_only", "maven:shaded"):
            return [_EMPTY_MAVEN_INFO]
        if tag.startswith(_MAVEN_COORDINATES_PREFIX):
            maven_artifacts.append(tag[len(_MAVEN_COORDINATES_PREFIX):])

    return [MavenInfo(
        maven_artifacts = depset(maven_artifacts, transitive = _maven_artifacts(exports)),
        maven_dependencies = depset([], transitive = _maven_artifacts(deps + exports)),
    )]

_collect_maven_info = aspect(
    attr_aspects = [
        "deps",
        "exports",
    ],
    doc = """
    Collects the Maven information for targets, their dependencies, and their transitive exports.
    """,
    implementation = _collect_maven_info_impl,
)

def _prefix_index_of(item, prefixes):
    """Returns the index of the first value in `prefixes` that is a prefix of `item`.

    If none of the prefixes match, return the size of `prefixes`.

    Args:
      item: the item to match
      prefixes: prefixes to match against

    Returns:
      an integer representing the index of the match described above.
    """
    for index, prefix in enumerate(prefixes):
        if item.startswith(prefix):
            return index
    return len(prefixes)

def _sort_artifacts(artifacts, prefixes):
    """Sorts `artifacts`, preferring group ids that appear earlier in `prefixes`.

    Values in `prefixes` do not need to be complete group ids. For example, passing `prefixes =
    ['io.bazel']` will match `io.bazel.rules:rules-artifact:1.0`. If multiple prefixes match an
    artifact, the first one in `prefixes` will be used.

    _Implementation note_: Skylark does not support passing a comparator function to the `sorted()`
    builtin, so this constructs a list of tuples with elements:
      - `[0]` = an integer corresponding to the index in `prefixes` that matches the artifact (see
        `_prefix_index_of`)
      - `[1]` = parts of the complete artifact, split on `:`. This is used as a tiebreaker when
        multilple artifacts have the same index referenced in `[0]`. The individual parts are used so
        that individual artifacts in the same group are sorted correctly - if just the string is used,
        the colon that separates the artifact name from the version will sort lower than a longer
        name. For example:
        -  `com.example.project:base:1
        -  `com.example.project:extension:1
        "base" sorts lower than "exension".
      - `[2]` = the complete artifact. this is a convenience so that after sorting, the artifact can
      be returned.

    The `sorted` builtin will first compare the index element and if it needs a tiebreaker, will
    recursively compare the contents of the second element.

    Args:
      artifacts: artifacts to be sorted
      prefixes: the preferred group ids used to sort `artifacts`

    Returns:
      A new, sorted list containing the contents of `artifacts`.
    """
    indexed = []
    for artifact in artifacts:
        parts = artifact.split(":")
        indexed.append((_prefix_index_of(parts[0], prefixes), parts, artifact))

    return [x[-1] for x in sorted(indexed)]

DEP_BLOCK = """
<dependency>
  <groupId>{0}</groupId>
  <artifactId>{1}</artifactId>
  <version>{2}</version>
</dependency>
""".strip()

CLASSIFIER_DEP_BLOCK = """
<dependency>
  <groupId>{0}</groupId>
  <artifactId>{1}</artifactId>
  <version>{2}</version>
  <type>{3}</type>
  <classifier>{4}</classifier>
</dependency>
""".strip()

def _pom_file(ctx):
    mvn_deps = depset(
        [],
        transitive = [target[MavenInfo].maven_dependencies for target in ctx.attr.targets],
    )

    formatted_deps = []
    for dep in _sort_artifacts(mvn_deps, ctx.attr.preferred_group_ids):
        parts = dep.split(":")
        if ":".join(parts[0:2]) in ctx.attr.excluded_artifacts:
            continue
        if len(parts) == 3:
            template = DEP_BLOCK
        elif len(parts) == 5:
            template = CLASSIFIER_DEP_BLOCK
        else:
            fail("Unknown dependency format: %s" % dep)

        formatted_deps.append(template.format(*parts))

    substitutions = {}
    substitutions.update(ctx.attr.substitutions)
    substitutions.update({
        "{generated_bzl_deps}": "\n".join(formatted_deps),
        "{pom_version}": ctx.var.get("pom_version", "LOCAL-SNAPSHOT"),
    })

    ctx.actions.expand_template(
        template = ctx.file.template_file,
        output = ctx.outputs.pom_file,
        substitutions = substitutions,
    )

pom_file = rule(
    attrs = {
        "template_file": attr.label(
            single_file = True,
            allow_files = True,
        ),
        "substitutions": attr.string_dict(
            allow_empty = True,
            mandatory = False,
        ),
        "targets": attr.label_list(
            mandatory = True,
            aspects = [_collect_maven_info],
        ),
        "preferred_group_ids": attr.string_list(),
        "excluded_artifacts": attr.string_list(),
    },
    doc = """
    Creates a Maven POM file for `targets`.

    This rule scans the deps of `targets` and their transitive exports, checking each for tags of
    the form `maven_coordinates=<coords>`. These tags are used to build the list of Maven
    dependencies for the generated POM.

    Users should call this rule with a `template_file` that contains a `{generated_bzl_deps}`
    placeholder. The rule will replace this with the appropriate XML for all dependencies.
    Additional placeholders to replace can be passed via the `substitutions` argument.

    The dependencies included will be sorted alphabetically by groupId, then by artifactId. The
    `preferred_group_ids` can be used to specify groupIds (or groupId-prefixes) that should be
    sorted ahead of other artifacts. Artifacts in the same group will be sorted alphabetically.

    Args:
      name: the name of target. The generated POM file will use this name, with `.xml` appended
      targets: a list of build target(s) that represent this POM file
      template_file: a pom.xml file that will be used as a template for the generated POM
      substitutions: an optional mapping of placeholders to replacement values that will be applied
        to the `template_file` (e.g. `{'GROUP_ID': 'com.example.group'}`). `{pom_version}` is
        implicitly included in this mapping and can be configured by passing `bazel build
        --define=pom_version=<version>`.
      preferred_group_ids: an optional list of maven groupIds that will be used to sort the
        generated deps.
      excluded_artifacts: an optional list of maven artifacts in the format "groupId:artifactId"
        that should be excluded from the generated pom file.
    """,
    outputs = {"pom_file": "%{name}.xml"},
    implementation = _pom_file,
)

def _fake_java_library(name, deps = None, exports = None):
    src_file = ["%s.java" % name]
    native.genrule(
        name = "%s_source_file" % name,
        outs = src_file,
        cmd = "echo 'class %s {}' > $@" % name,
    )
    native.java_library(
        name = name,
        srcs = src_file,
        tags = ["maven_coordinates=%s:_:_" % name],
        deps = deps or [],
        exports = exports or [],
    )

def _maven_info_test_impl(ctx):
    env = unittest.begin(ctx)
    asserts.set_equals(
        env,
        expected = depset(ctx.attr.maven_artifacts),
        actual = ctx.attr.target[MavenInfo].maven_artifacts,
        msg = "MavenInfo.maven_artifacts",
    )
    asserts.set_equals(
        env,
        expected = depset(ctx.attr.maven_dependencies),
        actual = ctx.attr.target[MavenInfo].maven_dependencies,
        msg = "MavenInfo.maven_dependencies",
    )
    unittest.end(env)

_maven_info_test = unittest.make(
    _maven_info_test_impl,
    attrs = {
        "target": attr.label(aspects = [_collect_maven_info]),
        "maven_artifacts": attr.string_list(),
        "maven_dependencies": attr.string_list(),
    },
)

def pom_file_tests():
    """Tests for `pom_file` and `MavenInfo`.
    """
    _fake_java_library(name = "A")
    _fake_java_library(
        name = "DepOnA",
        deps = [":A"],
    )

    _maven_info_test(
        name = "a_test",
        target = ":A",
        maven_artifacts = ["A:_:_"],
        maven_dependencies = [],
    )

    _maven_info_test(
        name = "dependencies_test",
        target = ":DepOnA",
        maven_artifacts = ["DepOnA:_:_"],
        maven_dependencies = ["A:_:_"],
    )

    _fake_java_library(
        name = "ExportsA",
        exports = [":A"],
    )

    _maven_info_test(
        name = "exports_test",
        target = ":ExportsA",
        maven_artifacts = [
            "ExportsA:_:_",
            "A:_:_",
        ],
        maven_dependencies = ["A:_:_"],
    )

    _fake_java_library(
        name = "TransitiveExports",
        exports = [":ExportsA"],
    )

    _maven_info_test(
        name = "transitive_exports_test",
        target = ":TransitiveExports",
        maven_artifacts = [
            "TransitiveExports:_:_",
            "ExportsA:_:_",
            "A:_:_",
        ],
        maven_dependencies = [
            "ExportsA:_:_",
            "A:_:_",
        ],
    )

    _fake_java_library(
        name = "TransitiveDeps",
        deps = [":ExportsA"],
    )

    _maven_info_test(
        name = "transitive_deps_test",
        target = ":TransitiveDeps",
        maven_artifacts = ["TransitiveDeps:_:_"],
        maven_dependencies = [
            "ExportsA:_:_",
            "A:_:_",
        ],
    )
