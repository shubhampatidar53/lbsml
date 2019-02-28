xquery version '1.0-ml';

module namespace billpredection-ctlr = 'http://alm.com/controller/billpredection';
import module namespace billpredection = 'http://alm.com/billpredection' at '/common/model/billpredection.xqy';

declare namespace util = 'http://alm.com/util';

declare option xdmp:mapping 'false';

declare function billpredection-ctlr:required($value as item()*, $parameter as xs:string) as item()*
{
    if (fn:exists($value)) then
        $value
    else
        fn:error(xs:QName('MISSINGPARAM'), fn:concat('Required param '', $parameter, '' is missing'))
};

declare function billpredection-ctlr:legislationAutoComplete($params as element(util:params))
{	
    let $request := xdmp:get-request-body()/request
    let $billId := $request//bill_id/text()

    return billpredection:legislationAutoComplete($billId)

};

declare function billpredection-ctlr:SP_BILLPREDICTIONSGET($params as element(util:params))
{	
    let $request := xdmp:get-request-body()/request

    let $title := $request/Title/text() 
    let $billId := $request/bill_id/text()
    let $predictionFrom := $request/Prediction/text()
    let $predictionTo := $request/ToPrediction/text()
    let $passPredictionFrom := $request/PassPrediction/text()
    let $passPredictionTo := $request/ToPassPrediction/text()
    let $status := $request/status/text()
    let $pageNumber := $request/PageNo/text()
    let $pageSize := $request/PageSize/text()
    let $sort := $request/Sort/text()
    let $direction := $request/Direction/text()

    return billpredection:SP_BILLPREDICTIONSGET(
        $title
        ,$billId
        ,$predictionFrom
        ,$predictionTo
        ,$passPredictionFrom
        ,$passPredictionTo
        ,$status
        ,$pageNumber
        ,$pageSize
        ,$sort
        ,$direction
        )
};

declare function billpredection-ctlr:SP_BILLPREDICTIONDETAILSGET($params as element(util:params))
{	
    let $request := xdmp:get-request-body()/request

    let $billId := $request/bill_id/text()

    return billpredection:SP_BILLPREDICTIONDETAILSGET(
	$billId
	)
    
};