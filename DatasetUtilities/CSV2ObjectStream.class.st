Class {
	#name : #CSV2ObjectStream,
	#superclass : #Object,
	#instVars : [
		'sourceStream',
		'headers',
		'filterBlock',
		'keyIndex',
		'filteredHeaders'
	],
	#category : #DatasetUtilities
}

{ #category : #accessing }
CSV2ObjectStream class >> source: readStream [

	^ self new
		  sourceStream: readStream;
		  yourself
]

{ #category : #'stream protocol' }
CSV2ObjectStream >> atEnd [

	^ sourceStream atEnd
]

{ #category : #'stream protocol' }
CSV2ObjectStream >> contents [

	| col |
	col := OrderedCollection new.

	[ self atEnd ] whileFalse: [ col addLast: self next ].
	^ self convertFromDictionaries: col
]

{ #category : #'stream protocol' }
CSV2ObjectStream >> convertFromDictionaries: records [

	^ self subclassResponsibility
]

{ #category : #'stream protocol' }
CSV2ObjectStream >> convertFromDictionary: record [

	^ self subclassResponsibility
]

{ #category : #accessing }
CSV2ObjectStream >> filteredHeaders: anObject [

	filteredHeaders := anObject
]

{ #category : #accessing }
CSV2ObjectStream >> headers [

	^ headers
]

{ #category : #initialization }
CSV2ObjectStream >> initialize [

	keyIndex := 0.
	filterBlock:=[:row| true]
]

{ #category : #accessing }
CSV2ObjectStream >> keyColumn: aString filterBlock: aBlock [

	keyIndex := headers indexOf: aString.
	filterBlock := aBlock
]

{ #category : #'stream protocol' }
CSV2ObjectStream >> next [

	| record row |
	sourceStream atEnd ifTrue: [ ^ nil ].
	row := self nextFilteredRow.
	row ifNil: [ ^ nil ].
	record := Dictionary new.

	1 to: headers size do: [ :idx | 
		(filteredHeaders notNil and: [ 
			 filteredHeaders includes: (headers at: idx) ]) ifTrue: [ 
			record at: (headers at: idx) asSymbol put: (row at: idx) ] ].
	^ self convertFromDictionary: record
]

{ #category : #'stream protocol' }
CSV2ObjectStream >> nextFilteredRow [

	| row |
	row := nil.
	[ sourceStream atEnd or: [ row notNil ] ] whileFalse: [ 
		row := self valueFilterBlockWithRow: sourceStream next ].
	^ row
]

{ #category : #accessing }
CSV2ObjectStream >> sourceStream [

	^ sourceStream
]

{ #category : #accessing }
CSV2ObjectStream >> sourceStream: anObject [

	sourceStream isNil
		ifTrue: [ 
			sourceStream := NeoCSVReader on:anObject.
			headers := sourceStream readHeader ]
		ifFalse: [ self error: 'Changing source is not allowed' ]
]

{ #category : #'stream protocol' }
CSV2ObjectStream >> valueFilterBlockWithRow: aRow [

	^ (keyIndex = 0 or: [ filterBlock value: (aRow at: keyIndex) ])
		  ifTrue: [ aRow ]
		  ifFalse: [ nil ]
]
