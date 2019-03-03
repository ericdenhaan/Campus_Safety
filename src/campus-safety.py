#----------------------------------------------------------------------------------------------
#   CPSC 4310 Project
#   campus-safety.py
#   Written By: Eric Den Haan
#----------------------------------------------------------------------------------------------

import csv, os

# Find the input csv locations, set the output location
os.chdir('../data/format-1')
csv_dir_format_1 = os.getcwd()
os.chdir('../format-2')
csv_dir_format_2 = os.getcwd()
os.chdir('../')
csv_output_dir = os.getcwd()
csv_output_location = 'combined.csv'

# csv header formats
csv_header_format_1 = 'Survey year,Unitid,Institution name,Campus ID,Campus Name,Institution Size,Illegal weapons possession,Drug law violations,Liquor law violations'
csv_header_format_2 = 'Survey year,Unitid,Institution name,Campus ID,Campus Name,Institution Size,Murder/Non-negligent manslaughter,Negligent manslaughter,Robbery,Aggravated assault,Burglary,Motor vehicle theft,Arson'

# Read and merge csv files
def csv_merge(format_dir, format_header):
	dir_tree = os.walk(format_dir)
	for dirpath, dirnames, filenames in dir_tree:
	   pass

	os.chdir(format_dir)
	csv_list_1 = []
	for file in filenames:
	   if file.endswith('.csv') and file != csv_output_location:
	      csv_list_1.append(file)

	csv_merge = open(csv_output_location, 'w')
	csv_merge.write(format_header)
	csv_merge.write('\n')

	for file in csv_list_1:
	   csv_in = open(file)
	   for index, line in enumerate(csv_in):
	      if index == 0:
	         continue
	      csv_merge.write(line)
	   csv_in.close()

csv_merge(csv_dir_format_1, csv_header_format_1)
print('Merged csv files of first format')
csv_merge(csv_dir_format_2, csv_header_format_2)
print('Merged csv files of second format')

