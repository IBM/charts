#!/bin/bash
    if [ $DECISION_RUNNER_ENABLED = "true" ]
    then
      sh /tests/wait-for-url.sh $DECISION_RUNNER_NAME
    fi

    if [ $DECISION_SERVER_RUNTIME_ENABLED = "true" ]
    then
      sh /tests/wait-for-url.sh $DECISION_SERVER_RUNTIME_NAME resExecutor resExecutor
    fi

    if [ $DECISION_CENTER_ENABLED = "true" ]
    then
      sh /tests/wait-for-url.sh $DECISION_CENTER_NAME/decisioncenter/t
      sh /tests/wait-for-url.sh $DECISION_CENTER_NAME/decisioncenter/assets/decision-center-client-api.zip
    fi

    if [ $DECISION_SERVER_CONSOLE_ENABLED = "true" ]
    then
      sh /tests/wait-for-url.sh $DECISION_SERVER_CONSOLE_NAME
    fi
