xquery version "1.0-ml";

module namespace topic = "http://alm.com/topic";
declare namespace group_lbs = "http://alm.com/LegalCompass/rd/GROUPS_LBS";
declare namespace topicgrouplbs = "http://alm.com/LegalCompass/rd/TOPICGROUPS_LBS";
declare namespace fieldgroup = "http://alm.com/LegalCompass/rd/FIELDGROUPS_LBS";

declare function topic:SP_GETTOPICBYGROUPLBS($groupID)
{
 let $res-array := json:array()
  let $orderBy := cts:index-order(cts:element-reference(xs:QName('topicgrouplbs:ID')) ,'ascending')
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/TOPICGROUPS_LBS/"),
                       cts:element-value-query(xs:QName('topicgrouplbs:ISACTIVE'),'1'),
                       cts:element-value-query(xs:QName('topicgrouplbs:GROUPID'),$groupID)
                       )),$orderBy)
  
  for $item in $result
                       let $res-obj := json:object()
                       let $_ := (map:put($res-obj,'ID',$item//topicgrouplbs:ID/text()),
                                  map:put($res-obj,'TopicName',$item//topicgrouplbs:TOPICNAME/text()),
                                  map:put($res-obj,'TopicDescription',$item//topicgrouplbs:TOPICDESCRIPTION/text()),
                                  map:put($res-obj,'GroupID',$item//topicgrouplbs:GROUPID/text()),
                                  map:put($res-obj,'GroupName',$item//topicgrouplbs:GROUPNAME/text()),
                                  map:put($res-obj,'Fields',topic:SP_GETFIELDSBYTOPICLBS($item//topicgrouplbs:ID/text()))
                                  )
                      (: let $_ := json:array-push($res-array,$res-obj)
                       return()           :)
return $res-obj
};

declare function topic:SP_GETFIELDSBYTOPICLBS($topicID)
{
  let $res-array := json:array()
  let $orderBy := cts:index-order(cts:element-reference(xs:QName('fieldgroup:ID')) ,'ascending')
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/FIELDGROUPS_LBS/"),
                       cts:element-value-query(xs:QName('fieldgroup:ISACTIVE'),'1'),
                       cts:element-value-query(xs:QName('fieldgroup:TOPICID'),$topicID)
                       )),$orderBy)
                       
 let $loopData := for $item in $result
                       let $res-obj := json:object()
                       
                       let $topicGroupData := cts:search(/,
                                        cts:and-query((
                                             cts:directory-query("/LegalCompass/relational-data/TOPICGROUPS_LBS/"),
                                             cts:element-value-query(xs:QName('topicgrouplbs:ISACTIVE'),'1'),
                                             cts:element-value-query(xs:QName('topicgrouplbs:ID'),$item//fieldgroup:TOPICID/text())
                                             )))[1]//topicgrouplbs:TOPICNAME/text()
											 
                       let $isSelected := if($item//fieldgroup:ISSELECTED/text() eq '1') then fn:boolean($item//fieldgroup:ISSELECTED[1]) else fn:boolean($item//fieldgroup:ISSELECTED[0])
                       let $isActive := if($item//fieldgroup:ISACTIVE/text() eq '1') then 1 else 0
                       let $_ := (map:put($res-obj,'ID',$item//fieldgroup:ID/text()),
                                  map:put($res-obj,'TopicID',$item//fieldgroup:TOPICID/text()),
                                  map:put($res-obj,'FieldName',$item//fieldgroup:FIELDNAME/text()),
                                  map:put($res-obj,'ColumnName',$item//fieldgroup:COLUMNNAME/text()),
                                  map:put($res-obj,'colName',fn:concat($topicGroupData,'#',$item//fieldgroup:COLUMNNAME/text())),
                                  map:put($res-obj,'IsActive',$isActive),
                                  map:put($res-obj,'TABLENAME',$item//fieldgroup:TABLENAME/text()),
                                  map:put($res-obj,'ISSELECTED',$isSelected)
                                  )
                                  
                       let $_ := json:array-push($res-array,$res-obj)
                       return()                               
                       
                       return $res-array
};

declare function topic:GetTopicAndFields()
{
  let $res-array := json:array()
  let $orderBy := cts:index-order(cts:element-reference(xs:QName('group_lbs:DISPLAYORDER')) ,'ascending')
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/GROUPS_LBS/"),
                       cts:element-value-query(xs:QName('group_lbs:ISACTIVE'),'1')
                       )),$orderBy)
					   
	for $item in $result   
                  return topic:SP_GETTOPICBYGROUPLBS($item//group_lbs:ID/text())
  
};