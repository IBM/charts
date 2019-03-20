## Shared Configurable Helpers Unit Tests

The following directory contains unit tests for verifying that code updates to the Shared Configurable Helpers (SCH) do not break backward compatibility. These tests are run by the Travis build as part of the pull request process. Any new function added to SCH requires new unit tests to test that function.

The unit test scripts are supported on Linux and MacOS.

### Prerequisites

Helm must be installed and be found in the system path.

### Test structure

A test contains a small Helm chart, an expected output, and an actual output file:

```bash
├── test-testname
│   ├── chart
│   │   ├── templates
│   |   |   ├── _sch-chart-config.tpl
│   |   |   ├── template_yaml_file.yaml
│   |   ├── Chart.yaml
│   |   ├── values.yaml
│   ├── expected.yaml
└── └── output.yaml
```


The runTests.sh script will find any folder starting with `test-` in the unit-tests folder, process the template, and compare that output with the expected output.

### Running the unit tests

Execute the tests by running the runTests.sh script. The script will run through all of the tests and report any successes or failures.

```
# cd unit-tests
# ./runTests.sh
```
