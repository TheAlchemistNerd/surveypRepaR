# surveypRepaR

[![R-CMD-check](https://github.com/TheAlchemistNerd/surveypRepaR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/YOUR_USERNAME/surveypRepaR/actions/workflows/R-CMD-check.yaml)

> An R package for efficient survey data cleaning. `surveypRepaR` transforms raw survey data from Excel files into analysis-ready SPSS (.sav) files.

## Overview

Researchers often face the tedious task of cleaning raw survey data before analysis can begin. This process involves correcting column names, handling different data types, and ensuring the data is properly labeled. `surveypRepaR` is an R package designed to automate this workflow, providing a seamless bridge from raw data collection in Excel to a clean, labeled dataset ready for analysis in SPSS or R.

The package is built to handle common cleaning tasks with a single function call, saving time and reducing the potential for manual errors.

## Features

- **Excel to SPSS Pipeline**: Directly reads `.xlsx` files and outputs analysis-ready `.sav` files.
- **Smart Name Cleaning**: Cleans column names using `janitor::clean_names()` and then shortens them to SPSS-compatible formats (`q1`, `q2`, etc.).
- **Data Tidying**: Automatically trims whitespace from character columns and removes completely empty rows or columns.
- **Automatic Factor Conversion**: Intelligently detects categorical variables based on the number of unique values and converts them to factors with appropriate levels.
- **Variable Labeling**: Preserves the original survey questions (the original column names) as variable labels in the final SPSS file, ensuring data context is not lost.
- **Dependency Management**: Checks for, installs, and loads all required packages automatically.

## Installation

This package is not yet on CRAN. You can install the development version from GitHub with:

```r
# install.packages("remotes")
remotes::install_github("TheAlchemistNerd/surveypRepaR")
```

## Usage

The primary function of the package is `clean_survey_data()`. It orchestrates the entire cleaning pipeline.

Here is a basic example of how to use the package:

```r
# 1. Load the package
library(surveypRepaR)

# 2. Define the file paths for your input and output files
input_file <- "path/to/your/Survey Responses.xlsx"
output_file <- "path/to/your/Survey_Responses_Cleaned.sav"

# 3. Run the main cleaning function
# This will read the Excel file, clean it, and save the result as an SPSS file.
clean_survey_data(
  input_file_path = input_file,
  output_file_path = output_file,
  categorical_threshold = 10 # Optional: Max unique values to be considered a factor
)

# The cleaned data is also returned invisibly if you wish to assign it to a variable:
# cleaned_df <- clean_survey_data(...)
```

## The Cleaning Workflow

The `clean_survey_data()` function performs the following steps in sequence:

1.  **Install and Load Packages**: Ensures all dependencies like `readxl`, `dplyr`, `janitor`, `haven`, and `labelled` are available.
2.  **Read Survey Data**: Loads the data from the specified Excel file.
3.  **Clean and Shorten Names**: Tidies the data and creates short, SPSS-friendly column names. The original names are stored for use as labels.
4.  **Detect and Convert Factors**: Analyzes each column and converts categorical variables into factors.
5.  **Attach Variable Labels**: Applies the original, descriptive column names as variable labels to the new, shortened columns.
6.  **Save Cleaned Data**: Exports the final, polished data frame to an SPSS (`.sav`) file, preserving the factor levels and variable labels.

## Contributing

Contributions are welcome! If you have suggestions for improvements or find a bug, please feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License.
