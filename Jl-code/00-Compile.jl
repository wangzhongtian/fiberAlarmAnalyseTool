# to compable to most X64 Computers ,you need to RUN this JL with julia -C x86-64
#julia %USERPROFILE%\.julia\packages\PackageCompiler\oT98U\juliac.jl -C haswell -vRe 31-OnlineApp.jl
#julia ~/.julia/packages/PackageCompiler/oT98U/juliac.jl -C haswell -vRe 31-OnlineApp.jl
#julia ~/.julia/packages/PackageCompiler/oT98U/juliac.jl -C ivybridge -vRe 31-OnlineApp.jl
#julia %USERPROFILE%\.julia\packages\PackageCompiler\oT98U\juliac.jl -C ivybridge -vRe 31-OnlineApp.jl

using PackageCompiler

function genbatFileetc( AppDir::String,srcName::String,ExecFolder::String,DLLFolder::String )
    startUpScript = replace( srcName ,Pair(".jl",".bat" ))
    scriptFile = "$AppDir/$startUpScript"

    ExecFolder= replace(ExecFolder,Pair(AppDir,"%cd%" ))
    ExecFolder = replace(ExecFolder,Pair("/","\\") );
    DLLFolder= replace(DLLFolder,Pair(AppDir,"%cd%" ));
    DLLFolder = replace(DLLFolder,Pair("/","\\") );

    f1 =open(scriptFile,"w" )
    write(f1, "set path=%cd%;$ExecFolder;$DLLFolder;%path%\r\n" )
    write(f1,"mkdir $ExecFolder\\Log \r\n")
    write(f1,"pushd $ExecFolder\r\n")

    write(f1,"start cmd /K\r\n")
    close(f1)
end
function CpDlls(tgrDLLFolder::String; DLLS=[] ::String[]) 
    if Base.Sys.islinux()
        DLLext=".so"
    else
        DLLext=".dll"    
    end
    for dllFile in DLLS
        srcDllName = joinpath( ".",dllFile*DLLext)
        tgrDllName = joinpath( tgrDLLFolder ,dllFile*DLLext )
        Base.Filesystem.cp(srcDllName,tgrDllName,force=true)
    end
end

function BuildExecute(;AppDir::String,appname="exec" ,srcName="" )
    glbCfgFolder="glbCfg"
    buildFolder   = "$AppDir/$appname/" 
    DLLFolder  = "$AppDir/DLL/"
    ExecFolder = buildFolder
    tgrcfgFolder = "$ExecFolder/$glbCfgFolder/"
    scfCfgFolder = "./$glbCfgFolder/"

    mkpath( tgrcfgFolder)
    mkpath( ExecFolder)
    mkpath( DLLFolder)

    Base.Filesystem.cp(scfCfgFolder,tgrcfgFolder,force=true)
    genbatFileetc( AppDir,srcName,ExecFolder,DLLFolder )

    build_executable(
        srcName,
        # snoopfile = "call_functions.jl", # Julia script which calls functions that you want to make sure to have precompiled [optional]
        builddir = buildFolder
        )
end
##################################################
AppDir="../Tem/"

tgrDLLFolder  = "$AppDir/DLL/"

mkpath( tgrDLLFolder)
CpDlls(tgrDLLFolder,DLLS=["RawProc","RawDataSave","partSnap"])

#BuildExecute(;AppDir=AppDir,appname="OfflineApp" ,srcName="03-OfflineApp.jl" )
#exit(-1)
BuildExecute(;AppDir=AppDir,appname="OnlineApp" ,srcName="31-OnlineApp.jl" )
exit(-1)

# BuildExecute(;AppDir=AppDir,appname="hw2PTFileTransfer" ,srcName="01-Apphw2PTFileTransfer.jl" )
# exit(-1)
