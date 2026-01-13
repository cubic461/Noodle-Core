package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"os"
	"strings"
)

// ProcessCSV processes a CSV file by uppercasing all text
// Args:
//
//	inputPath: Path to input CSV file
//	outputPath: Path to output CSV file
//
// Returns:
//
//	Number of lines processed
func ProcessCSV(inputPath string, outputPath string) (int, error) {
	// Read input file
	file, err := os.Open(inputPath)
	if err != nil {
		return 0, fmt.Errorf("error opening input file: %v", err)
	}
	defer file.Close()

	// Create CSV reader
	reader := csv.NewReader(file)
	reader.FieldsPerRecord = -1 // Allow variable number of fields

	// Read all records
	records, err := reader.ReadAll()
	if err != nil {
		return 0, fmt.Errorf("error reading CSV: %v", err)
	}

	lineCount := 0

	// Uppercase all text in records
	for i, record := range records {
		for j, field := range record {
			records[i][j] = strings.ToUpper(field)
		}
		lineCount++
	}

	// Create output file
	outFile, err := os.Create(outputPath)
	if err != nil {
		return 0, fmt.Errorf("error creating output file: %v", err)
	}
	defer outFile.Close()

	// Write processed records
	writer := csv.NewWriter(outFile)
	defer writer.Flush()

	err = writer.WriteAll(records)
	if err != nil {
		return 0, fmt.Errorf("error writing CSV: %v", err)
	}

	return lineCount, nil
}

func main() {
	// Define flags following Go CLI best practices
	var verbose bool
	var inputFile, outputFile string

	flag.StringVar(&inputFile, "input", "input.csv", "Input CSV file")
	flag.StringVar(&inputFile, "i", "input.csv", "Input CSV file (short)")

	flag.StringVar(&outputFile, "output", "output.csv", "Output CSV file")
	flag.StringVar(&outputFile, "o", "output.csv", "Output CSV file (short)")

	flag.BoolVar(&verbose, "v", false, "Verbose output")
	flag.BoolVar(&verbose, "verbose", false, "Verbose output")

	flag.Parse()

	// Check if positional args are provided (compatibility with original CLI)
	args := flag.Args()
	if len(args) > 0 {
		inputFile = args[0]
	}
	if len(args) > 1 {
		outputFile = args[1]
	}

	// Process CSV
	count, err := ProcessCSV(inputFile, outputFile)

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	if verbose {
		fmt.Printf("Successfully processed %d lines\n", count)
		fmt.Printf("Input:  %s\n", inputFile)
		fmt.Printf("Output: %s\n", outputFile)
	} else {
		fmt.Printf("Processed %d lines\n", count)
	}

	os.Exit(0)
}
