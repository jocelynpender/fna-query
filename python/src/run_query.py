# Run this file in your terminal like this: python -m src.run_query --output_file_name "file_name.csv" --query_string
# "[[Query::here]]"

import argparse
from src.query import *

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run an Ask query against the FNA Beta API')
    parser.add_argument('--output_file_name', type=str, help='output_file_name')
    parser.add_argument('--query_string', type=str, help='query_string')
    args = parser.parse_args()
    ask_query(args.query_string, args.output_file_name)
