. 00-envset.ps1


$folder="/media/wang/705fc396-8c76-4812-9d0b-d17382d9dfc7/backup/t/app/fiberproc/sjz004/xxxx20191126/xx1号机12月20日15：13-12月21日16：11--raw3数据"
$filename="20191220T151354.lc"
$filename="20191221T064555.lc"

$env:machineID="GYYS-001"
$env:splitedFileRootName="$folder/$filename"
julia   ../Jl-code/91-fileMerge.jl
julia  ../Jl-code/01-Entry-hw2PTFileTransfer.jl

