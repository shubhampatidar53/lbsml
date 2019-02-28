xquery version "1.0-ml";

module namespace watchlist = "http://alm.com/watchlist";

import module namespace config = "http://alm.com/config" at "/common/config.xqy";

declare namespace user_group_type = "http://alm.com/LegalCompass/rd/user_group_type";
declare namespace user_groups = "http://alm.com/LegalCompass/rd/user_groups";
declare namespace users = "http://alm.com/LegalCompass/rd/users";
declare namespace lc-watchlist = "http://alm.com/LegalCompass/rd/LC_WATCHLIST";
declare namespace user_group_companies = "http://alm.com/LegalCompass/rd/user_group_companies";

declare option xdmp:mapping "false";

declare function watchlist:GetWatchlist(
	 $UserEmail
	,$WatchlistType
	,$IsExcludeRankings
)
{
	let $user := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USERS-COLLECTION),
		cts:element-value-query(xs:QName("users:email"),$UserEmail)
	)))[1]
	
	let $user_group_type := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USER_GROUP_TYPE-COLLECTION),
			cts:element-value-query(xs:QName("user_group_type:group_type"),$WatchlistType),
			cts:element-value-query(xs:QName("user_group_type:user_Id"),$user//users:id/text())
	)))
	
	let $user_groups := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USER_GROUPS-COLLECTION),
			cts:element-value-query(xs:QName("user_groups:group_id"),$user_group_type//user_group_type:group_Id/text()),
			cts:element-value-query(xs:QName("user_groups:id"),$user//users:id/text())
		)),
		(
			cts:index-order(cts:element-reference(xs:QName('user_groups:group_name')), "ascending")
		)
	)
	
	let $watchlist-arr := json:array()
	
	let $_ := for $user_group in $user_groups
		let $watchlist-obj := json:object()
		let $_ := (
			map:put($watchlist-obj,"USERWATCHLISTDETAILSID",0),
			map:put($watchlist-obj,"WatchlistID",$user_group//user_groups:group_id/text()),
			map:put($watchlist-obj,"WatchlistName",$user_group//user_groups:group_name/text()),
			map:put($watchlist-obj,"Firms",""),
			map:put($watchlist-obj,"UserID",$user//users:id/text()),
			map:put($watchlist-obj,"UserEmail",$user//users:email/text()),
			map:put($watchlist-obj,"IsDefault", if($user_group//user_groups:flg_default/text() eq "Y") then 1 else 0),
			map:put($watchlist-obj,"WatchlistType", $WatchlistType),
			map:put($watchlist-obj,"IsExcludeRankings", $IsExcludeRankings)
		)
		let $_ := json:array-push($watchlist-arr,$watchlist-obj)
		return ()
		
	let $_ := if ($WatchlistType eq 1 and fn:not($IsExcludeRankings eq "true")) then
		let $arrRankingList := ("Am Law 100","Am Law 200","Global 100","NLJ 500","All Organizations","All Firms and Organizations")
		
		let $lcWatchList := cts:element-values(xs:QName('lc-watchlist:WATCHLIST_NAME'),(),(),cts:collection-query($config:RD-LC_WATCHLIST-COLLECTION))
		
		(: let $lcWatchList := fn:distinct-values(cts:search(/LC_WATCHLIST, cts:collection-query($config:RD-LC_WATCHLIST-COLLECTION), (cts:index-order(cts:element-reference(xs:QName('lc-watchlist:SORTORDER')), "ascending")))/lc-watchlist:WATCHLIST_NAME/text()) :)
		
		let $lcWatchList := fn:distinct-values(for $x in cts:search(/LC_WATCHLIST,cts:collection-query($config:RD-LC_WATCHLIST-COLLECTION))
				let $SORTORDER := $x/lc-watchlist:SORTORDER
				order by $SORTORDER ascending
				return $x/lc-watchlist:WATCHLIST_NAME/text())
		
		let $_ := for $item in ($arrRankingList,$lcWatchList)
			let $index := (fn:index-of(($arrRankingList,$lcWatchList),$item)-1)
			let $watchlist-obj := json:object()
			let $_ := (
				map:put($watchlist-obj,"USERWATCHLISTDETAILSID",0),
				map:put($watchlist-obj,"WatchlistID",fn:sum(10000+$index)),
				map:put($watchlist-obj,"WatchlistName",$item),
				map:put($watchlist-obj,"Firms",""),
				map:put($watchlist-obj,"UserID",0),
				map:put($watchlist-obj,"UserEmail",""),
				map:put($watchlist-obj,"IsDefault", 0),
				map:put($watchlist-obj,"WatchlistType", "3"),
				map:put($watchlist-obj,"IsExcludeRankings", $IsExcludeRankings)
			)
			let $_ := json:array-push($watchlist-arr,$watchlist-obj)
			return ()
		return ()
	else ()

	return $watchlist-arr
};

(:
MySql DB Proc -> sp_GetWatchlistByID
Author: Raveendra Sharma
:)
declare function watchlist:GetWatchListByID(
     $WatchlistID
	 , $UserEmail
)
{
  let $user := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USERS-COLLECTION),
		cts:element-value-query(xs:QName("users:email"),$UserEmail)
	)))
  
	let $user_group_type := cts:search(/,
		cts:and-query((
			cts:directory-query($config:RD-USER_GROUP_TYPE-PATH) ,
			cts:element-value-query(xs:QName("user_group_type:group_Id"),$WatchlistID) ,
			cts:element-value-query(xs:QName("user_group_type:user_Id"),$user//users:id/text()) 
	)))
  
	let $user_groups := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USER_GROUPS-COLLECTION),
			cts:element-value-query(xs:QName("user_groups:group_id"),$WatchlistID),
			cts:element-value-query(xs:QName("user_groups:id"),$user//users:id/text())
		)),
		(
			cts:index-order(cts:element-reference(xs:QName('user_groups:group_name')), "ascending")
		)
	)
	
	let $watchlist-arr := json:array()
	
	let $_ := for $user_group in $user_groups
		let $watchlist-obj := json:object()
		let $_ := (
			map:put($watchlist-obj,"USERWATCHLISTDETAILSID",0),
			map:put($watchlist-obj,"WatchlistID",$user_group//user_groups:group_id/text()),
			map:put($watchlist-obj,"WatchlistName",$user_group//user_groups:group_name/text()),
			map:put($watchlist-obj,"Firms",""),
			map:put($watchlist-obj,"UserID",$user//users:id/text()),
			map:put($watchlist-obj,"UserEmail",$user//users:email/text()),
			map:put($watchlist-obj,"IsDefault", if($user_group//user_groups:flg_default/text() eq "Y") then 1 else 0),
			map:put($watchlist-obj,"WatchlistType", $user_group_type[1]//user_group_type:group_type/text() )
		)
		let $_ := json:array-push($watchlist-arr,$watchlist-obj)
		return ()
			
	return $watchlist-arr[1]
  
};

(:
MySql DB Proc -> sp_GetCompanyDefaultWatchList
Author: Raveendra Sharma
:)
declare function watchlist:GetCompanyDefaultWatchList(
	 $UserEmail
)
{

  let $user := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USERS-COLLECTION),
		cts:element-value-query(xs:QName("users:email"),$UserEmail)
	)))

	let $user_groups := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USER_GROUPS-COLLECTION),
			cts:element-value-query(xs:QName("user_groups:id"),$user//users:id/text()) ,
      cts:element-value-query(xs:QName("user_groups:flg_default"),'Y')
		))
	)

  let $user_group_type := cts:search(/,
		cts:and-query((
			cts:directory-query($config:RD-USER_GROUP_TYPE-PATH) ,
			cts:element-value-query(xs:QName("user_group_type:group_Id"),$user_groups//user_groups:group_id/text()) ,
			cts:element-value-query(xs:QName("user_group_type:user_Id"),$user//users:id/text()) ,
      cts:element-value-query(xs:QName("user_group_type:group_type"), '2') 
	)))
  
  (:
  let $user_group_companies := cts:search(/,
    cts:and-query((
      cts:directory-query($config:RD-USER_GROUP_COMPANIES-PATH),
      cts:element-value-query(xs:QName("user_group_companies:group_Id"), $user_groups//user_groups:group_id/text()),
      cts:element-value-query(xs:QName("user_group_companies:Id"), $user_groups//user_groups:Id/text()),
  )))
  :)
	
	let $watchlist-arr := json:array()
	
	let $_ := for $user_group in $user_groups
		let $watchlist-obj := json:object()
		let $_ := (
			map:put($watchlist-obj,"USERWATCHLISTDETAILSID",0),
			map:put($watchlist-obj,"WatchlistID",$user_group//user_groups:group_id/text()),
			map:put($watchlist-obj,"WatchlistName",$user_group//user_groups:group_name/text()),
			map:put($watchlist-obj,"Firms",""),
			map:put($watchlist-obj,"UserID",$user//users:id/text()),
			map:put($watchlist-obj,"UserEmail",$user//users:email/text()),
			map:put($watchlist-obj,"IsDefault", if($user_group//user_groups:flg_default/text() eq "Y") then 1 else 0),
			map:put($watchlist-obj,"WatchlistType", if(fn:empty($user_group_type//user_group_type:group_type)) then "0" else $user_group_type//user_group_type:group_type/text())
		)
		let $_ := json:array-push($watchlist-arr,$watchlist-obj)
		return ()
	
  return if (fn:empty($user_group_type//user_group_type:group_type)) then
     $watchlist-arr[1]
  else
	 $watchlist-arr[1]
};

(:
MySql DB Proc -> sp_UpdateWatchlistName
Author: Raveendra Sharma
:)
declare function watchlist:UpdateWatchlistName($WatchlistID, $WatchlistEmailId, $WatchlistName)
{
  
  let $user := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USERS-COLLECTION),
		cts:element-value-query(xs:QName("users:email"),$WatchlistEmailId)
	)))
  
  let $user_groups := cts:search(/,
	cts:and-query((
		cts:collection-query($config:RD-USER_GROUPS-COLLECTION) ,
		cts:element-value-query(xs:QName("user_groups:id"),$user//users:id/text()) ,
    cts:element-value-query(xs:QName("user_groups:group_id"),$WatchlistID) 
		)))
 
  
   
	return if (fn:empty($user_groups)) then
		()
    else
       let $uri := xdmp:node-uri($user_groups[1])
       let $newValueNode := element { fn:QName("http://alm.com/LegalCompass/rd/user_groups", "group_name") } {xs:string($WatchlistName)}
	   return xdmp:node-replace(fn:doc($uri)/user_groups:user_groups/user_groups:group_name, $newValueNode)
	   (:return fn:doc($uri)/user_groups:user_groups/user_groups:group_name:)
   
};
(:
 local:UpdateWatchlistName("7", "atiwari@alm.com", "Canadian New Firms 4")
:)

(:
MySql DB Proc -> sp_SetDefaultWatchList
Author: Raveendra Sharma
:)
declare function watchlist:SetDefaultWatchList(
	 $UserEmail
   ,$WatchlistID
   ,$flgDefault
   ,$WatchlistType
)
{

  let $flgDefault := if ($flgDefault eq '0') then
		'N'
  else
		'Y' 

  let $user := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USERS-COLLECTION),
		cts:element-value-query(xs:QName("users:email"),$UserEmail)
	)))

  let $user_group_type := cts:search(/,
		cts:and-query((
			cts:directory-query($config:RD-USER_GROUP_TYPE-PATH) ,
			cts:element-value-query(xs:QName("user_group_type:user_Id"),$user//users:id/text()) ,
      cts:element-value-query(xs:QName("user_group_type:group_type"), $WatchlistType) 
	)))
  
	let $user_groups := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USER_GROUPS-COLLECTION),
			cts:element-value-query(xs:QName("user_groups:id"),$user//users:id/text())  , 
 			cts:element-value-query(xs:QName("user_groups:group_id"), $user_group_type//user_group_type:group_Id/text())  , 
      cts:element-value-query(xs:QName("user_groups:flg_default"),"Y") 
		))
	)
  
  let $_ := if ($flgDefault eq "Y") then
      for $user_group in  $user_groups 
      let $uri := xdmp:node-uri($user_group)
      let $newValueNode := element { fn:QName("http://alm.com/LegalCompass/rd/user_groups", "flg_default") } {xs:string("N")}
      return xdmp:node-replace(fn:doc($uri)/user_groups/user_groups:flg_default, $newValueNode)
  else
     ()
 
 let $user_group_setDefault := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USER_GROUPS-COLLECTION),
			cts:element-value-query(xs:QName("user_groups:id"),$user//users:id/text()), 
 			cts:element-value-query(xs:QName("user_groups:group_id"), $WatchlistID ) 
		))
	)[1]
  
  let $_ := if (fn:not(fn:empty($user_group_setDefault))) then
      let $uri := xdmp:node-uri($user_group_setDefault)
      let $newValueNode := element { fn:QName("http://alm.com/LegalCompass/rd/user_groups", "flg_default") } {xs:string($flgDefault)}
      return xdmp:node-replace(fn:doc($uri)/user_groups/user_groups:flg_default, $newValueNode)
  else
   ()
   
 return $user_group_setDefault 
};
(:
local:SetDefaultWatchList('atiwari@alm.com','22', 'N', '1')
:)

(:
MySql DB Proc -> sp_SetDefaultWatchList
Author: Raveendra Sharma
:)
declare function watchlist:RemovefromWatchlist($watchlistID, $UserEmail, $CompanyId)
{

 let $user := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USERS-COLLECTION),
		cts:element-value-query(xs:QName("users:email"),$UserEmail)
	)))
	
  let $user_group_companies := cts:search(/,
    cts:and-query((
      cts:directory-query($config:RD-USER_GROUP_COMPANIES-PATH) ,
      cts:element-value-query(xs:QName("user_group_companies:group_id"), $watchlistID) ,
      cts:element-value-query(xs:QName("user_group_companies:id"), $user//users:id/text()) ,
      cts:element-value-query(xs:QName("user_group_companies:company_id"), $CompanyId) 
  )))
  
  return if (fn:empty($user_group_companies)) then
    ()
    else
      let $uri := xdmp:node-uri($user_group_companies[1])
      return xdmp:document-delete($uri)
};
(:
local:RemovefromWatchlist('atiwari@alm.com','22', 'N', '1')
:)

