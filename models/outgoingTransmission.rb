class OutgoingTransmission
  include DataMapper::Resource

  property :id,         Serial   
  property :node_id,    Integer
  property :payload,    Text
  property :processed,  Boolean, :default  => false 
  property :created_at, DateTime
end
