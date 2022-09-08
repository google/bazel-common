# Copyright (C) 2017 The Dagger Authors.
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

"""See javadoc_library."""

def _android_jar(android_api_level):
    if android_api_level == -1:
        return None
    return Label("@androidsdk//:platforms/android-%s/android.jar" % android_api_level)

def _endswith_java(item):
    if item.path.endswith(".java"):
        return item.path

def _to_group(item):
    k, v = item
    return ["-group", k, ":".join(v)]

def _javadoc_library(ctx):
    transitive_deps = []
    for dep in ctx.attr.deps:
        if JavaInfo in dep:
            transitive_deps.append(dep[JavaInfo].transitive_deps)

    if ctx.attr._android_jar:
        transitive_deps.append(ctx.attr._android_jar.files)

    classpath = depset([], transitive = transitive_deps).to_list()

    java_home = str(ctx.attr._jdk[java_common.JavaRuntimeInfo].java_home)

    output_dir = ctx.actions.declare_directory("%s_javadoc" % ctx.attr.name)

    # javadoc args
    # - Should we use `ctx.host_configuration.host_path_separator` instead of `:`?
    jargs = ctx.actions.args()
    jargs.use_param_file(param_file_arg = "@%s", use_always = True)
    jargs.add("-use")
    jargs.add("-encoding", "UTF8")
    jargs.add_joined("-classpath", [jar.path for jar in classpath], join_with = ":")
    jargs.add("-notimestamp")
    jargs.add("-d", output_dir.path)
    jargs.add("-Xdoclint:-missing")
    jargs.add("-quiet")

    # Documentation for the javadoc command
    # https://docs.oracle.com/javase/9/javadoc/javadoc-command.htm
    if ctx.attr.root_packages:
        # TODO(b/167433657): Reevaluate the utility of root_packages
        # 1. Find the first directory under the working directory named '*java'.
        # 2. Assume all files to document can be found by appending a root_package name
        #    to that directory, or a subdirectory, replacting dots with slashes.
        jargs.add_all(ctx.attr.root_packages)
        jargs.add_joined("-subpackages", ctx.attr.root_packages, join_with = ":")
    else:
        # Document exactly the code in the specified source files.
        jargs.add_all(ctx.files.srcs, map_each = _endswith_java)

    if ctx.attr.doctitle:
        jargs.add("-doctitle", ctx.attr.doctitle)

    # Translate `groups` mapping to `-group k ":".join(v)`.
    jargs.add_all(
        ctx.attr.groups.items(),
        map_each = _to_group,
    )

    jargs.add_joined("-exclude", ctx.attr.exclude_packages, join_with = ":")

    for link in ctx.attr.external_javadoc_links:
        jargs.add("-linkoffline {0} {0}".format(link))

    if ctx.attr.bottom_text:
        jargs.add("-bottom", ctx.attr.bottom_text)

    srcs = depset(transitive = [src.files for src in ctx.attr.srcs]).to_list()

    # Invoke `javadoc` to generate Javadoc.
    ctx.actions.run_shell(
        inputs = srcs + classpath + ctx.files._jdk,
        outputs = [output_dir],
        arguments = [
            output_dir.path,
            "true" if ctx.attr.root_packages else "false",
            jargs,
        ],
        command = """
outdir=$1; shift
root_packages=$1; shift
jargsfile=$1; shift

# See also `TODO(b/167433657)` in javadoc.bzl.
if $root_packages; then
    sourcepath_args=(
        -sourcepath
        $(find * -type d -name '*.java' -print0 | tr '\\0' :)
    )
fi

${JAVA_HOME}/bin/javadoc $jargsfile ${sourcepath_args[@]}
""",
        env = {
            "JAVA_HOME": java_home,
        },
    )

    # Zip the outputs using Bazel's deterministic `zipper` utility.
    ctx.actions.run_shell(
        inputs = [output_dir],
        outputs = [ctx.outputs.jar],
        arguments = [ctx.executable._zipper.path, output_dir.path, ctx.outputs.jar.path],
        tools = [ctx.executable._zipper],
        command = """
zipper=$1; shift
outdir=$1; shift
outjar=$1; shift

cd $outdir
zargsfile=$OLDPWD/${outdir}.tmp
find * -type f | LC_ALL=C sort > $zargsfile
$OLDPWD/$zipper Cc $OLDPWD/$outjar @$zargsfile
""",
    )

javadoc_library = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_empty = False,
            allow_files = True,
            doc = "Source files to generate Javadoc for.",
        ),
        "deps": attr.label_list(
            doc = """
Targets that contain references to other types referenced in Javadoc. These can
be the java_library/android_library target(s) for the same sources.
""",
        ),
        "doctitle": attr.string(
            default = "",
            doc = "Title for generated index.html. See javadoc -doctitle.",
        ),
       "groups": attr.string_list_dict(
          doc = "Groups specified packages together in overview page. See javadoc -groups.",
       ),
        "root_packages": attr.string_list(
            doc = """
Java packages to include in generated Javadoc. Any subpackages not listed in
exclude_packages will be included as well. If none are provided, each file in
`srcs` is processed.
""",
        ),
        "exclude_packages": attr.string_list(
            doc = "Java packages to exclude from generated Javadoc.",
        ),
        "android_api_level": attr.int(
            default = -1,
            doc = """
If Android APIs are used, the API level to compile against to generate Javadoc.
""",
        ),
        "bottom_text": attr.string(
            default = "",
            doc = "Text passed to Javadoc's `-bottom` flag.",
        ),
        "external_javadoc_links": attr.string_list(
            doc = "URLs passed to Javadoc's `-linkoffline` flag.",
        ),
        "_android_jar": attr.label(
            default = _android_jar,
            allow_single_file = True,
        ),
        "_jdk": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
            providers = [java_common.JavaRuntimeInfo],
        ),
        "_zipper": attr.label(
            default = Label("@bazel_tools//tools/zip:zipper"),
            executable = True,
            cfg = "exec",
        ),
    },
    outputs = {"jar": "%{name}.jar"},
    doc = "Generates a Javadoc jar path/to/target/<name>.jar.",
    implementation = _javadoc_library,
)
