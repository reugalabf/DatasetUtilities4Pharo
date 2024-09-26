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
	converter := CSV2DictionaryStream source:
		             (ReadStream on: self incompleteDataset1).
		self halt.
	self should: [ converter headers size = 3 ].
	self should: [ converter next  size = 3 ]
]

{ #category : #tests }
CSV2ObjectStreamTest >> testDictionaryStreamCompleteDataset1FilteredHeads [

	| converter ws headers |
	converter := CSV2DictionaryStream source:
		             (ReadStream on: self incompleteDataset1).
	converter filteredHeaders: #( 'h1' 'h3' 'h2' ).
	self should: [ converter headers size = 3 ].
	ws := WriteStream on: String new.

	converter exportContentsAsCSVOn: ws.
	headers := (NeoCSVReader on: ws contents readStream) next.
	self should: [ (headers at: 1) = 'h1' ].
	self should: [ (headers at: 2) = 'h3' ].
	self should: [ (headers at: 3) = 'h2' ]
]

{ #category : #tests }
CSV2ObjectStreamTest >> testDictionaryStreamCompleteDataset1FilteredWrongHead [

	| converter ws |
	ws := WriteStream on: String new.
	converter := CSV2DictionaryStream source:
		             (ReadStream on: self incompleteDataset1).
	converter filteredHeaders: #( 'h1' 'h3' 'qq' ).
	self should: [ converter exportContentsAsCSVOn: ws ] raise: Error
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
CSV2ObjectStreamTest >> testDictionaryStreamContentsCompleteDataset2 [

	| converter |
	converter := CSV2DictionaryStream source:
		             (ReadStream on: self incompleteDataset2).
	self should: [ converter headers size = 3 ].
	self should: [ converter contents size = 3 ]
]

{ #category : #tests }
CSV2ObjectStreamTest >> testDictionaryStreamFilteredCompleteDataset1 [

	| converter |
	converter := CSV2DictionaryStream source:
		             (ReadStream on: self incompleteDataset2).
		converter keyColumn: 'h2' filterBlock: [:cell| cell notNil]. 
	self should: [ converter headers size = 3 ].
	"self should: [ converter next size = 3 ].
	self should: [ converter next isNil ]."
	self should: [converter contents size = 2].
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
CSV2ObjectStreamTest >> testJsonSchemaStreamContentsCompleteDataset1 [

	| converter |
	converter := CSV2JSONSchemaStream source:
		             (ReadStream on: self incompleteDataset1).
	self should: [ converter headers size = 3 ].

	self should: [ converter contents size = 3 ]


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

{ #category : #tests }
CSV2ObjectStreamTest >> testJsonStreamContentsCompleteDataset1 [

	| converter json |
	converter := CSV2JSONStream source:
		             (ReadStream on: self incompleteDataset1).
	self should: [ converter headers size = 3 ].

	json := converter contents.



	self should: [ (NeoJSONReader on: json readStream) next notNil ]
]
