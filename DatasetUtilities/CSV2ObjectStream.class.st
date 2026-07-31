"
Classes that takes a CSV file and tranform it to Dictionary, JSON or Domain Object (JSONSchema)
"
Class {
	#name : 'CSV2ObjectStream',
	#superclass : 'Object',
	#instVars : [
		'sourceStream',
		'headers',
		'filterBlock',
		'keyIndex',
		'filteredHeaders',
		'recordReifyBlock'
	],
	#category : 'DatasetUtilities',
	#package : 'DatasetUtilities'
}

{ #category : 'accessing' }
CSV2ObjectStream class >> source: readStream [

	^ self new
		  sourceStream: readStream;
		  yourself
]

{ #category : 'accessing' }
CSV2ObjectStream class >> source: readStream filteredHeaders: array [

	^ self new
		  sourceStream: readStream;
		  filteredHeaders: array;
		  yourself
]

{ #category : 'accessing' }
CSV2ObjectStream class >> source: readStream filteredHeaders: array recordReifyBlock: aBlock [

	^ self new
		  sourceStream: readStream;
		  filteredHeaders: array;
		  recordReifyBlock: aBlock;
		  yourself
]

{ #category : 'stream protocol' }
CSV2ObjectStream >> atEnd [

	^ sourceStream atEnd
]

{ #category : 'stream protocol' }
CSV2ObjectStream >> contents [

	| col |
	col := OrderedCollection new.

	[ self atEnd ] whileFalse: [ col addLast: self next ].
	^ self convertFromDictionaries: col
]

{ #category : 'stream protocol' }
CSV2ObjectStream >> convertFromDictionaries: records [

	^ self subclassResponsibility
]

{ #category : 'stream protocol' }
CSV2ObjectStream >> convertFromDictionary: record [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
CSV2ObjectStream >> filteredHeaders: anObject [

	filteredHeaders := anObject
]

{ #category : 'accessing' }
CSV2ObjectStream >> headers [

	^ headers
]

{ #category : 'initialization' }
CSV2ObjectStream >> initialize [

	keyIndex := 0.
	filterBlock := [ :row | true ].
	filteredHeaders := Array new.
	recordReifyBlock := [ :record | record ]
]

{ #category : 'accessing' }
CSV2ObjectStream >> keyColumn: aString filterBlock: aBlock [

	keyIndex := headers indexOf: aString.
	filterBlock := aBlock
]

{ #category : 'stream protocol' }
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


	^ self convertFromDictionary: (recordReifyBlock value: record)
]

{ #category : 'private' }
CSV2ObjectStream >> nextFilteredRow [

	| row |
	row := nil.
	[ sourceStream atEnd or: [ row notNil ] ] whileFalse: [ 
		row := self valueFilterBlockWithRow: sourceStream next ].
	^ row
]

{ #category : 'private' }
CSV2ObjectStream >> nextRaw [

	sourceStream atEnd ifTrue: [ ^ nil ].
	^ self nextFilteredRow
]

{ #category : 'accessing' }
CSV2ObjectStream >> recordReifyBlock: anObject [

	recordReifyBlock := anObject
]

{ #category : 'stream protocol' }
CSV2ObjectStream >> skip: integer [

	self assert: [ integer >= 0 ].
	integer timesRepeat: [
			self atEnd
				ifFalse: [ self nextRaw ]
				ifTrue: [ ^ false ] ].
	^ true
]

{ #category : 'accessing' }
CSV2ObjectStream >> sourceStream [

	^ sourceStream
]

{ #category : 'accessing' }
CSV2ObjectStream >> sourceStream: anObject [

	sourceStream
		ifNil: [
				sourceStream := NeoCSVReader on: anObject.
				filteredHeaders := headers := sourceStream readHeader ]
		ifNotNil: [ self error: 'Changing source is not allowed' ]
]

{ #category : 'private' }
CSV2ObjectStream >> valueFilterBlockWithRow: aRow [

	^ (keyIndex = 0 or: [ filterBlock value: (aRow at: keyIndex) ]) ifTrue: [ aRow ]
]
