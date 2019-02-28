xquery version "1.0-ml";

module namespace firm-comp-ctlr = "http://alm.com/controller/firm-comparison";

import module namespace firm-comp = "http://alm.com/firm-comparison" at "/common/model/firm-comparison.xqy";

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function firm-comp-ctlr:GetFirmRankings($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $PageNo := $request/PageNo/text()
	let $PageSize := $request/PageSize/text()
	let $FromYear := $request/FromYear/text()
	let $ToYear := $request/ToYear/text()
	let $FirmSearchKeys := $request/FirmSearchKeys/text()
	let $FirmLocation := $request/FirmLocation
	let $SortDirection := $request/SortDirection/text()
	let $SortBy := $request/SortBy/text()
	let $FirmSize1 := $request/FirmSize/text()
	let $FirmSize := if(fn:contains($FirmSize1,'All Firm Sizes') or fn:contains($FirmSize1,'Any')) then () else $FirmSize1
	
	let $PracticeAreas := $request/PracticeAreas/text()
	let $ALMRankingListName := $request/ALMRankingListName/text()
	
	return firm-comp:GetFirmRankings(
		$PageNo,
		$PageSize,
		$FromYear,
		$ToYear,
		$FirmSearchKeys,
		$FirmLocation,
		$SortDirection,
		$SortBy,
		$FirmSize,
		$PracticeAreas,
		$ALMRankingListName
	)
};

declare function firm-comp-ctlr:required($value as item()*, $parameter as xs:string) as item()*
{
    if (fn:exists($value)) then
        $value
    else
        fn:error(xs:QName("MISSINGPARAM"), fn:concat("Required param '", $parameter, "' is missing"))
};

declare function firm-comp-ctlr:SP_GETLAWFIRMREVENUEANDPROFIT($params as element(util:params))
{
   firm-comp:SP_GETLAWFIRMREVENUEANDPROFIT($params/util:firmID,$params/util:pYears)
};

declare function firm-comp-ctlr:GetLawFirmRankings($params as element(util:params))
{
    firm-comp:GetLawFirmRankings($params/util:firmID,$params/util:pYears)
};

declare function firm-comp-ctlr:SP_GETLAWFIRMDIVERSITY($params as element(util:params))
{
    firm-comp:SP_GETLAWFIRMDIVERSITY($params/util:firmID,$params/util:pYears)
};

declare function firm-comp-ctlr:SP_GETLAWFIRMSIZE($params as element(util:params))
{
    firm-comp:SP_GETLAWFIRMSIZE($params/util:firmID,$params/util:pYears)
};

declare function firm-comp-ctlr:SP_GETLAWFIRMASSOCIATENATL($params as element(util:params))
{
    firm-comp:SP_GETLAWFIRMASSOCIATENATL($params/util:firmID,$params/util:pYears)
};

declare function firm-comp-ctlr:SP_GETLAWFIRMASSOCIATEBILLING($params as element(util:params))
{
    firm-comp:SP_GETLAWFIRMASSOCIATEBILLING($params/util:firmID,$params/util:pYears)
};

declare function firm-comp-ctlr:SP_GETLAWFIRMALIST($params as element(util:params))
{
    firm-comp:SP_GETLAWFIRMALIST($params/util:firmID,$params/util:pYears)
};

declare function firm-comp-ctlr:SP_GETLAWFIRMTECHRANKING($params as element(util:params))
{
    firm-comp:SP_GETLAWFIRMTECHRANKING($params/util:firmID,$params/util:pYears)
};

declare function firm-comp-ctlr:SP_GETLAWFIRMPROBONO($params as element(util:params))
{
    firm-comp:SP_GETLAWFIRMPROBONO($params/util:firmID/text(),$params/util:pYears/text())
};

declare function firm-comp-ctlr:SP_GETLAWFIRMBILLING($params as element(util:params))
{
    firm-comp:SP_GETLAWFIRMBILLING($params/util:firmID,$params/util:pYears)
};

(: declare function firm-comp-ctlr:GetFirmRankings1($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $PageNo := $request/PageNo/text()
	let $PageSize := $request/PageSize/text()
	let $FromYear := $request/FromYear/text()
	let $ToYear := $request/ToYear/text()
	let $FirmSearchKeys := $request/FirmSearchKeys/text()
	let $FirmLocation := $request/FirmLocation
	let $SortDirection := $request/SortDirection/text()
	let $SortBy := $request/SortBy/text()
	let $FirmSize := $request/FirmSize/text()
	let $PracticeAreas := $request/PracticeAreas/text()
	let $ALMRankingListName := $request/ALMRankingListName/text()
	
	return firm-comp:GetFirmRankings1(
		$PageNo,
		$PageSize,
		$FromYear,
		$ToYear,
		$FirmSearchKeys,
		$FirmLocation,
		$SortDirection,
		$SortBy,
		$FirmSize,
		$PracticeAreas,
		$ALMRankingListName
	)
}; :)

