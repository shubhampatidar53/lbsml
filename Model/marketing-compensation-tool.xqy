xquery version '1.0-ml';

module namespace comptool = 'http://alm.com/marketing-compensation-tool';
import module namespace compensationtool = "http://alm.com/compensationtool" at "/common/model/compensationtool.xqy";
import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';

declare namespace CompensationTool = 'http://alm.com/LegalCompass/rd/MARKETING_COMPENSATION';

declare function comptool:GetMCompensationAndBillingAvg()
{
    let $request := xdmp:get-request-body()/request
    let $regions := fn:tokenize($request/Regions/text(),';')
    let $gender := fn:tokenize($request/Gender/text(),';')
    let $title := fn:tokenize($request/Title/text(),';')
    let $year := fn:tokenize($request/YearOfExperience/text(),';')
    let $year := $year ! fn:string(fn:replace(.,'years',''))
    let $firmSize := fn:tokenize($request/FirmSize/text(),';')
   

    let $jsonArray := json:array()
    let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else()
                        
                    ))

    let $totalCount :=  xdmp:estimate(cts:search(/,$andQuery))  

    let $andQuery1 := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:SALARY'),('','0')))
                    ))

    let $salary := cts:search(/,$andQuery1)//CompensationTool:SALARY/text()
    
    let $percentile25 := compensationtool:GetPercentile($salary,0.25)
    let $percentile75 := compensationtool:GetPercentile($salary,0.75)
     let $percentile25Text := concat('$',$percentile25)
    let $percentile75Text :=concat('$', $percentile75)

    (: let $minValue := if($salary) then compensationtool:GetPercentile($salary,0.05) else 0
    let $minText := if($salary) then concat('$',compensationtool:GetPercentile($salary,0.05)) else 0
    let $maxValue := if($salary) then compensationtool:GetPercentile($salary,0.95) else 0
    let $maxText := if($salary) then concat('$',$maxValue) else 0 :)

    let $minValue := if($salary) then fn:min($salary) else 0
    let $minText := if($salary) then concat('$',$minValue) else 0
    let $maxValue := if($salary) then fn:max($salary) else 0
    let $maxText := if($salary) then concat('$',$maxValue) else 0

    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','SALARY'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'Salary',$request/Salary/text()),
                map:put($jsonObj,'Bonus',$request/Bonus/text()),
                map:put($jsonObj,'SizeOfMarketingDepartment',$request/SizeOfMarketingDepartment/text()),
                map:put($jsonObj,'NumberOfYourDirectReports',$request/NumberOfYourDirectReports/text()),
                map:put($jsonObj,'NumberOfFullTimeLawyersAtFirm',$request/NumberOfFullTimeLawyersAtFirm/text()),
                map:put($jsonObj,'SalaryText',$request/Salary/text()),
                map:put($jsonObj,'BonusText',$request/Bonus/text()),
                map:put($jsonObj,'SizeOfMarketingDepartmentText',$request/SizeOfMarketingDepartment/text()),
                map:put($jsonObj,'NumberOfYourDirectReportsText',$request/NumberOfYourDirectReports/text()),
                map:put($jsonObj,'NumberOfFullTimeLawyersAtFirmText',$request/NumberOfFullTimeLawyersAtFirm/text()),
                 map:put($jsonObj,'Count', $totalCount)
              )

    let $_ := json:array-push($jsonArray,$jsonObj)

    let $andQuery2 := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:BONUS'),('','0')))
                    ))        

    let $bonus := cts:search(/,$andQuery2)//CompensationTool:BONUS/text()
    
    let $percentile25 := compensationtool:GetPercentile($bonus,0.25)
    let $percentile75 := compensationtool:GetPercentile($bonus,0.75)
     let $percentile25Text := concat('$',$percentile25)
    let $percentile75Text :=concat('$', $percentile75)

  
    let $minValue := if($bonus) then compensationtool:GetPercentile($bonus,0.05) else 0
    let $minText :=  if($bonus) then concat('$',$minValue) else 0
    let $maxValue := if($bonus) then compensationtool:GetPercentile($bonus,0.95) else 0
    let $maxText :=  if($bonus) then concat('$',$maxValue) else 0

    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','BONUS'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'Salary',$request/Salary/text()),
                map:put($jsonObj,'Bonus',$request/Bonus/text()),
                map:put($jsonObj,'SizeOfMarketingDepartment',$request/SizeOfMarketingDepartment/text()),
                map:put($jsonObj,'NumberOfYourDirectReports',$request/NumberOfYourDirectReports/text()),
                map:put($jsonObj,'NumberOfFullTimeLawyersAtFirm',$request/NumberOfFullTimeLawyersAtFirm/text()),
                map:put($jsonObj,'SalaryText',$request/Salary/text()),
                map:put($jsonObj,'BonusText',$request/Bonus/text()),
                map:put($jsonObj,'SizeOfMarketingDepartmentText',$request/SizeOfMarketingDepartment/text()),
                map:put($jsonObj,'NumberOfYourDirectReportsText',$request/NumberOfYourDirectReports/text()),
                map:put($jsonObj,'NumberOfFullTimeLawyersAtFirmText',$request/NumberOfFullTimeLawyersAtFirm/text()),
                 map:put($jsonObj,'Count', $totalCount)
              )      
    let $_ := json:array-push($jsonArray,$jsonObj)

    

    return $jsonArray
    
                       


};

