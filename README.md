# Bazel Common Libraries

This repository contains assorted common functionality for Google's open-source
libraries that are built with [`bazel`]. It is an experimental project and none
of the APIs/target names are fixed/guaranteed to remain. You are welcome to use
it and offer feedback at your own risk.

This is not an official Google product.

[`bazel`]: https://bazel.build

## Incrementing the Version of an Exported Library

1.  Open `workspace_defs.bzl`

2.  Find the library export you want to increment

3.  Update the `version` attribute to the new value

4.  Update the `sha256` attribute to the value obtained by running:

    ```sh
    curl "https://repo1.maven.org/maven2/${group_id//.//}/${artifact_id}/${version}/${artifact_id}-${version}.jar" | sha256sum
    ```

    TIP: Double-check that the download is the size you expect

5.  Send the change for review

6.  Once submitted, remember to update your own dep on `bazel_common` to the
    version containing your change
