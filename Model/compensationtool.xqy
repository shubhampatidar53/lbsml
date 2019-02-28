xquery version '1.0-ml';

module namespace comptool = 'http://alm.com/compensationtool';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';

declare namespace CompensationTool = 'http://alm.com/LegalCompass/rd/Compensation_Tool';

declare function comptool:GetSatisfactionData()
{
    let $request := xdmp:get-request-body()/request
    let $regions := fn:tokenize($request/Regions/text(),';')
    let $gender := fn:tokenize($request/Gender/text(),';')
    let $practiceArea := fn:tokenize($request/PrimaryPracticeArea/text(),';')
    let $year := fn:tokenize($request/YearOfExperience/text(),';')
    let $year :=  $year ! fn:string(fn:replace(.,'-',' to '))
    let $amlawRank := fn:tokenize($request/AmLawRank/text(),';')

    let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/Compensation_Tool/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($practiceArea) then cts:element-value-query(xs:QName('CompensationTool:PRACTICE_AREA'),$practiceArea) else(),
                        if($year) then if($year eq '20+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),'+20 Years')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),$year ! fn:string(concat(.,' years'))) else(),
                        if($amlawRank) then cts:element-value-query(xs:QName('CompensationTool:AM_LAW_200_RANK'),$amlawRank) else()
                    ))

    let $totalCount :=  xdmp:estimate(cts:search(/,$andQuery))               

    let $OverallJobAvg := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_OVERALLJOB/text())
    let $CompansationAvg :=fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_COMPENSATION/text())
    let $ProbonoAvg :=fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_PRO_BONO/text())
    let $DiversityAvg := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_DIVERSITY/text())
    let $WorkLifeBalanceAvg := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_WORKLIFEBALANCE/text())
    let $RegcRecWork := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_REGC_REC_WORK/text())
    let $RegcRecBringingWork := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_REGC_REC_BRINGING_BUS/text())
    let $PerformanceEvaluated := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_PERFORMANCE_EVALUATED/text())
    let $CompensationFirm := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_COMPENSATION_FIRM/text())
    let $RelationNonAttorneyStaff := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_RELATION_NONATTORNEYSTAFF/text())
    let $RelationAssociates := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_RELATION_ASSOCIATES/text())
    let $RelationOtherPartners := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_RELATION_OTHERPARTNERS/text())
    let $Leadership := fn:avg(cts:search(/,$andQuery)//CompensationTool:SF_LEADERSHIP/text()) 

    let $nonCompensationAvg := fn:avg(($DiversityAvg,$WorkLifeBalanceAvg,$ProbonoAvg))
    let $relationshipAvg := fn:avg(($RelationNonAttorneyStaff,$Leadership,$RelationOtherPartners,$RelationAssociates))
    let $recognizationAvg := fn:avg(($RegcRecWork,$PerformanceEvaluated,$CompensationFirm, $RegcRecBringingWork ))

    let $jsonObj := json:object()
    let $_ := (
                 map:put($jsonObj,'OverallJobAvg',fn:round-half-to-even($OverallJobAvg,1)),
                 map:put($jsonObj,'CompansationAvg',fn:round-half-to-even($CompansationAvg,1)),
                 map:put($jsonObj,'ProbonoAvg',fn:round-half-to-even($ProbonoAvg,1)),
                 map:put($jsonObj,'DiversityAvg',fn:round-half-to-even($DiversityAvg,1)),
                 map:put($jsonObj,'WorkLifeBalanceAvg',fn:round-half-to-even($WorkLifeBalanceAvg,1)),
                 map:put($jsonObj,'RegcRecWork',fn:round-half-to-even($RegcRecWork,1)),
                 map:put($jsonObj,'RegcRecBringingWork',fn:round-half-to-even($RegcRecBringingWork,1)),
                 map:put($jsonObj,'PerformanceEvaluated',fn:round-half-to-even($PerformanceEvaluated,1)),
                 map:put($jsonObj,'CompensationFirm',fn:round-half-to-even($CompensationFirm,1)),
                 map:put($jsonObj,'RelationNonAttorneyStaff',fn:round-half-to-even($RelationNonAttorneyStaff,1)),
                 map:put($jsonObj,'RelationAssociates',fn:round-half-to-even($RelationAssociates,1)),
                 map:put($jsonObj,'RelationOtherPartners',fn:round-half-to-even($RelationOtherPartners,1)),
                 map:put($jsonObj,'Leadership',fn:round-half-to-even($Leadership,1)),
                 map:put($jsonObj,'NonCompensationAvg', fn:round-half-to-even($nonCompensationAvg,1)),
                 map:put($jsonObj,'RelationshipAvg', fn:round-half-to-even($relationshipAvg,1)),
                 map:put($jsonObj,'RecognizationAvg', fn:round-half-to-even($recognizationAvg,1)),
                 map:put($jsonObj,'Count', $totalCount)
                 
              )

    return $jsonObj          

};

