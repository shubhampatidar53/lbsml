xquery version '1.0-ml';

module namespace survey-listing-ctlr = 'http://alm.com/controller/survey-listing';

import module namespace survey-listing = 'http://alm.com/survey-listing' at '/common/model/survey-listing.xqy';

declare namespace util = 'http://alm.com/util';

declare option xdmp:mapping 'false';

declare function survey-listing-ctlr:GetSurveyOrganizations($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $TableName := $request/TableName/text()
	let $type := if ($request/type/text() != '') then $request/type/text() else 'JSON'
	
	return survey-listing:GetSurveyOrganizations(
		 $TableName
		,$type
	)
	
	(: survey-listing:GetSurveyOrganizations(
		 survey-listing-ctlr:required($params/util:tableName, 'tableName')
		,'JSON'
	) :)
};


declare function survey-listing-ctlr:GetReID($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $aliID := $request/AliID/text()
	return survey-listing:GetReID($aliID)
	
	(: survey-listing:GetSurveyOrganizations(
		 survey-listing-ctlr:required($params/util:tableName, 'tableName')
		,'JSON'
	) :)
};

declare function survey-listing-ctlr:required($value as item()*, $parameter as xs:string) as item()*
{
    if (fn:exists($value)) then
        $value
    else
        fn:error(xs:QName('MISSINGPARAM'), fn:concat('Required param '', $parameter, '' is missing'))
};

declare function survey-listing-ctlr:GetSurveyList($params as element(util:params))
{
	let $ids := $params/util:ids/text()
	let $years := $params/util:years/text()
	let $clause := $params/util:clause/text()
	(: return survey-listing:GetSurveyList($ids) :)
	return survey-listing:GetSurveyList($ids,$years,$clause)
};