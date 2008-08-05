require 'rexml/document'

xml = REXML::Document.new(File.open("/Users/boyan/Desktop/supramap/public/files/13/poy_tree_24.xml"))
puts xml.elements.each("count(forest/tree/*)")
xml.elements.each("forest/tree/*") do |node|
  puts node.elements["id/text()"]
  puts node.elements["ancestors/ancestor/@id"]
  puts "------transformations----------"
  node.elements.each("transformations/*") do |transformation|
    puts transformation.attribute("Character")
    puts transformation.attribute("Pos")
    puts transformation.attribute("AncS")
    puts transformation.attribute("DescS")
    puts transformation.attribute("type")
    puts transformation.attribute("Cost")
    puts transformation.attribute("Definite")
  end
  puts "-------------------------------"
end
