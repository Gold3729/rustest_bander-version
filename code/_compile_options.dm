//#define TESTING //By using the testing("message") proc you can create debug-feedback for people with this
								//uncommented, but not visible in the release version)

//#define DATUMVAR_DEBUGGING_MODE //Enables the ability to cache datum vars and retrieve later for debugging which vars changed.

// Comment this out if you are debugging problems that might be obscured by custom error handling in world/Error
#ifdef DEBUG
#define USE_CUSTOM_ERROR_HANDLER
#endif

#ifdef TESTING
#define DATUMVAR_DEBUGGING_MODE

///Used to find the sources of harddels, quite laggy, don't be surpised if it freezes your client for a good while
//#define REFERENCE_TRACKING
#ifdef REFERENCE_TRACKING

///Run a lookup on things hard deleting by default.
//#define GC_FAILURE_HARD_LOOKUP
#ifdef GC_FAILURE_HARD_LOOKUP
#define FIND_REF_NO_CHECK_TICK
#endif //ifdef GC_FAILURE_HARD_LOOKUP

#endif //ifdef REFERENCE_TRACKING

//#define VISUALIZE_ACTIVE_TURFS //Highlights atmos active turfs in green
#endif //ifdef TESTING

//#define UNIT_TESTS //Enables unit tests via TEST_RUN_PARAMETER

#ifndef PRELOAD_RSC				//set to:
#define PRELOAD_RSC 2			//	0 to allow using external resources or on-demand behaviour;
#endif							//	1 to use the default behaviour;
								//	2 for preloading absolutely everything;

/// If this is uncommented, Autowiki will generate edits and shut down the server.
/// Prefer the autowiki build target instead.
// #define AUTOWIKI

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 514
#define MIN_COMPILER_BUILD 1556
#if DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 514.1556 or higher
#endif

//Update this whenever the byond version is stable so people stop updating to hilariously broken versions
//#define MAX_COMPILER_VERSION 514
//#define MAX_COMPILER_BUILD 1571
#if (DM_VERSION == 514 && DM_BUILD > 1575 && DM_BUILD <= 1577)
#error Your version of BYOND currently has a crashing issue that will prevent you from running Dream Daemon test servers.
#error We require developers to test their content, so an inability to test means we cannot allow the compile.
#error Please consider downgrading to 514.1575 or lower.
#endif
//Log the full sendmaps profile on 514.1556+, any earlier and we get bugs or it not existing
#if DM_VERSION >= 514 && DM_BUILD >= 1556
#define SENDMAPS_PROFILE
#endif

// Keep savefile compatibilty at minimum supported level
#if DM_VERSION >= 515
/savefile/byond_version = MIN_COMPILER_VERSION
#endif

// 515 split call for external libraries into call_ext
#if DM_VERSION < 515
#define LIBCALL call
#else
#define LIBCALL call_ext
#endif

//Additional code for the above flags.
#ifdef TESTING
#warn compiling in TESTING mode. testing() debug messages will be visible.
#endif

#ifdef CIBUILDING
#define UNIT_TESTS
#endif

#ifdef CITESTING
#define TESTING
#endif

// A reasonable number of maximum overlays an object needs
// If you think you need more, rethink it
#define MAX_ATOM_OVERLAYS 100

#define AUXMOS (world.system_type == MS_WINDOWS ? "auxmos.dll" : __detect_auxmos())

/proc/__detect_auxmos()
	var/static/auxmos_path
	if(!auxmos_path)
		if (fexists("./libauxmos.so"))
			auxmos_path = "./libauxmos.so"
		else if (fexists("./auxtools/libauxmos.so"))
			auxmos_path = "./auxtools/libauxmos.so"
		else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/libauxmos.so"))
			auxmos_path = "[world.GetConfig("env", "HOME")]/.byond/bin/libauxmos.so"
		else
			CRASH("Could not find libauxmos.so")
	return auxmos_path

// So we want to have compile time guarantees these procs exist on local type, unfortunately 515 killed the .proc/procname syntax so we have to use nameof()
#if DM_VERSION < 515
/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (.proc/##X)
/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (##TYPE.proc/##X)
/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)
#else
/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (nameof(.proc/##X))
/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)
#endif
