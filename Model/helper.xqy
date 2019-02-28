module namespace helper = 'http://alm.com/helper';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';

declare option xdmp:mapping 'false';

declare function helper:distinct-node( $nodes as node()* ) as node()* 
{
    for $seq in (1 to count($nodes))
      return $nodes[$seq][not(helper:is-node-in-sequence-deep-equal(.,$nodes[position() lt $seq]))]
};

declare function helper:is-node-in-sequence-deep-equal( $node as node()? ,$seq as node()*) as xs:boolean 
{
  some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node,'http://marklogic.com/collation//S1')
};

declare function helper:GetDatesBetweenTwoDates($sYear,$eYear)
{
  if ($sYear eq $eYear) then
    $sYear
  else
    if ($sYear le $eYear) then
      let $nYear := $sYear + 1
      return ($sYear,helper:GetDatesBetweenTwoDates(xs:integer($nYear),$eYear))
    else
      let $nYear := $sYear - 1
      return ($sYear,helper:GetDatesBetweenTwoDates(xs:integer($nYear),$eYear))
};