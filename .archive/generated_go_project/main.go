package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"strings"
)

// Config holds application configuration
type Config struct {
	Verbose bool
}

// App represents the CSV processor application
type App struct {
	config Config
}

// NewApp creates a new App instance
func NewApp(verbose bool) *App {
	return &App{
		config: Config{
			Verbose: verbose,
		},
	}
}

// ProcessCSV reads input CSV, transforms records, and writes output
func (app *App) ProcessCSV(inputPath, outputPath string) (int, error) {
	// Open input file
	inputFile, err := os.Open(inputPath)
	if err != nil {
		return 0, fmt.Errorf("failed to open input file '%s': %w", inputPath, err)
	}
	defer inputFile.Close()

	// Create output file
	outputFile, err := os.Create(outputPath)
	if err != nil {
		return 0, fmt.Errorf("failed to create output file '%s': %w", outputPath, err)
	}
	defer outputFile.Close()

	// Setup CSV readers and writers
	reader := csv.NewReader(inputFile)
	writer := csv.NewWriter(outputFile)
	
	// Configure reader (adjust as needed)
	reader.FieldsPerRecord = -1  // Allow variable fields
	reader.LazyQuotes = true     // Allow flexible quotes
	reader.TrimLeadingSpace = true

	var lineCount int

	for {
		// Read record
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Printf("Warning: error reading line %d: %v", lineCount+1, err)
			continue
		}

		// TODO: Implement custom transformation logic
		transformed := app.transformRecord(record)

		// Write transformed record
		if err := writer.Write(transformed); err != nil {
			return lineCount, fmt.Errorf("failed to write record: %w", err)
		}

		lineCount++
	}

	// Flush any buffered data
	writer.Flush()
	if err := writer.Error(); err != nil {
		return lineCount, fmt.Errorf("failed to flush output: %w", err)
	}

	return lineCount, nil
}

// transformRecord applies transformation to a single CSV record
func (app *App) transformRecord(record []string) []string {
	transformed := make([]string, len(record))
	for i, field := range record {
		// TODO: Customize transformation logic here
		// Currently implements uppercase transformation
		transformed[i] = strings.ToUpper(strings.TrimSpace(field))
	}
	return transformed
}

// run executes the main application logic
func (app *App) run(inputPath, outputPath string) error {
	// Validate input file exists
	if _, err := os.Stat(inputPath); os.IsNotExist(err) {
		return fmt.Errorf("input file '%s' not found", inputPath)
	}

	// Process CSV
	count, err := app.ProcessCSV(inputPath, outputPath)
	if err != nil {
		return err
	}

	// Output results
	if app.config.Verbose {
		fmt.Printf("Successfully processed %d lines\n", count)
		fmt.Printf("Input:  %s\n", filepath.Clean(inputPath))
		fmt.Printf("Output: %s\n", filepath.Clean(outputPath))
	} else {
		fmt.Printf("Processed %d lines\n", count)
	}

	return nil
}

func main() {
	// TODO: Parse command line arguments
	// For now, hardcode example values
	inputPath := "input.csv"
	outputPath := "output.csv"
	verbose := false

	app := NewApp(verbose)

	if err := app.run(inputPath, outputPath); err != nil {
		log.Fatalf("Error: %v", err)
		os.Exit(1)
	}

	os.Exit(0)
}
