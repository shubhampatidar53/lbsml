xquery version '1.0-ml';

module namespace research-ctlr = 'http://alm.com/controller/research';
import module namespace research = 'http://alm.com/research' at '/common/model/research.xqy';

declare namespace util = 'http://alm.com/util';

declare option xdmp:mapping 'false';

declare function research-ctlr:required($value as item()*, $parameter as xs:string) as item()*
{
    if (fn:exists($value)) then
        $value
    else
        fn:error(xs:QName('MISSINGPARAM'), fn:concat('Required param '', $parameter, '' is missing'))
};

declare function research-ctlr:GetSavedSearches($params as element(util:params))
{
	(: research:GetSavedSearches("1373722", 1, 10) :)
	research:GetSavedSearches(research-ctlr:required($params/util:userId, 'userId')
								,research-ctlr:required($params/util:pageNo, 'pageNo')
								,research-ctlr:required($params/util:pageSize, 'pageSize'))
};



