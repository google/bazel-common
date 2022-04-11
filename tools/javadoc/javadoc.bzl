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

    javadoc_command = [
        java_home + "/bin/javadoc",
        "-use",
        "-encoding UTF8",
        "-classpath",
        ":".join([jar.path for jar in classpath]),
        "-notimestamp",
        "-d %s" % output_dir.path,
        "-Xdoclint:-missing",
        "-quiet",
    ]

    # Documentation for the javadoc command
    # https://docs.oracle.com/javase/9/javadoc/javadoc-command.htm
    if ctx.attr.root_packages:
        # TODO(b/167433657): Reevaluate the utility of root_packages
        # 1. Find the first directory under the working directory named '*java'.
        # 2. Assume all files to document can be found by appending a root_package name
        #    to that directory, or a subdirectory, replacting dots with slashes.
        javadoc_command += [
            '-sourcepath $(find * -type d -name "*java" -print0 | tr "\\0" :)',
            " ".join(ctx.attr.root_packages),
            "-subpackages",
            ":".join(ctx.attr.root_packages),
        ]
    else:
        # Document exactly the code in the specified source files.
        javadoc_command += [f.path for f in ctx.files.srcs]

    if ctx.attr.doctitle:
        javadoc_command.append('-doctitle "%s"' % ctx.attr.doctitle)

    if ctx.attr.groups:
        groups = []
        for k, v in ctx.attr.groups.items():
            groups.append("-group \"%s\" \"%s\"" % (k, ":".join(v)))
        javadoc_command.append(" ".join(groups))

    if ctx.attr.exclude_packages:
        javadoc_command.append("-exclude %s" % ":".join(ctx.attr.exclude_packages))

    for link in ctx.attr.external_javadoc_links:
        javadoc_command.append("-linkoffline {0} {0}".format(link))

    if ctx.attr.bottom_text:
        javadoc_command.append("-bottom '%s'" % ctx.attr.bottom_text)

    # TODO(ronshapiro): Should we be using a different tool that doesn't include
    # timestamp info?
    jar_command = "%s/bin/jar cf %s -C %s ." % (java_home, ctx.outputs.jar.path, output_dir.path)

    srcs = depset(transitive = [src.files for src in ctx.attr.srcs]).to_list()
    ctx.actions.run_shell(
        inputs = srcs + classpath + ctx.files._jdk,
        command = "%s && %s" % (" ".join(javadoc_command), jar_command),
        outputs = [output_dir, ctx.outputs.jar],
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
    },
    outputs = {"jar": "%{name}.jar"},
    doc = "Generates a Javadoc jar path/to/target/<name>.jar.",
    implementation = _javadoc_library,
)