(:
MySql DB Proc -> DeleteWatchlist
Author: Raveendra Sharma
:)
declare function watchlist:DeleteWatchlist($WatchlistID, $UserEmail)
{
  
  let $user := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USERS-COLLECTION),
		cts:element-value-query(xs:QName("users:email"),$UserEmail)
	)))
	
  let $user_groups := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USER_GROUPS-COLLECTION),
			cts:element-value-query(xs:QName("user_groups:id"),$user//users:id/text()), 
 			cts:element-value-query(xs:QName("user_groups:group_id"), $WatchlistID) 
		)))
 
 let $user_group_types := cts:search(/,
		cts:and-query((
			cts:directory-query($config:RD-USER_GROUP_TYPE-PATH)  ,
			cts:element-value-query(xs:QName("user_group_type:user_Id"),$user//users:id/text())  ,
      cts:element-value-query(xs:QName("user_group_type:group_Id"), $WatchlistID) 
	)))
 
  let $user_group_companies := cts:search(/,
    cts:and-query((
      cts:directory-query($config:RD-USER_GROUP_COMPANIES-PATH) ,
      cts:element-value-query(xs:QName("user_group_companies:group_id"), $WatchlistID) ,
      cts:element-value-query(xs:QName("user_group_companies:id"), $user//users:id/text()) 
  )))
  
  let $_ := for $user_group in  $user_groups 
            let $uri := xdmp:node-uri($user_group)
            return xdmp:document-delete($uri)

  let $_ := for $user_group_type in  $user_group_types 
            let $uri := xdmp:node-uri($user_group_type)
            return xdmp:document-delete($uri)

  let $_ := for $user_group_company in  $user_group_companies 
            let $uri := xdmp:node-uri($user_group_company)
            return xdmp:document-delete($uri)

  return ()  
 
};

declare function watchlist:GetUserByEmail($UserEmail)
{
	let $user := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USERS-COLLECTION),
		cts:element-value-query(xs:QName("users:email"),$UserEmail)
	)))
	
	return $user
};

