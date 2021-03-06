import datetime, os, sys

if sys.platform == 'win32':
	buildversion = os.popen('SubWCRev .').read().split('\n')[2].split()[-1] or 'unknown'
else:
	buildversion = os.popen('bash -l -c "svnversion ."').read().strip() or 'unknown'

builddate = datetime.date.today().strftime('%Y-%m-%d')

f = open(os.path.normpath('src/BuildInfo.as'), 'w')
f.write('''\
/*
 * NOTE: This file was automatically generated by script/prebuild.py.
 * To regenerate it, run that script from the project's top-level folder.
 */



package
{
	public class BuildInfo
	{
		public static const VERSION:String = "%s";
		public static const DATE:String = "%s";
	}
}
''' % (buildversion, builddate))
f.close()
