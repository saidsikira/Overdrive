# Contributing guidelines

This document contains guidelines for contributing to repository.

## Topics

* [Reporting issues](#reporting-issues)
* [Pull requests](#pull-requests)
* [Developer Certificate of Origin](#developer-certificate-of-origin)

### Reporting issues

A great way to contribute to the project is to send a detailed issue when you encounter an problem. We always appreciate a well-written, thorough bug report.

When reporting issues, please use already predefined issue template and fill in necessary info such as Overdrive version, platform, etc.

Check that the project issues database doesn't already include that problem or suggestion before submitting an issue. If you find a match, add a quick "+1" or "I have this problem too." Doing this helps prioritize the most common problems and requests.

Also, include following information (if applicable):

* The full output of any stack trace or compiler error
* A code snippet that reproduces the described behavior, if applicable
* Any other details that would be useful in understanding the problem

This information will help us review and fix your issue faster.

### Pull requests

Before submitting pull requests, please make sure that all unit tests are passed. You can run the unit test suite by running following command in the project root folder.

```bash
$ sh build.sh test
```

This script will run all unit tests on each supported platform. This script is also called by the Travis CI each time you submit a pull request or you push to master branch.

Submitting any pull request will also trigger lint checks by Hound CI. Please make sure that you don't have any lint errors before submitting.

### Developer Certificate of Origin

```
By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```