declare function comptool:GetMSatisfactionData()
{
    let $request := xdmp:get-request-body()/request
    let $regions := fn:tokenize($request/Regions/text(),';')
    let $gender := fn:tokenize($request/Gender/text(),';')
    let $title := fn:tokenize($request/Title/text(),';')
    let $year := fn:tokenize($request/YearOfExperience/text(),';')
    let $year := $year ! fn:string(fn:replace(.,'years',''))
    let $firmSize := fn:tokenize($request/FirmSize/text(),';')

    let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else()
    ))

    let $totalCount :=  xdmp:estimate(cts:search(/,$andQuery))               

    let $OverallJobAvg := fn:avg(cts:search(/,$andQuery)//CompensationTool:SATISFACTION/text())
    
    let $jsonObj := json:object()
    let $_ := (
                 map:put($jsonObj,'OverallJobAvg',fn:round-half-to-even($OverallJobAvg,1)),
                 map:put($jsonObj,'Count', $totalCount)
                 
              )

    return $jsonObj          

};

(: declare function comptool:GetDepartmentFirmModelAvg()
{
    let $request := xdmp:get-request-body()/request
    let $regions := fn:tokenize($request/Regions/text(),';')
    let $gender := fn:tokenize($request/Gender/text(),';')
    let $title := fn:tokenize($request/Title/text(),';')
    let $year := fn:tokenize($request/YearOfExperience/text(),';')
    let $year := $year ! fn:string(fn:replace(.,'years',''))
    let $firmSize := fn:tokenize($request/FirmSize/text(),';')

    let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else()
    ))

    let $totalCount :=  xdmp:estimate(cts:search(/,$andQuery))               

    let $directReports := fn:avg(cts:search(/,$andQuery)//CompensationTool:DIRECT_REPORTS/text())
    let $karketDepartmentHeadcount := fn:avg(cts:search(/,$andQuery)//CompensationTool:MARKETING_DEPARTMENT_HEADCOUNT/text())
    let $lawyerfulltimeStaff := fn:avg(cts:search(/,$andQuery)//CompensationTool:LAWYERSPERFULLTIME_MKTGSTAFF/text())
    
    let $jsonObj := json:object()
    let $_ := (
                 map:put($jsonObj,'DirectReports',fn:round-half-to-even($directReports,1)),
                 map:put($jsonObj,'MarketingDepartmentHeadcount',fn:round-half-to-even($karketDepartmentHeadcount,1)),
                 map:put($jsonObj,'LawyersPerFullTimeMarketingStaff',fn:round-half-to-even($lawyerfulltimeStaff,1)),
                 map:put($jsonObj,'Count', $totalCount)
              )

    return $jsonObj          

}; :)

declare function comptool:GetDepartmentFirmModelAvg()
{
    let $request := xdmp:get-request-body()/request
    let $regions := fn:tokenize($request/Regions/text(),';')
    let $gender := fn:tokenize($request/Gender/text(),';')
    let $title := fn:tokenize($request/Title/text(),';')
    let $year := fn:tokenize($request/YearOfExperience/text(),';')
    let $year := $year ! fn:string(fn:replace(.,'years',''))
    let $firmSize := fn:tokenize($request/FirmSize/text(),';')
   

    let $jsonArray := json:array()
    let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else()
                        
                    ))

    let $totalCount :=  xdmp:estimate(cts:search(/,$andQuery))  

    let $andQuery1 := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:DIRECT_REPORTS'),('','0')))
                    ))

    let $directReports := cts:search(/,$andQuery1)//CompensationTool:DIRECT_REPORTS/text()
    
    let $percentile25 := compensationtool:GetPercentile($directReports,0.25)
    let $percentile75 := compensationtool:GetPercentile($directReports,0.75)
     let $percentile25Text := concat('$',$percentile25)
    let $percentile75Text :=concat('$', $percentile75)

    let $minValue := if($directReports) then compensationtool:GetPercentile($directReports,0.05) else 0
    let $minText := if($directReports) then concat('$',compensationtool:GetPercentile($directReports,0.05)) else 0
    let $maxValue := if($directReports) then compensationtool:GetPercentile($directReports,0.95) else 0
    let $maxText := if($directReports) then concat('$',$maxValue) else 0

    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','DirectReports'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'Salary',$request/Salary/text()),
                map:put($jsonObj,'Bonus',$request/Bonus/text()),
                map:put($jsonObj,'SizeOfMarketingDepartment',$request/SizeOfMarketingDepartment/text()),
                map:put($jsonObj,'NumberOfYourDirectReports',$request/NumberOfYourDirectReports/text()),
                map:put($jsonObj,'NumberOfFullTimeLawyersAtFirm',$request/NumberOfFullTimeLawyersAtFirm/text()),
                map:put($jsonObj,'SalaryText',$request/Salary/text()),
                map:put($jsonObj,'BonusText',$request/Bonus/text()),
                map:put($jsonObj,'SizeOfMarketingDepartmentText',$request/SizeOfMarketingDepartment/text()),
                map:put($jsonObj,'NumberOfYourDirectReportsText',$request/NumberOfYourDirectReports/text()),
                map:put($jsonObj,'NumberOfFullTimeLawyersAtFirmText',$request/NumberOfFullTimeLawyersAtFirm/text()),
                 map:put($jsonObj,'Count', $totalCount)
              )

    let $_ := json:array-push($jsonArray,$jsonObj)

    let $andQuery2 := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:MARKETING_DEPARTMENT_HEADCOUNT'),('','0')))
                    ))        

    let $headCount := cts:search(/,$andQuery2)//CompensationTool:MARKETING_DEPARTMENT_HEADCOUNT/text()
    
    let $percentile25 := compensationtool:GetPercentile($headCount,0.25)
    let $percentile75 := compensationtool:GetPercentile($headCount,0.75)
     let $percentile25Text := concat('$',$percentile25)
    let $percentile75Text :=concat('$', $percentile75)

  
    let $minValue := if($headCount) then compensationtool:GetPercentile($headCount,0.05) else 0
    let $minText :=  if($headCount) then concat('$',$minValue) else 0
    let $maxValue := if($headCount) then compensationtool:GetPercentile($headCount,0.95) else 0
    let $maxText :=  if($headCount) then concat('$',$maxValue) else 0

    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','MarketingDepartmentHeadcount'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'Salary',$request/Salary/text()),
                map:put($jsonObj,'Bonus',$request/Bonus/text()),
                map:put($jsonObj,'SizeOfMarketingDepartment',$request/SizeOfMarketingDepartment/text()),
                map:put($jsonObj,'NumberOfYourDirectReports',$request/NumberOfYourDirectReports/text()),
                map:put($jsonObj,'NumberOfFullTimeLawyersAtFirm',$request/NumberOfFullTimeLawyersAtFirm/text()),
                map:put($jsonObj,'SalaryText',$request/Salary/text()),
                map:put($jsonObj,'BonusText',$request/Bonus/text()),
                map:put($jsonObj,'SizeOfMarketingDepartmentText',$request/SizeOfMarketingDepartment/text()),
                map:put($jsonObj,'NumberOfYourDirectReportsText',$request/NumberOfYourDirectReports/text()),
                map:put($jsonObj,'NumberOfFullTimeLawyersAtFirmText',$request/NumberOfFullTimeLawyersAtFirm/text()),
                 map:put($jsonObj,'Count', $totalCount)
              )      
    let $_ := json:array-push($jsonArray,$jsonObj)

    let $andQuery3 := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:LAWYERSPERFULLTIME_MKTGSTAFF'),('','0')))
                    ))        

    let $lawyersFullTime := cts:search(/,$andQuery3)//CompensationTool:LAWYERSPERFULLTIME_MKTGSTAFF/text()
    
    let $percentile25 := compensationtool:GetPercentile($lawyersFullTime,0.25)
    let $percentile75 := compensationtool:GetPercentile($lawyersFullTime,0.75)
     let $percentile25Text := concat('$',$percentile25)
    let $percentile75Text :=concat('$', $percentile75)

  
    let $minValue := if($lawyersFullTime) then compensationtool:GetPercentile($lawyersFullTime,0.05) else 0
    let $minText :=  if($lawyersFullTime) then concat('$',$minValue) else 0
    let $maxValue := if($lawyersFullTime) then compensationtool:GetPercentile($lawyersFullTime,0.95) else 0
    let $maxText :=  if($lawyersFullTime) then concat('$',$maxValue) else 0
    let $numberOfFullTimeLawyer := if($request/NumberOfFullTimeLawyersAtFirm/text() and $request/SizeOfMarketingDepartment/text()) then
                                     $request/NumberOfFullTimeLawyersAtFirm/text() div $request/SizeOfMarketingDepartment/text()
                                   else 0  
    let $jsonObj := json:object()
    let $_ := (
                map:put($jsonObj,'DataPoint','LawyersPerFullTimeMarketingStaff'),
                map:put($jsonObj,'Percentile25',$percentile25),
                map:put($jsonObj,'Percentile75',$percentile75),
                map:put($jsonObj,'MinValue',if($minValue) then $minValue else 0),
                map:put($jsonObj,'MaxValue',if($maxValue) then $maxValue else 0),
                map:put($jsonObj,'MinText',$minText),
                map:put($jsonObj,'MaxText',$maxText),
                map:put($jsonObj,'Percentile25Text',$percentile25Text),
                map:put($jsonObj,'Percentile75Text',$percentile75Text),
                map:put($jsonObj,'Salary',$request/Salary/text()),
                map:put($jsonObj,'Bonus',$request/Bonus/text()),
                map:put($jsonObj,'SizeOfMarketingDepartment',$request/SizeOfMarketingDepartment/text()),
                map:put($jsonObj,'NumberOfYourDirectReports',$request/NumberOfYourDirectReports/text()),
                map:put($jsonObj,'NumberOfFullTimeLawyersAtFirm',fn:round-half-to-even($numberOfFullTimeLawyer,0)),
                map:put($jsonObj,'SalaryText',$request/Salary/text()),
                map:put($jsonObj,'BonusText',$request/Bonus/text()),
                map:put($jsonObj,'SizeOfMarketingDepartmentText',$request/SizeOfMarketingDepartment/text()),
                map:put($jsonObj,'NumberOfYourDirectReportsText',$request/NumberOfYourDirectReports/text()),
                map:put($jsonObj,'NumberOfFullTimeLawyersAtFirmText',fn:round-half-to-even($numberOfFullTimeLawyer,0)),
                 map:put($jsonObj,'Count', $totalCount)
              )      
    let $_ := json:array-push($jsonArray,$jsonObj)

    return $jsonArray
    
                       


};

