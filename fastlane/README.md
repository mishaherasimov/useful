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



----


## iOS

### ios load_codesign

```sh
[bundle exec] fastlane ios load_codesign
```

Sync and sign certificates

### ios build

```sh
[bundle exec] fastlane ios build
```

Build and sign the app

### ios upload_for_testing

```sh
[bundle exec] fastlane ios upload_for_testing
```

Build and upload the app to TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
