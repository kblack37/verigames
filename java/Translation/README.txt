To build the project, you must have an environment variable named $CHECKERS
storing the location of the checkers folder in your copy of the checker
framework.

To use the layout module, you must have Graphviz (graphviz.org) installed, and
its "dot" tool must be callable from the command line.

ant targets:

   build (default) - Builds the source files in src/ to bin/

   buildall - Builds the source files in src/ and the tests in test/ to bin/

   check-nullness - Runs the nullness checker on the files in src/

   clean - Deletes the files in bin/

   test - Runs clean, buildall, then all tests
      
   test.[level|layout|graph|levelBuilder] - Runs all the tests in the
                                            respective package. Does not clean
                                            or build first.

   javadoc - Generates Javadoc for public members

   javadoc.protected - Generates Javadoc for public and protected members

   javadoc.package - Generates Javadoc for public, protected, and
                     package-private members

   javadoc.private - Generates Javadoc for public, package-private, protected,
                     and private members
