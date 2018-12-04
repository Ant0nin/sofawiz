#!/bin/bash -e

progname=$(basename $0)
progdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
subcommand=$1

sub_help() {
	echo 'List of existing subcommands:'
	echo '   genclass cMakefileLocation myClassFolderLocation "my::namespace::MyClass<T...>" motherClassLocation "sofa::namespace::MotherClass<T...>"'
	echo '   rmclass cMakefileLocation myClassLocation'
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
	header_file=$(echo "$destfolder/$classname.h" | sed 's;//;/;g')
	cpp_file=$(echo "$destfolder/$classname.cpp" | sed 's;//;/;g')

	namespacebegin=''
	namespaceend=''
	for word in $(echo "$classnamespace")
	do
		namespacebegin+="namespace $word {\n"
		namespaceend="\} \/\/ $word \n$namespaceend"
	done
	namespacebegin=$(echo "${namespacebegin: : -4}")
	namespaceend=$(echo "${namespaceend: : -4}")
	
	mkdir -p $destfolder
	touch $header_file
	touch $cpp_file
	
	cat "$progdir/templates/sofa_licence" > $cpp_file
	cat "$progdir""/templates/sofa_licence" > $header_file

	# if new class is template class...
	if [ -n "$templateArgs" ]
	then
		typenameTemplateArgs=" typename $(echo "$templateArgs" | sed 's/ /, typename /g' )"
		templateArgs=$(echo $templateArgs | sed 's/ /, /g')
		templateArgsCount=$(echo $templateArgs | wc -w)

		cat "$progdir""/templates/component_templateclass.h" > $header_file
		cat "$progdir/templates/component_templateclass.cpp" > $cpp_file

		inl_file=$(echo "$destfolder/$classname.inl" | sed 's;//;/;g')
		touch $inl_file
		cat "$progdir/templates/sofa_licence" > $inl_file
		cat "$progdir/templates/component_templateclass.inl" > $inl_file

		sed -i "s/_ComponentName_/$classname/g" $inl_file
		sed -i "s/_namespacebegin_/$namespacebegin/g" $inl_file
		sed -i "s/_namespaceend_/""$namespaceend""/g" $inl_file

		sed -i "s/_typenameTemplateArgs_/$typenameTemplateArgs/g" $header_file
		sed -i "s/_templateArgs_/$templateArgs/g" $header_file
		
		if [ $templateArgsCount -eq '1' ]
		then
			sed -i "s/_templateArgsCount_//g" $header_file
		else
			sed -i "s/_templateArgsCount_/$templateArgsCount/g" $header_file
		fi

	else
		cat "$progdir""/templates/component_class.h" > $header_file
		cat "$progdir/templates/component_class.cpp" > $cpp_file
	fi

	motherTemplateArgs=$(echo $motherTemplateArgs | sed 's/ /, /g')
	motherTemplateArgsCount=$(echo $motherTemplateArgs | wc -w)

	# if mother class is template class...
	if [ "$motherTemplateArgs" ]
	then
		sed -i "s/_motherMacroDecl_/SOFA_TEMPLATE_motherTemplateArgsCount_(_MotherClass_, _motherTemplateArgs_)/g" $header_file
		sed -i "s/_motherTemplateArgs_/$motherTemplateArgs/g" $header_file
		sed -i "s/_MotherFullName_/$motherfullclassname/g" $header_file

		if [ $motherTemplateArgsCount -eq '1' ]
		then
			sed -i "s/_motherTemplateArgsCount_//g" $header_file
		else
			sed -i "s/_motherTemplateArgsCount_/$motherTemplateArgsCount/g" $header_file
		fi
	else
		sed -i "s/_motherMacroDecl_/_MotherClass_/g" $header_file
		sed -i "s/_MotherFullName_/_MotherClass_/g" $header_file
	fi

	sed -i "s;_motherLocation_;$motherlocation;g" $header_file
	sed -i "s/_COMPONENTNAME_/\U$classname/g" $header_file
	sed -i "s/_COMPONENTTYPE_/\U$componenttype/g" $header_file
	sed -i "s/_MotherClass_/$motherclassname/g" $header_file
	sed -i "s/_componenttype_/$componenttype/g" $header_file
	sed -i "s/_ComponentName_/$classname/g" $header_file
	sed -i "s/_namespacebegin_/$namespacebegin/g" $header_file
	sed -i "s/_namespaceend_/""$namespaceend""/g" $header_file

	sed -i "s/_componenttype_/$componenttype/g" $cpp_file
	sed -i "s/_ComponentName_/$classname/g" $cpp_file
	sed -i "s/_ComponentNameClass_/$classname""Class/g" $cpp_file
	sed -i "s/_namespacebegin_/$namespacebegin/g" $cpp_file
	sed -i "s/_namespaceend_/""$namespaceend""/g" $cpp_file
	
	sed -i "/set(HEADER_FILES/a \"$header_file\"" $cmakefile
	sed -i "/set(SOURCE_FILES/a \"$cpp_file\"" $cmakefile

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
