=begin

Thomas Camilli
Dr. Monisha Pulimood
CSC415-01
Monday, February 15, 2021

assignment1.rb

This program is designed to take database information about rooms and schedule times and create a system for planning out the event, reserving rooms and events for a TCNJ Hackathon.

Future Works: 
	Putting the event data in order, fixing any bugs related to time, duration, and scheduling.
	Allow multiple groups to book rooms based on capacity (keep track of the current number of attendees in each room)
	Test with more data.
=end

require 'csv'

#======================================================
# Room
# Variables: building, room, capacity, computersAvailable, seatingAvailable, seatingType, foodAllowed, priority, roomType
# A class for containing the room data.
#======================================================
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
#=====================================================
# Schedule
# Variables: building, room, date, time, available, bookingType
# A class for containing the schedule data.
#=====================================================
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

#====================================================
# readRooms()
# Input: filename
# Output: A list of Schedule objects.
# Reads in the room file if it exists and places it into a one-dimensional array of Room objects.
#====================================================
def readRooms (filename)
	# Parses the file without the header and places it into a two-dimensional array.
	roomList = CSV.parse(File.read(filename), headers: true)
	# Creates a new one-dimensional array for holding Room objects.
	roomObjList = Array.new
	c = 0
	# Loops through each list in the two-dimensional array and creates an object for each one.
	roomList.each do
		room = Room.new(roomList[c][0],roomList[c][1],roomList[c][2],roomList[c][3],roomList[c][4],roomList[c][5],roomList[c][6],roomList[c][7],roomList[c][8])
		c += 1
		# Pushes the newly created Room object onto the one-dimensional array.
		roomObjList.push(room)
	end
	# Returns the one-dimensional array holding Room objects.
	return roomObjList
end

#===================================================
# readSchedule()
# Input: filename
# Output: A list of Schedule objects.
# Reads in the schedule file if it exists and places it into a one-dimensional array of Schedule objects.
#===================================================
def readSchedule (filename)
	# Parses the file without the header and places it into a two-dimensional array.
	scheduleList = CSV.parse(File.read(filename), headers: true)
	# Creates a new one-dimensional array for holding Schedule objects.
	scheduleObjList = Array.new
	c = 0
	# Loops through each list in the two-dimensional array and creates an object for each one.
	scheduleList.each do
		schedule = Schedule.new(scheduleList[c][0],scheduleList[c][1],scheduleList[c][2],scheduleList[c][3],scheduleList[c][4],scheduleList[c][5])
		c += 1
		# Pushes the newly created Schedule object onto the one-dimensional array.
		scheduleObjList.push(schedule)
	end
	# Returns the one-dimensional array holding Room objects.
	return scheduleObjList
end

#=================================================
# getEventDate()
# Input: A list of Schedule objects (schedule)
# Output: A list of Schedule objects (updated)
# Using the list, this function asks the user for the starting date of the event and checks to make sure it is valid. Deletes dates from the list that won't be valid given the user-inputted date (happened in the past).
#=================================================
def getEventDate (schedule)
	# Loops until there's a valid date given and the data preceeding the start date is deleted from the list.
	k = 0
	while k == 0
		# Loops until the user enters a valid date.
		i = 0
		while i == 0
			# Receives the date from the user.
			print "Date of event (format \"yyyy-mm-dd\"): "
			date = gets.chomp
			# Splits the date into its components and checks to make sure they are numbers that make sense for dates.
			dateSplit = date.split("-")
			if dateSplit[0].to_i > 9999 or dateSplit[1].to_i > 12 or dateSplit[2].to_i > 31
				puts "Please enter a valid event date."
			else
				# The date is valid, exit the nested loop.
				i = i + 1
			end
		end

		index = 0
		# Creates a temporary list of Schedule objects that is a copy of the schedule list.
		scheduleTemp = schedule.map(&:clone)
		# Loops through each Schedule object and checks each date in its individual components.
		schedule.each do |scheduleObj|
			scheduleSplit = (scheduleObj.date).split("-")
			if scheduleSplit[0].to_i != dateSplit[0].to_i or scheduleSplit[1].to_i < dateSplit[1].to_i or scheduleSplit[2].to_i < dateSplit[2].to_i
				# Delete a date in the temporary list that comes before the entered date (user cannot book events that happened in the past).
				scheduleTemp.delete_at(index)
				index = index - 1
			end
			index = index + 1
		end
		if scheduleTemp.length == 0
			# All the values in the temporary list were deleted, so the date entered clearly isn't valid.
			puts "Please enter a valid date."
		else
			k = k + 1
		end
	end 
	# Return the temporary list as the new list.
	return scheduleTemp
