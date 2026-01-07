Extension { #name : 'NeoCSVReader' }

{ #category : '*DatasetUtilities' }
NeoCSVReader >> readUnquotedField [

	| field |
	(self atEnd or: [ self peekSeparator or: [ self peekEndOfLine ] ])
		ifTrue: [ ^ emptyFieldValue ].
	field := self stringStreamContents: [ :stream |
			         [
			         self atEnd or: [
				         self peekSeparator or: [ self peekEndOfLine ] ] ]
				         whileFalse: [ stream nextPut: self nextChar ] ].
	^ field isEmpty
		  ifTrue: [ emptyFieldValue ]
		  ifFalse: [
				  [ field asNumber ]
					  on: Error
					  do: [ :ex | field ] ]
]
