Class {
	#name : #CSV2JSONStream,
	#superclass : #CSV2ObjectStream,
	#category : #DatasetUtilities
}

{ #category : #'as yet unclassified' }
CSV2JSONStream >> convertFromDictionaries: records [

	^ NeoJSONWriter toStringPretty: records
]

{ #category : #'as yet unclassified' }
CSV2JSONStream >> convertFromDictionary: record [

	^ NeoJSONWriter toStringPretty: record
]
