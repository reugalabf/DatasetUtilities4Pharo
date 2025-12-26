Class {
	#name : 'CSV2DictionaryStream',
	#superclass : 'CSV2ObjectStream',
	#category : 'DatasetUtilities',
	#package : 'DatasetUtilities'
}

{ #category : 'stream protocol' }
CSV2DictionaryStream >> convertFromDictionaries: records [

	^ records
]

{ #category : 'stream protocol' }
CSV2DictionaryStream >> convertFromDictionary: record [

	^ record
]

{ #category : 'stream protocol' }
CSV2DictionaryStream >> exportContentsAsCSVOn: writeStream [

	| writer |
	writer := NeoCSVWriter on: writeStream.
	writer nextPut: filteredHeaders. "(headers select:[:each| filteredHeaders includes: each])"
	[ self atEnd ] whileFalse: [ 
		| record next |
		next := self next.
		record := Array new: filteredHeaders size.
		filteredHeaders do: [ :each | 
			| idx |
			idx := filteredHeaders indexOf: each.
			record at: idx put: (next at: each) ].
		writer nextPut: record ]
]
