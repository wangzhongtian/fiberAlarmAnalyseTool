import csv
def transferGB2312_TO_UTF8SigFile(SrcFile,TgrFilename):
    csv_file= csv.reader( open(SrcFile,"r") )
    UTF8fileObj = open(TgrFilename,"w",encoding="utf-8-sig")

    for line in csv_file:
        print(line)
        for col in line: #[0:end]:
            print( col,end=",", file= UTF8fileObj)
        print(file= UTF8fileObj )
    UTF8fileObj.close()

SrcFile="GYYS001-ParasGBk-FULL.csv"
TgrFilename ="GYYS-001-AlarmParas.csv"
transferGB2312_TO_UTF8SigFile(SrcFile,TgrFilename)
