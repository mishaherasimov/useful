fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### produce_app
```
fastlane produce_app
```


----

## iOS
### ios load_codesign
```
fastlane ios load_codesign
```
Sync and sign certificates
### ios build
```
fastlane ios build
```
Build and sign the app
### ios upload_for_testing
```
fastlane ios upload_for_testing
```
Build and upload the app to TestFlight

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
