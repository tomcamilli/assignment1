require 'csv'

class Room
	def initialize(building, room, capacity, computersAvailable, seatingAvailable, seatingType, foodAllowed, priority, roomType)
		@building = building
		@room = room
		@capacity = capacity
		@computersAvailable = computersAvailable
		@seatingAvailable = seatingAvailable
		@seatingType = seatingType
		@foodAllowed = foodAllowed
		@priority = priority
		@roomType = roomType
	end
	
	def building
		@building
	end
	def room
		@room
	end
	def capacity
		@capacity
	end
	def computersAvailable
		@computersAvailable
	end
	def seatingAvailable
		@seatingAvailable
	end
	def seatingType
		@seatingType
	end
	def foodAllowed
		@foodAllowed
	end
	def priority
		@priority
	end
	def roomType
		@roomType
	end
end

class Schedule
	def initialize(building, room, date, time, available, bookingType)
		@building = building
		@room = room
		@date = date
		@time = time
		@available = available
		@bookingType = bookingType
	end

	def set_available=(available)
		@available = available
	end
	def set_bookingType=(bookingType)
		@bookingType = bookingType
	end

	def building
		@building
	end
	def room
		@room
	end
	def date
		@date
	end
	def time
		@time
	end
	def available
		@available
	end
	def bookingType
		@bookingType
	end
end

# Reads in the room file
def readRooms (filename)
	roomList = CSV.parse(File.read(filename), headers: true)
	roomObjList = Array.new
	c = 0
	roomList.each do
		room = Room.new(roomList[c][0],roomList[c][1],roomList[c][2],roomList[c][3],roomList[c][4],roomList[c][5],roomList[c][6],roomList[c][7],roomList[c][8])
		c += 1
		roomObjList.push(room)
	end
	return roomObjList
end

# Reads in the schedule file
def readSchedule (filename)
	scheduleList = CSV.parse(File.read(filename), headers: true)
	scheduleObjList = Array.new
	c = 0
	scheduleList.each do
		schedule = Schedule.new(scheduleList[c][0],scheduleList[c][1],scheduleList[c][2],scheduleList[c][3],scheduleList[c][4],scheduleList[c][5])
		c += 1
		scheduleObjList.push(schedule)
	end
	return scheduleObjList
end

# Gets the event date
def getEventDate (schedule)
	k = 0
	while k == 0
		i = 0
		while i == 0
			print "Date of event (format \"yyyy-mm-dd\"): "
			date = gets.chomp
			dateSplit = date.split("-")
			if dateSplit[0].to_i > 9999 or dateSplit[1].to_i > 12 or dateSplit[2].to_i > 31
				puts "Please enter a valid event date."
			else
				i = i + 1
			end
		end

		index = 0
		scheduleTemp = schedule.map(&:clone)
		schedule.each do |scheduleObj|
			scheduleSplit = (scheduleObj.date).split("-")
			if scheduleSplit[0].to_i != dateSplit[0].to_i or scheduleSplit[1].to_i < dateSplit[1].to_i or scheduleSplit[2].to_i < dateSplit[2].to_i
				scheduleTemp.delete_at(index)
				index = index - 1
			end
			index = index + 1
		end
		if scheduleTemp.length == 0
			puts "Please enter a valid date."
		else
			k = k + 1
		end
	end 
	return scheduleTemp
end

# Gets the start time
def getStartTime (schedule)
	k = 0
	while k == 0
		i = 0
		while i == 0
			print "Start time of the event (format \"hh:mm AM/PM\"): "
			time = gets.chomp
			timeSplit = time.split(/\W+/)
			if timeSplit[0].to_i > 12 or timeSplit[1].to_i > 59 or (timeSplit[2] != "AM" and timeSplit[2] != "PM")
				puts "Please enter a valid start time."
			else
				i = i + 1
			end
		end
		index = 0
		scheduleTemp = schedule.map(&:clone)
		schedule.each do |scheduleObj|
			scheduleSplit = (scheduleObj.time).split(/\W+/)
			if scheduleObj.date == schedule[0].date and ((scheduleSplit[0].to_i < timeSplit[0].to_i and scheduleSplit[2] == timeSplit[2]) or (timeSplit[0].to_i == scheduleSplit[0].to_i and timeSplit[1].to_i > 0 and timeSplit[2] == scheduleSplit[2]) or (scheduleSplit[0] == "12" and timeSplit[0].to_i > 1 and scheduleSplit[2] == timeSplit[2]) or (scheduleSplit[2] == "AM" and timeSplit[2] == "PM"))
				if timeSplit[0] != "12" or (timeSplit[2] == "PM" and scheduleSplit[2] == "AM")
					scheduleTemp.delete_at(index)
					index = index - 1
				else
					if scheduleSplit[0] == "12"
						schedule.delete_at(index)
						index = index - 1
					end
				end
			end
			index = index + 1
		end
		if scheduleTemp.length == 0
			puts "Please enter a valid time."
		else
			k = k + 1
		end
	end
	return scheduleTemp
