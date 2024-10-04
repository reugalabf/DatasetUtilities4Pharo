"
Classes that takes a CSV file and tranform it to Dictionary, JSON or Domain Object (JSONSchema)
"
Class {
	#name : #CSV2ObjectStream,
	#superclass : #Object,
	#instVars : [
		'sourceStream',
		'headers',
		'filterBlock',
		'keyIndex',
		'filteredHeaders',
		'recordReifyBlock'
	],
	#category : #DatasetUtilities
}

{ #category : #accessing }
CSV2ObjectStream class >> source: readStream [

	^ self new
		  sourceStream: readStream;
		  yourself
]

{ #category : #accessing }
CSV2ObjectStream class >> source: readStream filteredHeaders: array [

	^ self new
		  sourceStream: readStream;
		  filteredHeaders: array;
		  yourself
]

{ #category : #accessing }
CSV2ObjectStream class >> source: readStream filteredHeaders: array recordReifyBlock: aBlock [

	^ self new
		  sourceStream: readStream;
		  filteredHeaders: array;
		  recordReifyBlock: aBlock;
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
	filterBlock := [ :row | true ].
	filteredHeaders := Array new.
	recordReifyBlock := [ :record | record ]
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

	filteredHeaders do: [ :each | 
		(headers includes: each)
			ifFalse: [ self error: 'Missing header' ]
			ifTrue: [ 
			record at: each asSymbol put: (row at: (headers indexOf: each)) ] ].


	"	1 to: headers size do: [ :idx | 
		(filteredHeaders isNil or: [ 
			 filteredHeaders includes: (headers at: idx) ])
			ifFalse: [ self error: 'Missing header' ]
			ifTrue: [ record at: (headers at: idx) asSymbol put: (row at: idx) ] ]."
	^ self convertFromDictionary: (recordReifyBlock  value: record)
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
CSV2ObjectStream >> recordReifyBlock: anObject [

	recordReifyBlock := anObject
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
			filteredHeaders := headers := sourceStream readHeader ]
		ifFalse: [ self error: 'Changing source is not allowed' ]
]

{ #category : #'stream protocol' }
CSV2ObjectStream >> valueFilterBlockWithRow: aRow [

	^ (keyIndex = 0 or: [ filterBlock value: (aRow at: keyIndex) ])
		  ifTrue: [ aRow ]
		  ifFalse: [ nil ]
]
