Class {
	#name : #DatasetAggregator,
	#superclass : #Object,
	#instVars : [
		'aggregation',
		'mappings',
		'keyBlock'
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

{ #category : #api }
DatasetAggregator >> aggregate: bulkCollection [

	"| result |
	bulkCollection do: [ :each | 
		| key |
		key := keyBlock value: each when.
		self applyMappingsTo: each key: key ].

	result := SortedCollection sortBlock: [ :a :b | a key < b key ].
	aggregation associationsDo: [ :each | 
		each value at: #when put: each key printString.
		result add: each ].


	^ result"

	^ self reifyValues:
		  (self aggregateStream: (ReadStream on: bulkCollection))
]

{ #category : #api }
DatasetAggregator >> aggregate: bulkCollection do: aBlock [

	(self aggregate: bulkCollection) do: aBlock
]

{ #category : #'api - export' }
DatasetAggregator >> aggregateCSV: bulkCollection [

	^ String streamContents: [ :stream | 
		  | writer |
		  writer := NeoCSVWriter on: stream.
		  writer nextPut: self csvHeader. "#( date rain )"
		  writer addObjectFields: #( key ).
		  self configureCSVFieldsOn: writer.
		  writer nextPutAll: (self aggregate: bulkCollection) ]
]

{ #category : #'api - export' }
DatasetAggregator >> aggregateJSON: bulkCollection [

	^ String streamContents: [ :stream | 
		  stream nextPutAll:
			  (NeoJSONWriter toStringPretty: ((self aggregate: bulkCollection)
					    inject: OrderedCollection new
					    into: [ :col :each | 
						    col
							    add: each value;
							    yourself ])) ]
]

{ #category : #api }
DatasetAggregator >> aggregateStream: readStream [

	| result |
	[ readStream atEnd ] whileFalse: [ 
		| each key |
		each := readStream next.
		key := keyBlock value: each when.
		self applyMappingsTo: each key: key ].

	result := SortedCollection sortBlock: [ :a :b | a key < b key ].
	aggregation associationsDo: [ :each | 
		each value at: #when put: each key printString.
		result add: each ].

	^ result
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
	  outReg
		  at: key
		  ifPresent: [ :v | 
			  outReg at: key put: (v
					   at: 1 put: (v at: 1) + value;
					   at: 2 put: (v at: 2) + 1;
					   yourself) ]
		  ifAbsent: [ 
			  outReg at: key put: { 
					  value.
					  1 } ].
	  outReg ]
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
			| obj |
			obj := dict value at: k asSymbol.
			obj isArray
				ifTrue: [ (obj first / obj second) asFloat ]
				ifFalse: [ obj ] ] ]
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
	keyBlock := [ :dt | ^ dt ]
]

{ #category : #private }
DatasetAggregator >> maxAggregationBlock [
^[ :bulk :outReg :key | 
		| value |
		value := bulk perform: key.
		outReg
			at: key
			ifPresent: [ :v | outReg at: key put: (value max: v) ]
			ifAbsent: [ outReg at: key put: value ].
		outReg ]
]

{ #category : #private }
DatasetAggregator >> minAggregationBlock [
^[ :bulk :outReg :key | 
		| value |
		value := bulk perform: key.
		outReg
			at: key
			ifPresent: [ :v | outReg at: key put: (value min: v) ]
			ifAbsent: [ outReg at: key put: value ].
		outReg ]
]

{ #category : #'api - export' }
DatasetAggregator >> reifyValues: aggregatedDataset [

	^ aggregatedDataset do: [ :each | 
		  | dict |
		  (dict := each value) keysDo: [ :key | 
			  | v |
			  (v := dict at: key) isArray ifTrue: [ 
				  dict at: key put: v first / v last ] ] ]
]

{ #category : #private }
DatasetAggregator >> sumAggregationBlock [
^[ :bulk :outReg :key | 
		| value |
		value := bulk perform: key.
		outReg
			at: key
			ifPresent: [ :v | outReg at: key put: value + v ]
			ifAbsent: [ outReg at: key put: value ].
		outReg ]
]
