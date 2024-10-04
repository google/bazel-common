# Bazel Common Libraries

This repository contains assorted common functionality for Google's open-source
libraries that are built with [`bazel`]. It is an experimental project and none
of the APIs/target names are fixed/guaranteed to remain. You are welcome to use
it and offer feedback at your own risk.

This is not an official Google product.

[`bazel`]: https://bazel.build

## Using Bazel Common

1.  Choose the commit hash you want to use.

2.  Add the following to your `MODULE.bazel` file, replacing `_COMMIT_` with the
    commit hash.

    ```bzl
    bazel_dep(name = "google_bazel_common")
    git_override(
        module_name = "google_bazel_common",
        commit = "_COMMIT_",
        remote = "https://github.com/google/bazel-common",
    )
    ```

To update the version of Bazel Common, choose a new commit and update your
`MODULE.bazel` file.

## Incrementing the version of an exported library

1.  Open `MODULE.bazel`

2.  Find the maven coordinate of the library export that you want to increment

3.  Update the version number in the maven coordinate

4.  Update the `maven_install.json` file by running:

    ```shell
    REPIN=1 bazelisk run @maven//:pin
    ```

5.  Send the change for review.

6.  Once submitted, remember to update your own dep on `bazel_common` to the
    version containing your change.
