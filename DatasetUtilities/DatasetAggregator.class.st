Class {
	#name : #DatasetAggregator,
	#superclass : #Object,
	#instVars : [
		'aggregation',
		'mappings',
		'keyBlock',
		'keyAspect',
		'filterBlock'
	],
	#category : #DatasetUtilities
}

{ #category : #api }
DatasetAggregator >> addAverageMappingFor: aSymbol [

	mappings at: aSymbol put: self averageAggregationBlock
]

{ #category : #api }
DatasetAggregator >> addMaxMappingFor: aSymbol [

	mappings at: aSymbol put: self maxAggregationBlock
]

{ #category : #api }
DatasetAggregator >> addMinMappingFor: aSymbol [

	mappings at: aSymbol put: self minAggregationBlock
]

{ #category : #api }
DatasetAggregator >> addSumMappingFor: aSymbol [

	mappings at: aSymbol put: self sumAggregationBlock
]

{ #category : #accessing }
DatasetAggregator >> afterDateandTime: dt [

	^ self filterBlock: [ :key | 
		  key > dt ]
]

{ #category : #api }
DatasetAggregator >> aggregate: bulkCollection [

	^ self reifyValues:
		  (self aggregateFromStream: (ReadStream on: bulkCollection))
]

{ #category : #'api - export' }
DatasetAggregator >> aggregate: bulkCollection csvOn: outputStream [

	| writer |
	writer := NeoCSVWriter on: outputStream.
	writer nextPut: self csvHeader. "#( date rain )"
	writer addObjectFields: #( key ).
	self configureCSVFieldsOn: writer.
	writer nextPutAll: (self aggregate: bulkCollection)
]

{ #category : #api }
DatasetAggregator >> aggregate: bulkCollection do: aBlock [

	(self aggregate: bulkCollection) do: aBlock
]

{ #category : #'api - export' }
DatasetAggregator >> aggregate: bulkCollection jsonOn: outputStream [

	"^ String streamContents: [ :stream | 
		  stream nextPutAll:
			  (NeoJSONWriter toStringPretty: ((self aggregate: bulkCollection)
					    inject: OrderedCollection new
					    into: [ :col :each | 
						    col
							    add: each value;
							    yourself ])) ]"
					
				
			outputStream nextPutAll:
			  (NeoJSONWriter toStringPretty: ((self aggregate: bulkCollection)
					    inject: OrderedCollection new
					    into: [ :col :each | 
						    col
							    add: each value;
							    yourself ]))
]

{ #category : #'api - export' }
DatasetAggregator >> aggregateCSV: bulkCollection [

	^ String streamContents: [ :stream | 
		  self aggregate: bulkCollection csvOn: stream ]
]

{ #category : #api }
DatasetAggregator >> aggregateFromStream: readStream [

	| result |
	[ readStream atEnd ] whileFalse: [ 
		| each key |
		each := readStream next.
		key := keyBlock value: (each perform: keyAspect).
		(filterBlock value: key) ifTrue:[self applyMappingsTo: each key: key] ].

	result := SortedCollection sortBlock: [ :a :b | a key < b key ].
	aggregation associationsDo: [ :each | 
		each value at: #when put: each key printString.
		result add: each ].

	^ result
]

{ #category : #'api - export' }
DatasetAggregator >> aggregateJSON: bulkCollection [

	^ String streamContents: [ :stream | 
		  self aggregate: bulkCollection jsonOn: stream ]
]

{ #category : #private }
DatasetAggregator >> applyMappingsTo: row key: key [

	mappings keysAndValuesDo: [ :k :map | 
		aggregation
			at: key
			ifPresent: [ :v | 
			aggregation at: key put: (map value: row value: v value: k) ]
			ifAbsent: [ 
				aggregation
					at: key
					put: (map value: row value: Dictionary new value: k) ] ]
]

{ #category : #private }
DatasetAggregator >> averageAggregationBlock [

	^ [ :bulk :outReg :key | 
	  | value |
	  value := bulk perform: key.
	  value isNumber ifTrue: 
[	  outReg
		  at: key
		  ifPresent: [ :v | 
			  v ifNotNil: [ 
				  outReg at: key put: (v
						   at: 1 put: ((v at: 1) + value);
						   at: 2 put: (v at: 2) + 1;
						   yourself) ] ]
		  ifAbsent: [ 
			  value ifNotNil: [ 
				  outReg at: key put: { 
						  value.
						  1 } ] ]].
	  outReg ]
]

{ #category : #accessing }
DatasetAggregator >> beforeDateandTime: dt [

	^ self filterBlock: [ :each | 
		  (DateAndTime fromString: (each at: 'when')) < dt ]
]

{ #category : #accessing }
DatasetAggregator >> between: dt1 and: dt2 [

	dt1 < dt2 ifFalse: [ self error: 'Period out of order' ].
	^ self filterBlock: [ :each | 
		  (DateAndTime fromString: (each at: 'when')) < dt2 and: [ 
			  (DateAndTime fromString: (each at: 'when')) > dt1 ] ]
]

{ #category : #private }
DatasetAggregator >> collateAggregationBlock [

	^ [ :bulk :outReg :key | 
	  | value |
	  value := bulk perform: key.
	  outReg
		  at: key
		  ifPresent: [ :v | outReg at: key put: v , ' ' , value ]
		  ifAbsent: [ outReg at: key put: value ].
	  outReg ]
]

{ #category : #'api - export' }
DatasetAggregator >> configureCSVFieldsOn: writer [

	mappings keysDo: [ :k | 
		writer addObjectField: [ :dict | 
			dict value at: k asSymbol ifAbsent: nil
			"| obj |
			obj := dict value at: k asSymbol ifAbsent: nil.
			obj isArray
				ifTrue: [ (obj first / obj second) asFloat ]
				ifFalse: [ obj ]" ] ]
]

{ #category : #'api - export' }
DatasetAggregator >> csvHeader [

	| header |
	header := OrderedCollection with: 'key'.
	header addAll: mappings keys.
	^ header
]

{ #category : #api }
DatasetAggregator >> daily [

	keyBlock := [ :dt | 
	            DateAndTime
		            year: dt year
		            month: dt month
		            day: dt day
		            hour: 0
		            minute: 0
		            second: 0
		            nanoSecond: 0
		            offset: dt offset ]
]

{ #category : #accessing }
DatasetAggregator >> filterBlock [

	^ filterBlock
]

{ #category : #accessing }
DatasetAggregator >> filterBlock: anObject [

	filterBlock := anObject
]

{ #category : #api }
DatasetAggregator >> hourly [

	keyBlock := [ :dt | 
	            DateAndTime
		            year: dt year
		            month: dt month
		            day: dt dayOfMonth
		            hour: dt hour
		            minute: 0
		            second: 0
		            nanoSecond: 0
		            offset: dt offset ]
]

{ #category : #initialization }
DatasetAggregator >> initialize [

	aggregation := Dictionary new.
	mappings := Dictionary new.
	keyBlock := [ :dt | dt ].
	filterBlock := [ :dt | true ]
]

{ #category : #accessing }
DatasetAggregator >> keyAspect [

	^ keyAspect
]

{ #category : #accessing }
DatasetAggregator >> keyAspect: anObject [

	keyAspect := anObject
]

{ #category : #private }
DatasetAggregator >> maxAggregationBlock [

	^ [ :bulk :outReg :key | 
	  | value |
	  value := bulk perform: key.
	  value isNumber ifTrue: [ 
		  outReg
			  at: key
			  ifPresent: [ :v | outReg at: key put: (value max: v) ]
			  ifAbsent: [ outReg at: key put: value ] ].
	  outReg ]
]

{ #category : #private }
DatasetAggregator >> minAggregationBlock [

	^ [ :bulk :outReg :key | 
	  | value |
	  value := bulk perform: key.
	  value isNumber ifTrue: [ 
		  outReg
			  at: key
			  ifPresent: [ :v | outReg at: key put: (value min: v) ]
			  ifAbsent: [ outReg at: key put: value ] ].
	  outReg ]
]

{ #category : #'api - export' }
DatasetAggregator >> reifyValues: aggregatedDataset [

	^ aggregatedDataset do: [ :each | 
		  | dict |
		  (dict := each value) keysDo: [ :key | 
			  | v |
			  (v := dict at: key) isArray ifTrue: [ 
				  dict at: key put: (v first / v last)asFloat ] ] ]
]

{ #category : #private }
DatasetAggregator >> sumAggregationBlock [

	^ [ :bulk :outReg :key | 
	  | value |
	  value := bulk perform: key.
	  value isNumber ifTrue: [ 
		  outReg
			  at: key
			  ifPresent: [ :v | outReg at: key put: value + v ]
			  ifAbsent: [ outReg at: key put: value ] ].
	  outReg ]
]
