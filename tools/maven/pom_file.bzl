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

MavenInfo = provider(
    fields = {
        "coordinates": "The maven coordinates of the target and all exported targets.",
        "coordinates_from_deps": "The `coordinates` of the direct deps of the target.",
    },
)

_EMPTY_MAVEN_INFO = MavenInfo(
    coordinates = depset(),
    coordinates_from_deps = depset(),
)

_MAVEN_COORDINATES_PREFIX = "maven_coordinates="

def _exported_maven_coordinates(targets):
  return [target[MavenInfo].coordinates
          for target in targets
          if MavenInfo in target]

def _collect_maven_info_impl(_target, ctx):
  tags = getattr(ctx.rule.attr, 'tags', [])
  deps = getattr(ctx.rule.attr, 'deps', [])
  exports = getattr(ctx.rule.attr, 'exports', [])

  coordinates = []
  for tag in tags:
    if tag in ("maven:compile_only", "maven:shaded"):
      return [_EMPTY_MAVEN_INFO]
    if tag.startswith(_MAVEN_COORDINATES_PREFIX):
      coordinates.append(tag[len(_MAVEN_COORDINATES_PREFIX):])

  return [MavenInfo(
      coordinates_from_deps = depset([], transitive = _exported_maven_coordinates(deps)),
      coordinates = depset(coordinates, transitive = _exported_maven_coordinates(exports)),
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
      [], transitive = [target[MavenInfo].coordinates_from_deps for target in ctx.attr.targets])

  formatted_deps = []
  for dep in _sort_artifacts(mvn_deps, ctx.attr.preferred_group_ids):
    parts = dep.split(":")
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
      "{pom_version}": ctx.var.get("pom_version", "LOCAL-SNAPSHOT")
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
    """,
    outputs = {"pom_file": "%{name}.xml"},
    implementation = _pom_file,
)
