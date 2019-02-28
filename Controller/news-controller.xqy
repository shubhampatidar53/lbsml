xquery version '1.0-ml';

module namespace news-ctlr = 'http://alm.com/controller/news';

import module namespace news = 'http://alm.com/news' at '/common/model/news.xqy';

declare namespace util = 'http://alm.com/util';

declare option xdmp:mapping 'false';

declare function news-ctlr:GetNews($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $pageNo := if ($request/pageNo/text() !='') then $request/pageNo/text() else 1
	let $recordsPerPage := if ($request/recordsPerPage/text() != '') then $request/recordsPerPage/text() else 10
	let $contentTypes := if ($request/contentTypes/text() != '') then $request/contentTypes/text() else ()
	let $twitterContentTypes := if ($request/twitterContentTypes/text() != '') then $request/twitterContentTypes/text() else ()
	let $fromDate := if ($request/fromDate/text() != '') then $request/fromDate/text() else ()
	let $toDate := if ($request/toDate/text() != '') then $request/toDate/text() else ()
	let $companyID := $request/companyID/text()
	let $ALMRankingListName := $request/ALMRankingListName/text()
	let $practiceAreas := $request/practiceAreas/text()
	let $Keywords := $request/Keywords/text()
	let $SortBy := $request/SortBy/text()
	let $SortDirection := $request/SortDirection/text()

	return news:GetNews(
		 $pageNo
		,$recordsPerPage
		,$contentTypes
		,$fromDate
		,$toDate
		,$companyID
		,$ALMRankingListName
		,$practiceAreas
		,$Keywords
		,$SortBy
		,$SortDirection
		,$twitterContentTypes
	)
};

declare function news-ctlr:GetNewsGLL($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $pageNo := if ($request/pageNo/text() !='') then $request/pageNo/text() else 1
	let $recordsPerPage := if ($request/recordsPerPage/text() != '') then $request/recordsPerPage/text() else 10
	let $contentTypes := if ($request/contentTypes/text() != '') then $request/contentTypes/text() else ()
	let $twitterContentTypes := if ($request/twitterContentTypes/text() != '') then $request/twitterContentTypes/text() else ()
	let $fromDate := if ($request/fromDate/text() != '') then $request/fromDate/text() else ()
	let $toDate := if ($request/toDate/text() != '') then $request/toDate/text() else ()
	let $companyID := $request/companyID/text()
	let $ALMRankingListName := $request/ALMRankingListName/text()
	let $practiceAreas := $request/practiceAreas/text()
	let $Keywords := $request/Keywords/text()
	let $SortBy := $request/SortBy/text()
	let $SortDirection := $request/SortDirection/text()
	

	return news:GetNewsGLL(
		 $pageNo
		,$recordsPerPage
		,$contentTypes
		,$fromDate
		,$toDate
		,$companyID
		,$ALMRankingListName
		,$practiceAreas
		,$Keywords
		,$SortBy
		,$SortDirection
	)
};

declare function news-ctlr:GetNewsFirmTrends($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $contentTypes := if ($request/contentTypes/text() != '') then $request/contentTypes/text() else ()
	let $fromDate := if ($request/fromDate/text() != '') then $request/fromDate/text() else ()
	let $toDate := if ($request/toDate/text() != '') then $request/toDate/text() else ()
	let $companyID := $request/companyID/text()
	let $practiceAreas := $request/practiceAreas/text()
	let $Keywords := $request/Keywords/text()
	let $twitterContentTypes := if ($request/twitterContentTypes/text() != '') then $request/twitterContentTypes/text() else ()
	
	return news:GetNewsFirmTrends(
		 $contentTypes
		,$fromDate
		,$toDate
		,$companyID
		,$practiceAreas
		,$Keywords
		,$twitterContentTypes
	)
};

declare function news-ctlr:GetNewsPracticeTrends($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $contentTypes := if ($request/contentTypes/text() != '') then $request/contentTypes/text() else ()
	let $fromDate := if ($request/fromDate/text() != '') then $request/fromDate/text() else ()
	let $toDate := if ($request/toDate/text() != '') then $request/toDate/text() else ()
	let $companyID := $request/companyID/text()
	let $practiceAreas := $request/practiceAreas/text()
	let $Keywords := $request/Keywords/text()

	return news:GetNewsPracticeTrends(
		 $contentTypes
		,$fromDate
		,$toDate
		,$companyID
		,$practiceAreas
		,$Keywords
	)
};

declare function news-ctlr:GetNewsPracticeTrends1($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $contentTypes := if ($request/contentTypes/text() != '') then $request/contentTypes/text() else ()
	let $fromDate := if ($request/fromDate/text() != '') then fn:tokenize($request/fromDate/text(),'T')[1] else ()
	let $toDate := if ($request/toDate/text() != '') then fn:tokenize($request/toDate/text(),'T')[1] else ()
	let $companyID := $request/companyID/text()
	let $practiceAreas := $request/practiceAreas/text()
	let $Keywords := $request/Keywords/text()

	return news:GetNewsPracticeTrends1(
		 $contentTypes
		,$fromDate
		,$toDate
		,$companyID
		,$practiceAreas
		,$Keywords
	)
};

declare function news-ctlr:GetNewsPracticeTrends2($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $contentTypes := if ($request/contentTypes/text() != '') then $request/contentTypes/text() else ()
	let $fromDate := if ($request/fromDate/text() != '') then fn:tokenize($request/fromDate/text(),'T')[1] else ()
	let $toDate := if ($request/toDate/text() != '') then fn:tokenize($request/toDate/text(),'T')[1] else ()
	let $companyID := $request/companyID/text()
	let $practiceAreas := $request/practiceAreas/text()
	let $Keywords := $request/Keywords/text()
	let $twitterContentTypes := if ($request/twitterContentTypes/text() != '') then $request/twitterContentTypes/text() else ()

	return news:GetNewsPracticeTrends2(
		 $contentTypes
		,$fromDate
		,$toDate
		,$companyID
		,$practiceAreas
		,$Keywords
		,$twitterContentTypes
	)
};