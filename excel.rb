require 'rubygems'
require 'sinatra'
require 'json'
require 'tempfile'
require 'jxl.jar'
require 'base64'


Rack::Utils.key_space_limit = 999999999999999

set :logging, true
set :dump_errors, true
set :raise_errors, false


DATE_COL=0
DESCRIPTION_COL=1
CLIENT_COL=2
CATEGORY_COL=3
TOTAL_COL=5

EXPENSE_START_ROW = 13

NAME_COL = 1
NAME_ROW = 9

SIGNATURE_COL = 1
SIGNATURE_ROW = 23

post '/excel' do 
  expense = JSON.parse(request.body.read)
  
  writeable_workbook = nil
  begin
    template = java.io.File.new("finance_template.xls")
    temp_file =	java.io.File.createTempFile(java.lang.String.valueOf(java.lang.System.currentTimeMillis()), ".xls")
    temp_file.deleteOnExit()
    workbook = Java::jxl.Workbook.getWorkbook(template)
    writeable_workbook =  Java::jxl.Workbook.createWorkbook(temp_file, workbook)
    sheet = writeable_workbook.getSheet(0)
    name_label = Java::jxl.write.Label.new(NAME_COL, NAME_ROW, "John Smith")
	  sheet.addCell(name_label)
	
    expense["receipts"].each_with_index do |receipt, i|
      date_label = Java::jxl.write.Label.new(DATE_COL, EXPENSE_START_ROW + i, receipt["date"])
      description_label = Java::jxl.write.Label.new(DESCRIPTION_COL, EXPENSE_START_ROW + i, receipt["description"])
      category_label = Java::jxl.write.Label.new(CATEGORY_COL, EXPENSE_START_ROW + i, receipt["category"])
      client_label = Java::jxl.write.Label.new(CLIENT_COL, EXPENSE_START_ROW + i, receipt["client"])
    
      amount_in_dollars = receipt["amount_in_cents"] ? receipt["amount_in_cents"].to_f/100 : receipt["amountInCents"].to_f/100
      amount_number = Java::jxl.write.Number.new(TOTAL_COL, EXPENSE_START_ROW + i, amount_in_dollars)
      
      sheet.addCell(date_label)
      sheet.addCell(description_label)
      sheet.addCell(category_label)
      sheet.addCell(client_label)
      sheet.addCell(amount_number)
    end
    
    if (expense["signature"])
      image_signature = Base64.decode64(expense["signature"])

      signature = Tempfile.new(['signature', '.png'])
      signature.write(image_signature)
      signature.rewind
      writable_image = Java::jxl.write.WritableImage.new(SIGNATURE_COL, SIGNATURE_ROW, 2, 1, java.io.File.new(signature.path))
      sheet.addImage(writable_image)
    end
 
  ensure
    if (writeable_workbook)
      writeable_workbook.write
      writeable_workbook.close
    end
  end
  
  send_file(temp_file.path)
end
