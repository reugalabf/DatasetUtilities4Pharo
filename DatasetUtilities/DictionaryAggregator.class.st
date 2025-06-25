Class {
	#name : #DictionaryAggregator,
	#superclass : #DatasetAggregator,
	#category : #DatasetUtilities
}

{ #category : #private }
DictionaryAggregator >> computeValueOf: aSymbol from: bulk [

	^ aSymbol = keyAspect
		  ifTrue: [ 
			  | value |
			  value := bulk at: aSymbol.
			  value isString
				  ifTrue: [ DateAndTime fromString: value ]
				  ifFalse: [ value ] ]
		  ifFalse: [ bulk at: aSymbol ]
]
