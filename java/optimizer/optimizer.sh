#!/bin/bash

DIR="$(dirname "$0")"
JAR="$DIR/build/libs/optimizer.jar"

if [ ! -e "$JAR" ]; then
    echo "Failed to find $JAR... try running 'gradle jar' in $DIR"
    exit 1
fi

pushd "$DIR" >/dev/null
CP="$JAR:$(gradle -q printRuntimeClasspath | tail -n1):$CLASSPATH"
popd >/dev/null

# Note: you may need to raise/lower the max heap size for your workload
exec java -Xmx6G -cp "$CP" verigames.optimizer.Main $@
