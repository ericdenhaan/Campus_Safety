(:===================================================================================================================:)
(: assoc-rules-paper XQuery Script :)
(: Generate association rules using dataset provided by researchers :)
(:===================================================================================================================:)

(: Imports/Namespaces :)
declare namespace prof="http://basex.org/modules/prof";

(:===================================================================================================================:)
(: commonItems function :)
(:===================================================================================================================:)

declare function local:commonItems($X, $Y)
{
	for $item in $X
	where some $i in $Y satisfies $i = $item
	return $item
};


(:===================================================================================================================:)
(: removeItems function :)
(:===================================================================================================================:)

declare function local:removeItems($X, $Y)
{
	for $item in $X
	where every $i in $Y satisfies $i != $item
	return $item
};

(:===================================================================================================================:)
(: Script :)
(:===================================================================================================================:)

prof:time(
let $minconf := 1.00
let $src := doc('../output/large-itemsets-paper.xml')//largeItemset
for $itemset1 in $src
  let $items1 := $itemset1/items/*
for $itemset2 in $src
  let $items2 := $itemset2/items/*
  where count($items1) > count($items2) and
    count(local:commonItems($items1, $items2)) =
    count($items2) and $itemset1/support div
    $itemset2/support >= $minconf
    return  <rule support ='{$itemset1/support}'
              confidence = '{($itemset1/support*1.0) div
              ($itemset2/support*1.0)}'>
              <antecedent> {$items2} </antecedent>
              <consequent>
                {local:removeItems($items1,$items2)}
              </consequent>
            </rule>,
'Execution time of association rules computation from paper: ')