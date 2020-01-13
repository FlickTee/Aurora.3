/mob/living/silicon
	var/register_alarms = 1
	var/datum/nano_module/alarm_monitor/all/alarm_monitor
	var/datum/nano_module/law_manager/law_manager
	var/datum/nano_module/rcon/rcon
	var/obj/item/modular_computer/silicon/computer

/mob/living/silicon/ai
	var/datum/nano_module/computer_ntnetmonitor/ntnet_monitor

/mob/living/silicon
	var/list/silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_alarm_monitor,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/computer_interact
	)

/mob/living/silicon/ai
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_alarm_monitor,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/ai/proc/subsystem_ntnet_monitor,
		/mob/living/silicon/proc/computer_interact
	)

/mob/living/silicon/robot/syndicate
	register_alarms = 0
	silicon_subsystems = list(/mob/living/silicon/proc/subsystem_law_manager)

/mob/living/silicon/Destroy()
	QDEL_NULL(alarm_monitor)
	QDEL_NULL(law_manager)
	QDEL_NULL(computer)

	return ..()

/mob/living/silicon/ai/Destroy()
	QDEL_NULL(ntnet_monitor)

	return ..()

/mob/living/silicon/proc/init_subsystems()
	alarm_monitor 	= new(src)
	law_manager 	= new(src)
	rcon 			= new(src)

	if(!register_alarms)
		return

	for(var/datum/alarm_handler/AH in SSalarm.all_handlers)
		AH.register_alarm(src, /mob/living/silicon/proc/receive_alarm)
		queued_alarms[AH] = list()	// Makes sure alarms remain listed in consistent order

/mob/living/silicon/ai/init_subsystems()
	..()
	computer = new/obj/item/modular_computer/silicon/ai(src)
	ntnet_monitor = new(src)

/mob/living/silicon/pai/init_subsystems()
	..()
	computer = new/obj/item/modular_computer/silicon/pai(src)

/mob/living/silicon/robot/init_subsystems()
	..()
	computer = new/obj/item/modular_computer/silicon/robot(src)

/****************
*	Computer	*
*****************/
/mob/living/silicon/proc/computer_interact()
	set name = "Open Computer Interface"
	set category = "Subystems"

	computer.attack_self(src)

/mob/living/silicon/emag_act(remaining_charges, mob/user, emag_source)
	. = ..()
	computer.emag_act(remaining_charges, user, emag_source)

/********************
*	Alarm Monitor	*
********************/
/mob/living/silicon/proc/subsystem_alarm_monitor()
	set name = "Alarm Monitor"
	set category = "Subystems"

	alarm_monitor.ui_interact(usr, state = self_state)

/****************
*	Law Manager	*
****************/
/mob/living/silicon/proc/subsystem_law_manager()
	set name = "Law Manager"
	set category = "Subystems"

	law_manager.ui_interact(usr, state = conscious_state)

/********************
*	NTNet Monitor	*
********************/
/mob/living/silicon/ai/proc/subsystem_ntnet_monitor()
	set name = "NTNet Monitoring"
	set category = "Subystems"

	ntnet_monitor.ui_interact(usr, state = conscious_state)