end

#===============================================
# getStartTime()
# Input: A list of Schedule objects (schedule)
# Output: A list of Schedule objects, updated.
# Using this list, this function asks the user for the starting time of the event and checks to make sure it is valid. Deletes times from the list that won't be valid given the user-inputted time (happened in the past).
#===============================================
def getStartTime (schedule)
	# Loops until there's a valid time given and the data preceeding the start time is deleted from the list.
	k = 0
	while k == 0
		# Loops until the user enters a valid date.
		i = 0
		while i == 0
			# Receives the time from the user.
			print "Start time of the event (format \"hh:mm AM/PM\"): "
			time = gets.chomp
			# Splits the time into its components and checks to make they are numbers that make sense for time.
			timeSplit = time.split(/\W+/)
			if timeSplit[0].to_i > 12 or timeSplit[1].to_i > 59 or (timeSplit[2] != "AM" and timeSplit[2] != "PM")
				puts "Please enter a valid start time."
			else
				# The time is valid, exit the nested loop.
				i = i + 1
			end
		end
		index = 0
		# Creates a temporary list of Schedule objects that is a copy of the schedule list.
		scheduleTemp = schedule.map(&:clone)
		# Loops through each Schedule object and checks each time in its individual components.
		schedule.each do |scheduleObj|
			scheduleSplit = (scheduleObj.time).split(/\W+/)
			if scheduleObj.date == schedule[0].date and ((scheduleSplit[0].to_i < timeSplit[0].to_i and scheduleSplit[2] == timeSplit[2]) or (timeSplit[0].to_i == scheduleSplit[0].to_i and timeSplit[1].to_i > 0 and timeSplit[2] == scheduleSplit[2]) or (scheduleSplit[0] == "12" and timeSplit[0].to_i > 1 and scheduleSplit[2] == timeSplit[2]) or (scheduleSplit[2] == "AM" and timeSplit[2] == "PM"))
				if timeSplit[0] != "12" or (timeSplit[2] == "PM" and scheduleSplit[2] == "AM")
					# Delete a time in the temporary list that comes before the entered time (user cannot book events that happened in the past).
					scheduleTemp.delete_at(index)
					index = index - 1
				else
					if scheduleSplit[0] == "12"
						# Delete a time in the temporary list that comes before the entered time (user cannot book events that happened in the past).
						scheduleTemp.delete_at(index)
						index = index - 1
					end
				end
			end
			index = index + 1
		end
		if scheduleTemp.length == 0
			# All the values in the temporary list were deleted, so the date entered clearly isn't valid.
			puts "Please enter a valid time."
		else
			k = k + 1
		end
	end
	# Returns the temporary list as the new list.
	return scheduleTemp
end

#===============================================
# getEventDuration
# Input: None
# Output: Event duration as an array of two integers.
# Gets the event duration and makes sure it is a valid number.
# ==============================================
def getEventDuration
	# Loops until a valid event duration is given.
	i = 0
	while i == 0
		# Receives a proper event duration.
		print "Duration of the event (format \"hh:mm\"): "
		duration = gets.chomp
		marker = 0
		# Splits the number into its components.
		durationSplit = duration.split(":")
		if durationSplit[1].to_i > 59
			# Makes sure the user doesn't enter a number of minutes greater than 59 (which would be an hour).
			puts "Please enter a proper number of minutes (<60)."
			marker = 1
		end
		if durationSplit[0].to_i > 23 and (durationSplit[0].to_i != 24 or durationSplit[1].to_i > 0)
			# Makes sure the user doesn't enter a number of hours greater than 23 (which would be a day, which isn't applicable because a hackathon is stated as being a 24 hour event.
			puts "A hackathon is only 24 hours. Please state a smaller duration."
		else
			if marker != 1
				i = i + 1
			end
		end
	end
	# Returns the duration of the event.
	return durationSplit
end

