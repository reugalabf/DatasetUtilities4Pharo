"
This class makes it possible to join two different datasets as implemented by class DatasetView.
"
Class {
	#name : #DatasetJoiner,
	#superclass : #Object,
	#instVars : [
		'dsView1',
		'dsView2',
		'result',
		'header'
	],
	#category : #DatasetUtilities
}

{ #category : #private }
DatasetJoiner >> csvHeaderOf: join [

	^ join anyOne value keys
]

{ #category : #initialization }
DatasetJoiner >> dsView1: view1 dsView2: view2 [

	dsView1 := view1.
	dsView2 := view2
]

{ #category : #initialization }
DatasetJoiner >> initialize [

	result := Dictionary new.
	^ self
]

{ #category : #API }
DatasetJoiner >> join [

	| kStream |
	kStream := dsView1 keyStream.
	[ kStream atEnd ] whileFalse: [ 
		|each record |
		each:= kStream next.
		record := Dictionary new.
		record at: 'key' put: each printString.
		dsView1 recordAt: each on: record.
		dsView2 recordAt: each on: record.
		result at: each put: record ].
	^result
]

{ #category : #API }
DatasetJoiner >> joinAsCsv [

	| outputStream |
	outputStream := WriteStream on: String new.
	self joinAsCsvOn: outputStream.
	^ outputStream contents
]

{ #category : #API }
DatasetJoiner >> joinAsCsvOn: outputStream [

	| writer join |
	join := self join.
	writer := NeoCSVWriter on: outputStream.
	writer nextPut: (self csvHeaderOf: join). "#( date rain )"

	writer nextPutAll: join
]

{ #category : #API }
DatasetJoiner >> joinAsJson [

	| outputStream |
	outputStream := WriteStream on: String new.

	outputStream nextPutAll: (NeoJSONWriter toStringPretty:
			 (self join inject: OrderedCollection new into: [ :col :each | 
				  col
					  add: each value;
					  yourself ])).
	^ outputStream contents
]

{ #category : #API }
DatasetJoiner >> joinAsJsonOn: outputStream [

	outputStream nextPutAll: (NeoJSONWriter toStringPretty:
			 (self join inject: OrderedCollection new into: [ :col :each | 
				  col
					  add: each value;
					  yourself ]))
]