end

# Gets the event duration
def getEventDuration
	i = 0
	while i == 0
		print "Duration of the event (format \"hh:mm\"): "
		duration = gets.chomp
		durationSplit = duration.split(":")
		if durationSplit[1].to_i > 59
			puts "Please enter a proper number of minutes (<60)."
		end
		if durationSplit[0].to_i > 23 or (durationSplit[0].to_i == 24 and durationSplit[1].to_i > 0)
			puts "A hackathon is only 24 hours. Please state a smaller duration."
		else
			i = i + 1
		end
	#format: hh:m
	end
	return durationSplit
end

# Gets the number of attendees
def getNumAttendees
	print "Number of attendees: "
	numAttendee = gets.chomp
	#format: int
	return numAttendee
end

def slotRoom(bookingEvent, scheduleData, eventSlots)
	scheduleData.set_available = "false"
	scheduleData.set_bookingType = bookingEvent
	eventSlots.push(scheduleData)
	puts "DATA: #{scheduleData.date} #{scheduleData.time} #{scheduleData.building} #{scheduleData.room}"
	puts "Time slot reserved."
	return eventSlots
end

def formatTime(time)
	if time[1] != 0
		if time[0].to_i < 10
			return "0#{time[0]}:#{time[1]} #{time[2]}"
		else
			return "#{time[0]}:#{time[1]} #{time[2]}"
		end
	else
		if time[0].to_i < 10
			return "0#{time[0]}:#{time[1]}0 #{time[2]}"
		else
			return "#{time[0]}:#{time[1]}0 #{time[2]}"
		end
	end
end

def checkAvailable(schedule, time, date, room, building)
	schedule.each do |scheduleObj|
		if (scheduleObj.time == time) and (scheduleObj.date == date) and (scheduleObj.room == room) and (scheduleObj.building == building)
			return scheduleObj.available
		end
	end
	return "not found"
end

