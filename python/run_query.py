import argparse
import query

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Build Naive Bayes classifier model')
    parser.add_argument('--output_file_name', type=str, help='output_file_name')
    parser.add_argument('--query_string', type=str, help='query_string')
    args = parser.parse_args()
    query.ask_query_titles_properties(args.query_string, args.output_file_name)