#=============================================
# getNumAttendees
# Input: None
# Output: A number of attendees (integer)
#=============================================
def getNumAttendees
	print "Number of attendees: "
	numAttendee = gets.chomp
	return numAttendee
end

#=============================================
# slotRoom
# Input: bookingEvent, scheduleData, eventSlots
# Output: A list of events (eventSlots)
# Books an available room/time slot by marking it as unavailable and adding it to a list of events.
#=============================================
def slotRoom(bookingEvent, scheduleData, eventSlots)
	# Sets the given data as unavailable.
	scheduleData.set_available = "false"
	# Sets the bookingType of the time slot as the given parameter "bookingEvent"
	scheduleData.set_bookingType = bookingEvent
	# Pushes the data onto the list of events.
	eventSlots.push(scheduleData)
	puts "Time slot reserved."
	# Returns the list of events.
	return eventSlots
end

#===========================================
# formatTime
# Input: time, formatted as an array
# Output: time, but formatted correctly as a string
# Given an array of components for time (hours, minutes, AM/PM), it converts it back into the hh:mm AM/PM format.
#===========================================
def formatTime(time)
	if time[1].to_i != 0
		if time[0].to_i < 10
			# The hours needs a zero in front of it.
			return "0#{time[0]}:#{time[1]} #{time[2]}"
		else
			# The time is already formatted correctly.
			return "#{time[0]}:#{time[1]} #{time[2]}"
		end
	else
		if time[0].to_i < 10
			# The hours needs a zero in front of it and the minutes needs a zero following it.
			return "0#{time[0]}:#{time[1]}0 #{time[2]}"
		else
			# The minutes neeeds a zero following it.
			return "#{time[0]}:#{time[1]}0 #{time[2]}"
		end
	end
end

#==========================================
# checkAvailable
# Input: schedule, time, date, room, building
# Output: A string saying "true", "false", or "not found"
# Given a list of parameters, this function checks to make sure that the time slot is available.
#==========================================
def checkAvailable(schedule, time, date, room, building)
	schedule.each do |scheduleObj|
		# Look through the list of schedule objects for the given time slot. If it is available, return "true". If not, return "false"
		if (scheduleObj.time == time) and (scheduleObj.date == date) and (scheduleObj.room == room) and (scheduleObj.building == building)
			return scheduleObj.available
		end
	end
	return "not found"
end

