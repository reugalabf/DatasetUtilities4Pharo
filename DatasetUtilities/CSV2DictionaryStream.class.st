Class {
	#name : #CSV2DictionaryStream,
	#superclass : #CSV2ObjectStream,
	#category : #DatasetUtilities
}

{ #category : #'stream protocol' }
CSV2DictionaryStream >> convertFromDictionaries: records [

	^ records
]

{ #category : #'as yet unclassified' }
CSV2DictionaryStream >> convertFromDictionary: record [

	^ record
]

{ #category : #'as yet unclassified' }
CSV2DictionaryStream >> exportContentsAsCSVOn: writeStream [

	| writer |
	writer := NeoCSVWriter on: writeStream.
	writer nextPut: (headers select:[:each| filteredHeaders includes: each]). 
	[ self atEnd ] whileFalse: [ writer nextPut: self next values ].

]
