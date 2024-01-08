Class {
	#name : #CSV2JSONSchemaStream,
	#superclass : #CSV2ObjectStream,
	#instVars : [
		'schema'
	],
	#category : #DatasetUtilities
}

{ #category : #'stream protocol' }
CSV2JSONSchemaStream >> convertFromDictionaries: records [

	^ (NeoJSONReader on:
		   (NeoJSONWriter toStringPretty: records) readStream) nextListAs:
		  schema
]

{ #category : #'stream protocol' }
CSV2JSONSchemaStream >> convertFromDictionary: record [

	| json |
	json := NeoJSONWriter toStringPretty: record.
	^ (NeoJSONReader on: json readStream) nextAs: schema
]

{ #category : #'stream protocol' }
CSV2JSONSchemaStream >> nextListAs: schema [

	"	| record row |
	row := sourceStream next.
	record := Dictionary new.
	1 to: headers size do: [ :idx | 
	record at: (headers at: idx) asSymbol put: (row at: idx) ].
	^ NeoJSONWriter toStringPretty: record"

	| col reader |
	col := OrderedCollection new.
	reader := NeoJSONReader on: sourceStream.
	[ self atEnd ] whileFalse: [ col addLast: (self nextAs: schema) ].
	^ col
]

{ #category : #accessing }
CSV2JSONSchemaStream >> schema: anObject [

	schema := anObject
]
