# Overview

[![build](https://github.com/jbmorley/overview/actions/workflows/build.yaml/badge.svg)](https://github.com/jbmorley/overview/actions/workflows/build.yaml)

Generate monthly durations for similarly named calendar events.

<img src="screenshot-default@2x.png" alt="Screenshot of Overview on macOS showing details of two calendars" width="872">

## Development

### Builds

Overview follows the version numbering, build and signing conventions for InSeven apps. Further details can be found [here](https://github.com/inseven/build-documentation).

Release builds are created on GitHub Actions using 'build.sh' in the 'scripts' directory. This script is primarily focused on setting up the environment for testing and signing. Local builds can be performed using the  Xcode project found in the 'macOS' directory.

### Tests

It's helpful to be able to manually walk through the full Calendar authorisation flows before release. This authorisation can be reset using the following command, which should allow for testing the first-run experience:

```bash
tccutil reset Calendar uk.co.jbmorley.apps.overview
```

### Documentation

Documentation is built with [Jekyll](https://jekyllrb.com) and deployed at https://overview.jbmorley.co.uk.

Jekyll can be used to serve the documentation locally for testing:

```bash
cd docs
gem install
bundle exec jekyll serve
```

## Licensing

Overview is licensed under the MIT License (see [LICENSE](LICENSE)).
