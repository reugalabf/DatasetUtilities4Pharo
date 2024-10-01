Class {
	#name : #DictionaryAggregator,
	#superclass : #DatasetAggregator,
	#category : #DatasetUtilities
}

{ #category : #private }
DictionaryAggregator >> computeValueOf: aSymbol from: bulk [

	^ bulk at: aSymbol
]
