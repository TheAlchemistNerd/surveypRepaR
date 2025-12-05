# data_cleaning_functions.R

#' Install and Load Required Packages
#'
#' Checks if necessary packages are installed and loads them. If a package is missing, it attempts to install it.
#' @keywords internal
install_and_load_packages <- function() {
  pkgs <- c("readxl", "dplyr", "janitor", "haven", "labelled")
  
  # Function to install missing packages
  install_missing <- function(p) {
    if (!requireNamespace(p, quietly = TRUE)) {
      install.packages(p, dependencies = TRUE)
    }
    library(p, character.only = TRUE)
  }
  
  invisible(lapply(pkgs, install_missing))
}

#' Read Survey Data from an Excel File
#'
#' Reads survey data from a specified Excel file into a data frame.
#' @param file_path A string, the path to the Excel file.
#' @return A data frame containing the raw survey data.
#' @import readxl
#' @export
read_survey_data <- function(file_path) {
  if (!file.exists(file_path)) {
    stop(paste("Error: File not found at", file_path))
  }
  read_excel(file_path)
}

#' Clean and Shorten Column Names
#'
#' Cleans column names using `janitor::clean_names()` and shortens them to 'q1', 'q2', etc.
#' It also trims whitespace from all character columns, filters out empty rows, and removes
#' columns that are entirely NA.
#' @param df_raw A data frame, the raw survey data.
#' @return A data frame with cleaned and shortened column names, and initial data cleaning applied.
#' @import dplyr janitor
#' @export
clean_and_shorten_names <- function(df_raw) {
  df_clean <- df_raw %>%
    # Trim whitespace from all character columns
    mutate(across(where(is.character), ~trimws(as.character(.)))) %>%
    # Filter out rows where all values are empty or NA
    filter(if_any(everything(), ~ . != "" & !is.na(.))) %>%
    # Remove columns that are entirely NA
    select(where(~!all(is.na(.))))
  
  # Save original names for labelling before renaming
  original_labels <- names(df_clean)
  
  # Generate short names: q1, q2, ...
  short_names <- paste0("q", seq_along(df_clean))
  names(df_clean) <- short_names
  
  attr(df_clean, "original_labels") <- original_labels
  return(df_clean)
}

#' Detect and Convert Categorical Variables to Factors
#'
#' Dynamically detects categorical variables based on a unique value threshold
#' and converts them to factors.
#' @param df A data frame.
#' @param threshold An integer, the maximum number of unique values for a column
#'   to be considered categorical and converted to a factor.
#' @return A data frame with identified categorical columns converted to factors.
#' @import dplyr
#' @export
detect_and_convert_to_factors <- function(df, threshold = 10) {
  df %>%
    mutate(across(everything(), ~ {
      x <- as.character(.)
      if(length(unique(na.omit(x))) <= threshold) {
        factor(x, levels = unique(x))
      } else {
        .
      }
    }))
}

#' Attach Original Survey Questions as Variable Labels
#'
#' Attaches the original column names (survey questions) as variable labels
#' to the cleaned data frame.
#' @param df A data frame.
#' @param original_labels A character vector, the original column names from the raw data.
#' @return A data frame with variable labels attached.
#' @import labelled
#' @export
attach_variable_labels <- function(df, original_labels) {
  if (length(original_labels) != ncol(df)) {
    warning("Number of original labels does not match number of columns in cleaned data. Labels may be misaligned.")
  }
  for (i in seq_along(df)) {
    if (i <= length(original_labels)) {
      var_label(df[[i]]) <- original_labels[i]
    } else {
      var_label(df[[i]]) <- names(df)[i] # Fallback to column name if no original label
    }
  }
  return(df)
}

#' Save Cleaned Data as SPSS File
#'
#' Saves the cleaned data frame to an SPSS (.sav) file, preserving variable labels.
#' @param df A data frame, the cleaned data.
#' @param output_file_path A string, the path where the SPSS file will be saved.
#' @import haven
#' @export
save_cleaned_data_as_spss <- function(df, output_file_path) {
  write_sav(df, output_file_path)
  message(paste("Cleaning done! File saved as '", output_file_path, "' with factors and labels.", sep=""))
}


#' Main Function to Clean Survey Data
#'
#' This function orchestrates the entire survey data cleaning process:
#' reading an Excel file, cleaning and shortening column names, dynamically
#' detecting and converting categorical variables, attaching original survey
#' questions as variable labels, and saving the result as an SPSS file.
#'
#' @param input_file_path A string, the path to the input Excel file
#'   containing survey responses.
#' @param output_file_path A string, the path where the cleaned data will be
#'   saved as an SPSS (.sav) file.
#' @param categorical_threshold An integer, the maximum number of unique values
#'   for a column to be considered categorical and converted to a factor.
#'   Defaults to 10.
#' @return A data frame containing the cleaned survey data (invisibly).
#' @import readxl dplyr janitor haven labelled
#' @export
clean_survey_data <- function(input_file_path, output_file_path, categorical_threshold = 10) {
  
  install_and_load_packages() # Ensure all packages are loaded
  
  message(paste("Starting data cleaning process for: ", input_file_path))
  
  # 1. Read Excel file
  df_raw <- read_survey_data(input_file_path)
  
  # 2. Clean names & shorten for SPSS, and get original labels
  df_cleaned_intermediate <- clean_and_shorten_names(df_raw)
  original_labels <- attr(df_cleaned_intermediate, "original_labels")
  df_clean <- df_cleaned_intermediate
  attr(df_clean, "original_labels") <- NULL # Remove attribute before further processing
  
  # 3. Dynamically detect categorical variables and convert to factors
  df_clean <- detect_and_convert_to_factors(df_clean, categorical_threshold)
  
  # 4. Attach original survey questions as variable labels
  df_clean <- attach_variable_labels(df_clean, original_labels)
  
  # 5. Save cleaned data into SPSS file with labels
  save_cleaned_data_as_spss(df_clean, output_file_path)
  
  invisible(df_clean)
}

# Example Usage (will be removed or commented out in final package)
# Assuming 'Survey Responses.xlsx' is in the current working directory
# clean_survey_data(
#   input_file_path = "Survey Responses.xlsx",
#   output_file_path = "Survey_Responses_Cleaned_Package.sav",
#   categorical_threshold = 7
# )
