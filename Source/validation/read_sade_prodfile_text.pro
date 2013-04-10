function read_sade_prodfile_text,prodfile

template=CREATE_STRUCT('VERSION', 1.0,$
                      'DATASTART',0,$
                      'DELIMITER', ' ',$  ;IS SPACE DELIMITED
                      'MISSINGVALUE',-999,$
                      'COMMENTSYMBOL','"',$
                      'FIELDCOUNT',[1],$
                      'FIELDTYPES', [7],$
                      'FIELDNAMES', ['badprod'],$
                      'FIELDLOCATIONS',[0],$
                      'FIELDGROUPS',[1])

prodDATA = READ_ASCII(prodFILE,TEMPLATE=TEMPLATE)
RETURN,prodDATA

end