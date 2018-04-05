CLASSPATH=../java/verigames.jar
SCALA=../../../scala/bin/scala

export jsr308_imports=checkers.interning.quals.*:checkers.nullness.quals.*:checkers.regex.quals.*:checkers.signature.quals.*
export JAVA_OPTS="-ea -server -Xmx1024m -Xms512m -Xss1m
-Xbootclasspath/p:$CLASSPATH"

ME=`basename $0`

  $SCALA checkers.inference.TTIRun --checker trusted.TrustedChecker --visitor trusted.TrustedVisitor --solver trusted.TrustedGameSolver --weightmgr nninf.NninfWeightManager $*;