declare function firm-comp-ctlr:GetFirmRankingsAdvanceSearch($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $PageNo := $request/PageNo/text()
	let $PageSize := $request/PageSize/text()
	let $FromYear := $request/FromYear/text()
	let $ToYear := $request/ToYear/text()
	let $FirmSearchKeys := $request/FirmSearchKeys/text()
	let $FirmLocation := $request/FirmLocation
	let $IsHeadquarter := $request/isHeadquarter/text()	
	let $SortDirection := $request/SortDirection/text()
	let $SortBy := $request/SortBy/text()
	let $FirmSize := $request/FirmSize/text()
	let $PracticeAreas := $request/PracticeAreas/text()
	let $ALMRankingListName := $request/ALMRankingListName/text()
	let $MLQuery := fn:replace($request/MLQuery/text(),"ALI_RE_Attorney_Combined","organization_advancesearch")
	let $MLQuery := fn:replace($MLQuery,"&amp;","&amp;amp;")
	let $RegionMLQuery := $request/RegionMLQuery/text()
	let $USRegionMLQuery := $request/USRegionMLQuery/text()
	let $CountryMLQuery := $request/CountryMLQuery/text()
	let $StateMLQuery := $request/StateMLQuery/text()
	let $MetroAreaMLQuery := $request/MetroAreaMLQuery/text()
	let $CityMLQuery := $request/CityMLQuery/text()	
	let $PracticeAreaMLQuery := $request/PracticeAreaMLQuery/text()	
	let $ISVEREINSMLQuery := $request/ISVEREINSMLQuery/text()	
	let $SurveyParticipationMLQuery := $request/SurveyParticipationMLQuery/text()
	let $MansfieldMLQuery := $request/MansfieldMLQuery/text()
	let $NoOfOfficesMLQuery := fn:replace($request/NoOfOfficesMLQuery/text(),"ALI_RE_Attorney_Combined","organization_advancesearch")
	let $YearMLQuery := $request/YearMLQuery/text()

	return firm-comp:GetFirmRankingsAdvanceSearch(
		$PageNo,
		$PageSize,
		$FromYear,
		$ToYear,
		$FirmSearchKeys,
		$FirmLocation,
		$IsHeadquarter,
		$SortDirection,
		$SortBy,
		$FirmSize,
		$PracticeAreas,
		$ALMRankingListName,
		$MLQuery,
		$RegionMLQuery,
		$USRegionMLQuery,
		$CountryMLQuery,
		$StateMLQuery,
		$MetroAreaMLQuery,
		$CityMLQuery,
		$PracticeAreaMLQuery,
		$ISVEREINSMLQuery,
		$SurveyParticipationMLQuery,
		$NoOfOfficesMLQuery,
		$MansfieldMLQuery,
		$YearMLQuery
	)
};

declare function firm-comp-ctlr:GetFirmRankings1($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $PageNo := $request/PageNo/text()
	let $PageSize := $request/PageSize/text()
	let $FromYear := $request/FromYear/text()
	let $ToYear := $request/ToYear/text()
	let $FirmSearchKeys := $request/FirmSearchKeys/text()
	let $FirmLocation := $request/FirmLocation
	let $IsHeadquarter := $request/isHeadquarter/text()	
	let $SortDirection := $request/SortDirection/text()
	let $SortBy := $request/SortBy/text()
	let $FirmSize := $request/FirmSize/text()
	let $PracticeAreas := $request/PracticeAreas/text()
	let $ALMRankingListName := $request/ALMRankingListName/text()
	let $MLQuery := fn:replace($request/MLQuery/text(),"ALI_RE_Attorney_Combined","organization_advancesearch")
	let $MLQuery := fn:replace($MLQuery,"&amp;","&amp;amp;")
	let $RegionMLQuery := $request/RegionMLQuery/text()
	let $CountryMLQuery := $request/CountryMLQuery/text()
	let $StateMLQuery := $request/StateMLQuery/text()
	let $MetroAreaMLQuery := $request/MetroAreaMLQuery/text()
	let $CityMLQuery := $request/CityMLQuery/text()	
	let $PracticeAreaMLQuery := $request/PracticeAreaMLQuery/text()	
	let $ISVEREINSMLQuery := $request/ISVEREINSMLQuery/text()	
	let $SurveyParticipationMLQuery := $request/SurveyParticipationMLQuery/text()
	let $NoOfOfficesMLQuery := fn:replace($request/NoOfOfficesMLQuery/text(),"ALI_RE_Attorney_Combined","organization_advancesearch")
	
	return firm-comp:GetFirmRankings1(
		$PageNo,
		$PageSize,
		$FromYear,
		$ToYear,
		$FirmSearchKeys,
		$FirmLocation,
		$IsHeadquarter,
		$SortDirection,
		$SortBy,
		$FirmSize,
		$PracticeAreas,
		$ALMRankingListName,
		$MLQuery,
		$RegionMLQuery,
		$CountryMLQuery,
		$StateMLQuery,
		$MetroAreaMLQuery,
		$CityMLQuery,
		$PracticeAreaMLQuery,
		$ISVEREINSMLQuery,
		$SurveyParticipationMLQuery,
		$NoOfOfficesMLQuery
	)
};