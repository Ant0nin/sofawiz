#!/bin/bash -e

progname=$(basename $0)
progdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
subcommand=$1

sub_help() {
	echo 'List of existing subcommands:'
	echo '   [TODO]'
}

sub_genclass() {
	fullclassname=$1
	componenttype=$2
	motherclass=$3
	cmakefile=$4

	destfolder="${fullclassname%/*}"
	echo "Generate folder $destfolder..."
	mkdir -p $destfolder
	classname=$(basename $fullclassname)

	header_file="$fullclassname"".h"
	echo "Generate file $header_file..."
	touch $header_file
	cat "$progdir""/templates/sofa_licence" > $header_file
	cat "$progdir""/templates/component_class.h" > $header_file
	sed -i "s/_COMPONENTNAME_/\U""$classname""/g" $header_file
	sed -i "s/_COMPONENTTYPE_/\U""$componenttype""/g" $header_file
	sed -i "s/_MotherClass_/""$motherclass""/g" $header_file
	sed -i "s/_componenttype_/""$componenttype""/g" $header_file
	sed -i "s/_ComponentName_/""$classname""/g" $header_file

	cpp_file="$fullclassname"".cpp"
	echo "Generate file $cpp_file..."
	touch $cpp_file
	cat "$progdir""/templates/sofa_licence" > $cpp_file
	cat "$progdir""/templates/component_class.cpp" > $cpp_file
	sed -i "s/_componenttype_/""$componenttype""/g" $cpp_file
	sed -i "s/_ComponentName_/""$classname""/g" $cpp_file
	sed -i "s/_ComponentNameClass/""$classname""/g" $cpp_file

	echo 'Add entries in CMakeLists.txt...'
	sed -i "/set(HEADER_FILES/a \"$header_file\"" $cmakefile
	sed -i "/set(SOURCE_FILES/a \"$cpp_file\"" $cmakefile

	echo 'Finished!'
}

sub_rmclass() {
	fullclassname=$1
	cmakefile=$2

	echo 'Delete related files...'
	rm $(echo "$fullclassname.*")
	echo 'Remove related entries in CMakeLists.txt...'
	sed -i "\;$fullclassname.;d" $cmakefile

	echo 'Finished!'
}

case $subcommand in
	"-h" | "--help")
		sub_help $@
		;;
	*)
		shift
		sub_$subcommand $@
       		if [ $? = 127 ]; then
       	     		echo "Error: '$subcommand' is not a known subcommand." >&2
       	     		echo "       Run '$progname --help' for a list of known subcommands." >&2
       	     		exit 1
       	 	fi
       	 	;;
esac
