xquery version "1.0-ml";

module namespace datadump-ctlr = "http://alm.com/controller/DataDumpUtility";

 import module namespace datadump = "http://alm.com/datadump" at "/common/model/datadump.xqy"; 

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function datadump-ctlr:DeleteDocuments($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
    let $directoryPath := $request/DirectoryPath/text()
	let $QName := $request/QName/text()
	let $IDs := $request/ID/text()
	
	return datadump:DeleteDocuments($directoryPath,$QName,$IDs)
	
};

declare function datadump-ctlr:InserPacerData($params as element(util:params))
{
	let $request := xdmp:get-request-body()
	return datadump:InserPacerData($request)
};

declare function datadump-ctlr:AddFirmID($params as element(util:params))
{
	let $scopeID := $params/util:scopeID/text()
	 
	return datadump:AddFirmID($scopeID)
};

declare function datadump-ctlr:AddALIIdForClients($params as element(util:params))
{
	let $firmID := $params/util:firmID/text()
	 
	return datadump:AddALIIdForClients($firmID)
};

declare function datadump-ctlr:GetClientData($params as element(util:params))
{
	let $from := $params/util:from/text()
	let $to := $params/util:to/text()
	 
	return datadump:GetClientData($from,$to)
};
