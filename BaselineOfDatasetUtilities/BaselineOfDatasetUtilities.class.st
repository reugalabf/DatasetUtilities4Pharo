Class {
	#name : 'BaselineOfDatasetUtilities',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfDatasetUtilities',
	#package : 'BaselineOfDatasetUtilities'
}

{ #category : 'baselines' }
BaselineOfDatasetUtilities >> baseline: spec [

	<baseline>
	spec for: #common do: [
			self
				neoBaselines: spec;
				ztimestampBaseline: spec.
			spec
				package: #DatasetUtilities 
				with: [ spec requires: #( 'NeoJSON' 'NeoJSON' 'ZTimestamp' ) ];
				package: #'DatasetUtilities-Tests' 
				with: [ spec requires: #( 'DatasetUtilities' ) ].
			spec
				group: 'Core' with: #( 'DatasetUtilities' );
				group: 'Tests' with: #( 'DatasetUtilities-Tests' );
				group: 'default' with: #( 'Core' 'Tests' ) ]
]

{ #category : 'utilities' }
BaselineOfDatasetUtilities >> neoBaselines: spec [

	spec
		baseline: 'NeoJSON'
		with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].

	spec
		baseline: 'NeoCSV'
		with: [ spec repository: 'github://svenvc/NeoCSV/repository' ]
]

{ #category : 'utilities' }
BaselineOfDatasetUtilities >> ztimestampBaseline: spec [

	spec baseline: 'ZTimestamp' with: [ 
		spec
			loads: #( 'common' );
			repository: 'https://github.com/svenvc/ztimestamp.git' ]
]
