Class {
	#name : 'DictionaryTransformerStream',
	#superclass : 'Object',
	#instVars : [
		'source',
		'transformerBlocks'
	],
	#category : 'DatasetUtilities',
	#package : 'DatasetUtilities'
}

{ #category : 'accessing' }
DictionaryTransformerStream class >> source: dictionaryStream [

	^ self new
		  source: dictionaryStream;
		  yourself
]

{ #category : 'adding' }
DictionaryTransformerStream >> addKey: aSymbol transformationBlock: aBlock [

	transformerBlocks at: aSymbol put: aBlock
]

{ #category : 'initialization' }
DictionaryTransformerStream >> initialize [

	transformerBlocks := Dictionary new.
	^self
]

{ #category : 'accessing' }
DictionaryTransformerStream >> next [

	^ self transform: source next on: Dictionary new
]

{ #category : 'accessing' }
DictionaryTransformerStream >> skip: anIntenger [

	source skip: anIntenger
]

{ #category : 'accessing' }
DictionaryTransformerStream >> source: dictionaryStream [

	source := dictionaryStream
]

{ #category : 'accessing' }
DictionaryTransformerStream >> transform: sourceDict on: resultDict [

	sourceDict ifNotNil: [ :obj |
			obj keysAndValuesDo: [ :key :datum |
					transformerBlocks
						at: key
						ifPresent: [ :block | resultDict at: key put: (block value: datum) ]
						ifAbsent: [ resultDict at: key put: datum ] ] ].
	^ resultDict
]
