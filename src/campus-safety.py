#----------------------------------------------------------------------------------------------
#   CPSC 4310 Project
#   campus-safety.py
#   Written By: Eric Den Haan
#----------------------------------------------------------------------------------------------

import csv, os

#----------------------------------------------------------------------------------------------
# Global Variables
#----------------------------------------------------------------------------------------------

csv_header_format_1 = 'Survey year,Unitid,Institution name,Campus ID,Campus Name,Institution Size,Illegal weapons possession,Drug law violations,Liquor law violations'
csv_header_format_2 = 'Survey year,Unitid,Institution name,Campus ID,Campus Name,Institution Size,Murder/Non-negligent manslaughter,Negligent manslaughter,Robbery,Aggravated assault,Burglary,Motor vehicle theft,Arson'
csv_header_format_3 = 'Institution name,Murder/Non-negligent manslaughter,Negligent manslaughter,Robbery,Aggravated assault,Burglary,Motor vehicle theft,Arson,Illegal weapons possession,Drug law violations,Liquor law violations'
institutions = ['University of California-San Diego', 'California State University-Long Beach', 'California State University-Northridge', 'University of California-Los Angeles']

#----------------------------------------------------------------------------------------------
# Methods
#----------------------------------------------------------------------------------------------

# Get the sum of a column for a given year/institution in a csv file
def sum_row(file, inst, mode):
	sum_list = [inst, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	if(mode == 1 or mode == 2):
		sum_list[0] += ' - Subtotal'
	for line in file:
		splitLine = line.split(',')
		if(mode == 1 or mode ==2):
			if(splitLine[2] == inst):
				if(mode == 1):
					sum_list[8] += int(splitLine[6])
					sum_list[9] += int(splitLine[7])
					sum_list[10] += int(splitLine[8])
				if(mode == 2):
					sum_list[1] += int(splitLine[6])
					sum_list[2] += int(splitLine[7])
					sum_list[3] += int(splitLine[8])
					sum_list[4] += int(splitLine[9])
					sum_list[5] += int(splitLine[10])
					sum_list[6] += int(splitLine[11])				
					sum_list[7] += int(splitLine[12])
		if(mode == 3):
			if(splitLine[0] == inst + ' - Subtotal'):
				sum_list[1] += int(splitLine[1])
				sum_list[2] += int(splitLine[2])
				sum_list[3] += int(splitLine[3])
				sum_list[4] += int(splitLine[4])
				sum_list[5] += int(splitLine[5])
				sum_list[6] += int(splitLine[6])				
				sum_list[7] += int(splitLine[7])
				sum_list[8] += int(splitLine[8])
				sum_list[9] += int(splitLine[9])
				sum_list[10] += int(splitLine[10])

	for index, sum in enumerate(sum_list):
		sum_list[index] = str(sum_list[index])
	return sum_list

# Get the sums for csv files
def csv_sum(format_dir, mode):
	os.chdir(format_dir)
	if(mode == 1 or mode == 2):
		for inst in institutions:
			csv_merge = open(csv_output_location, 'r+w')
			sum_list = sum_row(csv_merge, inst, mode)
			csv_merge.write(','.join(sum_list))
			csv_merge.write('\n')
	if(mode == 3):
		for inst in institutions:
			csv_merge = open('master.csv', 'r+w')
			sum_list = sum_row(csv_merge, inst, mode)
			csv_merge.write(','.join(sum_list))
			csv_merge.write('\n')

# Read and merge similar csv files
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

# Create the master csv
def create_master():
	os.chdir(csv_dir_format_1)
	combined_1 = open(csv_output_location, 'r')
	os.chdir(csv_dir_format_2)
	combined_2 = open(csv_output_location, 'r')
	os.chdir(csv_output_dir)
	master_csv = open('master.csv', 'w')
	master_csv.write(csv_header_format_3)
	master_csv.write('\n')
	for line in combined_1:
		splitLine = line.split(',')
		for inst in institutions:
			if(splitLine[0] == inst + ' - Subtotal'):
				master_csv.write(line)
	for line in combined_2:
		splitLine = line.split(',')
		for inst in institutions:
			if(splitLine[0] == inst + ' - Subtotal'):
				master_csv.write(line)

#----------------------------------------------------------------------------------------------
# Script
#----------------------------------------------------------------------------------------------

# Ask the user which institution to analyze
print('Which institution would you like to analyze?')
print('1 = University of California-San Diego')
print('2 = California State University-Long Beach')
print('3 = California State University-Northridge')
print('4 = University of California-Los Angeles')
institutionNum = 0
while(institutionNum < 1 or institutionNum > 4):
  	institutionNum = input('Please make a choice: ')

if(institutionNum == 1):
	institutionName = 'University of California-San Diego'
elif(institutionNum == 2):
	institutionName = 'California State University-Long Beach'
elif(institutionNum == 3):
	institutionName = 'California State University-Northridge'
elif(institutionNum == 4):
	institutionName = 'University of California-Los Angeles'

# Find the input csv locations, set the output location
os.chdir('../data/format-1')
csv_dir_format_1 = os.getcwd()
os.chdir('../format-2')
csv_dir_format_2 = os.getcwd()
os.chdir('../')
csv_output_dir = os.getcwd()
csv_output_location = 'combined.csv'

# Merge the csv files of format type 1
csv_merge(csv_dir_format_1, csv_header_format_1)
csv_sum(csv_dir_format_1, 1)
print('Merged csv files of first format')

# Merge the csv files of format type 2
csv_merge(csv_dir_format_2, csv_header_format_2)
csv_sum(csv_dir_format_2, 2)
print('Merged csv files of second format')

# Create the master csv file
create_master()
csv_sum(csv_output_dir, 3)
print('Master csv file created')

# Execute the csv to xml xslt script using saxon
os.chdir(csv_output_dir)
os.system('java -cp ../lib/saxon9he.jar net.sf.saxon.Transform -o:master-csv.xml -it:main ../lib/csv-to-xml_v2.xslt pathToCSV=../data/master.csv')
print('Translation from csv to xml complete')

# Execute the xslt transform to get the final xml document
os.chdir('../src')
xsltString = 'java -cp ../lib/saxon9he.jar net.sf.saxon.Transform -s:../data/master-csv.xml -xsl:./master-transform.xslt -o:../data/master-csv-transformed.xml institutionName="' + institutionName + '"'
os.system(xsltString)
print('Finished xslt transformations')

# Generate the large itemsets for the apriori algorithm
os.system('java -cp ../lib/BaseX912.jar org.basex.BaseX -o ../data/large-itemsets-paper.xml ./apriori-paper.xquery')
os.system('java -cp ../lib/BaseX912.jar org.basex.BaseX -o ../data/large-itemsets.xml ./apriori-1.xquery')
print('Large itemsets computed')

# Generate the association rules
os.system('java -cp ../lib/BaseX912.jar org.basex.BaseX -o ../data/rules-paper.xml ./assoc-rules-paper.xquery')
os.system('java -cp ../lib/BaseX912.jar org.basex.BaseX -o ../data/rules.xml ./assoc-rules.xquery')
print('Association rules computed')