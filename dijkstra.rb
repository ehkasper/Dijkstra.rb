file = File.new "file.csv", "r"

while (row = file.gets)
	columns = row.split(";")
	columns = columns.map { |column| column.strip }
	print columns
end

file.close

