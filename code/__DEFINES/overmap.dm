#define OVERMAP_GENERATOR_SOLAR "solar_system"
#define OVERMAP_GENERATOR_RANDOM "random"

// Star spectral types. A star's visible color is based on this.
// Only loosely adherent to real spectral types, because real spectral types
// are actually just a tool for classifying stellar emission spectra and
// don't exactly correspond to different "types" of star.
#define STAR_O 0 // Very hot/bright blue giant (IRL some of these are main-sequence)
#define STAR_B 1 // Bright blue main sequence star / blue giant / white dwarf
#define STAR_A 2 // Light blue main sequence star / cool blue giant/dwarf
#define STAR_F 3 // White main sequence star
#define STAR_G 4 // Yellow main sequence star / yellow giant
#define STAR_K 5 // Orange main sequence star / hot red giant
#define STAR_M 6 // Red dwarf or red giant
#define STAR_L 7 // Cool red dwarf/giant OR very warm brown dwarf
#define STAR_T 8 // Medium brown dwarf
#define STAR_Y 9 // Very cool brown dwarf

//Amount of times the overmap generator will attempt to place something before giving up
#define MAX_OVERMAP_PLACEMENT_ATTEMPTS 5

//Possible dynamic encounter types
#define DYNAMIC_WORLD_LAVA "lava" //base planets
#define DYNAMIC_WORLD_ICE "ice"
#define DYNAMIC_WORLD_SAND "sand"
#define DYNAMIC_WORLD_JUNGLE "jungle"

#define DYNAMIC_WORLD_ROCKPLANET "rockplanet" //wacky planets
#define DYNAMIC_WORLD_BEACHPLANET "beachplanet"
#define DYNAMIC_WORLD_WASTEPLANET "wasteplanet"

#define DYNAMIC_WORLD_REEBE "reebe" //celestial bodies
#define DYNAMIC_WORLD_ASTEROID "asteroid"
#define DYNAMIC_WORLD_SPACERUIN "space"

//Если бы я мог
//Я бы вынес всё это отдельно
//Но кодеры говнокодеры
#define DYNAMIC_WORLD_RANDOM "random" // Не внесён в динамик лист
#define DYNAMIC_WORLD_RUINED_CITY "ruined_city"
#define DYNAMIC_WORLD_ROBOTIC_GUARDIANS "robotic_guardians"
#define DYNAMIC_WORLD_BARREN "barren"
#define DYNAMIC_WORLD_CHLORINE "chlorine"
#define DYNAMIC_WORLD_BAYDESERT "baydesert" // BAYDESERT а не DESERT потому что в шиптесте уже есть пустыня
#define DYNAMIC_WORLD_GRASS "grass"
#define DYNAMIC_WORLD_GRASS_TERRAFORMED "grass_terraformed"
#define DYNAMIC_WORLD_SHROUDED "shrouded"
#define DYNAMIC_WORLD_SNOW "snow"
#define DYNAMIC_WORLD_VOLCANIC "volcanic" // Не внесён в динамик лист

/// Make sure you are adding new planet types to this, in order as seen above preferrably
#define DYNAMIC_WORLD_LIST_ALL list(\
	DYNAMIC_WORLD_LAVA,\
	DYNAMIC_WORLD_ICE,\
	DYNAMIC_WORLD_SAND,\
	DYNAMIC_WORLD_JUNGLE,\
	DYNAMIC_WORLD_ROCKPLANET,\
	DYNAMIC_WORLD_BEACHPLANET,\
	DYNAMIC_WORLD_WASTEPLANET,\
	DYNAMIC_WORLD_REEBE,\
	DYNAMIC_WORLD_ASTEROID,\
	DYNAMIC_WORLD_SPACERUIN)
/*
// Потом это добавлю
	DYNAMIC_WORLD_RUINED_CITY,\
	DYNAMIC_WORLD_ROBOTIC_GUARDIANS,\
	DYNAMIC_WORLD_BARREN,\
	DYNAMIC_WORLD_CHLORINE,\
	DYNAMIC_WORLD_BAYDESERT,\
	DYNAMIC_WORLD_GRASS,\
	DYNAMIC_WORLD_GRASS_TERRAFORMED,\
	DYNAMIC_WORLD_SHROUDED,\
	DYNAMIC_WORLD_SNOW,\
*/

//Possible ship states
#define OVERMAP_SHIP_IDLE "idle"
#define OVERMAP_SHIP_FLYING "flying"
#define OVERMAP_SHIP_ACTING "acting"
#define OVERMAP_SHIP_DOCKING "docking"
#define OVERMAP_SHIP_UNDOCKING "undocking"

// Ship join modes. The string values are player-facing, so be careful modifying them. Be sure to update ShipSelect.js if you add to/change these!
#define SHIP_JOIN_MODE_CLOSED "Locked"
#define SHIP_JOIN_MODE_APPLY "Apply"
#define SHIP_JOIN_MODE_OPEN "Open"

// Тип входа в игру на русском
#define SHIP_JOIN_MODE_CLOSED_RU "Закрыт"
#define SHIP_JOIN_MODE_APPLY_RU "По приглашению"
#define SHIP_JOIN_MODE_OPEN_RU "Открыт"

// Ship application states. Some of the string values are player-facing, so be careful modifying them.
#define SHIP_APPLICATION_UNFINISHED "unfinished"
#define SHIP_APPLICATION_CANCELLED "cancelled"
#define SHIP_APPLICATION_PENDING "pending"
#define SHIP_APPLICATION_ACCEPTED "accepted"
#define SHIP_APPLICATION_DENIED "denied"

///Used to get the turf on the "physical" overmap representation.
#define OVERMAP_TOKEN_TURF(x_pos, y_pos) locate(SSovermap.overmap_vlevel.low_x + SSovermap.overmap_vlevel.reserved_margin + x_pos - 1, SSovermap.overmap_vlevel.low_y + SSovermap.overmap_vlevel.reserved_margin + y_pos - 1, SSovermap.overmap_vlevel.z_value)

// Burn direction defines
#define BURN_NONE 0
#define BURN_STOP -1
