#!/bin/bash
# Run the sequence by name

NAME="$1"
if [ "X$NAME" == "X" ]; then
  echo "Usage $0 sequence"
  exit 1
fi

guard=$(kubectl get iscguard $NAME -o 'jsonpath={.spec.generation}' 2>/dev/null)
seq=$(kubectl get iscsequence $NAME -o 'jsonpath={.spec.labels.generation}' 2>/dev/null)

if [ "X$guard" == "X$seq" ]; then
  echo "Updating completed sequence"
else
  echo "Sequence was not completed - updating anyway"
  echo "Sequence uuid: $seq"
  echo "Guard uuid: $seq"
fi

kubectl patch iscsequence $NAME --type merge --patch '{"spec":{"labels":{"generation":"'$(date +%s)'"}}}'

seq=$(kubectl get iscsequence $NAME -o 'jsonpath={.spec.labels.generation}' 2>/dev/null)
echo "Updated sequence uuid: $seq"