declare function comptool:GetCompensationAndBillingAvg()
{
    let $request := xdmp:get-request-body()/request
    let $regions := fn:tokenize($request/Regions/text(),';')
    let $gender := fn:tokenize($request/Gender/text(),';')
    let $practiceArea := fn:tokenize($request/PrimaryPracticeArea/text(),';')
    let $year := fn:tokenize($request/YearOfExperience/text(),';')
    let $year := $year ! fn:string(fn:replace(.,'-',' to '))
    let $amlawRank := fn:tokenize($request/AmLawRank/text(),';')
   

    let $jsonArray := json:array()
    let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/Compensation_Tool/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($practiceArea) then cts:element-value-query(xs:QName('CompensationTool:PRACTICE_AREA'),$practiceArea) else(),
                        if($year) then if($year eq '20+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),'+20 Years')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),$year ! fn:string(concat(.,' years'))) else(),
                        if($amlawRank) then cts:element-value-query(xs:QName('CompensationTool:AM_LAW_200_RANK'),$amlawRank) else()
                        
                    ))

    let $totalCount :=  xdmp:estimate(cts:search(/,$andQuery))  

    let $andQuery1 := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/Compensation_Tool/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($practiceArea) then cts:element-value-query(xs:QName('CompensationTool:PRACTICE_AREA'),$practiceArea) else(),
                        if($year) then if($year eq '20+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),'+20 Years')                         else cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),$year ! fn:string(concat(.,' years'))) else(),
                        if($amlawRank) then cts:element-value-query(xs:QName('CompensationTool:AM_LAW_200_RANK'),$amlawRank) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:TOTAL_COMPENSATION'),''))
                    ))

    let $totalCompensation := cts:search(/,$andQuery1)//CompensationTool:TOTAL_COMPENSATION/text()
    (: let $percentile25 := math:percentile(($totalCompensation ! xs:double(.)),(0.25))
    let $percentile75 := math:percentile(($totalCompensation ! xs:double(.)),(0.75)) :)

    let $percentile25 := comptool:GetPercentile($totalCompensation,0.25)
    let $percentile75 := comptool:GetPercentile($totalCompensation,0.75)
     let $percentile25Text := concat('$',$percentile25)
    let $percentile75Text :=concat('$', $percentile75)

    (: let $minValue := if($totalCompensation) then min($totalCompensation) else 0
    let $minText := if($totalCompensation) then concat('$',(min($totalCompensation))) else 0
    let $maxValue := if($totalCompensation) then max($totalCompensation) else 0
    let $maxText := if($totalCompensation) then concat('$',(max($totalCompensation))) else 0 :)

    let $minValue := if($totalCompensation) then comptool:GetPercentile($totalCompensation,0.05) else 0
    let $minText := if($totalCompensation) then concat('$',comptool:GetPercentile($totalCompensation,0.05)) else 0
    let $maxValue := if($totalCompensation) then comptool:GetPercentile($totalCompensation,0.95) else 0
    let $maxText := if($totalCompensation) then concat('$',$maxValue) else 0

    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','TOTAL_COMPENSATION'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'SalaryBonus',$request/SalaryBonus/text()),
                map:put($jsonObj,'Originations',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRate',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHours',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHours',$request/YearlyNonBillableHours/text()),
                map:put($jsonObj,'SalaryBonusText',$request/SalaryBonus/text()),
                map:put($jsonObj,'OriginationsText',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRateText',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHoursText',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHoursText',$request/YearlyNonBillableHours/text()),
                 map:put($jsonObj,'Count', $totalCount)
              )

    let $_ := json:array-push($jsonArray,$jsonObj)

    let $andQuery2 := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/Compensation_Tool/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($practiceArea) then cts:element-value-query(xs:QName('CompensationTool:PRACTICE_AREA'),$practiceArea) else(),
                        if($year) then if($year eq '20+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),'+20 Years')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),$year ! fn:string(concat(.,' years'))) else(),
                        if($amlawRank) then cts:element-value-query(xs:QName('CompensationTool:AM_LAW_200_RANK'),$amlawRank) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:TOTAL_ORIGINATIONS'),''))
                    ))          

    let $totalOriginations := cts:search(/,$andQuery2)//CompensationTool:TOTAL_ORIGINATIONS/text()
    (: let $percentile25 := math:percentile(($totalOriginations ! xs:double(.)),(0.25))
    let $percentile75 := math:percentile(($totalOriginations ! xs:double(.)),(0.75))

    let $percentile25Text := concat('$',math:percentile(($totalOriginations ! xs:double(.)),(0.25)))
    let $percentile75Text :=concat('$', math:percentile(($totalOriginations ! xs:double(.)),(0.75))) :)

    let $percentile25 := comptool:GetPercentile($totalOriginations,0.25)
    let $percentile75 := comptool:GetPercentile($totalOriginations,0.75)
     let $percentile25Text := concat('$',$percentile25)
    let $percentile75Text :=concat('$', $percentile75)

    (: let $minValue := if($totalOriginations) then min($totalOriginations) else 0
    let $minText := if($totalOriginations) then concat('$',(min($totalOriginations))) else 0
    let $maxValue := if($totalOriginations) then max($totalOriginations) else 0
    let $maxText := if($totalOriginations) then concat('$',(max($totalOriginations))) else 0 :)

    let $minValue := if($totalOriginations) then comptool:GetPercentile($totalOriginations,0.05) else 0
    let $minText := if($totalOriginations) then concat('$',$minValue) else 0
    let $maxValue := if($totalOriginations) then comptool:GetPercentile($totalOriginations,0.95) else 0
    let $maxText := if($totalOriginations) then concat('$',$maxValue) else 0

    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','TOTAL_ORIGINATIONS'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'SalaryBonus',$request/SalaryBonus/text()),
                map:put($jsonObj,'Originations',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRate',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHours',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHours',$request/YearlyNonBillableHours/text()),
                map:put($jsonObj,'SalaryBonusText',$request/SalaryBonus/text()),
                map:put($jsonObj,'OriginationsText',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRateText',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHoursText',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHoursText',$request/YearlyNonBillableHours/text()),
                 map:put($jsonObj,'Count', $totalCount)
              )      
    let $_ := json:array-push($jsonArray,$jsonObj)

    let $andQuery3 := cts:and-query((
                                cts:directory-query('/LegalCompass/relational-data/Compensation_Tool/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($practiceArea) then cts:element-value-query(xs:QName('CompensationTool:PRACTICE_AREA'),$practiceArea) else(),
                        if($year) then if($year eq '20+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),'+20 Years')                         else cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),$year ! fn:string(concat(.,' years'))) else(),
                        if($amlawRank) then cts:element-value-query(xs:QName('CompensationTool:AM_LAW_200_RANK'),$amlawRank) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:HOURLY_BILLING_RATE'),''))
                    ))

    let $hourlyBillingRate := cts:search(/,$andQuery3)//CompensationTool:HOURLY_BILLING_RATE/text()
    
     let $percentile25 := comptool:GetPercentile($hourlyBillingRate,0.25)
    let $percentile75 := comptool:GetPercentile($hourlyBillingRate,0.75)
     let $percentile25Text := concat('$',$percentile25, '/hr')
    let $percentile75Text :=concat('$', $percentile75, '/hr')
    
    
    (: let $percentile25 := math:percentile(($hourlyBillingRate ! xs:double(.)),(0.25))
    let $percentile75 := math:percentile(($hourlyBillingRate ! xs:double(.)),(0.75))

    let $percentile25Text := concat('$',math:percentile(($hourlyBillingRate ! xs:double(.)),(0.25)) , '/hr')
    let $percentile75Text :=concat('$', math:percentile(($hourlyBillingRate ! xs:double(.)),(0.75)) , '/hr') :)

    (: let $minValue := if($hourlyBillingRate) then min($hourlyBillingRate) else 0
    let $minText := if($hourlyBillingRate) then concat('$',(min($hourlyBillingRate))) else 0
    let $maxValue := if($hourlyBillingRate) then max($hourlyBillingRate) else 0
    let $maxText := if($hourlyBillingRate) then concat('$',(max($hourlyBillingRate))) else 0 :)

    let $minValue := if($hourlyBillingRate) then comptool:GetPercentile($hourlyBillingRate,0.05) else 0
    let $minText := if($hourlyBillingRate) then concat('$',$minValue) else 0
    let $maxValue := if($hourlyBillingRate) then comptool:GetPercentile($hourlyBillingRate,0.95) else 0
    let $maxText := if($hourlyBillingRate) then concat('$',$maxValue) else 0

    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','HOURLY_BILLING_RATE'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'SalaryBonus',$request/SalaryBonus/text()),
                map:put($jsonObj,'Originations',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRate',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHours',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHours',$request/YearlyNonBillableHours/text()),
                map:put($jsonObj,'SalaryBonusText',$request/SalaryBonus/text()),
                map:put($jsonObj,'OriginationsText',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRateText',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHoursText',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHoursText',$request/YearlyNonBillableHours/text()),
                 map:put($jsonObj,'Count', $totalCount)
              )   

    let $_ := json:array-push($jsonArray,$jsonObj)

     let $andQuery4 := cts:and-query((
                                 cts:directory-query('/LegalCompass/relational-data/Compensation_Tool/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($practiceArea) then cts:element-value-query(xs:QName('CompensationTool:PRACTICE_AREA'),$practiceArea) else(),
                        if($year) then if($year eq '20+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),'+20 Years')                         else cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),$year ! fn:string(concat(.,' years'))) else(),
                        if($amlawRank) then cts:element-value-query(xs:QName('CompensationTool:AM_LAW_200_RANK'),$amlawRank) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:TOTAL_BILLABLE_HOURS'),''))
                    ))

    let $totalBillableHours := cts:search(/,$andQuery4)//CompensationTool:TOTAL_BILLABLE_HOURS/text()

    let $percentile25 := comptool:GetPercentile($totalBillableHours,0.25)
    let $percentile75 := comptool:GetPercentile($totalBillableHours,0.75)
     let $percentile25Text := concat('$',$percentile25, 'hrs')
    let $percentile75Text :=concat('$', $percentile75, 'hrs')

    (: let $percentile25 := math:percentile(($totalBillableHours ! xs:double(.)),(0.25))
    let $percentile75 := math:percentile(($totalBillableHours ! xs:double(.)),(0.75))

    let $percentile25Text := concat(math:percentile(($totalBillableHours ! xs:double(.)),(0.25)) , 'hrs')
    let $percentile75Text :=concat(math:percentile(($totalBillableHours ! xs:double(.)),(0.75)) , 'hrs') :)

    (: let $minValue := if($totalBillableHours) then min($totalBillableHours) else 0
    let $minText := if($totalBillableHours) then concat('$',(min($totalBillableHours))) else 0
    let $maxValue := if($totalBillableHours) then max($totalBillableHours) else 0
    let $maxText := if($totalBillableHours) then concat('$',(max($totalBillableHours))) else 0 :)

    let $minValue := if($totalBillableHours) then comptool:GetPercentile($totalBillableHours,0.05) else 0
    let $minText := if($totalBillableHours) then concat('$',$minValue) else 0
    let $maxValue := if($totalBillableHours) then comptool:GetPercentile($totalBillableHours,0.95) else 0
    let $maxText := if($totalBillableHours) then concat('$',$maxValue) else 0

    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','TOTAL_BILLABLE_HOURS'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'SalaryBonus',$request/SalaryBonus/text()),
                map:put($jsonObj,'Originations',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRate',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHours',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHours',$request/YearlyNonBillableHours/text()),
                map:put($jsonObj,'SalaryBonusText',$request/SalaryBonus/text()),
                map:put($jsonObj,'OriginationsText',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRateText',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHoursText',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHoursText',$request/YearlyNonBillableHours/text()),
                 map:put($jsonObj,'Count', $totalCount)
              )   

    let $_ := json:array-push($jsonArray,$jsonObj)

    let $andQuery5 := cts:and-query((
                                cts:directory-query('/LegalCompass/relational-data/Compensation_Tool/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($practiceArea) then cts:element-value-query(xs:QName('CompensationTool:PRACTICE_AREA'),$practiceArea) else(),
                        if($year) then if($year eq '20+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),'+20 Years')                         else cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),$year ! fn:string(concat(.,' years'))) else(),
                        if($amlawRank) then cts:element-value-query(xs:QName('CompensationTool:AM_LAW_200_RANK'),$amlawRank) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:TOTAL_NONBILLABLE_HOURS'),''))
                    ))

    let $totalNonBillableHours := cts:search(/,$andQuery5)//CompensationTool:TOTAL_NONBILLABLE_HOURS/text()
    (: let $percentile25 := math:percentile(($totalNonBillableHours ! xs:double(.)),(0.25))
    let $percentile75 := math:percentile(($totalNonBillableHours ! xs:double(.)),(0.75))

    let $percentile25Text := concat(math:percentile(($totalNonBillableHours ! xs:double(.)),(0.25)) , 'hrs')
    let $percentile75Text :=concat(math:percentile(($totalNonBillableHours ! xs:double(.)),(0.75)) , 'hrs') :)

    let $percentile25 := comptool:GetPercentile($totalNonBillableHours,0.25)
    let $percentile75 := comptool:GetPercentile($totalNonBillableHours,0.75)
     let $percentile25Text := concat('$',$percentile25, 'hrs')
    let $percentile75Text :=concat('$', $percentile75, 'hrs')

    (: let $minValue := if($totalNonBillableHours) then min($totalNonBillableHours) else 0
    let $minText := if($totalNonBillableHours) then concat('$',(min($totalNonBillableHours))) else 0
    let $maxValue := if($totalNonBillableHours) then max($totalNonBillableHours) else 0
    let $maxText := if($totalNonBillableHours) then concat('$',(max($totalNonBillableHours))) else 0 :)

     let $minValue := if($totalNonBillableHours) then comptool:GetPercentile($totalNonBillableHours,0.05) else 0
    let $minText := if($totalNonBillableHours) then concat('$',$minValue) else 0
    let $maxValue := if($totalNonBillableHours) then comptool:GetPercentile($totalNonBillableHours,0.95) else 0
    let $maxText := if($totalNonBillableHours) then concat('$',$maxValue) else 0

    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','TOTAL_NONBILLABLE_HOURS'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'SalaryBonus',$request/SalaryBonus/text()),
                map:put($jsonObj,'Originations',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRate',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHours',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHours',$request/YearlyNonBillableHours/text()),
                map:put($jsonObj,'SalaryBonusText',$request/SalaryBonus/text()),
                map:put($jsonObj,'OriginationsText',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRateText',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHoursText',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHoursText',$request/YearlyNonBillableHours/text()),
                 map:put($jsonObj,'Count', $totalCount)
              )   

    let $_ := json:array-push($jsonArray,$jsonObj)

    let $andQuery6 := cts:and-query((
                                cts:directory-query('/LegalCompass/relational-data/Compensation_Tool/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($practiceArea) then cts:element-value-query(xs:QName('CompensationTool:PRACTICE_AREA'),$practiceArea) else(),
                        if($year) then if($year eq '20+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),'+20 Years')                         else cts:element-value-query(xs:QName('CompensationTool:YEARS_AS_PARTNER'),$year ! fn:string(concat(.,' years'))) else(),
                        if($amlawRank) then cts:element-value-query(xs:QName('CompensationTool:AM_LAW_200_RANK'),$amlawRank) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:SALARY_AS_ORIGINATIONS'),''))
                    ))

    let $salaryAsOrigins := cts:search(/,$andQuery6)//CompensationTool:SALARY_AS_ORIGINATIONS/text()
    (: let $percentile25 := math:percentile(($salaryAsOrigins ! xs:double(.)),(0.25))
    let $percentile75 := math:percentile(($salaryAsOrigins ! xs:double(.)),(0.75))

    let $percentile25Text := concat('$',math:percentile(($salaryAsOrigins ! xs:double(.)),(0.25)))
    let $percentile75Text :=concat('$',math:percentile(($salaryAsOrigins ! xs:double(.)),(0.75))) :)

    let $percentile25 := comptool:GetPercentile($salaryAsOrigins,0.25)
    let $percentile75 := comptool:GetPercentile($salaryAsOrigins,0.75)
     let $percentile25Text := concat('$',$percentile25)
    let $percentile75Text :=concat('$', $percentile75)

    (: let $minValue := if($salaryAsOrigins) then min($salaryAsOrigins) else 0
    let $minText := if($salaryAsOrigins) then concat('$',(min($salaryAsOrigins))) else 0
    let $maxValue := if($salaryAsOrigins) then max($salaryAsOrigins) else 0
    let $maxText := if($salaryAsOrigins) then concat('$',(max($salaryAsOrigins))) else 0 :)

    let $minValue := if($salaryAsOrigins) then comptool:GetPercentile($salaryAsOrigins,0.05) else 0
    let $minText := if($salaryAsOrigins) then concat('$',$minValue) else 0
    let $maxValue := if($salaryAsOrigins) then comptool:GetPercentile($salaryAsOrigins,0.95) else 0
    let $maxText := if($salaryAsOrigins) then concat('$',$maxValue) else 0

    let $SalaryBonus :=if($request/Originations/text()) then fn:round-half-to-even((xs:double($request/SalaryBonus/text()) div xs:double($request/Originations/text())) * 100,2) else 0

    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','SALARY_AS_ORIGINATIONS'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'SalaryBonus',$SalaryBonus),
                map:put($jsonObj,'Originations',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRate',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHours',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHours',$request/YearlyNonBillableHours/text()),
                map:put($jsonObj,'SalaryBonusText',$request/SalaryBonus/text()),
                map:put($jsonObj,'OriginationsText',$request/Originations/text()),
                map:put($jsonObj,'HourlyBillingRateText',$request/HourlyBillingRate/text()),
                map:put($jsonObj,'YearlyBillableHoursText',$request/YearlyBillableHours/text()),
                map:put($jsonObj,'YearlyNonBillableHoursText',$request/YearlyNonBillableHours/text()),
                 map:put($jsonObj,'Count', $totalCount)
              )   

    let $_ := json:array-push($jsonArray,$jsonObj)

    return $jsonArray
    
                       


};

declare function comptool:GetPercentile($seq,$percentile)
{
    (: let $seq := fn:tokenize('155000,158840,170000,180000,200000,200000,200000,205000,208500,210000,220000,220000,225000,225000,250000,270000,300000,320000,330000,345000,350000,350000,365000,375000,375000,380000,400000,400000,400000,400000,440000,450000,450000,487500,500000,510000,575000,610000,630000,710000,750000,750000,825000,835000,850000,875000,1000000,1100000,1200000,2000000,2100000,2100000,2800000',',')    :)

    let $seq := for $i in $seq
                 let $a := xs:integer(fn:round($i))
                    order by $a ascending
                    return $a

    let $N := fn:count($seq)
    
    let $n2 := ($N + 1) * $percentile
    let $n := fn:round(($N + 1) * $percentile)
    let $k := xs:integer($n2)

    let $d := $n2 - $k
    let $p2 := ($d * (xs:integer($seq[$k + 1]) - xs:integer($seq[$k])))
    let $res := if($n eq 1) then $seq[1] 
                else if($n eq $N) then $seq[$N]
                else if($percentile eq 0.125) then (xs:integer($seq[$k - 1]) + $p2) else (xs:integer($seq[$k]) + $p2)

    return $res 

};