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

# Debugging 

## `deleteInstances.sh`

If you run into issues with "phantom" instances (although this should be fixed in CPD 2.5), run:

```
./deleteInstances.sh ICP4D_NAMESPACE
```

where `ICP4D_NAMESPACE` is the namespace where ICP4D is installed (usually `zen`)

For example

```
./deleteInstances.sh zen
```
