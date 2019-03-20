#!/bin/bash
    bash /tests/wait-for-url.sh $ODMSERVER:9060/DecisionRunner
    bash /tests/wait-for-url.sh $ODMSERVER:9060/DecisionService resAdmin resAdmin
    bash /tests/wait-for-url.sh $ODMSERVER:9060/decisioncenter/t
    bash /tests/wait-for-url.sh $ODMSERVER:9060/teamserver
    bash /tests/wait-for-url.sh $ODMSERVER:9060/res
