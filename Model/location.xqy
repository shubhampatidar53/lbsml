xquery version '1.0-ml';

module namespace location = 'http://alm.com/location';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';

declare namespace org-branch = 'http://alm.com/LegalCompass/rd/organization-branch';

declare option xdmp:mapping 'false';

declare function location:GetLocations()
{
	let $USRegions := cts:element-values(xs:QName('org-branch:US_REGIONS'),(),(),
		cts:and-query((
			cts:collection-query($config:RD-ORGANIZATION_BRANCH-COLLECTION),
			cts:not-query(cts:element-value-query(xs:QName('org-branch:US_REGIONS'),''))
			,cts:element-value-query(xs:QName('org-branch:FISCAL_YEAR'),'2018')
		)))
  
	let $states := cts:element-values(xs:QName('org-branch:STATE'),(),(),
	cts:and-query((
		cts:collection-query($config:RD-ORGANIZATION_BRANCH-COLLECTION),
			cts:element-value-query(xs:QName('org-branch:COUNTRY'),'USA'),
			cts:not-query(cts:element-value-query(xs:QName('org-branch:STATE'),''))
			,cts:element-value-query(xs:QName('org-branch:FISCAL_YEAR'),'2018')
		)))
  
	let $location-arr := json:array()
	
	let $us-location-arr := json:array()
	let $us-location-obj := json:object()
	let $_ := (
		map:put($us-location-obj, 'title', 'United States'),
		map:put($us-location-obj, 'isFolder', 'false'),
		map:put($us-location-obj, 'isLazy', 'false'),
		map:put($us-location-obj, 'key', ''),
		map:put($us-location-obj, 'dataKey', 'United States'),
		map:put($us-location-obj, 'cssClass', 'dynageoregion'),
		map:put($us-location-obj, 'nodeCategoryName', 'georegion')
	)
	
	(: ---------------------- US Region ---------------------- :)
	let $child-location-obj := json:object()
	let $_ := (
	  map:put($child-location-obj, 'title','US Regions'),
	  map:put($child-location-obj, 'isFolder', 'false'),
	  map:put($child-location-obj, 'isLazy', 'false'),
	  map:put($child-location-obj, 'key', ''),
	  map:put($child-location-obj, 'dataKey','US Regions'),
	  map:put($child-location-obj, 'cssClass', 'dynausregion'),
	  map:put($child-location-obj, 'nodeCategoryName', 'usregion')
	)

	let $child-location-arr := json:array()
	let $_ := for $USRegion in $USRegions
	  let $location-obj := json:object()
	  let $_ := (
		map:put($location-obj, 'title', $USRegion),
		map:put($location-obj, 'isFolder', 'false'),
		map:put($location-obj, 'isLazy', 'false'),
		map:put($location-obj, 'key', ''),
		map:put($location-obj, 'dataKey', fn:concat($USRegion,',US Regions')),
		map:put($location-obj, 'cssClass', 'dynausregion'),
		map:put($location-obj, 'nodeCategoryName', 'usregion'),
		map:put($location-obj, 'children','')
	  )
	  let $_ := json:array-push($child-location-arr,$location-obj)
	  return ()
	let $_ := map:put($child-location-obj, 'children', $child-location-arr)
	let $_ := json:array-push($us-location-arr, $child-location-obj)
	(: ---------------------- US Region ---------------------- :)
	
	(: ---------------------- US City/State ---------------------- :)
	let $child-location-obj := json:object()
	let $_ := (
	  map:put($child-location-obj, 'title','US States/Cities'),
	  map:put($child-location-obj, 'isFolder', 'false'),
	  map:put($child-location-obj, 'isLazy', 'false'),
	  map:put($child-location-obj, 'key', ''),
	  map:put($child-location-obj, 'dataKey','US States/Cities'),
	  map:put($child-location-obj, 'cssClass', 'dynausregion'),
	  map:put($child-location-obj, 'nodeCategoryName', 'usregion')
	)

	let $child-location-arr := json:array()
	let $_ := for $state in $states
	  let $location-obj := json:object()
	  let $_ := (
		map:put($location-obj, 'title', $state),
		map:put($location-obj, 'isFolder', 'false'),
		map:put($location-obj, 'isLazy', 'false'),
		map:put($location-obj, 'key', ''),
		map:put($location-obj, 'dataKey', fn:concat($state,',US States/Cities')),
		map:put($location-obj, 'cssClass', 'dynastate'),
		map:put($location-obj, 'nodeCategoryName', 'state')
	  )
	  
	  let $cities := cts:element-values(xs:QName('org-branch:CITY'),(),(),
		cts:and-query((
		  cts:collection-query($config:RD-ORGANIZATION_BRANCH-COLLECTION),
		  cts:element-value-query(xs:QName('org-branch:COUNTRY'),'USA'),
		  cts:element-value-query(xs:QName('org-branch:STATE'),$state),
		  cts:not-query(cts:element-value-query(xs:QName('org-branch:CITY'),''))
			,cts:element-value-query(xs:QName('org-branch:FISCAL_YEAR'),'2018')
		)))
	  
	  let $grand-child-location-arr := json:array()
	  let $_ := for $city in $cities
		let $temp-location-obj := json:object()
		let $_ := (
		  map:put($temp-location-obj, 'title', $city),
		  map:put($temp-location-obj, 'isFolder', 'false'),
		  map:put($temp-location-obj, 'isLazy', 'false'),
		  map:put($temp-location-obj, 'key', ''),
		  map:put($temp-location-obj, 'dataKey', fn:concat($city,'|',$state)),
		  map:put($temp-location-obj, 'cssClass', 'dynauscity'),
		  map:put($temp-location-obj, 'nodeCategoryName', 'city'),
		  map:put($temp-location-obj, 'children','')
		)
		let $_ := json:array-push($grand-child-location-arr,$temp-location-obj)
		return ()
	  
	  let $_ := map:put($location-obj, 'children',$grand-child-location-arr)
	  
	  let $_ := json:array-push($child-location-arr,$location-obj)
	  return ()

	let $_ := map:put($child-location-obj, 'children', $child-location-arr)
	let $_ := json:array-push($us-location-arr, $child-location-obj)
	(: ---------------------- US City/State ---------------------- :)

	let $_ := map:put($us-location-obj, 'children', $us-location-arr)
	let $_ := json:array-push($location-arr, $us-location-obj)


	(: ---------------------- Processing Non-US Location Data ---------------------- :)
	let $GeographicRegions := cts:element-values(xs:QName('org-branch:GEOGRAPHIC_REGION'),(),(),
	  cts:and-query((
		cts:collection-query($config:RD-ORGANIZATION_BRANCH-COLLECTION),
		cts:not-query(cts:element-value-query(xs:QName('org-branch:GEOGRAPHIC_REGION'),'')),
		cts:not-query(cts:element-value-query(xs:QName('org-branch:GEOGRAPHIC_REGION'),'United States'))
		,cts:element-value-query(xs:QName('org-branch:FISCAL_YEAR'),'2018')
	  )))

	let $_ := for $GeoRegions in $GeographicRegions
	  let $location-obj := json:object()
	  let $_ := (
		map:put($location-obj, 'title', $GeoRegions),
		map:put($location-obj, 'isFolder', 'false'),
		map:put($location-obj, 'isLazy', 'false'),
		map:put($location-obj, 'key', ''),
		map:put($location-obj, 'dataKey', $GeoRegions),
		map:put($location-obj, 'cssClass', 'dynageoregion'),
		map:put($location-obj, 'nodeCategoryName', 'georegion')
	  )
	  
	  let $countries := cts:element-values(xs:QName('org-branch:COUNTRY'),(),(),
		cts:and-query((
		  cts:collection-query($config:RD-ORGANIZATION_BRANCH-COLLECTION),
		  cts:not-query(cts:element-value-query(xs:QName('org-branch:COUNTRY'),'')),
		  cts:element-value-query(xs:QName('org-branch:GEOGRAPHIC_REGION'),$GeoRegions)
			,cts:element-value-query(xs:QName('org-branch:FISCAL_YEAR'),'2018')
		)))
	  
	  let $child-location-arr := json:array()
	  let $_ := for $country in $countries
		let $child-location-obj := json:object() 
		let $_ := (
		  map:put($child-location-obj, 'title', $country),
		  map:put($child-location-obj, 'isFolder', 'false'),
		  map:put($child-location-obj, 'isLazy', 'false'),
		  map:put($child-location-obj, 'key', ''),
		  map:put($child-location-obj, 'dataKey', $country),
		  map:put($child-location-obj, 'cssClass', 'dynacountry'),
		  map:put($child-location-obj, 'nodeCategoryName', 'country')
		)
		
		let $cities := cts:element-values(xs:QName('org-branch:CITY'),(),(),
		  cts:and-query((
			cts:collection-query($config:RD-ORGANIZATION_BRANCH-COLLECTION),
			cts:not-query(cts:element-value-query(xs:QName('org-branch:City'),'')),
			cts:element-value-query(xs:QName('org-branch:GEOGRAPHIC_REGION'),$GeoRegions),
			cts:element-value-query(xs:QName('org-branch:COUNTRY'),$country)
			,cts:element-value-query(xs:QName('org-branch:FISCAL_YEAR'),'2018')
		  )))
		
		let $grand-child-location-arr := json:array()
		let $_ := for $city in $cities
		  let $grand-child-location-obj := json:object()
		  let $_ := (
			map:put($grand-child-location-obj, 'title', $city),
			map:put($grand-child-location-obj, 'isFolder', 'false'),
			map:put($grand-child-location-obj, 'isLazy', 'false'),
			map:put($grand-child-location-obj, 'key', ''),
			map:put($grand-child-location-obj, 'dataKey', fn:concat($city,',',$country)),
			map:put($grand-child-location-obj, 'cssClass', 'dynacity'),
			map:put($grand-child-location-obj, 'nodeCategoryName', 'city'),
			map:put($grand-child-location-obj, 'children','')
		  )
		  let $_ := json:array-push($grand-child-location-arr, $grand-child-location-obj)
		  return ()
		
		let $_ := map:put($child-location-obj, 'children', $grand-child-location-arr)  
		let $_ := json:array-push($child-location-arr, $child-location-obj)
		return ()
	  
	  let $_ := map:put($location-obj, 'children', $child-location-arr)
	  let $_ := json:array-push($location-arr, $location-obj)
	  return ()
	(: ---------------------- Processing Non-US Location Data ---------------------- :)

	
	return $location-arr
};