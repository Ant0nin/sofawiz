#!/bin/bash -e

progname=$(basename $0)
progdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
subcommand=$1

sub_help() {
	echo 'List of existing subcommands:'
	echo '   genclass cMakefileLocation myClassFolderLocation "my::namespace::MyClass<T...>" motherClassLocation "sofa::namespace::MotherClass<T...>"'
}

sub_genclass() {
	cmakefile=$1
	destfolder=$2
	fullclassname=$3
	motherlocation=$4
	motherfullclassname=$5

	templateArgs=$(echo $fullclassname | sed 's/.*<\(.*\)>/\1/g' | sed 's/,/ /g')
	classname=$(echo "$fullclassname" | cut -d'<' -f1 | rev | sed 's/::/,/g' | cut -d',' -f1 | rev)
	componenttype=$(echo "$fullclassname" | cut -d'<' -f1 | rev | sed 's/::/,/g' | cut -d',' -f2 | rev)
	classnamespace=$(echo "$fullclassname" | cut -d'<' -f1 | sed 's/::/ /g' | sed 's/.\w*$//')
	motherclassname=$(echo "$motherfullclassname" | cut -d'<' -f1)
	motherTemplateArgs=$(echo $motherfullclassname | sed 's/.*<\(.*\)>/\1/g' | sed 's/,/ /g')
	
	mkdir -p $destfolder

	# if template class...
	if [ -n "$templateArgs" ]
	then
		typenameTemplateArgs=" typename $(echo "$templateArgs" | sed 's/ /, typename /g' )"
		templateArgs=$(echo $templateArgs | sed 's/ /, /g')
		motherTemplateArgs=$(echo $motherTemplateArgs | sed 's/ /, /g')
		templateArgsCount=$(echo $templateArgs | wc -w)
		motherTemplateArgsCount=$(echo $motherTemplateArgs | wc -w)

		header_file="$destfolder/$classname.h"
		touch $header_file
		cat "$progdir""/templates/sofa_licence" > $header_file
		cat "$progdir""/templates/component_templateclass.h" > $header_file


		cpp_file="$destfolder/$classname.cpp"
		touch $cpp_file
		cat "$progdir/templates/sofa_licence" > $cpp_file
		cat "$progdir/templates/component_templateclass.cpp" > $cpp_file

		inl_file="$destfolder/$classname.inl"
		cat "$progdir/templates/sofa_licence" > $inl_file
		cat "$progdir/templates/component_templateclass.inl" > $inl_file

		sed -i "s/_typenameTemplateArgs_/$typenameTemplateArgs/g" $header_file
		sed -i "s/_templateArgs_/$templateArgs/g" $header_file
		sed -i "s/_motherTemplateArgs_/$motherTemplateArgs/g" $header_file
		
		if [ $templateArgsCount -eq '1' ]
		then
			sed -i "s/_templateArgsCount_//g" $header_file
		else
			sed -i "s/_templateArgsCount_/$templateArgsCount/g" $header_file
		fi

		if [ $motherTemplateArgsCount -eq '1' ]
		then
			sed -i "s/_motherTemplateArgsCount_//g" $header_file
		else
			sed -i "s/_motherTemplateArgsCount_/$motherTemplateArgsCount/g" $header_file
		fi
	else
		header_file="$destfolder/$classname.h"
		touch $header_file
		cat "$progdir""/templates/sofa_licence" > $header_file
		cat "$progdir""/templates/component_class.h" > $header_file
	
		cpp_file="$destfolder/$classname.cpp"
		touch $cpp_file
		cat "$progdir/templates/sofa_licence" > $cpp_file
		cat "$progdir/templates/component_class.cpp" > $cpp_file
	fi

	sed -i "s;_motherLocation_;$motherlocation;g" $header_file
	sed -i "s/_COMPONENTNAME_/\U$classname/g" $header_file
	sed -i "s/_COMPONENTTYPE_/\U$componenttype/g" $header_file
	sed -i "s/_MotherClass_/$motherclassname/g" $header_file
	sed -i "s/_componenttype_/$componenttype/g" $header_file
	sed -i "s/_ComponentName_/$classname/g" $header_file

	sed -i "s/_componenttype_/$componenttype/g" $cpp_file
	sed -i "s/_ComponentName_/$classname/g" $cpp_file
	sed -i "s/_ComponentNameClass/$classname/g" $cpp_file
	
	sed -i "/set(HEADER_FILES/a \"$header_file\"" $cmakefile
	sed -i "/set(SOURCE_FILES/a \"$cpp_file\"" $cmakefile

	namespacebegin=''
	namespaceend=''
	for word in $(echo "$classnamespace")
	do
		namespacebegin+="namespace $word {\n\n"
		namespaceend+="\} \/\/ $word \n\n"
	done
	namespacebegin=$(echo "${namespacebegin: : -4}")
	namespaceend=$(echo "${namespaceend: : -4}")
	sed -i "s/_namespacebegin_/$namespacebegin/g" $header_file
	sed -i "s/_namespacebegin_/$namespacebegin/g" $cpp_file
	sed -i "s/_namespaceend_/""$namespaceend""/g" $header_file
	sed -i "s/_namespaceend_/""$namespaceend""/g" $cpp_file

	echo 'Finished!'
}

sub_rmclass() {
	cmakefile=$1
	fullclassname=$2

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
