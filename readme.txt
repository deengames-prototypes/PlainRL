~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
                         PlainRL				   
~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
				    Table of Contents

	1. What is PlainRL?
	2. Running on Windows
	2. What's a RogueLike?
	3. Mechanics
	4. Tweakable Content
	5. Questions/Comments/Feedback/Bugs?
	
~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
                   1. What is PlainRL?
				   
PlainRL is a plain, simple RogueLike. (Not sure what a RL
is? See the next section.) Rather than any unique features
or setting or theme, it aims to implement a set of commonly
-used features and functionality.

PlainRL includes the following (this has spoilers, so skip
this section and come back later if you're keen on that):

	1. Randomly-generated dungeons
	2. Equipment (weapons, armour)
	3. Range-Weapons (bows; projectile firing)
	4. User skills (whirlwind, vortex, ruqiyyah)
	5. Weapon and range-weapon skills
	6. Combining weapons or armour together
	7. Quests
	8. Monsters that spawn other monsters
	9. Tweakable content; see the Tweakable Content section.
	10. Open-Source. All the code is here, ready for tweaking.

Assuming you're used to the standard of RogueLikes, PlainRL
differs in the following ways:

	* No gods, praying or sacrificing to any being, etc.
	* No character classes (Human, Elf, Troll, etc.)
	* No professions (Warrior, Mage, Monk, etc.)
	* No magic. Instead, there are skills.
	* No food or hunger-mangement
	* No weight-mangement of items
	* Save game does not delete when you die
	
PlainRL was meant to be plain and capture a subset of
common functionality across RogueLike games; it's also
intended to be an open-source project, so you can extend
it and take it in any direction you want. (A large amount
of in-game mechanics and data are tweakable without any
coding changes; see the Tweakable Content section.)


~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
				  2. Running on Windows
				  
I spent a lot of time trying to get PlainRL to work with
Windows; the bottom line is: If you want to run PlainRL on
Windows, then install Cygwin.

Not the best, most user-friendly solution, but it's there.
Why do I say this? Why not port it? Because:

- Ruby is source code; I can't compile and include any libraries.
- Ruby on Windows is not as good as Ruby on Linux
- Curses on Windows is not as good as Curses on Linux
- No matter which library I use (NCurses, PDCurses, etc.)
  the amount of setup is, in my opinon, not worth the effort.
  
Since most people who use Ruby are coders themselves, it shouldn't
be such a big deal for you to install Cygwin :) or if you want to
port the game over to another library like NCurses, you're welcome
to do so--just drop me an email so I can include the revised source
on my website.

~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
                 3. What's a RogueLike?
				 
If you've ever heard of Diablo, that's a roguelike game. 
Generally, it pits a character against an ever-changing dungeon
of some set number of floors, with some boss creature at the
end that needs to be defeated to complete the game. Typically,
it takes place in a fantasy setting, with swords, monsters,
magic, bows, mutliple gods, and other medievil elements.

The player can acquire quests (tasks to do which entail reward),
but ultimately, the end-of-game scenario means going down to the
depth of the dungeon; difficulty increases at each stage.

~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
					   4. Mechanics

Assuming you've tried the game out and gotten to some sort
of dungeon depth beyond 1F, it might interest you to know
the following game mechanics:

* Monsters grow in groups. There are monsters of roughly
	equal skill and power, and then the next group of
	monsters are much more powerful (but also roughly equal).
* Weapon damage is constant; it's not randomized. It depends
	on your strength, and on your weapon skill.
* Weapon skill increases with each attack. Skill is determined
	by weapon type (eg. axe)
* You can equip one piece of armour per type; default types
	are armour (body armour), helmets (headgear), etc.
* The number of shots you fire with your bow depends on your
	skill with that type of range weapon type (eg. crossbow).
	Like weapon skill, it increases with each shot you fire.
* Experience is proportional to the amount of damage you give
	and take, as well as the number of attacks you perform;
	this prevents harvesting easy monsters for high EXP.
* Skills generally increase in effectiveness as they reach
	higher levels; you heal more, and hit stronger and farther.
	
~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
				   5. Tweakable Content

A large amount of the in-game content is tweakable, without
editing source-code. Almost all of the in-game content
(weapon types, armour types and names, monster names, etc.)
is loaded from various files in the "data" folder; you can
edit these files to subsequentially change the values.

Here is a list of all those files, and their expected values:
(* indicates that you can easily change this, - indicates that
there may be more code changes required before things work.)

	* Adjectives.dat: a list of adjectives for weapons,
	  and monsters, one adjective per line.
	- Ammo.dat: a list of ammunition types. I don't advise
	  you change this, because there's lots of hard-coded
	  code that says that "bows only work with arrows and
	  crossbows only work with bolts."
	* Armour.dat: a list of armour types, one per line. The
	  number at the end of each type indicates the relative
	  defense; so armour is generally more powerful than
	  helmets. The middle word is the armour type.
	* Armour_Adjectives.dat: a list of armour adjectives,
	  one per line. These are similar to adjectives, with
	  some additions and subtractions.
	- Bosses.dat: a list of bosses, what their vitals are
	  (strength, agility, toughness), which floor they appear
	  on, and what item they drop (and how likely). You can
	  add your own bosses or change their vitals, but like ammo,
	  there is hard-coded code in dungeon.rb (under add_quest_stuff)
	  that specifies what to spawn on which floor.
	* Creatures.dat: a list of the creatures who you can
	  meet in-dungeon and fight, one creature type per line.
	* Items.dat: a list of non-valuable items you can find
	  in-dungeon (for the armourer), one per line.
	- Perks.dat: a list of perks, with description, and the
	  level you gain them on; actual logic to apply each
	  perk is implemented in-game.
	- Quests.dat: a list of quests by name, summary, 
	  description, and the person you talk to to get it.
	  Again, implementing boss-spawning (as all these quests
	  result in a boss, or other beings, being spawned) is
	  implemented in the dungeon class (under add_quest_stuff).
	- Range_Weapons.dat: the types of range weapons that
	  exist, one per line, and a relative range of each (like
	  armour/weapons). Not advisable to change, since logic
	  of which ammo goes to which range weapon type needs
	  to be changed, as well.
	- Skills.dat: a list of skills (name, description, cost,
	  character to press, and implementation). Cost can be
	  absolute, or a percentage of SP; implementation needs
	  to go into the Skill class.
	* Weapons.dat: a list of all the weapon types, one per line,
	  and relative power of each weapon. Be advised thta if you
	  add new weapons, you won't have enough space in the
	  character weapon-skill screen to see them all.
	
As you can see, there's a great deal that you can somewhat
easily change to achieve a drastically different game--even
to theme it in a completely different direction (like sci-fi).

The final file is globals.rb in the classes folder. At the
top, it contains a list of several constants that you can
change, to change in-game mechanics. For example, 
monster_item_drop and monster_weapon_drop affect the
probability of when a monster drops items or weapons.
levels_per_sight_up is how many levels you gain before your
sight increases; points_per_weapon_skill_level is how many
points you need to gain before your weapon-skill level increases.

You can tweak these as you see fit, but it may make the game
(more) imbalanced. Keep backups incase the code doesn't
compile after you changed it and you don't know how to fix it.

~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		   6. Questions/Comments/Feedback/Bugs?
~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~

I appreciate that you took the time out to try this game. If
you have any questions or comments, find any bugs, or perhaps
even have some features to request, feel free to contact me
at ashes999@yahoo.com with your feedback. (Please put PlainRL
in the subject-line, so it dodges through the spam filters.)