declare function watchlist:AddtoWatchlist($list)
{

	(:let $list := "<List><request><GroupID>19</GroupID><UserEmail>atiwari@alm.com</UserEmail><DateAdded>2018-01-15T14:32:28.5332322+05:30</DateAdded><CompanyID>7</CompanyID></request><request><GroupID>19</GroupID><UserEmail>atiwari@alm.com</UserEmail><DateAdded>2018-01-15T14:32:28.5332322+05:30</DateAdded><CompanyID>12</CompanyID></request><request><GroupID>19</GroupID><UserEmail>atiwari@alm.com</UserEmail><DateAdded>2018-01-15T14:32:28.5332322+05:30</DateAdded><CompanyID>47</CompanyID></request><request><GroupID>19</GroupID><UserEmail>atiwari@alm.com</UserEmail><DateAdded>2018-01-15T14:32:28.5332322+05:30</DateAdded><CompanyID>95</CompanyID></request><request><GroupID>19</GroupID><UserEmail>atiwari@alm.com</UserEmail><DateAdded>2018-01-15T14:32:28.5332322+05:30</DateAdded><CompanyID>173</CompanyID></request></List>":)
	(:let $list := xdmp:unquote($list):)

	let $userGroupCompanies_baseDocUri := '/LegalCompass/relational-data/user_group_companies/'
	let $userGroupCompanies_NS := 'http://alm.com/LegalCompass/rd/user_group_companies'
	
	let $eachRequest_ := for $request in $list/request
	
		let $userMail := $request/UserEmail/text()
		let $userId := watchlist:GetUserByEmail($userMail)//users:id/text()
		let $groupId := $request/GroupID/text()
		let $companyID := $request/CompanyID/text()
		let $dateAdded := $request/DateAdded/text()
	
		let $user_group_companies := cts:search(/,
			cts:and-query((
			cts:directory-query($config:RD-USER_GROUP_COMPANIES-PATH) ,
			cts:element-value-query(xs:QName("user_group_companies:group_id"), $groupId) ,
			cts:element-value-query(xs:QName("user_group_companies:id"), $userId),
			cts:element-value-query(xs:QName("user_group_companies:company_id"), $companyID)
			)))
		
		let $exists_ := if ($user_group_companies) then
				  ()
		else
			let $uri := fn:concat($userGroupCompanies_baseDocUri
											, xs:string($userId)
											, '_' , xs:string($groupId)
											, '_', xs:string($companyID)
											, '.xml')
			let $userGroupCompanies := (element{ fn:QName($userGroupCompanies_NS, "user_group_companies")}
									{element { fn:QName($userGroupCompanies_NS, "id")}	{ xs:string($userId)}
										, element { fn:QName($userGroupCompanies_NS, "group_id")}	{ xs:string($groupId)}
										, element { fn:QName($userGroupCompanies_NS, "company_id")}	{ xs:string($companyID)}
										, element { fn:QName($userGroupCompanies_NS, "date_added")}	{ xs:string($dateAdded)}})
			
			let $insert_result :=  xdmp:document-insert($uri, $userGroupCompanies, xdmp:default-permissions())
			let $insert_result :=  xdmp:document-set-collections($uri, $config:RD-USER_GROUP_COMPANIES-COLLECTION)
          
			return ($userGroupCompanies)
      
		return $exists_

	return $eachRequest_	
};

