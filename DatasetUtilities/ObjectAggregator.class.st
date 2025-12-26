Class {
	#name : 'ObjectAggregator',
	#superclass : 'DatasetAggregator',
	#category : 'DatasetUtilities',
	#package : 'DatasetUtilities'
}

{ #category : 'private' }
ObjectAggregator >> computeValueOf: aSymbol from: bulk [

	^ bulk perform: aSymbol
]
