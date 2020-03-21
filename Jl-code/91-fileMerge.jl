# function: 　将带ＩＤ的分拆的文件合成为一个文件，并转换成ＰT格式的RAW?文件。

Base.MainInclude.include( "common/fileSplitMerge.jl" )
using Base.Filesystem
###$$$$$$$$$$$$$$$$$$$$
##自动根据输入的文件名，将对应文件名后面加上.001,.002,.003 .....,以此类推，最多到.999的所有文件合并，写入到srcfile指定的目标文件中。
#srcfile="/media/wang/705fc396-8c76-4812-9d0b-d17382d9dfc7/backup/t/app/fiberproc/sjz004/高邑元氏20191126/20191126T033756.lc"
srcfile=ENV["splitedFileRootName"]
try 
		;MergeRestorefile(srcfile )
	catch e
		println(e)
end
