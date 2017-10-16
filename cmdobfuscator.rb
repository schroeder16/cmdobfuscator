#!/usr/bin/ruby

bannertext = File.read("./banner")
puts bannertext

=begin

This is currently a PoC obfuscation technique for windows cmd line args. 

It is important to note that windows has different parsing techniques, and different programs implement different ones.

This has been designed to work for the majority of cases, but may not work for some (i.e dir needs a different token parsing method then assumed 

for first arg and so will fail using technique below.

=end

#Arg2 obsfucater 
def obfuscatearg2(token)
	wordlen = token.length
	i = 0
	obfuscatedcmd = ""
	
	token.split("").each do | char |
		#for other args just want to add ^"^ in
		i = i + 1
		
		if char.eql? "/"
			obfuscatedcmd.concat(char)
			next
		end

		if i == wordlen
			obfuscatedcmd.concat(char)
			next
		end
		
		#padding = char + '^"^' This can also work but seems to more capricious
                padding = char + "^"
		
                obfuscatedcmd.concat(padding)

	end
	return obfuscatedcmd
end



# Function definiation for obfuscateword method arg1
def obfuscatearg1(cmdstring)
	
	wordlen = cmdstring.length
	i = 0
	obfuscatedcmd = ""
	noarray = Array.new
	evencheck = false	
	
	#Start obfuscating individual word
        cmdstring.split("").each do | char |
                i = i + 1
                
                obfuscatedcmd.concat(char)

                #This is place to check for certain conditions. E.g. /domain - '/' is sensitive char so skip
		#If you are on the last character leave it alone
		if (i == wordlen || char == "/")
                        next
		#If you are on pnultimate char you need to make the number of " even or else it will be set on incorrect parse for second arg
                elsif (i == (wordlen -1))
			# If you are one before the end
			sum = 0
			noarray.each do | agg |
				
				sum = sum + agg
			end
			#puts "Total sum = #{sum}"
			if (sum % 2 == 0)
				
				even = false

                        	#In this case total is even so next number should be even
				while even == false
					randno = rand(3..2000)
					if (randno % 2 == 0)
						#padding = '^' + ('"' *randno) + '^'
						padding = '"'*randno
			                        obfuscatedcmd.concat(padding)
						even = true
					end	
				end
                        else
				odd = false
                                #In this case total is odd so next number should be odd
                                while odd == false
                                        randno = rand(3..2000)
                                        if (randno % 2 != 0)
                                                #padding = '^' + ('"' * randno) + '^'
                                                padding = '"'*randno
						obfuscatedcmd.concat(padding)
                                                odd = true
					
                                        end
                                end

			end
		else
			randno = rand(3..2000)
        	        #padding = '^' + ('"' *randno) + '^'
	                padding = '"'*randno
			obfuscatedcmd.concat(padding)
 			noarray.push(randno)
		end
	end
	#puts "Final obfuscated cmd: #{obfuscatedcmd}"
	return obfuscatedcmd
end
		
# Main
if ARGV.length > 1
	puts '[-] Please enter your cmd as a single string. For example, "net view /domain"'
	exit
end

puts "[+] Parsing tokens in cmd..."
cmd = ARGV[0].split(" ")

obfuscatedcmd = ""
arraylen = cmd.length

i = 0

# Iterate over each token and obfuscate
cmd.each do | word |
        i = i + 1
	
        wordlen = word.length
        #puts "[+] Token Length = #{wordlen}"
        puts "[+] Token being obfuscated: #{word}"

        # Call obfuscation function
	puts "[+] Obfuscating Token...."

	# Windows parses " in strange ways. For first arg it seems to need to be even or it will be in wrong parsing mode for following arguments and crash
	if i == 1
		obfuscatedcmd.concat(obfuscatearg1(word))
		obfuscatedcmd.concat(" ")	
	else
		obfuscatedcmd.concat(obfuscatearg2(word))
		obfuscatedcmd.concat(" ")
	end
end
puts "\n"
puts "Final obfuscated output: #{obfuscatedcmd}"
