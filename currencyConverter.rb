require 'rexml/document'
require 'open-uri'
require 'htmlentities'

include REXML

class Utility

def openConnection(uri)
	@connection = open(uri){|f|
		 @xml = ""
  		 f.each_line {|line| @xml << line}
	}	
end

def setLocation()
	puts "Enter Country: "
	@location = gets.chomp
end

def getLocation()
	return @location
end

def printLocation()
puts "Your location: #{@location}"
end

def XML()
	@decoded = HTMLEntities.new.decode(@xml)
	return @decoded
end

end

puts "NOTE: This is a currency conversion from 1 Philippine Peso to any currency"

util = Utility.new
util.openConnection("http://www.webservicex.net/country.asmx/GetCurrencies")
util.setLocation()

# Parse to XML format
doc = Document.new(util.XML())

# Construct a Hash for country to currency code correspondence
currencyHash = Hash.new
countryArray = {}
currencyArray = {}

# Get the Countries from XML
i = 0
XPath.each(doc, "//Table/Name") { 
	|element| 
	countryArray[i] = element.text
	i+=1
}

# Get the CurrencyCode from XML
i = 0
XPath.each(doc, "//Table/CurrencyCode") { 
	|element| 
	currencyArray[i] = element.text 
	i+=1
}

# Hash Values [country] = currencycode
i = 0
countryArray.each{
	|x| 
	currencyHash[x[1]] = currencyArray[i]
	i+=1
}

# Get the Location Inputted by the user
# Return the currency code
currencyCode = currencyHash[util.getLocation()]


# Default value is USD
if currencyCode == nil
	currencyCode = "USD"
end

# Parse the result
value = ""

# Open Yahoo! Finance web service for conversion
open("http://download.finance.yahoo.com/d/quotes.csv?s=PHP"+currencyCode+"=X&f=sl1d1t1ba&e=.csv"){|f|
		f.each_line {|line| value << line}
}	

# Get the conversion value from 1 PHP to the target currency
currencyValue = value.split(",")[1]

# Convert to Float
conversion = currencyValue.delete(',').to_f

# Get the conversion
puts "Conversion: "
puts "1 PHP = " + conversion.to_s + " " + currencyCode

# wait for input key
gets.chomp