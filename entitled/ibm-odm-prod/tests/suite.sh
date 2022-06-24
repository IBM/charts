#!/bin/bash
    if [ $DECISION_RUNNER_ENABLED = "true" ]
    then
      sh /tests/wait-for-url.sh $PROTOCOL://$DECISION_RUNNER_NAME:9443/DecisionRunner
    fi

    if [ $DECISION_SERVER_RUNTIME_ENABLED = "true" ]
    then
      sh /tests/wait-for-url.sh $PROTOCOL://$DECISION_SERVER_RUNTIME_NAME:9443/DecisionService resExecutor resExecutor
    fi

    if [ $DECISION_CENTER_ENABLED = "true" ]
    then
      sh /tests/wait-for-url.sh $PROTOCOL://$DECISION_CENTER_NAME:9453/decisioncenter/t
      sh /tests/wait-for-url.sh $PROTOCOL://$DECISION_CENTER_NAME:9453/decisioncenter/assets/decision-center-client-api.zip
    fi

    if [ $DECISION_SERVER_CONSOLE_ENABLED = "true" ]
    then
      sh /tests/wait-for-url.sh $PROTOCOL://$DECISION_SERVER_CONSOLE_NAME:9443/res
    fi
