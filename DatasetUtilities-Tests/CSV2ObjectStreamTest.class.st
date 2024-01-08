Class {
	#name : #CSV2ObjectStreamTest,
	#superclass : #TestCase,
	#category : #'DatasetUtilities-Tests'
}

{ #category : #tests }
CSV2ObjectStreamTest >> completeDataset [
^
'h1,h2,h3
a1,b1,c1
a2,b2,c2
a3,b3,c3'
]

{ #category : #tests }
CSV2ObjectStreamTest >> incompleteDataset1 [
^
'h1,h2,h3
a1,b1,
a2,b2,c2
a3,b3,c3'
]

{ #category : #tests }
CSV2ObjectStreamTest >> incompleteDataset2 [
^
'h1,h2,h3
a1,,c1
a2,b2,c2
a3,b3,c3'
]

{ #category : #tests }
CSV2ObjectStreamTest >> testDictionaryStreamCompleteDataset1 [

	| converter |
	
	converter := CSV2DictionaryStream  source:
		             (ReadStream on: self incompleteDataset1).
	self should: [ converter headers size = 3 ].
	self should:[ (converter halt next) size = 3 ]
]

{ #category : #tests }
CSV2ObjectStreamTest >> testDictionaryStreamCompleteDataset2 [

	| converter |
	converter := CSV2DictionaryStream  source:
		             (ReadStream on: self incompleteDataset2).
	self should: [ converter headers size = 3 ].
	self should:[ (converter next) size = 3 ]
]

{ #category : #tests }
CSV2ObjectStreamTest >> testDictionaryStreamWithCompleteDataset [

	| converter |
	converter := CSV2DictionaryStream source:
		             (ReadStream on: self completeDataset).
	self should: [converter headers size = 3].
	self should:[ (converter next) size = 3 ]
]

{ #category : #tests }
CSV2ObjectStreamTest >> testJsonSchemaStreamCompleteDataset1 [

	| converter |
	converter := CSV2JSONSchemaStream source:
		             (ReadStream on: self incompleteDataset1).
	self should: [ converter headers size = 3 ].

	self should: [ converter next size = 3 ]
]

{ #category : #tests }
CSV2ObjectStreamTest >> testJsonStreamCompleteDataset1 [

	| converter |
	converter := CSV2JSONStream source:
		             (ReadStream on: self incompleteDataset1).
	self should: [ converter headers size = 3 ].

	self should: [ 
		(NeoJSONReader on: converter next readStream) next notNil ].
	self should: [ 
		(NeoJSONReader on: converter next readStream) next notNil ].
	self should: [ 
		(NeoJSONReader on: converter next readStream) next notNil ].
	self should: [ converter next isNil ]
]
