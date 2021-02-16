# Gitlab Pipeline Image for Adopting standard-version

This Docker image is supposed to be used as build environment inside gitlab pipelines in order to
implement semantic versioning workflows.

It is an alpine-based nodejs image with the [standard-version](https://www.npmjs.com/package/standard-version) program installed
plus scripts that allow to save some boilerplate code required in gitlab to push version tags from the pipeline.

In addition to node, `git` and `openssh` are installed for workflows involving tagging and pushing.

## How to Use

In your project's `.gitlab-ci.yml` you add jobs before/after your actual build to deal with computing and tagging versions.

```yaml
compute-version:
  stage: Prepare
  image: fruiture/gitlab-standard-version:1.0.0
  script:
    - standard-version ...
```

## Shortcuts

For some standard problems inside gitlab, there are scripts packaged
in addition that allow you to write less code in your `.gitlab-ci.yml`.
They are on the `PATH` so you can just invoke them.

### `gitlab-compute-version`

Runs `standard-version` only to compute the version number (release or pre-release) from the commit history. Makes sure to fetch all tags before.

Will return the version number to STDOUT (all else goes to STDERR) and also write it to a file.

The behaviour is configured through environment variables:

* `VERSION_FILE_NAME` name of a simple text file that will be created and will contain the version number. This is useful for transporting the version number to other stages of the process - as an artifact.
    Default is `VERSION.txt`
* `RELEASE_BRANCH` is the name of the branch on which actual releases are made,
  on all other branches, pre-release version (with the branch name as) are generated. Default is `main`.

    * E.g. on a branch named `wip`, the computed versions will look like `1.2.3-wip.1`.
    * while on branch `main`, they will not be pre-releases: `1.2.3`
  
  If you never wan to do pre-releases, set `RELEASE_BRANCH="$CI_COMMIT_BRANCH"`.

  If you always want to do pre-releases, set `RELEASE_BRANCH="---"` (a branch name that will never match.)

### `gitlab-ssh-tag-version`

This script wraps all the boilerplate needed to create and push a version tag from your gitlab pipeline. It does not even invoke `standard-version`.

Requires some environment variables:

* `GIT_PUSH_KEY` must be the name of an ssh private key file (not the key itself) that will be used to authenticate. The script will adjust the file's permissions so `ssh` does not complain.
* `REPO_SSH_ADDRESS` must be address of the repo (`git@gitlab-host:/path/to/repo`)

By default, the current version is read from `VERSION.txt` and a lightweight tag `v$VERSION` (e.g. `v1.2.3`) is created and then pushed. You can
change this behaviour through environment variables:

* Set `TAG` if the tag is already set. The script will now only push this tag.
* Set `VERSION` to specifiy the version. The script will not read a file, but create the tag and push it.
* Set `VERSION_FILE_NAME` to change the name of the version file. Th script will read this file instead, create a tag and push it.

### Where does the `GIT_PUSH_KEY` come from?

Create a *Deploy Key* with write access configured in your *Repository Settings*. Add the private key as a variable (of type **file**) for your pipeline. **Important:** Make sure the private key text as a trailing newline.
