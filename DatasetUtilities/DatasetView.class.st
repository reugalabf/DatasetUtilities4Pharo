"
This class is a decorator on top of Dictionary to be used by DatasetJoiner.
"
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

	source
		detect: [ :each | key = (keyBlock value: each) ]
		ifFound: [ :record | 
			columns do: [ :each | 
				aDictionary at: name , '.' , each put: (record at: each) ] ]
]
