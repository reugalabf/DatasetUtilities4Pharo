Class {
	#name : #CSV2JSONStream,
	#superclass : #CSV2ObjectStream,
	#category : 'DatasetUtilities'
}

{ #category : #'stream protocol' }
CSV2JSONStream >> convertFromDictionaries: records [

	^ NeoJSONWriter toStringPretty: records
]

{ #category : #'stream protocol' }
CSV2JSONStream >> convertFromDictionary: record [

	^ NeoJSONWriter toStringPretty: record
]
