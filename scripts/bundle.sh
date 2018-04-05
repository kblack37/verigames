# The production version is at
# /homes/abstract/bdwalker/www/java/verigames.jar

# The process is:
# - rebuild all projects in Eclipse
# - set the VERIGAMESJAR environment variable to the verigames.jar file
# - run scripts/bundle.sh

# The script does not depend on the existing build files for the
# sub-projects and instead collects the .class files out of the Eclipse
# build folders.
# The reason for this is that we want one big, flat .jar file that can
# be run directly.

# TODO: An improved alternative would be to use ant to build all
# sub-projects and then unpack all the resulting .jar files and
# re-package into the final verigames.jar file. Anyone interested in
# writing such an ant file?

# We are in the scripts directory
mydir=`dirname $0`

# the root (all-projects) is up 2 levels

root=`cd $mydir/../..; pwd`
# echo $root

tmp=/tmp
jar=$VERIGAMESJAR

echo Make sure all projects are built in Eclipse!
echo Creating $jar

# rm $jar

cd $root/jsr308-langtools/build/classes
jar -uf $jar `find . -name "*.class"` `find . -name "*.properties"` 

cd $root/checker-framework/checkers/build
jar -uf $jar `find . -name "*.class"` `find . -name "*.properties"` 

cd $root/checker-framework/javaparser/build
jar -uf $jar `find . -name "*.class"`

cd $root/annotation-tools/annotation-file-utilities/bin
jar -uf $jar `find . -name "*.class"`

cd $root/annotation-tools/scene-lib/bin
jar -uf $jar `find . -name "*.class"`

cd $root/annotation-tools/asmx/bin
jar -uf $jar `find . -name "*.class"`

cd $root/annotation-tools/scene-lib/bin
jar -uf $jar `find . -name "*.class"`

cd $root/plume-lib/bin-eclipse
jar -uf $jar `find . -name "*.class"`

cd $root/checker-framework-inference/bin
jar -uf $jar `find . -name "*.class"`

cd $root/verigames/java/Generation/bin
jar -uf $jar `find . -name "*.class"`

cd $root/verigames/java/Translation/bin
jar -uf $jar `find . -name "*.class"`

