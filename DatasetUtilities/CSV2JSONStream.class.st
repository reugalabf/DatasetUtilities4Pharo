Class {
	#name : #CSV2JSONStream,
	#superclass : #Object,
	#instVars : [
		'sourceStream',
		'headers'
	],
	#category : #DatasetUtilities
}

{ #category : #accessing }
CSV2JSONStream class >> source: readStream [

	^ self new
		  sourceStream: readStream;
		  yourself
]

{ #category : #'stream protocol' }
CSV2JSONStream >> atEnd [

	^ sourceStream atEnd
]

{ #category : #accessing }
CSV2JSONStream >> headers [

	^ headers
]

{ #category : #'stream protocol' }
CSV2JSONStream >> next [

	| record row |
	row := sourceStream next.
	record := Dictionary new.
	1 to: headers size do: [ :idx | 
	record at: (headers at: idx) asSymbol put: (row at: idx) ].
	^ NeoJSONWriter toStringPretty: record
]

{ #category : #accessing }
CSV2JSONStream >> sourceStream [

	^ sourceStream
]

{ #category : #accessing }
CSV2JSONStream >> sourceStream: anObject [

	sourceStream isNil
		ifTrue: [ 
			sourceStream := NeoCSVReader on:anObject.
			headers := sourceStream readHeader ]
		ifFalse: [ self error: 'Changing source is not allowed' ]
]
