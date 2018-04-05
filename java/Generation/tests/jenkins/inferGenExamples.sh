#!/bin/bash

thisDir="`dirname $0`"
case `uname -s` in
    CYGWIN*)
      thisDir=`cygpath -m $mydir`
      ;;
esac

distDir=$thisDir"/../../../dist"
exampleDir=$thisDir"/../../examples"

#For every java file in "java/Generation/examples" run inferNullness.sh
#and after all finish exit 0 if none failed or 1 if any had a non-zero exit status

files=(`find $exampleDir -type f \( -iname "*.java" ! -iname "*_vars.java" \)` )

success=true
count=0
failed=0
passed=0
for f in "${files[@]}"
do
	
	#create dot string for fileName.......status!
	length="${#f}"
	numDots=`expr 70 - ${length}`

	if [ $numDots -lt 1 ]
	then
	    numDots=1
	fi

	dots=""
	if [ $length -lt 60 ]
	then
        for i in $(seq 1 $numDots)
		do 
    		dots=$dots"." 
		done
	fi
	
	eval python $distDir"/scripts/verigames.py --checker ostrusted.OsTrustedChecker "$f
	
	if [ $? -ne 0 ]
		then  
			files[$count]=$f$dots" failed!"
			success=false
			failed=`expr ${failed} + 1`
		else 
			files[$count]=$f$dots" passed!"
			passed=`expr ${passed} + 1`
	fi
	
    count=`expr ${count} + 1`
    
	echo ""
	echo "========================================"
	echo ""
done

echo ""
echo "Results:"
for f in "${files[@]}"
do
	echo $f
done

msg=$count" Total Files "$passed" Passed "$failed" Failed"
length="${#msg}"
numSpaces=`expr 67 - ${length}`
spaces=""
if [ $length -lt 67 ]
	then
        for i in $(seq 1 $numSpaces)
	    do 
        	spaces="_$spaces"
		done
fi

echo $spaces$msg

if $success ; 
	then
    	echo 'Success!'
		echo ""
    else
    	echo 'Failed!'
		echo ""
    	exit 1
fi
