util      = require 'util'
fs        = require 'fs'
cheerio 	= require 'cheerio'
escaper 	= require 'true-html-escape'
exec      = (require 'child_process').exec
file      = 'test'


# pdfParser.on "pdfParser_dataReady", (res) ->
# 	fs.writeFile 'dataAll.out', res.data.Pages[0], (err) ->
# 		if !err? then console.log 'Saved' 
# 		else console.log err
# 	text = res.data.Pages[0].Texts
# 	text = (decodeURIComponent item.R[0].T for item in text)
# 	data = 
# 		'Date Received': text[14]
# 		'Account #': text[7]
# 		'Lot #': text[9]
# 		'Settlement #': text[10]
# 		'Net weight received': text[18] + ' Ozs. Troy ' + text[23]
# 		'After processing weight': text[20] + ' Ozs. Troy'
# 		# 'Gold Total': text[]
# 		# 'Silver Total': text[]
# 		# 'Platinum Total': text[]
# 		# 'Palladium Total': text[]
# 	console.log data

# pdfParser.on "pdfParser_dataError", ->

#pdfParser.loadPDF file

last = exec "pdftohtml -p -noframes -i #{file}.pdf", (error, stdout, stderr) ->
    # console.log 'stdout: ' + stdout
    # console.log 'stderr: ' + stderr
    # if error isnt null
    #   console.log 'exec error: ' + error
last.stdout.on 'data', (data) ->  
	fs.readFile "#{file}.html", (err, html) -> 
		$ = cheerio.load html.toString()
		html = (escaper.unescape $('body').html()).replace(/<br>/g, '').replace(/<b>/g, '').replace(/<\/b>/g, '')
		arr = html.split('\n')
		data = {}
		data['Total Less Charge'] = 0
		parse arr, i, data for line, i in arr
		console.log data

parse = (arr, i, data) -> 
	line = arr[i]
	if line[0] is '$' and line[line.length-1] is '*' then data['Total Less Charge'] += Number line.slice 1, -1
	switch line
		when 'Date Received:' 					then data['Date Received'] 						= arr[i+1]
		when 'Account # :' 							then data['Account #'] 								= arr[i+1]
		when 'Lot # :' 									then data['Lot #'] 										= arr[i+1]
		when 'Settlement # :' 					then data['Settlement #'] 						= arr[i+1]
		when 'Net Weight Received:'			then data['Net Weight Received'] 			= arr[i+1] + ' ' + arr[i+2]
		when 'After Processing Weight:'	then data['After Processing Weight']	= arr[i+1]
		when 'Gold Total:'							then data['Gold Total']								= joinTotal arr, i+1
		when 'Silver Total:'						then data['Silver Total']							= joinTotal arr, i+1
		when 'Platinum Total:'					then data['Platinum Total']						= joinTotal arr, i+1
		when 'Palladium Total'					then data['Palladium Total']					= joinTotal arr, i+1
joinTotal = (arr, i) ->
	total = arr[i].slice(0, -2) + arr[i+1] + '%'
