Class {
	#name : #DatasetView,
	#superclass : #Object,
	#instVars : [
		'name',
		'keyBlock',
		'columns',
		'source'
	],
	#category : #DatasetUtilities
}

{ #category : #'instance creation' }
DatasetView class >> name: aString source: dict keyBlock: aBlock [

	^ self new
		  name: aString source: dict keyBlock: aBlock;
		  yourself
]

{ #category : #accessing }
DatasetView >> columns [

	^ columns
]

{ #category : #accessing }
DatasetView >> columns: anObject [

	columns := anObject
]

{ #category : #accessing }
DatasetView >> keyStream [

	^ (source collect: [ :each | keyBlock value: each ]) readStream
]

{ #category : #initialize }
DatasetView >> name: aString source: dict keyBlock: aBlock [

	name := aString.
	source := dict.
	keyBlock := aBlock
]

{ #category : #accessing }
DatasetView >> recordAt: key on: aDictionary [

	| record |
	record := source detect: [ :each | key =( keyBlock value: each) ]. " it needs to get one entry for the key!!!!"

	columns do: [ :each | 
		aDictionary at: name , '.' , each put: (record at: each) ]
]
