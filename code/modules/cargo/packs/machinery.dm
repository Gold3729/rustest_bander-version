/datum/supply_pack/machinery
	group = "Оборудование"
	crate_type = /obj/structure/closet/crate/engineering

/*
		Parts
*/

/datum/supply_pack/machinery/lightbulbs
	name = "Лампочки"
	desc = "На случай тотального блэкаута. Содержит 3 коробки с лампочками."
	cost = COST_MIN * 1000
	contains = list(/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed)
	crate_name = "replacement lights"
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/machinery/t1
	name = "Детали - Т1"
	desc = "Сама жизнь машин."
	cost = COST_MIN * 500
	contains = list(/obj/item/storage/box/stockparts/basic)
	crate_name = "\improper T2 parts crate"
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/machinery/t2
	name = "Детали - Т2"
	desc = "Чуть получше Т1."
	cost = COST_MIN * 7500
	contains = list(/obj/item/storage/box/stockparts/t2)
	crate_name = "\improper T2 parts crate"
	crate_type = /obj/structure/closet/crate/science

/datum/supply_pack/machinery/t3
	name = "Детали - Т3"
	desc = "Считались самыми лучшими до изучения блюспейс."
	cost = COST_MED * 15000
	contains = list(/obj/item/storage/box/stockparts/t3)
	crate_name = "\improper T3 parts crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/machinery/t4
	name = "Детали - Т4"
	desc = "Пик технологий."
	cost = COST_HIGH * 20000
	contains = list(/obj/item/storage/box/stockparts/t4)
	crate_name = "\improper T4 parts crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/machinery/t5
	name = "Детали - Т5"
	desc = "Технологии Триглава были совмещены с имеющимися у нас технологиями. Результатом стал технологический прорыв во всех областях."
	cost = COST_HIGH * 30000
	contains = list(/obj/item/storage/box/stockparts/t5)
	crate_name = "\improper T5 parts crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/machinery/power
	name = "Power Cell Crate"
	desc = "Looking for power overwhelming? Look no further. Contains three high-voltage power cells."
	cost = COST_MIN * 1000
	contains = list(/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high)
	crate_name = "power cell crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/*
		Atmospherics
*/

/datum/supply_pack/machinery/space_heater
	name = "Space Heater Crate"
	desc = "Contains a single space heater-cooler, for when things get too cold / hot to handle."
	cost = COST_MIN * 500
	contains = list(/obj/machinery/space_heater)
	crate_name = "space heater crate"

/datum/supply_pack/machinery/thermomachine
	name = "Thermomachine Crate"
	desc = "Freeze or heat your air."
	cost = COST_MED * 2000
	contains = list(/obj/item/circuitboard/machine/thermomachine,
					/obj/item/circuitboard/machine/thermomachine)
	crate_name = "thermomachine crate"

/datum/supply_pack/machinery/portapump
	name = "Portable Air Pump Crate"
	desc = "Want to drain a room of air without losing a drop? We've got you covered. Contains two portable air pumps."
	cost = COST_MIN * 3000
	contains = list(/obj/machinery/portable_atmospherics/pump,
					/obj/machinery/portable_atmospherics/pump)
	crate_name = "portable air pump crate"

/datum/supply_pack/machinery/portascrubber
	name = "Portable Scrubber Crate"
	desc = "Clean up that pesky plasma leak with your very own set of two portable scrubbers."
	cost = COST_MIN * 3000
	contains = list(/obj/machinery/portable_atmospherics/scrubber,
					/obj/machinery/portable_atmospherics/scrubber)
	crate_name = "portable scrubber crate"

/datum/supply_pack/machinery/hugescrubber
	name = "Huge Portable Scrubber Crate"
	desc = "A huge portable scrubber for huge atmospherics mistakes."
	cost = COST_MIN * 5000
	contains = list(/obj/machinery/portable_atmospherics/scrubber/huge/movable/cargo)
	crate_name = "huge portable scrubber crate"
	crate_type = /obj/structure/closet/crate/large

/*
		Bots
*/

