xquery version "1.0-ml";

module namespace practice-area = "http://alm.com/practice-area";

import module namespace config = "http://alm.com/config" at "/common/config.xqy";

declare namespace rep-type = "http://alm.com/LegalCompass/rd/REPRESENTATION_TYPES";

declare option xdmp:mapping "false";

declare function GetPracticeAreas()
{
	let $Level1Values := cts:element-values(xs:QName("rep-type:LEVEL_1"),(),(),cts:collection-query($config:RD-REPRESENTATION_TYPES-COLLECTION))
	let $response-arr := json:array()
	
	let $_ := for $Level1 in $Level1Values
		let $practice-area-arr := json:object()
		
		let $_ := (
			map:put($practice-area-arr, "title", $Level1),
			map:put($practice-area-arr, "isFolder", "false"),
			map:put($practice-area-arr, "isLazy", "false"),
			map:put($practice-area-arr, "key", ""),
			map:put($practice-area-arr, "dataKey", ""),
			map:put($practice-area-arr, "cssClass", ""),
			map:put($practice-area-arr, "nodeCategoryName", "")
		)
		
		let $Level2Values := cts:element-values(xs:QName("rep-type:LEVEL_2"),(),(),
			cts:and-query((
				cts:collection-query($config:RD-REPRESENTATION_TYPES-COLLECTION),
				cts:element-value-query(xs:QName("rep-type:LEVEL_1"),$Level1),
				cts:not-query(cts:element-value-query(xs:QName("rep-type:LEVEL_2"),''))
			))
		)
		
		let $level-arr := json:array()
		let $_ := for $Level2 in $Level2Values
			let $record-arr := json:object()
			let $_ := (
				map:put($record-arr, "title", $Level2),
				map:put($record-arr, "isFolder", "false"),
				map:put($record-arr, "isLazy", "false"),
				map:put($record-arr, "key", ""),
				map:put($record-arr, "dataKey", fn:concat($Level2,",",$Level1)),
				map:put($record-arr, "cssClass", ""),
				map:put($record-arr, "nodeCategoryName", "")
			)
			let $_ := json:array-push($level-arr, $record-arr)
			return ()
		
		let $_ := map:put($practice-area-arr, "children", $level-arr)
		let $_ := json:array-push($response-arr, $practice-area-arr)
		return ()
	return $response-arr
};