declare function comptool:GetDirectManagers()
{
    let $request := xdmp:get-request-body()/request
    let $regions := fn:tokenize($request/Regions/text(),';')
    let $gender := fn:tokenize($request/Gender/text(),';')
    let $title := fn:tokenize($request/Title/text(),';')
    let $year := fn:tokenize($request/YearOfExperience/text(),';')
    let $year := $year ! fn:string(fn:replace(.,'years',''))
    let $firmSize := fn:tokenize($request/FirmSize/text(),';')
    let $jsonArray := json:array()

    let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else()
    ))

    let $totalCount :=  xs:double(xdmp:estimate(cts:search(/,$andQuery)))

    let $loopData := for $item in fn:tokenize('Other,Marketing Committee,Managing Partner,COO/Executive Director,Marketing Partner',',')
                          let $andQuery1 := cts:and-query((
                                                cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                                                if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                                                if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                                                if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                                                if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                                                else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                                                if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else(),
                                                cts:element-value-query(xs:QName('CompensationTool:DIRECT_MANAGER'),$item)
                                                ))

                          let $res := xs:double(count(cts:search(/,$andQuery1)))
                          let $titlePercentage := fn:round-half-to-even(($res div $totalCount) * 100 ,2)

  
                          let $jsonObj := json:object()
                          let $_ := (
                                    map:put($jsonObj,'Title',$item),
                                    map:put($jsonObj,'ActualValue',$res),
                                    map:put($jsonObj,'Percentage',$titlePercentage),
                                    map:put($jsonObj,'Count', $totalCount)
                                )

                          let $_ := json:array-push($jsonArray,$jsonObj)
                          return()

    return $jsonArray          

};

