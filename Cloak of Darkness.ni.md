# Cloak of Darkness

## Preamble

The story headline is "A basic IF demonstration."

Use scoring.

The maximum score is 2.

## Rooms

### Foyer

Foyer of the Opera House is a room.  "You are standing in a spacious hall, splendidly decorated in red and gold, with glittering chandeliers overhead. The entrance from the street is to the north, and there are doorways south and west."

Instead of going north in the Foyer, say "You've only just arrived, and besides, the weather outside seems to be getting worse."

### Cloakroom

The Cloakroom is west of the Foyer. "The walls of this small room were clearly once lined with hooks, though now only one remains. The exit is a door to the east."

In the Cloakroom is a supporter called the small brass hook. The hook is scenery. Understand "peg" as the hook.

The description of the hook is "It's just a small brass hook, `if something is on the hook`with `a list of things on the hook` hanging on it`otherwise`screwed to the wall`end if`."

### Bar

The Bar is south of the Foyer. The printed name of the bar is "Foyer Bar". The Bar is dark.  "The bar, much rougher than you'd have guessed after the opulence of the foyer to the north, is completely empty. There seems to be some sort of message scrawled in the sawdust on the floor."

The scrawled message is scenery in the Bar. Understand "floor" or "sawdust" as the message.

Neatness is a kind of value. The neatnesses are neat, scuffed, and trampled. The message has a neatness. The message is neat.

Instead of examining the message:
	- increment score;
	- say "The message, neatly marked in the sawdust, reads...";
	- end the story finally.

Instead of examining the trampled message:
	say "The message has been carelessly trampled, making it difficult to read. You can just distinguish the words...";
	end the story saying "You have lost".

Instead of doing something other than going in the bar when in darkness:
	if the message is not trampled, now the neatness of the message is the neatness after the neatness of the message;
	say "In the dark? You could easily disturb something."

Instead of going nowhere from the bar when in darkness:
	now the message is trampled;
	say "Blundering around in the dark isn't a good idea!"

The player wears a velvet cloak. The cloak can be hung or unhung. Understand "dark" or "black" or "satin" as the cloak. The description of the cloak is "A handsome cloak, of velvet trimmed with satin, and slightly splattered with raindrops. Its blackness is so deep that it almost seems to suck light from the room."

Carry out taking the cloak:
	now the bar is dark.

Carry out putting the unhung cloak on something in the cloakroom:
	now the cloak is hung;
	increment score.

Carry out putting the cloak on something in the cloakroom:
	now the bar is lit.

Carry out dropping the cloak in the cloakroom:
	now the bar is lit.

Instead of dropping or putting the cloak on when the player is not in the cloakroom:
	say "This isn't the best place to leave a smart cloak lying around."

When play begins:
	say "`paragraph break`Hurrying through the rainswept November night, you're glad to see the bright lights of the Opera House. It's surprising that there aren't more people about but, hey, what do you expect in a cheap demo game...?" 

Understand "hang `something preferably held` on `something`" as putting it on.

Test me with "s / n / w / inventory / hang cloak on hook / e / s / read message".
