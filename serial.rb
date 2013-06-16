#!/usr/bin/ruby
require 'bundler'
Bundler.require(:default)

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/database.db")
Dir["#{Dir.pwd}/models/*.rb"].each {|file| require file }
DataMapper.finalize
DataMapper.auto_upgrade!

ser = SerialPort.new("/dev/ttyAMA0", 9600, 8, 1, SerialPort::NONE)
sleep 0.5 

ser.write "123x"
sleep 0.1
ser.write "1i"
sleep 0.1
ser.write "109g"
sleep 0.1
ser.write "8b"
sleep 0.1
ser.write "123x"
sleep 0.1

while response = ser.readline do

	transmission = response.split(' ')
	if transmission.count > 1 && transmission.shift.to_i == 1
		node_id = transmission.shift.to_i
		type = transmission.shift.to_i
		if (type == 0)
			entry = OutgoingTransmission.last(node_id: node_id, processed: false)
			if entry
				payload = ''
				entry.payload.scan(/.{2}/).each do | hex |
					payload += hex.to_i(16).to_s + ","
				end
				ser.write node_id.to_s + "," + payload + ",2s"
				entry.processed = true
				entry.save
				puts "Outgoing transmission: " + entry.payload + " to node " + node_id.to_s
			end
			
		elsif transmission.count > 0 
			entry = IncomingTransmission.new
			entry.node_id = node_id
			entry.type = type
			payload = ''
			transmission.each do | byte |
				payload += "%02X" % byte
			end
			entry.payload = payload
			entry.save
			puts "Incomming transmission: " + payload + " of type " + type.to_s + " from node " + node_id.to_s	 
		end	
	end
end 
