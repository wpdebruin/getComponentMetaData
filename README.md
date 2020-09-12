Demonstrating inconsistent behaviour of getComponentMetaData

We ran into this issue because coldbox was generating errors but not reporting filenames and line numbers on syntax errors

Finally it seems getComponentMetaData is not reporting filename and line number of syntax errors (which is used a lot by wirebox).
I discovered this erratic behaviour only occurs when the opening { of a component definition is not on the same line as the component keyword itself.

This sample code demonstrates both cases. InvalidComponent and InvalidComponentWithoutDetails only differ in the first two lines.
