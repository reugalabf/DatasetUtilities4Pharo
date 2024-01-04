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

{ #category : #'as yet unclassified' }
DatasetJoiner >> csvHeaderOf: join [

	^ join anyOne value keys
]

{ #category : #'as yet unclassified' }
DatasetJoiner >> dsView1: view1 dsView2: view2 [

	dsView1 := view1.
	dsView2 := view2
]

{ #category : #initialization }
DatasetJoiner >> initialize [

	result := Dictionary new.
	^ self
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
DatasetJoiner >> joinAsCsv [

	| outputStream |
	outputStream := WriteStream on: String new.
	self joinAsCsvOn: outputStream.
	^ outputStream contents
]

{ #category : #'as yet unclassified' }
DatasetJoiner >> joinAsCsvOn: outputStream [


	| writer join|
	join:= self join.
	writer := NeoCSVWriter on: outputStream.
	writer nextPut: (self csvHeaderOf:join). "#( date rain )"
	"writer addObjectFields: #( key ).
	self configureCSVFieldsOn: writer.
	"
	writer nextPutAll: (join)
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
DatasetJoiner >> joinAsJsonOn: outputStream [

	outputStream nextPutAll: (NeoJSONWriter toStringPretty:
			 (self join inject: OrderedCollection new into: [ :col :each | 
				  col
					  add: each value;
					  yourself ]))
]
