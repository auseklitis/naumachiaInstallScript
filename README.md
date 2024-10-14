sed -i -e 's/\r$//' setup_naumachia.sh
will fix in a later update, this is a temporary patch

use Ubuntu Server LTS24 and do not install any additional packages when the installation prompts it, including docker, because it contains a problematic version. The docker is installed using within the script.

the script will create a seperate directory for Naumachia so run the install script from a directory where you want a "Naumachia" directory created
