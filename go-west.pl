/* 
	Go West is a simple text-based game. 
	Consult this file and type:
		"start." to start the game
		"cmd." to see available commands
	
	yotkaz
*/

/* ###------------------------------------------------------ */
/* ###------------------------------------------------------ */

/* Dynamic varables */
:- dynamic power/1, days_left/1, current_location/1. 

/* ###------------------------------------------------------ */
/* ###------------------------------------------------------ */

/* Full names */
full_name(west, "West").
full_name(east, "East").
full_name(north, "North").
full_name(south, "South").

full_name(road, "regular road").
full_name(low_mountains, "low mountains").
full_name(high_mountains, "high mountains").
full_name(river, "river").

full_name(gotham, "Gotham City").
full_name(michi, "Michi City").
full_name(cina, "Cina Town").
full_name(last_known_town, "Last Known Town").
full_name(fara, "Fort Fara").
full_name(kolo, "Kolo City").
full_name(hala, "Fort Hala").
full_name(vega, "Vega City").
full_name(franco, "Los Franco").
full_name(angelo, "San Angelo").

/* Paths (start_town, target_town, direction, type, distance) */
path(gotham, michi, west, road, 3).
path(michi, gotham, east, road, 3).

path(gotham, cina, south, road, 2).
path(cina, gotham, north, road, 2).

path(michi, last_known_town, south, road, 3).
path(last_known_town, michi, north, road, 3).

path(cina, last_known_town, west, river, 1).
path(last_known_town, cina, east, river, 1).

path(last_known_town, fara, west, road, 1).
path(fara, last_known_town, east, road, 1).

path(fara, hala, west, road, 2).
path(hala, fara, east, road, 2).

path(fara, kolo, south, road, 1).
path(kolo, fara, north, road, 1).

path(hala, vega, south, low_mountains, 2).
path(vega, hala, north, low_mountains, 2).

path(kolo, vega, west, high_mountains, 2).
path(vega, kolo, east, high_mountains, 2).

path(hala, franco, west, high_mountains, 3).
path(franco, hala, east, high_mountains, 3).

path(vega, angelo, west, low_mountains, 2).
path(angelo, vega, east, low_mountains, 2).

path(angelo, franco, north, road, 1).
path(franco, angelo, south, road, 1).

/* Path difficulty */
path_difficulty(road, 1).
path_difficulty(low_mountains, 2).
path_difficulty(high_mountains, 5).
path_difficulty(river, 10).

/* ###------------------------------------------------------ */
/* ###------------------------------------------------------ */

cmd(StartCommand) :-
	nl,
	write("Type cmd. to see this message"), nl,
	write("Type "), write(StartCommand), write(". to "), write(StartCommand), write(" the game"), nl,
	write("Type info. to see your power, days left, current location and towns in neighbourhood"), nl,
	write("Type west. to go West"), nl,
	write("Type east. to go East"), nl,
	write("Type north. to go North"), nl,
	write("Type south. to go South"), nl.

cmd :- 
	cmd("restart").

welcome_message :-
	days_left(Days_Left),
	nl,
	write("You heard that there's a lot of gold on the west of your country."), nl,
	write("You decided to go to Los Franco, to get some gold."), nl,
	write("You will have to deal with mountains and rivers."), nl,
	write("Each type of road has different difficulty level which will affect your power loss."), nl,
	write("Hurry up! You have only "), write(Days_Left), write(" days."), nl.

restart_message :-
	nl,
	write("Type restart. to restart the game"), nl.

short_info :-
	current_location(Here),
	power(Power),
	days_left(Days_Left),
	full_name(Here, Here_Full_Name),
	nl,
	write("Your power: "), write(Power), nl,
	write("Days left: "), write(Days_Left), nl,
	write("Current location: "), write(Here_Full_Name), nl.
	
is_neighbour(Here, Direction) :-
	path(Here, _, Direction, _, _).

neighbour_info(Here, Direction) :-
	path(Here, Target, Direction, Type, Distance),
	path_difficulty(Type, Difficulty),
	full_name(Target, Target_Full_Name),
	full_name(Direction, Direction_Full_Name),
	full_name(Type, Type_Full_Name),
	write("On the "), write(Direction_Full_Name),
		write(" there's "), write(Target_Full_Name),
		write(". The distance is "), write(Distance),
		write(" via "), write(Type_Full_Name),
		write(" (difficulty is "), write(Difficulty), write(")"), nl.
	

neighbour_info_if_needed(Here, Direction) :-
	(is_neighbour(Here, Direction) -> neighbour_info(Here, Direction); write("")).

info :- 
	current_location(Here),
	short_info,
	write("Towns in your neighbourhood: "), nl,
	neighbour_info_if_needed(Here, west),
	neighbour_info_if_needed(Here, east),
	neighbour_info_if_needed(Here, north),
	neighbour_info_if_needed(Here, south).

west :- 
	go(west).

east :- 
	go(east).
	
north :- 
	go(north).
	
south :- 
	go(south).

go(Direction) :-
	current_location(Here),
	power(Power),
	days_left(Days_Left),
	path(Here, Target, Direction, Type, Distance),
	path_difficulty(Type, Difficulty),
	retract(current_location(Here)),
	assert(current_location(Target)),
	Updated_Days_Left is Days_Left - Distance,
	retract(days_left(Days_Left)),
	assert(days_left(Updated_Days_Left)),
	Updated_Power is Power - Distance * Difficulty,
	retract(power(Power)),
	assert(power(Updated_Power)),
	(Updated_Power > 0, Updated_Days_Left >= 0 -> info_or_success_or_game_over;  game_over).
	
info_or_success_or_game_over :-
	(days_left(0) -> (current_location(franco) -> success; game_over); info).
	
info_or_success :-
	(current_location(franco) -> success;  info).
	
success :- 
	nl,
	write("SUCCESS"), nl,
	write("Bravo, you found the gold!"), nl,
	short_info,
	restart_message.	
	
game_over :-
	nl,
	write("GAME OVER"), nl,
	short_info,
	restart_message.
	
restart :-
	retractall(power(_)),
	assert(power(20)),
	retractall(days_left(_)),
	assert(days_left(14)),
	retractall(current_location(_)),
	assert(current_location(gotham)),
	welcome_message,
	info.
	
start :- 
	restart.
		
/* ###------------------------------------------------------ */
/* ###------------------------------------------------------ */

/* Let's play :) */
:- cmd("start").