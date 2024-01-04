package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
	"os"
)

var rootCmd = &cobra.Command{
	Use:   "aicc",
	Short: "ai content creation tools (aka aicc)",
	Long: `ai content creation tools (aka aicc) is a CLI for creating content
			`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("aicc called")
	},
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.AddCommand(lineRecordingCmd)
}