(:
Description: Insert new watchlist into the database.
Author: Raveendra Sharma
:)
declare function watchlist:SaveWatchList(
    $groupId
   ,$userGroupTypeId
   ,$userEmail
   ,$watchlistName
   ,$watchlistType
)
{
   (:
   let $userEmail := 'atiwari@alm.com'
   let $watchlistName := 'abc123'
   let $watchlistType := '4'
   :)
   
   let $userGroup_NS := "http://alm.com/LegalCompass/rd/user_groups"
   let $userGroupType_NS := "http://alm.com/LegalCompass/rd/user_group_type"
   let $userGroups_baseDocUri := "/LegalCompass/relational-data/user_groups/"
   let $userGroupType_baseDocUri := '/LegalCompass/relational-data/user_group_type/'
    
	(:
    let $user := cts:search(/,
		cts:and-query((
			cts:collection-query($config:RD-USERS-COLLECTION),
		cts:element-value-query(xs:QName("users:email"),$userEmail)
	)))
	
	let $userId := $user//users:id
	:)
	
	let $userId := watchlist:GetUserByEmail($userEmail)//users:id/text()
   
	let $dateAdded := fn:current-dateTime()
	let $defaultFlag := 'N'
  
	let $user_groups := cts:search(/,
			cts:and-query((cts:collection-query($config:RD-USER_GROUPS-COLLECTION),
			cts:element-value-query(xs:QName("user_groups:id"),$userId))))
	
	let $newGroupId := if (fn:empty($user_groups)) then
		1
	else
		max($user_groups//user_groups:group_id) + 1
    
	(: if given groupId is not empty and non zero then use it instead generating new one. :)
	let $groupId := if ($groupId eq "") then
		"0"
	else
		$groupId

		
	let $newGroupId := if ($groupId eq "0") then
		xs:string($newGroupId)
	else
		xs:string($groupId)
 
	(: START: Adding new user group :)
   
	let $newGroupUri := fn:concat($userGroups_baseDocUri, xs:string($userId), '_' , xs:string($newGroupId), '.xml')
      
	let $newUserGroup := (element{ fn:QName($userGroup_NS, "user_groups")}
									{element { fn:QName($userGroup_NS, "id")}	{ xs:string($userId)}
										, element { fn:QName($userGroup_NS, "group_id")}	{ xs:string($newGroupId)}
										, element { fn:QName($userGroup_NS, "group_name")}	{ xs:string($watchlistName)}
										, element { fn:QName($userGroup_NS, "date_added")}	{ xs:string($dateAdded)}
                    , element { fn:QName($userGroup_NS, "flg_default")}	{ xs:string($defaultFlag)}})

	let $_ :=  xdmp:document-insert($newGroupUri, $newUserGroup, xdmp:default-permissions()) 
	let $_ :=  xdmp:document-set-collections($newGroupUri, $config:RD-USER_GROUPS-COLLECTION)
  
	(:END: Adding new user group :)
   
	(: START: Adding new user group type :)
   
	let $user_group_types := cts:search(/,cts:collection-query($config:RD-USER_GROUP_TYPE-COLLECTION))
	
	let $newUserGroupTypeId := if (fn:empty($user_group_types)) then
      1
	else
      (max($user_group_types//user_group_type:Id)) + 1
  
	
	(: if given groupId is not empty and non zero then use it instead generating new one. :)
	let $userGroupTypeId := if (($userGroupTypeId eq "") or ($userGroupTypeId eq "-1")) then
		"0"
	else
		$userGroupTypeId
		
	let $newUserGroupTypeId := if ($userGroupTypeId eq "0") then
		xs:string($newUserGroupTypeId)
	else
		xs:string($userGroupTypeId)
	
  
  
	let $newUserGroupTypeUri := fn:concat($userGroupType_baseDocUri, xs:string($newUserGroupTypeId), '.xml')
                      
	let $newUserGroupType := (element{ fn:QName($userGroupType_NS, "user_group_type")}
									   {element { fn:QName($userGroupType_NS, "Id")}	{ xs:string($newUserGroupTypeId)}
										, element { fn:QName($userGroupType_NS, "group_Id")}	{ xs:string($newGroupId)}
										, element { fn:QName($userGroupType_NS, "group_type")}	{ xs:string($watchlistType)}
										, element { fn:QName($userGroupType_NS, "user_Id")}	{ xs:string($userId)}})
   
	let $insertResult_ :=  xdmp:document-insert($newUserGroupTypeUri, $newUserGroupType, xdmp:default-permissions()) 
	let $insertResult_ :=  xdmp:document-set-collections($newUserGroupTypeUri, $config:RD-USER_GROUP_TYPE-COLLECTION)
    
	return $newGroupId
};