#=========================================
# reserveRoom
# Input: bookingEvent, autoSchedule, rooms, schedule, eventSlots, building, room, date, startTime, duration, capacity, computersAvailable, seatingAvailable, seatingType, foodAllowed, priority, roomType
# Output: eventSlots, updated with the new room reservation.
# Finds a room to reserve based on your given parameters and any that you enter in this method. 
#========================================
def reserveRoom(bookingEvent, autoSchedule, rooms, schedule, eventSlots, building, room, date, startTime, duration, capacity, computersAvailable, seatingAvailable, seatingType, foodAllowed, priority, roomType)
	i = 0
	# If we are auto-scheduling this event, we won't take any user parameters (thus we skip the next loop). Events like the opening and closing ceremony are autoschedule.
	if autoSchedule == "T"
		i = i + 1
	end

	# If we aren't auto-scheduling this event, loop until the user enters as many parameters for the room as they want.
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
			# Receives user-input for building
			building = gets.chomp
		elsif option == "b"
			print "What room? "
			# Receives user-input for room
			room = gets.chomp
		elsif option == "c"
			print "What date (format \"yyyy-mm-dd\")? "
			# Receives user-input for date
			date = gets.chomp
		elsif option == "d"
			print "What start time (format \"hh:mm AM/PM\")? "
			# Receives user-input for time
			startTime = gets.chomp
			# Make sure the user entered data is formatted correctly.
			startTime = startTime.split(/\W+/)
			startTime = formatTime(startTime)
		elsif option == "e"
			print "What duration (format \"hh:mm\")? "
			# Receives user-input for duration
			fullDuration = gets.chomp
			durationSplit = fullDuration.split(":")
			# Converts duration to minutes.
			duration = durationSplit[0].to_i*60 + durationSplit[1].to_i
		elsif option == "f"
			print "What capacity? "
			# Receives user-input for capacity
			capacity = gets.chomp
		elsif option == "g"
			print "Are computers necessary (format \"Yes/No\")? "
			# Receives user-input for if computers are available
			computersAvailable = gets.chomp
		elsif option == "h"
			print "What seating is necessary?  "
			# Receives user-input for what seating is necessary
			seatingAvailable = gets.chomp
		elsif option == "i"
			print "What type of seating? "
			# Receives user-input for what type of seating
			seatingType = gets.chomp
		elsif option == "j"
			print "Does food need to be allowed (format \"Yes/No\")? "
			# Receives user-input for whether food is allowed in the room
			foodAllowed = gets.chomp
		elsif option == "k"
			print "What priority? "
			# Receives user-input for the room's priority
			priority = gets.chomp
		elsif option == "l"
			print "What type of room? "
			# Receives user-input for the type of room
			roomType = gets.chomp
		elsif option == "q"
			i = i + 1
			# Leaves the loop with the desired parameters.
		else
			# A wrong value was entered.
			puts "\n>>> Please enter a valid parameter."
			puts "Press any key to continue."
			gets.chomp
		end
	end
	puts "Searching for a room..."	
	validRoom = 0
	counter = 0
	# Loops until a valid room is found
	while validRoom == 0
		# Loops through all Schedule objects in the list
		schedule.each do |scheduleData|
			# Loops through all Room objects in the list
			rooms.each do |roomData|
				# Checks to see if the object matches the given parameters.
				if (scheduleData.building == roomData.building) and (scheduleData.room == roomData.room) and (building == -1 or (scheduleData.building == building and roomData.building == building)) and (room == -1 or (scheduleData.room == room and roomData.room == room)) and (date == -1 or scheduleData.date == date) and (startTime == -1 or scheduleData.time == startTime) and (capacity == -1 or capacity >= roomData.capacity) and (computersAvailable == -1 or roomData.computersAvailable == computersAvailable) and (seatingAvailable == -1 or roomData.seatingAvailable == seatingAvailable) and (seatingType == -1 or roomData.seatingType == seatingType) and (foodAllowed == -1 or roomData.foodAllowed == foodAllowed) and (priority == -1 or roomData.priority == priority) and (roomType == -1 or roomData.roomType == roomType)
					# Determines the number of hours/intervals that rooms need to be booked for, based on the given duration.
					durationIntervals = duration/60
					durationIntervals = durationIntervals.abs()-1
					durationValid = 1
					# a represents the index of the data in the list of Schedule objects
					a = schedule.find_index(scheduleData)
					for x in 0..durationIntervals
						if schedule[a+x].available == "false"
							# One of the time slots in the duration was found to be occupied/available.
							durationValid = 0
							if startTime != -1
								# If the event's time was one of the given parameters, we can increment by one hour to accomodate the unavailable time.
								startTime = startTime.split(/\W+/)
								startTime[0] = startTime[0].to_i + 1
								# Added time might push the time over 12 to 1'o'clock
								if startTime[0].to_i > 12
									startTime[0] = 1
									if startTime[2] == "PM"
										startTime[2] = "AM"
									elsif startTime[2] == "AM"
										startTime[2] = "PM"
									end
								end
								# Format the time again.
								startTime = formatTime(startTime)
							end
						end
					end
					# If the duration is valid, we can ask the user if they want to book this time.
					if durationValid == 1
						validReply = 1
						while validReply == 1
							# Loop until a valid reply is given to this question.
							print "How does #{scheduleData.building} #{scheduleData.room} at #{scheduleData.time} on #{scheduleData.date} sound? (Y/N) "
							reply = gets.chomp
							if reply == "Y" or reply == "y" or reply == "yes" or reply == "Yes"
								# User agreed to the event parameters.
								validRoom = 0
								validReply = 0
								b = schedule.find_index(scheduleData)
								for y in 0..durationIntervals
									# Book the room for all time slots on the interval
									eventSlots = slotRoom(bookingEvent, schedule[b+y], eventSlots)
								end
								return eventSlots
							elsif reply == "N" or reply == "n" or reply == "no" or reply == "No"
								# The user disagreed to the event parameters, find a different Schedule object and time slot.
								validReply = 0
							else
								# The user didn't enter a valid response.
								puts "Please enter a valid reply!"
							end
						end
					end
				end
			end
		end
		counter = counter + 1
		# If invalid parameters were entered, the program will continually search through both the lists for a long time. Ask the user to wait for the process to complete, so the loop will end (and not loop indefinitely).
		if counter == (schedule.length/8) or counter == (schedule.length/4) or counter == (3*schedule.length/8) or counter == (schedule.length/2) or counter == (5*schedule.length/8) or (counter == 3*schedule.length/4) or counter == (7*schedule.length/8)
			puts "Please wait..."
		end
		if counter == schedule.length
			puts "No rooms found matching the parameters."
			validRoom = 1
		end
	end
	# Return the list of events (which was changed by the slotRoom() method).
	return eventSlots
