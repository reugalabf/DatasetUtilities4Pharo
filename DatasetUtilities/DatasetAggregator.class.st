"
Class operates over a collection of Domain Objects

it can aggregate data hourly or daily
it can also create new columns based on a given function implemented by a Block
"
Class {
	#name : #DatasetAggregator,
	#superclass : #Object,
	#instVars : [
		'aggregation',
		'mappings',
		'blockMappings',
		'keyBlock',
		'keyAspect',
		'filterBlock'
	],
	#category : #DatasetUtilities
}

{ #category : #api }
DatasetAggregator >> addAverageMappingFor: aSymbol [

	self addAverageMappingFor: aSymbol as: aSymbol
]

{ #category : #api }
DatasetAggregator >> addAverageMappingFor: aSymbol as: anotherSymbol [

	mappings
		at: aSymbol -> anotherSymbol
		put: self averageAggregationBlock
]

{ #category : #api }
DatasetAggregator >> addBlockMapping: aBlock as: aSymbol [

	blockMappings 
		at: aSymbol -> aSymbol
		put: (self blockAggregationBlockWith: aBlock)
]

{ #category : #api }
DatasetAggregator >> addDateMappingFor: aSymbol [

	self addDateMappingFor: aSymbol as: #Date
]

{ #category : #api }
DatasetAggregator >> addDateMappingFor: aSymbol as: anotherSymbol [

	mappings at: aSymbol -> anotherSymbol put: self dateSplitBlock
]

{ #category : #api }
DatasetAggregator >> addMaxMappingFor: aSymbol [

	self addMaxMappingFor: aSymbol as: aSymbol
]

{ #category : #api }
DatasetAggregator >> addMaxMappingFor: aSymbol as: anotherSymbol [

	mappings at: aSymbol -> anotherSymbol put: self maxAggregationBlock
]

{ #category : #api }
DatasetAggregator >> addMinMappingFor: aSymbol [

	self addMinMappingFor: aSymbol as: aSymbol
]

{ #category : #api }
DatasetAggregator >> addMinMappingFor: aSymbol as: anotherSymbol [

	mappings at: aSymbol -> anotherSymbol put: self minAggregationBlock
]

{ #category : #api }
DatasetAggregator >> addSumMappingFor: aSymbol [

	self addSumMappingFor: aSymbol as: aSymbol
]

{ #category : #api }
DatasetAggregator >> addSumMappingFor: aSymbol as: anotherSymbol [

	mappings at: aSymbol -> anotherSymbol put: self sumAggregationBlock
]

{ #category : #api }
DatasetAggregator >> addTimeMappingFor: aSymbol [

	self addTimeMappingFor: aSymbol as: #Time
]

{ #category : #api }
DatasetAggregator >> addTimeMappingFor: aSymbol as: anotherSymbol [

	mappings at: aSymbol -> anotherSymbol put: self timeSplitBlock
]

{ #category : #accessing }
DatasetAggregator >> afterDateandTime: dt [

	^ self filterBlock: [ :key | 
		  key > dt ]
]

{ #category : #api }
DatasetAggregator >> aggregate: bulkCollection [

	^ self reifyValues:
		  (self  aggregateFromStream: (ReadStream on: bulkCollection))
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
		key := keyBlock value: (self computeValueOf: keyAspect  from: each).
		(filterBlock value: key) ifTrue: [ 
			self applyMappingsTo: each key: key ] ].

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
DatasetAggregator >> applyBlockMappingsTo: row key: key [

	blockMappings  keysAndValuesDo: [ :k :map | 
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

	^ [ :bulk :outReg :assocKey | 
	  | value |
	  value := self computeValueOf: assocKey key asSymbol from: bulk.
	  value isNumber ifTrue: [ 
		  outReg
			  at: assocKey value
			  ifPresent: [ :v | 
				  v ifNotNil: [ 
					  outReg at: assocKey value put: (v
							   at: 1 put: (v at: 1) + value;
							   at: 2 put: (v at: 2) + 1;
							   yourself) ] ]
			  ifAbsent: [ 
				  value ifNotNil: [ 
					  outReg at: assocKey value put: { 
							  value.
							  1 } ] ] ].
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
DatasetAggregator >> blockAggregationBlockWith: aBlock [

	^ [ :bulk :outReg :assocKey | 
	  outReg at: assocKey value put: (aBlock value: bulk).
	  outReg ]
]

{ #category : #private }
DatasetAggregator >> collateAggregationBlock [

	^ [ :bulk :outReg :assocKey | 
	  | value |
	  value := self computeValueOf: assocKey key asSymbol from: bulk.
	  outReg
		  at: assocKey value
		  ifPresent: [ :v | outReg at: assocKey put: v , ' ' , value ]
		  ifAbsent: [ outReg at: assocKey put: value ].
	  outReg ]
]

{ #category : #private }
DatasetAggregator >> computeValueOf: aSymbol from: bulk [

	^ self subclassResponsibility
]

{ #category : #'api - export' }
DatasetAggregator >> configureCSVFieldsOn: writer [

	mappings keysDo: [ :assocKey | 
		writer addObjectField: [ :dict | 
			dict value at: assocKey key asSymbol ifAbsent: nil
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
	header addAll: self keys.
	^ header
]

{ #category : #'api - frequency' }
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

{ #category : #private }
DatasetAggregator >> dateSplitBlock [

	^ [ :bulk :outReg :assocKey | 
	  | value |
	  value := self computeValueOf: assocKey key asSymbol from: bulk.
	  value class = DateAndTime ifTrue: [ 
		  outReg at: assocKey value put: value asDate.
		  outReg ] ]
]

{ #category : #accessing }
DatasetAggregator >> filterBlock [

	^ filterBlock
]

{ #category : #accessing }
DatasetAggregator >> filterBlock: anObject [

	filterBlock := anObject
]

{ #category : #'api - frequency' }
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
	blockMappings := Dictionary new.
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

{ #category : #'api - export' }
DatasetAggregator >> keys [

	^ mappings keys collect: [ :each | each value ]
]

{ #category : #private }
DatasetAggregator >> maxAggregationBlock [

	^ [ :bulk :outReg :assocKey | 
	  | value |
	  value := self computeValueOf: assocKey key asSymbol from: bulk.
	  value isNumber ifTrue: [ 
		  outReg
			  at: assocKey value
			  ifPresent: [ :v | outReg at: assocKey value  put: (value max: v) ]
			  ifAbsent: [ outReg at: assocKey value put: value ] ].
	  outReg ]
]

{ #category : #private }
DatasetAggregator >> minAggregationBlock [

	^ [ :bulk :outReg :assocKey | 
	  | value |
	  value := self computeValueOf: assocKey key asSymbol from: bulk.
	  value isNumber ifTrue: [ 
		  outReg
			  at: assocKey value
			  ifPresent: [ :v | outReg at: assocKey value put: (value min: v) ]
			  ifAbsent: [ outReg at: assocKey value put: value ] ].
	  outReg ]
]

{ #category : #private }
DatasetAggregator >> reifyValues: aggregatedDataset [

	^ aggregatedDataset do: [ :each | 
		  | dict |
		  (dict := each value) keysDo: [ :key | 
			  | v |
			  (v := dict at: key) isArray ifTrue: [ 
				  dict at: key put: (v first / v last round: 1) asFloat ] ].

		  self applyBlockMappingsTo: each value key: each key ]
]

{ #category : #private }
DatasetAggregator >> sumAggregationBlock [

	^ [ :bulk :outReg :assocKey | 
	  | value |
	  value := self computeValueOf: assocKey key asSymbol from: bulk.
	  value isNumber ifTrue: [ 
		  outReg
			  at: assocKey value
			  ifPresent: [ :v | outReg at: assocKey value put: value + v ]
			  ifAbsent: [ outReg at: assocKey value put: value ] ].
	  outReg ]
]

{ #category : #private }
DatasetAggregator >> timeSplitBlock [

	^ [ :bulk :outReg :assocKey | 
	  | value |
	  value := self computeValueOf: assocKey key asSymbol from: bulk.
	  value class = DateAndTime ifTrue: [ 
		  outReg at: assocKey value put: value asTime.
		  outReg ] ]
]

{ #category : #'api - export' }
DatasetAggregator >> valueAt: aSymbol from: aRow [

	^ aRow at: (self keys indexOf: aSymbol)
]
