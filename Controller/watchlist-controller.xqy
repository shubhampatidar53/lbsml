xquery version "1.0-ml";

module namespace watchlist-ctlr = "http://alm.com/controller/watchlist";

import module namespace watchlist = "http://alm.com/watchlist" at "/common/model/watchlist.xqy";

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function watchlist-ctlr:GetWatchlist($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $UserEmail := $request/UserEmail/text()
	let $WatchlistType := $request/WatchlistType/text()
	let $IsExcludeRankings := $request/IsExcludeRankings/text()
	
	return watchlist:GetWatchlist(
		 $UserEmail
		,$WatchlistType
		,$IsExcludeRankings
	)
};

declare function watchlist-ctlr:required($value as item()*, $parameter as xs:string) as item()*
{
    if (fn:exists($value)) then
        $value
    else
        fn:error(xs:QName('MISSINGPARAM'), fn:concat('Required param '', $parameter, '' is missing'))
};

declare function watchlist-ctlr:GetWatchListByID($params as element(util:params))
{
	watchlist:GetWatchListByID(watchlist-ctlr:required($params/util:WatchlistID, 'WatchlistID')
	, watchlist-ctlr:required($params/util:UserEmail, 'UserEmail'))
	
};

declare function watchlist-ctlr:GetCompanyDefaultWatchList($params as element(util:params))
{
	watchlist:GetCompanyDefaultWatchList(watchlist-ctlr:required($params/util:UserEmail, 'UserEmail'))
};

declare function watchlist-ctlr:UpdateWatchlistName($params as element(util:params))
{
	watchlist:UpdateWatchlistName(watchlist-ctlr:required($params/util:WatchlistID, 'WatchlistID')
								, watchlist-ctlr:required($params/util:WatchlistEmailId, 'WatchlistEmailId')
								, watchlist-ctlr:required($params/util:WatchlistName, 'WatchlistName'))
};

declare function watchlist-ctlr:SetDefaultWatchList($params as element(util:params))
{
	watchlist:SetDefaultWatchList(watchlist-ctlr:required($params/util:UserEmail, 'UserEmail')
								, watchlist-ctlr:required($params/util:WatchlistID, 'WatchlistID')
								, watchlist-ctlr:required($params/util:flgDefault, 'flgDefault')
								, watchlist-ctlr:required($params/util:WatchlistType, 'WatchlistType'))
};

declare function watchlist-ctlr:RemovefromWatchlist($params as element(util:params))
{
	watchlist:RemovefromWatchlist(watchlist-ctlr:required($params/util:WatchlistID, 'WatchlistID')
								, watchlist-ctlr:required($params/util:UserEmail, 'UserEmail')
								, watchlist-ctlr:required($params/util:CompanyId, 'CompanyId'))
};

declare function watchlist-ctlr:DeleteWatchlist($params as element(util:params))
{
	watchlist:DeleteWatchlist(watchlist-ctlr:required($params/util:WatchlistID, 'WatchlistID')
								, watchlist-ctlr:required($params/util:UserEmail, 'UserEmail'))
};

declare function watchlist-ctlr:AddtoWatchlist($params as element(util:params))
{
	let $list := xdmp:get-request-body()/List
	return	watchlist:AddtoWatchlist($list)
};

declare function watchlist-ctlr:SaveWatchList($params as element(util:params))
{
	watchlist:SaveWatchList(watchlist-ctlr:required($params/util:GroupId, 'GroupId')
								,watchlist-ctlr:required($params/util:UserGroupTypeId, 'UserGroupTypeId')
								, watchlist-ctlr:required($params/util:UserEmail, 'UserEmail')
								, watchlist-ctlr:required($params/util:WatchlistName, 'WatchlistName')
								, watchlist-ctlr:required($params/util:WatchlistType, 'WatchlistType'))
};