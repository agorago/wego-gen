function constructComponentNameFromPackageName() {
  a=${1}
  component=""

  echo $a | tr '-' '\n' |
  {
    while  read A
    do
      A="$(tr '[:lower:]' '[:upper:]' <<< ${A:0:1})${A:1}"
      component="$component$A"
    done
    echo $component
  }
}

function smallFirstLetter() {
	A=$1
	echo "$(tr '[:upper:]' '[:lower:]' <<< ${A:0:1})${A:1}"
}

function makeSedScript(){
	register_action="Register${caps_package_to_generate}Action"
	echo "s#CarFuelOrder#$caps_package_to_generate#g"
	echo "s#__PackageName__#$caps_package_to_generate#g"
	echo "s#order-carfuel#$package_name#g"
	echo "s#__package_name__#$package_name#g"
	echo "s#RegisterCarFuelAction#$register_action#g"
	echo "s#__RegisterPackageNameAction__#$register_action#g"
	echo "s#Jsonfile#$stdfile#g"
	echo "s#starterrorcode#$starterrorcode#g"
}

function setenv(){
	curprog=${1}
	scripts_folder=${curprog%/*}
	[[ $scripts_folder != /* ]] && scripts_folder=$(pwd)/${scripts_folder}

	base_folder=${scripts_folder%/bin}
	template_folder=$base_folder/template-files/gen-workflow
	config_folder=$base_folder/config
	source $config_folder/setenv.sh
}

prog=${0##*/}
tmp=/tmp/$prog.$$
stdfile=$1
package_name=${stdfile%"-std.json"}
caps_package_to_generate=$(constructComponentNameFromPackageName $package_name)
small_package_to_generate=$(smallFirstLetter $caps_package_to_generate)

if [[ -z $1 ]] || [[ $1 != *-std.json ]] || [[ ! -f $1 ]] || [[ -z $2 ]]
then
	echo "Usage: $prog <workflow file> [URL-for-module]"
	echo "Workflow file must be of form *-std.json"
	exit 1
fi
workflow_file=$1
URL=$2
starterrorcode=$3
setenv $0

destdir=$(pwd)
packagedir=$destdir/$package_name
cp -r $template_folder $packagedir
cd $packagedir
go mod init $URL
go mod edit --replace ${URLPrefix}/bplus=../bplus
cd -
cp $stdfile $packagedir/configs/workflow
sedscript=/tmp/sedscript.$prog.$$
makeSedScript > $sedscript
sed -f $sedscript $template_folder/configs/bundles/en-US/en.toml > $packagedir/configs/bundles/en-US/$package_name.toml
rm $packagedir/configs/bundles/en-US/en.toml
sed -f $sedscript $template_folder/internal/scripts/test/test.sh > $packagedir/internal/scripts/test/test.sh
sed -f $sedscript $template_folder/init.go > $packagedir/init.go
sed -f $sedscript $template_folder/model/model.go > $packagedir/model/model.go
sed -f $sedscript $template_folder/internal/cmd/main/main.go > $packagedir/internal/cmd/main/main.go
sed -f $sedscript $template_folder/internal/service/register.go > $packagedir/internal/service/register.go
sed -f $sedscript $template_folder/internal/service/repo.go > $packagedir/internal/service/repo.go
sed -f $sedscript $template_folder/internal/service/preprocessor.go > $packagedir/internal/service/preprocessor.go
sed -f $sedscript $template_folder/internal/err/codes.go > $packagedir/internal/err/codes.go
sed -f $sedscript $template_folder/internal/actions/init.go > $packagedir/internal/actions/init.go

# For each event generate an action
$scripts_folder/json-parser $workflow_file events  |
while read event
do
	$scripts_folder/gen-action.sh $event $sedscript $packagedir
done
# Find all automatic keys and generate stubs for each one of them
$scripts_folder/json-parser $workflow_file autostates |
while read key
do
  $scripts_folder/gen-auto-state.sh $key $sedscript $packagedir
done

exit 0
