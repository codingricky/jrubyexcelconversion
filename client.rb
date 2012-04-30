require 'rubygems'
require 'json'
require 'rest_client'
require 'base64'
# require 'patron'
require 'faraday'
image_signature = Base64.encode64(File.read("test.png"))
# image_signature = ""
expense = {:name => 'John Smith', :signature => image_signature}
receipt_1 = {:client => 'Jemena', :category => 'Travel', :date => '24/4/2012', :amount_in_cents => 9999, :description => 'Taxi from City to SOP'}
receipt_2 = {:client => 'ResMed', :category => 'Travel', :date => '25/4/2012', :amount_in_cents => 8888, :description => 'Taxi from City to Bella Vista'}
expense[:receipts] = [receipt_1, receipt_2]

url = 'http://localhost:4567/excel'
puts expense.to_json

# response = RestClient.post url, File.read("/Users/ricky/Snapshots/MainFrame-2012-04-11-shutdown-2.snapshot")
# response = Request.execute(:method => :post, :url => url, :timeout => 90000000,  :payload => expense.to_json)

# resource = RestClient::Resource.new(url, :timeout => 9999999, :open_timeout => 9999999)
# response = resource.post expense.to_json 
        

# response = RestClient.post url, "hello"
# 
# sess = Patron::Session.new
# sess.base_url = "http://localhost:4567"
# resp = sess.post("/excel", expense.to_json)

conn = Faraday.new(:url => url)
resp = conn.post expense.to_json
File.open('output.xls', 'w') {|f| f.write resp.body}
