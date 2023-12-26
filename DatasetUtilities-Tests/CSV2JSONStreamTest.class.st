Class {
	#name : #CSV2JSONStreamTest,
	#superclass : #TestCase,
	#category : #'DatasetUtilities-Tests'
}

{ #category : #tests }
CSV2JSONStreamTest >> completeDataset [
^
'h1,h2,h3
a1,b1,c1
a2,b2,c2
a3,b3,c3'
]

{ #category : #tests }
CSV2JSONStreamTest >> incompleteDataset1 [
^
'h1,h2,h3
a1,b1,
a2,b2,c2
a3,b3,c3'
]

{ #category : #tests }
CSV2JSONStreamTest >> incompleteDataset2 [
^
'h1,h2,h3
a1,,c1
a2,b2,c2
a3,b3,c3'
]

{ #category : #tests }
CSV2JSONStreamTest >> testCompleteDataset [

	| converter |
	converter := CSV2JSONStream source:
		             (ReadStream on: self completeDataset).
	self should: [converter headers size = 3].
	self should:[ (NeoJSONReader on: converter next readStream)next size = 3 ]
]

{ #category : #tests }
CSV2JSONStreamTest >> testinCompleteDataset1 [

	| converter |
	converter := CSV2JSONStream source:
		             (ReadStream on: self incompleteDataset1).
	self should: [ converter headers size = 3 ].
	self should: [ 
		(NeoJSONReader on: converter next readStream) next size = 3 ]
]

{ #category : #tests }
CSV2JSONStreamTest >> testinCompleteDataset2 [

	| converter |
	converter := CSV2JSONStream source:
		             (ReadStream on: self incompleteDataset2).
	self should: [ converter headers size = 3 ].
	self should: [ 
		(NeoJSONReader on: converter next readStream) next size = 3 ]
]