def reserveRoom(bookingEvent, autoSchedule, rooms, schedule, eventSlots, building, room, date, startTime, duration, capacity, computersAvailable, seatingAvailable, seatingType, foodAllowed, priority, roomType)
	i = 0
	if autoSchedule == "T"
		i = i + 1
	end

	while i == 0
		puts "\nSelect a parameter for the room:\n"
		puts "a - Enter a building"
		puts "b - Enter a room number"
		puts "c - Enter a date for your reservation"
		puts "d - Enter a start time for your reservation"
		puts "e - Enter a duration for your reservation"
		puts "f - Enter a desired capacity for your reserved room"
		puts "g - Mark if computers are necessary"
		puts "h - Enter what seating needs to be available in your reserved room"
		puts "i - Enter the type of seating in your reserved room"
		puts "j - Enter if food needs to be allowed in your reserved room"
		puts "k - Enter priority type for your reserved room"
		puts "l - Enter type of room for your reserved room"
		puts "q - CONTINUE"
		
		print "\nEnter your option: "
		option = gets.chomp
		if option == "a"
			print "What building? "
			building = gets.chomp
		elsif option == "b"
			print "What room? "
			room = gets.chomp
		elsif option == "c"
			print "What date (format \"yyyy-mm-dd\")? "
			date = gets.chomp
		elsif option == "d"
			print "What start time (format \"hh:mm AM/PM\")? "
			startTime = gets.chomp
			# Make sure the user entered data is formatted correctly.
			startTime = startTime.split(/\W+/)
			startTime = formatTime(startTime)
		elsif option == "e"
			print "What duration (format \"hh:mm\")? "
			fullDuration = gets.chomp
			durationSplit = fullDuration.split(":")
			duration = durationSplit[0].to_i*60 + durationSplit[1].to_i
		elsif option == "f"
			print "What capacity? "
			capacity = gets.chomp
		elsif option == "g"
			print "Are computers necessary (format \"Yes/No\")? "
			computersAvailable = gets.chomp
		elsif option == "h"
			print "What seating is necessary?  "
			seatingAvailable = gets.chomp
		elsif option == "i"
			print "What type of seating? "
			seatingType = gets.chomp
		elsif option == "j"
			print "Does food need to be allowed (format \"Yes/No\")? "
			foodAllowed = gets.chomp
		elsif option == "k"
			print "What priority? "
			priority = gets.chomp
		elsif option == "l"
			print "What type of room? "
			roomType = gets.chomp
		elsif option == "q"
			i = i + 1
		else
			puts "\n>>> Please enter a valid parameter."
			puts "Press any key to continue."
			gets.chomp
		end
	end
	puts "Searching for a room..."	
	validRoom = 0
	counter = 0
	while validRoom == 0
		schedule.each do |scheduleData|
			rooms.each do |roomData|
				if (scheduleData.building == roomData.building) and (scheduleData.room == roomData.room) and (building == -1 or (scheduleData.building == building and roomData.building == building)) and (room == -1 or (scheduleData.room == room and roomData.room == room)) and (date == -1 or scheduleData.date == date) and (startTime == -1 or scheduleData.time == startTime) and (capacity == -1 or capacity >= roomData.capacity) and (computersAvailable == -1 or roomData.computersAvailable == computersAvailable) and (seatingAvailable == -1 or roomData.seatingAvailable == seatingAvailable) and (seatingType == -1 or roomData.seatingType == seatingType) and (foodAllowed == -1 or roomData.foodAllowed == foodAllowed) and (priority == -1 or roomData.priority == priority) and (roomType == -1 or roomData.roomType == roomType)
					durationIntervals = duration/60
					durationIntervals = durationIntervals.abs()-1
					durationValid = 1
					a = schedule.find_index(scheduleData)
					#puts "----------------"
					#puts "#{scheduleData.building} #{scheduleData.room}"
					#puts "Entered capacity: #{capacity}"
					#puts "Room Capacity for #{roomData.building} #{roomData.room}: #{roomData.capacity}"
					#puts capacity <= roomData.capacity
					#puts "#{a} - #{counter}"
					for x in 0..durationIntervals
						if schedule[a+x].available == "false"
							durationValid = 0
							if startTime != -1
								startTime = startTime.split(/\W+/)
								startTime[0] = startTime[0].to_i + 1
								if startTime[0].to_i > 12
									startTime[0] = 1
									if startTime[2] == "PM"
										startTime[2] = "AM"
									elsif startTime[2] == "AM"
										startTime[2] = "PM"
									end
								end
								startTime = formatTime(startTime)
							end
						end
					end
					if durationValid == 1
						validReply = 1
						while validReply == 1
							print "How does #{scheduleData.building} #{scheduleData.room} at #{scheduleData.time} on #{scheduleData.date} sound? (Y/N) "
							reply = gets.chomp
							if reply == "Y" or reply == "y" or reply == "yes" or reply == "Yes"
								validRoom = 0
								validReply = 0
								b = schedule.find_index(scheduleData)
								for y in 0..durationIntervals
									eventSlots = slotRoom(bookingEvent, schedule[b+y], eventSlots)
								end
								return eventSlots
							elsif reply == "N" or reply == "n" or reply == "no" or reply == "No"
								validReply = 0
							else
								puts "Please enter a valid reply!"
							end
						end
					end
				end
			end
		end
		counter = counter - 1
		if counter == (schedule.length/8) or counter == (schedule.length/4) or counter == (3*schedule.length/8) or counter == (schedule.length/2) or counter == (5*schedule.length/8) or (counter == 3*schedule.length/4) or counter == (7*schedule.length/8)
			puts "Please wait..."
		end
		if counter == schedule.length
			puts "No rooms found matching the parameters."
			validRoom = 1
		end
	end
	return eventSlots
