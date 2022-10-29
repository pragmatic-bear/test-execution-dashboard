# Test Execution Dashboard

A tool to help with monitoring Test Execution time as you go through development or refactoring. It's intended to encourage writing faster tests and catch things that slow you down.


## How does it work?

Simply by creating 2 equivalent SObjects to ApexTestRunResult and ApexTestResult which can then store your test results permanently and be reported on.

## What's included
The aforementioned objects and some basic Reports and Dashboards: Evolution of the total test execution time (by day, week or month) along with average time per method and a list of slowest test classes.
## Convenience

A bash script is included in the repository to move data from the ApexTest(Run)Result Tooling API object to the new SObjects via Bulk API.

Same scripts are also available as a [Reusable GitHub Action](https://github.com/pragmatic-bear/test-execution-dashboard-action) in a separate repository.

# How to use it
The reporting is based on simple averages per time period. It is therefore important that all the imported test results be comparable. 

Typical use case may be importing test results obtained during validation of a merge to your main branch.

Org Id field is available and could be used for filtering, however included reports and convenience tools are not adjusted to use that yet.

## Installation
Install the most recent Unlocked Package version (```04t7S000000TtzUQAS```) or clone/fork the repository and go crazy. 