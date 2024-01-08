Class {
	#name : #CSV2ObjectStream,
	#superclass : #Object,
	#instVars : [
		'sourceStream',
		'headers',
		'filterAssociation'
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

	| col reader |
	col := OrderedCollection new.
	reader := NeoJSONReader on: sourceStream.
	[ self atEnd ] whileFalse: [ col addLast: self next ].
	^ col
]

{ #category : #'stream protocol' }
CSV2ObjectStream >> convertFromDictionary: record [

	^ self subclassResponsibility
]

{ #category : #accessing }
CSV2ObjectStream >> filterBlock: anObject [

	filterAssociation := anObject
]

{ #category : #accessing }
CSV2ObjectStream >> headers [

	^ headers
]

{ #category : #'stream protocol' }
CSV2ObjectStream >> next [

	| record row |
	sourceStream atEnd ifTrue: [ ^ nil ].
	row := sourceStream next.
	record := Dictionary new.
	1 to: headers size do: [ :idx | 
	record at: (headers at: idx) asSymbol put: (row at: idx) ].
	^ self convertFromDictionary: record
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
