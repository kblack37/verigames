AS3COMPILER="asc2.jar"
AS3COMPILERARGS="java -jar ../../crossbridge/sdk/usr/lib/${AS3COMPILER} -merge -md"
set -e
if [ "$1" = "clean" ]; then
    rm -f maxsat_util.swc as_swig.c maxsat_swig.as *.abc maxsat.abc *~ */*~
else
    echo "Running SWIG..."
    ${FLASCC}/usr/bin/swig.exe -as3 -module maxsat_swig -outdir . -includeall -ignoremissing -o as_swig.c as_swig.i

    echo "Compiling ActionScript..."
    ${AS3COMPILERARGS} -abcfuture -AS3 -import ${FLASCC}/usr/lib/builtin.abc -import ${FLASCC}/usr/lib/playerglobal.abc maxsat_swig.as
    ${AS3COMPILERARGS} -abcfuture -AS3 -import ${FLASCC}/usr/lib/builtin.abc -import ${FLASCC}/usr/lib/playerglobal.abc maxsat.as

    echo "Creating SWC..."
    ${FLASCC}/usr/bin/gcc maxsat.abc maxsat_swig.abc as_swig.c as_main.c borchers/maxsat_borchers.c borchers/wmaxsat.c maxsatz2009/maxsat_maxsatz2009.c maxsatz2009/maxsatz2009.c main.c -emit-swc=maxsat_package -o maxsat_util.swc

    echo "Installing..."
    cp maxsat_util.swc ../example/lib/
fi
