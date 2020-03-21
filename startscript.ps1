$rootfolder="/home/work/workspace/current"
$cmd1="$rootfolder/../linuxtool/00-envset.ps1"
out-host  -inputobject $cmd1
.   $cmd1
.   "$rootfolder/build/a06-exec.ps1"


# call this ps with follow command :
#   cd /home/work/workspace/current/build/
#  /home/work/workspace/linuxtool/ps/pwsh    ../../startscript.ps1