end 

#===========================================
# meals()
# Input: rooms, schedule, eventSlots
# Output: A list of events (eventSlots)
# Finds the date and time of the closing ceremony using eventSlots, then loops until it reaches that time, adding events for meals along the way.
#===========================================
def meals(rooms, schedule, eventSlots)
	mealCounter = 0
	i = 1

	endTime = -1
	endDate = -1

	# Looks through the list of events for the closing ceremony, takes the event's date and time.
	eventSlots.each do |event|
		if event.bookingType == "closing ceremony"
			endTime = event.time
			endDate = event.date
		end
	end
	if endTime == -1 and endDate == -1
		puts "Error! Closing ceremony not booked."
	end

	schedule.each do |scheduleObj|
		# For each Schedule object in the list, check to make sure we didn't hit the end yet.
		if scheduleObj.time != endTime or scheduleObj.date != endDate
			if  mealCounter == 5
				# If we hit the 6th hour (mealCounter == 5), it's time for a meal.
				puts "MEAL #{i}"
				i = i + 1
				# Auto-reserve a room for the meal (will still ask for the user's verification).
				eventSlots = reserveRoom("meal", "T", rooms, schedule, eventSlots, -1, -1, scheduleObj.date, scheduleObj.time, 60, -1, -1, -1, -1, "Yes", -1, -1)
				# Resets the meal counter.
				mealCounter = 0
			end
			# Increment the meal counter.
			mealCounter = mealCounter + 1
		else
			if i == 1
				# We hit the end of the event's duration, and no meals have been scheduled.
				puts "Could not schedule any meal times with the duration given."
			end
			# Return the list of events (eventSlots) after it was updated with the new events.
			return eventSlots
		end
	end
	# This return statement should never occur, but is kept there for safety.
	return eventSlots	
end

#=========================================
# writeEvents()
# Input: A list of events (eventSlots)
# Output: None, but it does write the events to a new file.
# Converts the list of events (eventSlots) into a 2D array before writing the array into a csv file called "events.csv"
#=========================================
def writeEvents(eventSlots)
	i = 0
	# Initializes the 2D array with a header.
	eventRows = [["Building","Room","Date","Time","Available","Booking Type"]]
	until i == eventSlots.length
		# Pushes each event/Schedule object in the eventSlots list of events into the 2D array.
		eventRows.push(["#{eventSlots[i].building}","#{eventSlots[i].room}","#{eventSlots[i].date}","#{eventSlots[i].time}","#{eventSlots[i].available}","#{eventSlots[i].bookingType}"])
		i = i + 1
	end
	# Writes the 2D array into a csv file called "events.csv". Will overwrite any preexisting file.
	File.write("events.csv", eventRows.map(&:to_csv).join)
end

#========================================
# menu()
# Input: rooms, schedule, eventSlots (three lists of objects)
# Output: A list of events (eventSlots)
# A menu that allows the user to perform a few different actions, such as reserve a room or save their current events to a csv file.
#======================================== 
def menu (rooms, schedule, eventSlots)
	i = 0
	while i == 0
		# Loops until the user quits the menu.
		puts "A - Reserve a room."
		puts "B - Save events to a file."
		puts "Q - Quit"
		

		print "Enter your option: "
		option = gets.chomp
		if option == "A"
			# Reserves a room, allowing the user the pick out the room's parameters within the reserveRoom() function itself.
			eventSlots = reserveRoom("event", "F", rooms, schedule, eventSlots, -1, -1, -1, -1, 60, -1, -1, -1, -1, -1, -1, -1)	
		elsif option == "B"
			# Writes the current events to a csv file. This will happen automatically at the end of the main() function.
			writeEvents(eventSlots)
			puts "\nEvents have been saved to the file \"events.csv\"!\n\n"
		elsif option == "Q"
			# Breaks out of the loop.
			i = i + 1
		else
			# The user entered an invalid option.
			puts "Please enter a valid option."
		end
	end
	# Returns the list of events.
	return eventSlots
