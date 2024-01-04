package main

import (
	"aicontentcreationtools/cmd"
	_ "embed"
)

var (
	//go:embed schemas/line-reading-input-file.schema.json
	lineReadInputSchemaJson string
)

func init() {
	// inject embed schema for use in cmd
	cmd.LineReadingSchemaJson = lineReadInputSchemaJson
}
func main() {
	cmd.Execute()
}
