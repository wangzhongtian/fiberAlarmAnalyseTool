#=
  本文件配置个性化参数，具体参见 initAlarmSegparas! 中的注释
=#

function initAlarmSegparas1!(SegAlarmParasDictObj::Dict,SrcDictObj::Dict )   #####################
    SegParaNameTuple1 =  ( segID = 0 , 
          microtime=Seg_MicroTimeParaStruct() ,
          microSpace=Seg_MicroSpaceParaStruct(),
          macroSpace= Seg_MacroSpaceParaStruct(),
          macroTime= Seg_MacroTimeParaStruct(),
          )

    SegParaNameTuple1.microtime.StaticThreshold = Int(2200) 
    SegParaNameTuple1.microtime.DynamicThreshold_CalTimePeriod = UInt( 60 ) 
    SegParaNameTuple1.microtime.DynamicThresHold_calCFactor=Int( 130 )
    SegParaNameTuple1.microtime.minTh=2200
    SegParaNameTuple1.microtime.maxTh=2200
    #微观过滤和合并 时间
    SegParaNameTuple1.microtime.microMergeTimePeriod  = Int(2) 
    SegParaNameTuple1.microtime.microFilterTimePeriod = Int(2) 
    
    #微观过滤和合并 空间
    SegParaNameTuple1.microSpace.microMergeSpaceLength = UInt(1)
    SegParaNameTuple1.microSpace.microFilterSpaceLength = UInt(3) 
    
    #宏观 空间 限制范围
    SegParaNameTuple1.macroSpace.macroMaxSpaceLength = UInt(100)
    SegParaNameTuple1.macroSpace.macroMinSpaceLength = UInt(4)
    #宏观 时间  限制范围
    SegParaNameTuple1.macroTime.macroMaxTimeInterval = UInt(30) 
    SegParaNameTuple1.macroTime.macroMinTimeInterval = UInt(15) 

    SegAlarmParasDictObj[SegParaNameTuple1.segID ] = SegParaNameTuple1
end

function initAlarmSegparas!(SegAlarmParasDictObj::Array{NamedTuple,1},SrcDictObj::Dict )   #####################
  a= keys(SrcDictObj)
  b= a
  # v=[]
  # for a1 in  b
  #   append!(v,a1)
  # end

  # for v1 in sort(v)
  #   println( v1)
  # end
  # exit()
  for segid in b
      if segid > 8192  
          println( segid ,"---SEGID OUTof Range--$segid----")
          exit()
      end
      if segid < 0 
        println( segid ,"-----SEGID OUTof Range--$segid---")
        exit()
      end    
      # println( segid ,"---------")
      aobj = ( segID = segid , microtime=Seg_MicroTimeParaStruct() ,
                            microSpace=Seg_MicroSpaceParaStruct(),
                            macroSpace= Seg_MacroSpaceParaStruct(),
                            macroTime= Seg_MacroTimeParaStruct(),
                          )

      valVector = SrcDictObj[ segid ]
      #="通道,标牌坐标1,标牌坐标2,
      4 ~7 :动态阈值时长,动态阈值系数,动态阈值下限,动态阈值上限,
      8 ~11 : 事件合并时长,事件滤除时间,事件合并距离,事件滤除距离,
      12~15: 告警空间下限,告警空间上限,告警续时下限,告警续时上限"      
      =#
     # println("exit out 1 !!!!"); exit();
     l1= length( valVector)
    #  for i in 1:l1 
    #     println( valVector[i] )
    #  end
      aobj.microtime.StaticThreshold = typemax(Int)
      aobj.microtime.DynamicThreshold_CalTimePeriod = UInt( valVector[4-3] ) 

      aobj.microtime.DynamicThresHold_calCFactor = Int(  valVector[5-3]   )
      # println(aobj.microtime.DynamicThresHold_calCFactor );
      # println("---------------")
      aobj.microtime.minTh = Int(  valVector[6-3]   )
      aobj.microtime.maxTh = Int(  valVector[7-3]   )
      #微观过滤和合并 时间
      aobj.microtime.microMergeTimePeriod  = Int(  valVector[8-3]   ) 
      aobj.microtime.microFilterTimePeriod = Int(  valVector[9-3]   ) 
      
      #微观过滤和合并 空间
      aobj.microSpace.microMergeSpaceLength =  UInt( valVector[10-3]   )
      aobj.microSpace.microFilterSpaceLength = UInt( valVector[11-3]  ) 
      
      #宏观 空间 限制范围
      aobj.macroSpace.macroMaxSpaceLength = UInt(  valVector[13-3]   )
      aobj.macroSpace.macroMinSpaceLength = UInt(  valVector[12-3]   ) 
      #宏观 时间  限制范围
      #println("exit out 3 !!!!"); exit();
      aobj.macroTime.macroMaxTimeInterval = UInt(  valVector[15-3]   ) 
      aobj.macroTime.macroMinTimeInterval = UInt(  valVector[14-3]   ) 
    #  println("exit out 6 !!!!",typeof( segid)  , typeof(SegAlarmParasDictObj)  ); exit();
    # println( "-typeof(segid)--",segid, "=$typeof(aobj)== ",aobj)
      SegAlarmParasDictObj[ segid ] = aobj
    #  SegAlarmParasDictObj[aobj.segID ] = aobj
    # println("exit out 7 !!!!",typeof( segid)); # exit();
      # break
  end
end