end

#======================================
# preexistingEvents()
# Input: schedule, eventSlots
# Output: The list of events (eventSlots)
# Fills the list of events with those currently in the schedule list (list of Schedule objects).
#======================================
def preexistingEvents(schedule, eventSlots)
	schedule.each do |scheduleObj|
		# If an event is discovered in the list of Schedule objects, add it to the list of events.
		if scheduleObj.bookingType == "event"
			eventSlots.push(scheduleObj)
		end
	end
	# Return the filled list of events (eventSlots)
	return eventSlots
end

#======================================
# main()
# The first method that's run by this program.
#======================================
def main
	# Reads in the filename for the room data, continually prompting for it until it is found and entered correctly.
	i = 0
	while i == 0
		print "What file will have the room data? "
		roomFileName = gets.chomp
		if(File.exist?(roomFileName))
			rooms = readRooms(roomFileName)
			i = 1
		else
			puts "Error. File not found."
		 end
	end
	# Reads in the filename for the schedule data, continually prompting for it until is found and entered correctly.
	j = 0
	while j == 0
		print "What file will have the schedule data? "
		scheduleFileName = gets.chomp
		if(File.exist?(scheduleFileName))
			schedule = readSchedule(scheduleFileName)
			j = 1
		else
			puts "Error. File not found."
		end
	end
	
	# Creates a new array that's filled with events that appear in the schedule data.
	eventSlots = Array.new
	eventSlots = preexistingEvents(schedule, eventSlots)

	print "\n"

	# Gets the event's start date and removes any preceeding days from the dataset object list. 
	schedule = getEventDate(schedule)
	# Gets the event's start time and removes any preceeding time from the dataset object list.
	schedule = getStartTime(schedule)
	# Gets the event's duration.
	duration = getEventDuration
	# Gets the number of attendees to the event.
	numAttendee = getNumAttendees

	# Books the opening/welcome session for the Hackathon
	puts "\nBooking room for opening/welcome session..."
	eventSlots = reserveRoom("opening ceremony", "T", rooms, schedule, eventSlots, -1, -1, schedule[0].date, schedule[0].time, 60, numAttendee, -1, -1, -1, -1, -1, -1)
	
	# Books the closing session for the Hackathon
	puts "\nBooking room for final presentation and awards..."
	finalDate = (schedule[0].date).split("-")
	finalTime = (schedule[0].time).split(/\W+/)
	# Calculates the final time and date for the closing session to occur on, using the event's duration.
	if duration[0].to_i == 24
		finalDate[2] = finalDate[2].to_i + 1
	else
		# Ignores the minutes for the final time to make calculations easier.
		finalTime[1] = 0
		if (finalTime[1].to_i + duration[1].to_i) > 30
			finalTime[0] = finalTime[0].to_i + 1
		end
		# Calculates whether the duration takes the time of the final event to a new day, or not.
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
				if (finalTime[0].to_i + duration[0].to_i) > 12
					finalTime[0] = (finalTime[0].to_i - duration[0].to_i).abs()
				end
				finalTime[2] = "AM"
				finalDate[2] = finalDate[2].to_i + 1
			end
		end
	end
	# Formats the final date and time correctly.
	finalDate = "#{finalDate[0]}-#{finalDate[1]}-#{finalDate[2]}"
	finalTime = formatTime(finalTime)
	# Reserves the room for the final event.
	eventSlots = reserveRoom("closing ceremony", "T", rooms, schedule, eventSlots, -1, -1, finalDate, finalTime, 60, numAttendee, -1, -1, -1, -1, -1, -1)

	# Begins scheduling mealtimes by calling the meals() function.
	puts "\nScheduling mealtimes..."
	eventSlots = meals(rooms, schedule, eventSlots)

	# Starts the menu and the user-controlled reserving room process by calling the menu() function.
	puts "\nOptions:"
	eventSlots = menu(rooms, schedule, eventSlots)

	# At the end of the program, saves all the created events to a csv file automatically. The file is named "events.csv".
	writeEvents(eventSlots)
end

# Calls the main() function.
main


