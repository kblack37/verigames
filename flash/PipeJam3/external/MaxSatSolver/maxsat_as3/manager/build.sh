AS3COMPILER="asc2.jar"
AS3COMPILERARGS="java -jar ${FLASCC}/usr/lib/${AS3COMPILER} -merge -md"
COMPC="${FLEX_HOME}/lib/compc.jar  +flexlib=$FLEX_HOME/frameworks"

set -e

if [ "$1" = "clean" ]; then
    rm -f maxsat_manager.swc *~ */*~
else
    echo "Creating SWC..."
    java -jar ${COMPC} -target-player=11.5 -source-path+=. maxsat/MaxSatManager -o maxsat_manager.swc

    echo "Installing..."
    cp maxsat_manager.swc ../example/lib/
fi