/datum/supply_pack/machinery/mule
	name = "MULEbot Crate"
	desc = "Pink-haired Quartermaster not doing her job? Replace her with this tireless worker, today!"
	cost = COST_MIN * 2000
	contains = list(/mob/living/simple_animal/bot/mulebot)
	crate_name = "\improper MULEbot Crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/machinery/robotics
	name = "Robotics Assembly Crate"
	desc = "The tools you need to replace those finicky humans with a loyal robot army! Contains four proximity sensors, four robotic arms, two empty first aid kits, two health analyzers, two red hardhats, two mechanical toolboxes, and two cleanbot assemblies!"
	cost = COST_MIN * 2500 // maybe underpriced ? unsure
	contains = list(/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/bodypart/r_arm/robot/surplus,
					/obj/item/bodypart/r_arm/robot/surplus,
					/obj/item/bodypart/r_arm/robot/surplus,
					/obj/item/bodypart/r_arm/robot/surplus,
					/obj/item/storage/firstaid,
					/obj/item/storage/firstaid,
					/obj/item/healthanalyzer,
					/obj/item/healthanalyzer,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/bot_assembly/cleanbot,
					/obj/item/bot_assembly/cleanbot)
	crate_name = "robotics assembly crate"
	crate_type = /obj/structure/closet/crate/science

/*
		Miscellaneous machines
*/

/datum/supply_pack/machinery/breach_shield_gen
	name = "Anti-breach Shield Projector Crate"
	desc = "Hull breaches again? Say no more with the Nanotrasen Anti-Breach Shield Projector! Uses forcefield technology to keep the air in, and the space out. Contains two shield projectors."
	cost = COST_MED * 2500
	contains = list(/obj/machinery/shieldgen,
					/obj/machinery/shieldgen)
	crate_name = "anti-breach shield projector crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/machinery/wall_shield_gen
	name = "Shield Generator Crate"
	desc = "These four shield wall generators are guaranteed to keep any unwanted lifeforms on the outside, where they belong! Not rated for containing singularities or tesla balls."
	cost = COST_MED * 2000
	contains = list(/obj/machinery/power/shieldwallgen,
					/obj/machinery/power/shieldwallgen,
					/obj/machinery/power/shieldwallgen,
					/obj/machinery/power/shieldwallgen)
	crate_name = "shield generators crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/machinery/blackmarket_telepad
	name = "Black Market LTSRBT"
	desc = "Need a faster and better way of transporting your illegal goods from and to the sector? Fear not, the Long-To-Short-Range-Bluespace-Transceiver (LTSRBT for short) is here to help. Contains a LTSRBT circuit, two bluespace crystals, and one ansible."
	cost = COST_HIGH * 5000
	contains = list(
		/obj/item/circuitboard/machine/ltsrbt,
		/obj/item/stack/ore/bluespace_crystal/artificial,
		/obj/item/stack/ore/bluespace_crystal/artificial,
		/obj/item/stock_parts/subspace/ansible
	)
	crate_type = /obj/structure/closet/crate/science

/datum/supply_pack/machinery/shuttle_in_a_box
	name = "Shuttle in a Box"
	desc = "The bare minimum amount of machine and computer boards required to create a working spacecraft."
	cost = COST_HIGH * 8000
	contains = list(
		/obj/item/circuitboard/computer/shuttle/helm,
		/obj/item/circuitboard/machine/shuttle/smes,
		/obj/item/circuitboard/machine/shuttle/engine/electric,
		/obj/item/shuttle_creator
	)
	crate_name = "Shuttle in a Box"

/*
		Power generation machines
*/

