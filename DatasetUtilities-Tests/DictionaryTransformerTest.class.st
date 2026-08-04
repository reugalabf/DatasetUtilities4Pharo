Class {
	#name : 'DictionaryTransformerTest',
	#superclass : 'TestCase',
	#category : 'DatasetUtilities-Tests',
	#package : 'DatasetUtilities-Tests'
}

{ #category : 'tests' }
DictionaryTransformerTest >> completeDataset [
^
'h1,h2,h3
2026-07-31T16:07:26,1,4
2026-07-31T17:47:26,-3,3
2026-07-31T16:47:26,-2,2
2026-07-31T17:07:26,3,3
'
]

{ #category : 'tests' }
DictionaryTransformerTest >> testNoColumnsTransformation [
"'h1,h2,h3
2026-07-31T16:07:26,1,4
2026-07-31T17:47:26,-3,3
2026-07-31T16:47:26,-2,2
2026-07-31T17:07:26,3,3
'"


	| source transformer tuple |
	source := CSV2DictionaryStream source:
		             (ReadStream on: self completeDataset).
	transformer := DictionaryTransformerStream source: source.	

	tuple :=transformer next.
	self assert: (tuple at: #h2)  equals: '1'.
	self assert: (tuple at: #h3)  equals: '4'.
	tuple :=transformer next.
	self assert: (tuple at: #h2)  equals: '-3'.
	self assert: (tuple at: #h3)  equals: '3'.

]

{ #category : 'tests' }
DictionaryTransformerTest >> testOneColumnTransformation [
"'h1,h2,h3
2026-07-31T16:07:26,1,4
2026-07-31T17:47:26,-3,3
2026-07-31T16:47:26,-2,2
2026-07-31T17:07:26,3,3
'"


	| source transformer tuple |
	source := CSV2DictionaryStream source:
		             (ReadStream on: self completeDataset).
	transformer := DictionaryTransformerStream source: source.	
	transformer addKey: #h2 transformationBlock: [ :v | Number readFrom: v ].
	tuple :=transformer next.
	self assert: (tuple at: #h2)  equals: 1.
	self assert: (tuple at: #h3)  equals: '4'.
	tuple :=transformer next.
	self assert: (tuple at: #h2)  equals: -3.
	self assert: (tuple at: #h3)  equals: '3'.

]

{ #category : 'tests' }
DictionaryTransformerTest >> testSkipTwoColumnsTransformation [
	"'h1,h2,h3
2026-07-31T16:07:26,1,4
2026-07-31T17:47:26,-3,3
2026-07-31T16:47:26,-2,2
2026-07-31T17:07:26,3,3
'"

	| source transformer tuple |
	source := CSV2DictionaryStream source: (ReadStream on: self completeDataset).
	transformer := DictionaryTransformerStream source: source.
	transformer addKey: #h2 transformationBlock: [ :v | Number readFrom: v ].
	transformer addKey: #h3 transformationBlock: [ :v | Number readFrom: v ].
	transformer skip: 1.
	tuple := transformer next.
	self assert: (tuple at: #h2) equals: -3.
	self assert: (tuple at: #h3) equals: 3.
	transformer skip: 1.
	tuple := transformer next.
	self assert: (tuple at: #h2) equals: 3.
	self assert: (tuple at: #h3) equals: 3.
	transformer skip: 2.
	self assert: transformer next isEmpty .
]

{ #category : 'tests' }
DictionaryTransformerTest >> testTwoColumnsTransformation [
"'h1,h2,h3
2026-07-31T16:07:26,1,4
2026-07-31T17:47:26,-3,3
2026-07-31T16:47:26,-2,2
2026-07-31T17:07:26,3,3
'"


	| source transformer tuple |
	source := CSV2DictionaryStream source:
		             (ReadStream on: self completeDataset).
	transformer := DictionaryTransformerStream source: source.	
	transformer addKey: #h2 transformationBlock: [ :v | Number readFrom: v ].
	transformer addKey: #h3 transformationBlock: [ :v | Number readFrom: v ].
	tuple :=transformer next.
	self assert: (tuple at: #h2)  equals: 1.
	self assert: (tuple at: #h3)  equals: 4.
	tuple :=transformer next.
	self assert: (tuple at: #h2)  equals: -3.
	self assert: (tuple at: #h3)  equals: 3.

]