declare function comptool:GetWeeklyHours()
{
    let $request := xdmp:get-request-body()/request
    let $regions := fn:tokenize($request/Regions/text(),';')
    let $gender := fn:tokenize($request/Gender/text(),';')
    let $title := fn:tokenize($request/Title/text(),';')
    let $year := fn:tokenize($request/YearOfExperience/text(),';')
    let $year := $year ! fn:string(fn:replace(.,'years',''))
    let $firmSize := fn:tokenize($request/FirmSize/text(),';')
    let $jsonArray := json:array()
    let $hoursCriteria := fn:tokenize('37 or Less;37.5;40;More Than 40',';')

    let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                        if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                        if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                        if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                        if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                        else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                        if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else(),
                        cts:not-query(cts:element-value-query(xs:QName('CompensationTool:WORK_WEEK_HOURS'),''))
    ))

    let $totalCount :=  xs:double(xdmp:estimate(cts:search(/,$andQuery)))

    let $loopData := for $item in $hoursCriteria
                          let $andQuery1 := cts:and-query((
                                                cts:directory-query('/LegalCompass/relational-data/MARKETING_COMPENSATION/'),
                                                if($regions) then cts:element-value-query(xs:QName('CompensationTool:REGION'),$regions) else(),
                                                if($gender) then cts:element-value-query(xs:QName('CompensationTool:GENDER'),$gender) else(),
                                                if($title) then cts:element-value-query(xs:QName('CompensationTool:TITLE'),$title) else(),
                                                if($year) then if($year eq '21+') then cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),'21+')
                                                else cts:element-value-query(xs:QName('CompensationTool:YEARS_OF_EXPERIENCE'),$year ! fn:string(.)) else(),
                                                if($firmSize) then cts:element-value-query(xs:QName('CompensationTool:LAWYER_COUNTS'),$firmSize) else(),
                                                cts:element-value-query(xs:QName('CompensationTool:WORK_WEEK_HOURS'),$item)
                                                ))

                          let $res := xs:double(count(cts:search(/,$andQuery1)))
                          let $titlePercentage := fn:round-half-to-even(($res div $totalCount) * 100 ,2)

  
                          let $jsonObj := json:object()
                          let $_ := (
                                    map:put($jsonObj,'Title',$item),
                                    map:put($jsonObj,'ActualValue',$res),
                                    map:put($jsonObj,'Percentage',$titlePercentage),
                                    map:put($jsonObj,'Count', $totalCount)
                                )

                          let $_ := json:array-push($jsonArray,$jsonObj)
                          return()

    return $jsonArray          

};