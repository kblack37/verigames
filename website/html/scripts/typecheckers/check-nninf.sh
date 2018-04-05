export CLASSPATH=../java/verigames.jar

# This actually creates ambiguity between nullness and nninf!
# export jsr308_imports=checkers.interning.quals.*:checkers.nullness.quals.*:checkers.regex.quals.*:checkers.signature.quals.*

ME=`basename $0`

ea=-ea:com.sun.tools...

JAVAC="java -Xbootclasspath/p:../java/verigames.jar ${ea} com.sun.tools.javac.Main"

if [ "$ME" == "check-nninf.sh" ] ; then
  eval "$JAVAC -processor nninf.NninfChecker $*";
elif [ "$ME" == "check-trusted.sh" ] ; then
  eval "$JAVAC -processor trusted.TrustedChecker $*";
else
  echo "Incorrect usage: $ME";
fi