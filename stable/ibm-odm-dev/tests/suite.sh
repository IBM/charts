#!/bin/sh

    sh /tests/wait-for-url.sh $ODMSERVER:9060/DecisionRunner
    sh /tests/wait-for-url.sh $ODMSERVER:9060/DecisionService resAdmin resAdmin
    sh /tests/wait-for-url.sh $ODMSERVER:9060/decisioncenter/t
    sh /tests/wait-for-url.sh $ODMSERVER:9060/teamserver
    sh /tests/wait-for-url.sh $ODMSERVER:9060/res
