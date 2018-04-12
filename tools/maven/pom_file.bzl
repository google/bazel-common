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

def _replace_bazel_deps_impl(ctx):
  template_file = ctx.file.template_file
  deps_xml = ctx.file.deps_xml
  pom_file = ctx.outputs.pom_file
  ctx.actions.run(
      inputs = [template_file, deps_xml],
      executable = ctx.executable._replace_bazel_deps,
      arguments = [template_file.path, deps_xml.path, pom_file.path],
      outputs = [pom_file],
  )

_replace_bazel_deps = rule(
    attrs = {
        "pom_file": attr.output(mandatory = True),
        "template_file": attr.label(
            single_file = True,
            allow_files = True,
        ),
        "deps_xml": attr.label(
            single_file = True,
            allow_files = True,
        ),
        "_replace_bazel_deps": attr.label(
            executable = True,
            cfg = "host",
            allow_files = True,
            default = Label("//tools:replace_bazel_deps"),
        ),
    },
    implementation = _replace_bazel_deps_impl,
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

def _deps_xml_impl(ctx):
  mvn_deps = depset(
      [], transitive = [target[MavenInfo].coordinates_from_deps for target in ctx.attr.targets])

  formatted_deps = []
  for dep in _sort_artifacts(mvn_deps.to_list(), ctx.attr.preferred_group_ids):
    parts = dep.split(":")
    if len(parts) == 3:
      template = DEP_BLOCK
    elif len(parts) == 5:
      template = CLASSIFIER_DEP_BLOCK
    else:
      fail("Unknown dependency format: %s" % dep)

    formatted_deps.append(template.format(*parts))

  ctx.actions.write(
      content = '\n'.join(formatted_deps),
      output = ctx.outputs.output_file,
  )

_deps_xml = rule(
    attrs = {
        "targets": attr.label_list(
            mandatory = True,
            aspects = [_collect_maven_info],
        ),
        "output_file": attr.output(mandatory = False),
        "preferred_group_ids": attr.string_list(),
    },
    implementation = _deps_xml_impl,
)

def pom_file(name, targets, template_file, preferred_group_ids=None):
  """Creates a Maven POM file for `targets`.

  This rule scans the deps of `targets` and their transitive exports, checking
  each for tags of the form `maven_coordinates=<coords>`. These tags are used to
  build the list of Maven dependencies for the generated POM.

  Users should call this rule with a `template_file` that contains a
  `<generated_bzl_deps />` xml tag. The rule will replace this tag with the
  appropriate XML for all dependencies.

  The dependencies included will be sorted alphabetically by groupId, then by
  artifactId. The `preferred_group_ids` can be used to specify groupIds (or
  groupId-prefixes) that should be sorted ahead of other artifacts. Artifacts in
  the same group will be sorted alphabetically.

  Args:
    name: the name of the generated POM file (typically `"pom.xml"`)
    targets: a list of build target(s) that represent this POM file
    template_file: a pom.xml file that will be used as a template for the
      generated POM
    preferred_group_ids: an optional list of maven groupIds that will be used
      to sort the generated deps.
  """
  pom_deps_file = name + ".depsxml"
  _deps_xml(
      name = name + "_deps_xml",
      targets = targets,
      output_file = pom_deps_file,
      preferred_group_ids = preferred_group_ids,
  )

  _replace_bazel_deps(
      name = name + "_replace_bazel_deps",
      pom_file = name,
      template_file = template_file,
      deps_xml = pom_deps_file,
  )
