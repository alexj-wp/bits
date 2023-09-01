# bits
Collection of little automation tools I've written

## MacPorts Maintenence
I'm not an active MacPorts maintainer, but I wanted to make this script available, both as a backup, and as a way to share my process with others.

### macports/setup.sh
This script clones my personal MacPorts tree and sets up the system to use it.

### macports/openstack.sh
This script automates modifying many portfiles in a standarddized way.
The first array of packages are modified to include recent versions of Python.
The second array of packages + versions are used to modify their respective Portfiles; as well as rebuild their hashes and size calculation.
This will then generate a commit for each Port change, one for the Python bump, one for the Version bump.
Be careful about running this script multiple times. It will generate a commit for each python package each time the script is run. Doing this twice will create incorrect commits stating "Package: x.y.z => x.y.z" as the version was already updated.

I'd like to eventually check against PyPi; and possibly reduce the number of commits to one-per-package. This may involve changing the arrays setup at the top of the file.
