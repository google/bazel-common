# Copyright (C) 2018 The Bazel Common Authors.
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
"""Skylark rules for jarjar. See https://github.com/pantsbuild/jarjar
"""

def _jarjar_library(ctx):
    ctx.actions.write(
        output = ctx.outputs._rules_file,
        content = "\n".join(ctx.attr.rules),
    )

    jar_files = depset(transitive = [jar.files for jar in ctx.attr.jars]).to_list()

    # TODO(dpb): Extract this command to a separate shell script file
    command = """
  JAVA_HOME="$(cd "{java_home}" && pwd)" # this is used outside of the root

  TMPDIR=$(mktemp -d)
  for jar in {jars}; do
    unzip -qq -B $jar -d $TMPDIR
  done

  pushd $TMPDIR &>/dev/null

  # Concatenate similar files in META-INF that allow it.
  mergeMetaInfFiles=(services/.* {merge_meta_inf_files})
  for metaInfPattern in ${{mergeMetaInfFiles[@]}}; do
    for file in $(find META-INF -regex "META-INF/$metaInfPattern\\(~[0-9]*\\)?"); do
      original=$(echo $file | sed s/"~[0-9]*$"//)
      if [[ "$file" != "$original" ]]; then
        cat $file >> $original
        rm $file
      fi
    done
  done

  rm META-INF/MANIFEST.MF*
  rm -rf META-INF/maven/
  duplicate_files=$(find * -type f -regex ".*~[0-9]*$")
  if [[ -n "$duplicate_files" ]]; then
    echo "Error: duplicate files in merged jar: $duplicate_files"
    exit 1
  fi
  $JAVA_HOME/bin/jar cf combined.jar *

  popd &>/dev/null

  {jarjar} process {rules_file} $TMPDIR/combined.jar {outfile}
  rm -rf $TMPDIR
  """.format(
        jars = " ".join([jar.path for jar in jar_files]),
        java_home = str(ctx.attr._jdk[java_common.JavaRuntimeInfo].java_home),
        jarjar = ctx.executable._jarjar.path,
        rules_file = ctx.outputs._rules_file.path,
        outfile = ctx.outputs.jar.path,
        merge_meta_inf_files = " ".join(ctx.attr.merge_meta_inf_files),
    )

    ctx.actions.run_shell(
        command = command,
        inputs = [ctx.outputs._rules_file] + jar_files + ctx.files._jdk,
        outputs = [ctx.outputs.jar],
        tools = [ctx.executable._jarjar],
    )

_jarjar_library_attrs = {
    "rules": attr.string_list(),
    "jars": attr.label_list(
        allow_files = [".jar"],
    ),
    "merge_meta_inf_files": attr.string_list(
        allow_empty = True,
        default = [],
        mandatory = False,
        doc = """A list of regular expressions that match files relative to the
        META-INF directory that will be merged into the output jar, in addition
        to files in META-INF/services. To add all files in META-INF/foo, for
        example, use "foo/.*".""",
    ),
}

# Additional attributes only used in opensource builds
_jarjar_library_attrs.update({
    "_jarjar": attr.label(
        default = Label("//tools/jarjar"),
        executable = True,
        cfg = "host",
    ),
    "_jdk": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
        providers = [java_common.JavaRuntimeInfo],
    ),
})


jarjar_library = rule(
    attrs = _jarjar_library_attrs,
    outputs = {
        "jar": "%{name}.jar",
        "_rules_file": "%{name}.jarjar_rules",
    },
    implementation = _jarjar_library,
)
