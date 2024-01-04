Class {
	#name : #DatasetJoiner,
	#superclass : #Object,
	#instVars : [
		'dsView1',
		'dsView2',
		'result'
	],
	#category : #DatasetUtilities
}

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
