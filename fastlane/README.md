fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### produce_app

```sh
[bundle exec] fastlane produce_app
```

Create an app on the app store connect. Produce

### bump_version

```sh
[bundle exec] fastlane bump_version
```

Increments build number and marketing version

To update marketing version provide `include_marketing` option (e.g. include_marketing:true)

To update specific semver item provide `type` option (e.g. type:major)

----


## iOS

### ios load_codesign

```sh
[bundle exec] fastlane ios load_codesign
```

Sync and sign certificates. Match

### ios build

```sh
[bundle exec] fastlane ios build
```

Build and sign the app. Gym

### ios upload_for_testing

```sh
[bundle exec] fastlane ios upload_for_testing
```

Build and upload the app to TestFlight. Pilot

### ios prepare_new_build

```sh
[bundle exec] fastlane ios prepare_new_build
```

Create a new tag and send it to the remote to trigger the release lane on CI

### ios unit_test

```sh
[bundle exec] fastlane ios unit_test
```

Build the app and run unit tests. Scan

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