/datum/supply_pack/machinery/pacman
	name = "P.A.C.M.A.N Generator Crate"
	desc = "Engineers can't set up the engine? Not an issue for you, once you get your hands on this P.A.C.M.A.N. Generator! Takes in plasma and spits out sweet sweet energy."
	cost = COST_MIN * 2500
	contains = list(/obj/machinery/power/port_gen/pacman)
	crate_name = "PACMAN generator crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/machinery/solar
	name = "Solar Panel Crate"
	desc = "Go green with this DIY advanced solar array. Contains twenty one solar assemblies, a solar-control circuit board, and tracker. If you have any questions, please check out the enclosed instruction book."
	cost = COST_MIN * 2500
	contains  = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/circuitboard/computer/solar_control,
					/obj/item/electronics/tracker,
					/obj/item/paper/guides/jobs/engi/solars)
	crate_name = "solar panel crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/machinery/teg
	name = "Thermoelectric Generator Crate"
	desc = "Turn heat into electricity! Warranty void if sneezed upon."
	cost = COST_MIN * 5000
	contains = list(/obj/item/circuitboard/machine/generator,
					/obj/item/circuitboard/machine/circulator,
					/obj/item/circuitboard/machine/circulator)
	crate_name = "thermoelectric generator crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/machinery/collector
	name = "Radiation Collector Crate"
	desc = "Contains three radiation collectors. Put that radiation to work on something other than your DNA!"
	cost = COST_MIN * 3000
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	crate_name = "collector crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/machinery/tesla_coils
	name = "Tesla Coil Crate"
	desc = "Whether it's high-voltage executions, creating research points, or just plain old power generation, this pack of four Tesla coils can do it all!"
	cost = COST_MIN * 2500
	contains = list(/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil)
	crate_name = "tesla coil crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/*
		Additional engine machines
*/

/datum/supply_pack/machinery/emitter
	name = "Emitter Crate"
	desc = "Useful for powering forcefield generators while destroying locked crates and intruders alike. Contains two high-powered energy emitters."
	cost = COST_MED * 3000
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	crate_name = "emitter crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/machinery/field_gen
	name = "Field Generator Crate"
	desc = "Contains two high-powered field generators, crucial for containing singularities and tesla balls. Must be powered by emitters."
	cost = COST_MED * 2000
	contains = list(/obj/machinery/field/generator,
					/obj/machinery/field/generator)
	crate_name = "field generator crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/machinery/grounding_rods
	name = "Grounding Rod Crate"
	desc = "Four grounding rods guaranteed to keep any uppity tesla's lightning under control."
	cost = COST_MED * 1750
	contains = list(/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod)
	crate_name = "grounding rod crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/machinery/PA
	name = "Particle Accelerator Crate"
	desc = "A supermassive black hole or hyper-powered teslaball are the perfect way to spice up any party! This \"My First Apocalypse\" kit contains everything you need to build your own particle accelerator! Ages 10 and up."
	cost = COST_HIGH * 3000
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	crate_name = "particle accelerator crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/*
		Engine cores
*/

/datum/supply_pack/machinery/sing_gen
	name = "Singularity Generator Crate"
	desc = "The key to unlocking the power of Lord Singuloth. Particle accelerator not included."
	cost = COST_HIGH * 15000
	contains = list(/obj/machinery/the_singularitygen)
	crate_name = "singularity generator crate"
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/supply_pack/machinery/supermatter_shard
	name = "Supermatter Shard Crate"
	desc = "The power of the heavens condensed into a single crystal."
	cost = COST_HIGH * 20000
	contains = list(/obj/machinery/power/supermatter_crystal/shard)
	crate_name = "supermatter shard crate"
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/supply_pack/machinery/tesla_gen
	name = "Tesla Generator Crate"
	desc = "The stabilized heart of a tesla engine. Particle accelerator not included."
	cost = COST_HIGH * 16000
	contains = list(/obj/machinery/the_singularitygen/tesla)
	crate_name = "tesla generator crate"
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/supply_pack/machinery/mechcomp
	name = "Ящик деталей MechComp"
	desc = "Содержит внутри Goon интегралки для создания своих неповторимых кастомных систем."
	cost = COST_MED * 5000
	contains = list(/obj/item/mechcomp/button = 10,
					/obj/item/mechcomp/delay = 15,
					/obj/item/mechcomp/speaker = 5,
					/obj/item/mechcomp/textpad = 5,
					/obj/item/mechcomp/pressurepad = 3,
					/obj/item/mechcomp/grav_accelerator = 1,
					/obj/item/mechcomp/math = 30,
					/obj/item/mechcomp/list_packer = 10,
					/obj/item/mechcomp/list_extractor = 10,
					/obj/item/mechcomp/find_regex = 5,
					/obj/item/mechcomp/timer = 1,
					/obj/item/mechcomp/microphone = 3,
					/obj/item/mechcomp/teleport = 2,
					/obj/structure/disposalconstruct/mechcomp = 1,
					/obj/item/multitool/mechcomp = 1)
	crate_name = "ящик с MechComp"
	crate_type = /obj/structure/closet/crate/secure/engineering
