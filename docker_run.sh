docker run --privileged --gpus all \
-v ${COLOSSAL_HOME}:/workspace/ColossalAI \
-v ${COLOSSAL_EXAMPLE}:/workspace/ColossalAI-Examples \
-it --name colossalai-${USER} colossalai:main