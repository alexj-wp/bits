#!/bin/bash
IFS=''

portdir="${HOME}/Projects/Code/macports-ports"

increase_python_version=(
  "py-cinderclient"
  "py-cliff"
  "py-cmd2"
  "py-debtcollector"
  "py-dogpile-cache"
  "py-keystoneauth1"
  "py-keystoneclient"
  "py-netifaces"
  "py-novaclient"
  "py-openstackclient"
  "py-openstacksdk"
  "py-os-service-types"
  "py-osc-lib"
  "py-oslo-config"
  "py-oslo-i18n"
  "py-oslo-serialization"
  "py-oslo-utils"
  "py-prettytable"
  "py-requestsexceptions"
)

bump=(
  "py-cinderclient 9.3.0"
  "py-cliff 4.3.0"
  "py-debtcollector 2.5.0"
  "py-keystoneauth1 5.2.1"
  "py-keystoneclient 5.1.0"
  "py-novaclient 18.3.0"
  "py-openstackclient 6.2.0"
  "py-openstacksdk 1.4.0"
  "py-os-service-types 1.7.0"
  "py-osc-lib 2.8.0"
  "py-oslo-config 9.1.1"
  "py-oslo-i18n 6.0.0"
  "py-oslo-serialization 5.1.1"
  "py-oslo-utils 6.2.0"
)

cd $portdir

## Read in modules that need to build for 3.11
for module in ${increase_python_version[@]}
do 
  portfile="${portdir}/python/${module}/Portfile"
  sed -i '' -e '/^python.versions.*38$/ s/$/ 39 310 311/' \
      -e '/^python.versions.*39$/ s/$/ 310 311/' \
      -e '/^python.versions.*310$/ s/$/ 311/' \
     $portfile
  git add $portfile
  git commit -m "$module: build for up to Python 3.11"
done

### Read in version changes
for update in ${bump[@]}
do
  IFS=' '
  updatearray=($update)        ## Arrayify the line
  module=${updatearray[0]}     ## Extract the python module we're targetting
  version=${updatearray[1]}    ## and the version we're targetting

  ## Set the file we're editing
  portfile="${portdir}/python/${module}/Portfile"
  
  ## Find the old version in the Portfile
  prior=$(grep ^version $portfile | awk '{print $2}')

  ## Swap the version in the file
  sed -i '' -e '/^version.*$/ s/'$prior'/'$version'/' $portfile

  ## do checks for each python version
  for pyver in "38" "39" "310" "311"
  do
    ## version specific python module name
    pyvermodule=${module/py/py$pyver}
    ## cleanup before build
    sudo port clean --all $pyvermodule 2>&1 > /dev/null

    ## Download and rebuild checksums
    greplines=$(sudo port -dv checksum $pyvermodule 2>&1 | grep "Calculated")

    ## Do the actual checksum swap per entry
    while IFS= read -r line
    do
      # Get the sum type we're editing
      type=$(echo $line | awk '{ print $3 }' | sed 's/[)(]//g')
      # and the sum we're inputing
      sum=$(echo $line | awk '{ print $5 }')
      # placeholder
      oldsum=''

      # Find the old sum line and break it up
      sumarr=($(grep "$type" $portfile))
      # Store the old sum
      for i in "${!sumarr[@]}"
      do
        if [[ "${sumarr[$i]}" = "${type}" ]]
        then
          j=$((i+1))
          oldsum="${sumarr[$j]}"
        fi
      done
      ## Swap sums
      sed -i '' -e '/'$type'/ s/'$oldsum'/'$sum'/' $portfile
    done <<< "$greplines"

    ## Lint the portfile
    sudo port lint --nitpick $pyvermodule

    ## Run Tests
    # sudo port test $pyvermodule
    # These ports don't typically have tests,
    # so not worth running by default

    ## List Variants
    # sudo port variants $pyvermodule
    # These ports don't typically have variants,
    # so not worth running by default

    ## Clean up at end of module
    sudo port clean --all $pyvermodule 2>&1 > /dev/null
  done

  git add $portfile
  git commit -m "$module: $prior => $version"
done