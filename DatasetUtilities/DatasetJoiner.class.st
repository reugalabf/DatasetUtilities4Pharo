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

{ #category : #initialization }
DatasetJoiner >> initialize [

	result := Dictionary new.
	^ self
]

{ #category : #'as yet unclassified' }
DatasetJoiner >> join [

	| kStream |
	kStream := dsView1 keyStream.
	[ kStream atEnd ] whileFalse: [ :each | 
		| record |
		record := Dictionary new.
		record at: 'key' put: each printString.
		dsView1 recordAt: each on: record.
		dsView2 recordAt: each on: record.
		result at: each put: record ]
]
