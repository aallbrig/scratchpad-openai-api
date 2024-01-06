package main

import (
	"aicontentcreationtools/cmd"
	"aicontentcreationtools/pkg/recordingStudio"
	_ "embed"
)

var (
	//go:embed schemas/line-reading-input-file.schema.json
	lineReadInputSchemaJson string
)

func init() {
	// inject embed schema for use in cmd
	recordingStudio.LineReadingSchemaJson = lineReadInputSchemaJson
}
func main() {
	cmd.Execute()
}