end 

def writeEvents(eventSlots)
	i = 0
	eventRows = [["Building","Room","Date","Time","Available","Booking Type"]]
	until i == eventSlots.length
		eventRows.push(["#{eventSlots[i].building}","#{eventSlots[i].room}","#{eventSlots[i].date}","#{eventSlots[i].time}","#{eventSlots[i].available}","#{eventSlots[i].bookingType}"])
		i = i + 1
	end
	File.write("events.csv", eventRows.map(&:to_csv).join)
end

def menu (rooms, schedule, eventSlots)
	i = 0
	while i == 0
		puts "A - Reserve a room."
		puts "B - Save events to a file."
		puts "Q - Quit"
		

		print "Enter your option: "
		option = gets.chomp
		if option == "A"
			eventSlots = reserveRoom("event", "F", rooms, schedule, eventSlots, -1, -1, -1, -1, 60, -1, -1, -1, -1, -1, -1, -1)	
		elsif option == "B"
			writeEvents(eventSlots)
			puts "\nEvents have been saved to the file \"events.csv\"!\n\n"
		elsif option == "Q"
			i = i + 1
		else
			puts "Please enter a valid option."
		end
	end
end

def preexistingEvents(schedule, eventSlots)
	schedule.each do |scheduleObj|
		if scheduleObj.bookingType == "event"
			eventSlots.push(scheduleObj)
		end
	end
	return eventSlots
end

def main
	print "What file will have the room data? "
	roomFileName = gets.chomp
	rooms = readRooms(roomFileName)
	print "What file will have the schedule data? "
	scheduleFileName = gets.chomp
	schedule = readSchedule(scheduleFileName)
	#puts rooms[2].building
	
	eventSlots = Array.new
	eventSlots = preexistingEvents(schedule, eventSlots)	

	print "\n"

	schedule = getEventDate(schedule)
	schedule = getStartTime(schedule)
	duration = getEventDuration
	numAttendee = getNumAttendees

	puts "\nBooking room for opening/welcome session..."
	eventSlots = reserveRoom("opening ceremony", "T", rooms, schedule, eventSlots, -1, -1, schedule[0].date, schedule[0].time, 60, numAttendee, -1, -1, -1, -1, -1, -1)
	
	# Calculate start time of final session using event duration
	puts "\nBooking room for final presentation and awards..."
	finalDate = (schedule[0].date).split("-")
	finalTime = (schedule[0].time).split(/\W+/)
	if duration[0].to_i == 24
		finalDate[2] = finalDate[2].to_i + 1
	else
		finalTime[1] = 0 # Makes searching much easier without counting the minutes
		if (finalTime[1].to_i + duration[1].to_i) > 30
			finalTime[0] = finalTime[0].to_i + 1
		end
		if (finalTime[0].to_i + duration[0].to_i) < 12
			finalTime[0] = finalTime[0].to_i + duration[0].to_i
		else
			finalTime[0] = (finalTime[0].to_i + duration[0].to_i) - 12
			if finalTime[0].to_i == 0
				finalTime[0] = 12
			end
			if finalTime[2] == "AM"
				if (finalTime[0].to_i + duration[0].to_i) < 24
					finalTime[2] = "PM"
				else
					finalTime[0] = (duration[0].to_i+finalTime[0].to_i)-24
					finalDate[2] = finalDate[2].to_i + 1
				end
			elsif finalTime[2] == "PM"
				print finalTime
				finalTime[2] = "AM"
				finalDate[2] = finalDate[2].to_i + 1
			end
		end
	end
	finalDate = "#{finalDate[0]}-#{finalDate[1]}-#{finalDate[2]}"
	finalTime = formatTime(finalTime)
	eventSlots = reserveRoom("closing ceremony", "T", rooms, schedule, eventSlots, -1, -1, finalDate, finalTime, 60, numAttendee, -1, -1, -1, -1, -1, -1)
	

	puts "\nOptions:"
	menu(rooms, schedule, eventSlots)
	writeEvents(eventSlots)
end
main


