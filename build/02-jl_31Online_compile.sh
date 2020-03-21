BuildSCript="julia $JULIA_DEPOT_PATH/packages/PackageCompiler/oT98U/juliac.jl " #julia 1.2
BuildSCript="julia $JULIA_DEPOT_PATH/packages/PackageCompiler/CJQcs/juliac.jl " #julia 1.3
BuildOutPath="/media/wang/34e67bec-7d42-4d87-824f-2f98672a41af/t/app/fiberproc/exec/"
BuildOutPath="/media/wang/705fc396-8c76-4812-9d0b-d17382d9dfc7/backup/t/app/fiberproc/exec/"


Architecture=ivybridge
Architecture=x86-64
jlnameEntry=../Jl-code/31-OnlineApp.jl
a=`pwd`
cd ..
b=`pwd`

cd $a
echo dangqian:
pwd 

# cd  builddir
echo enter into `pwd`
if [ -L Jl-Aux  ]; then 
    echo is Link
    rm   Jl-Aux 
fi 
#ln -s $b/Jl-Aux .
#ls -l Jl-Aux 
# cd $as

echo $a
#echo $b/Jl-Aux 
#-vRe
#exec bash
$BuildSCript -C $Architecture   -vaRe --math-mode fast  $jlnameEntry  -d $BuildOutPath #-vatre 
