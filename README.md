# Bazel Common Libraries

This repository contains assorted common functionality for Google's open-source
libraries that are built with [`bazel`]. It is an experimental project and none
of the APIs/target names are fixed/guaranteed to remain. You are welcome to use
it and offer feedback at your own risk.

This is not an official Google product.

[`bazel`]: https://bazel.build

## Incrementing the version of an exported library

1. Run [`update_version`], passing the group, artifact ID, and version you want
    to update:

    ```shell
    $ update_version com.google.guava guava 31.0.1-jre
    ```

    If several artifacts share the same version via a variable, such as
    `ERROR_PRONE_VERSION`, you can pass just the variable and the new version:

    ```shell
    $ update_version ERROR_PRONE_VERSION 2.3.2
    ```

2.  Send the change for review.

3.  Once submitted, remember to update your own dep on `bazel_common` to the
    version containing your change.

### If `update_version` doesn't work

1.  Open `workspace_defs.bzl`

2.  Find the library export you want to increment

3.  Update the `version` attribute to the new value

4.  Update the `sha256` attribute to the value obtained by running:

    ```sh
    curl "https://repo1.maven.org/maven2/${group_id//.//}/${artifact_id}/${version}/${artifact_id}-${version}.jar" | sha256sum
    ```

    TIP: Double-check that the download is the size you expect

5. Return to step 2 above.

[`update_version`]: https://github.com/google/bazel-common/blob/master/update_version
