# Cluster Administration - pre-install scripts

## `labelNamespace.sh`

This script has to be run once per cluster.
Run:
```
./labelNamespace.sh ICP4D_NAMESPACE
```

where `ICP4D_NAMESPACE` is the namespace where ICP4D is installed (usually `zen`)

For example

```
./labelNamespace.sh zen
```

## `deleteInstances.sh`

This script has to be run before each installation
Run:
```
./deleteInstances.sh ICP4D_NAMESPACE
```

where `ICP4D_NAMESPACE` is the namespace where ICP4D is installed (usually `zen`)

For example

```
./labelNamespace.sh zen
```
