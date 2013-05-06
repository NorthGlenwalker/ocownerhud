/* --- RLVRelay Cager and Strip script adapted by Betsy Hastings
--- released to the public with all permission under the
--- condition that this header remains intact and the script
--- may not be resold.
--- A simple script that uses the Restrained Life relay to force someone to sit
--- receives avatar key via link_message (already filtered for RLV users)
-----------------------------------------------------------
--- 06-17-2009 by Betsy Hastings
--- 14 July 2009 Additions by Tonya Souther:
--- Allow owner to set follow distance via menu
-----------------------------------------------------------

--- 05-06-2013 by North Glenwalker
--- Added the new attach and clothing points

-----------------------------------------------------------
*/

// ------------- Variables you might wanna change: ---------- 
vector sit_offset = <0.0,0.0,0.85>;
vector sit_rotation = <0.0,0.0,0.0>;
integer debugger = FALSE; // TRUE will send debug messages
integer timeout = 30;
string restraints = "@unsit=n|@sittp=n|@tploc=n|@tplure=n|@tplm=n|@sendim=n|@recvim=n|@acceptpermission=add";  // add or remove restrictions according to RLV protocol

// ------------------- constants & variables -----------------
integer anim_num;
integer animchannel   = 987216;
integer attachchannel = 987215;
integer clothchannel  = 987214;
integer victimactionschannel = 987213;
integer selectvictimchannel = 987212;
integer followdistchannel = 987211;
integer b;
integer i;
integer listener;
integer page;
integer pagesize = 10;
integer relaychannel = -1812221819;
integer shock;


string cmd;
string cmdname;
string first_name;
string null;
string oldanim;
string ping;
string temp_obj_name;
string victim_name;
string UNSIT = "*Unsit*";
string CLOTHMENU = "Clothes";
string ATTACHMENU = "Attachments";
string ANIMS = "Animations";
string FOLLOWDIST = "Follow dist";
string MORE = " > ";
string UPMENU = " ^ ";

key toucher;
key victimkey;
key owner;

list a;
list animations;
list buttons;
list clothpoints = [  //added Tattoo, Alpha, Physics [NG]
    "Shirt",
    "Pants",
    "Shoes",
    "Socks",
    "Jacket",
    "Gloves",
    "Undershirt",
    "Underpants",
    "Skirt",
    "Tattoo",
    "Alpha",
    "Physics"
/*,  The below are commented out because.... can you really remove skin?
        "skin",
        "eyes",
        "hair",
        "shape"
*/
        ];

list attachpoints = [  //Added Skull, Neck, Avatar Center [NG]
    "Skull",
    "Left Shoulder",
    "Right Shoulder",
    "Left Hand",
    "Right Hand",
    "Left Foot",
    "Right Foot",
    "Spine",
    "Pelvis",
    "Mouth",
    "Chin",
    "Left Ear",
    "Right Ear",
    "Left Eyeball",
    "Right Eyeball",
    "Nose",
    "R Upper Arm",
    "R Forearm",
    "L Upper Arm",
    "L Forearm",
    "Right Hip",
    "R Upper Leg",
    "R Lower Leg",
    "Left Hip",
    "L Upper Leg",
    "L Lower Leg",
    "Stomach",
    "Left Pec",
    "Right Pec",
    "Neck",
    "Avatar Center"
        ];
        
list followdistances = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "8",
    "10",
    "15",
    "20",
    "25",
    "30"
        ];

// -------------------- functions ---------------------

debug(string bugger)
{
    if (debugger)
    {
        temp_obj_name = llGetObjectName();
        llSetObjectName(llGetScriptName());
        llWhisper(0,bugger);
        llSetObjectName(temp_obj_name);
    }
}

list FillMenu(list in)
{
//adds empty buttons until the list length is multiple of 3, to max of 12
    while (llGetListLength(in) < 12 && (llGetListLength(in) % 3) != 0 )
    {
        in += [" "];
    }
    return in;
}

list RestackMenu(list in)
{
//re-orders a list so dialog buttons start in the top row
    list out = llList2List(in, 9, 11);
    out += llList2List(in, 6, 8);
    out += llList2List(in, 3, 5);
    out += llList2List(in, 0, 2);
    return out;
}

TakeOff(string cloth)
{
    string cmd = "@remoutfit:" + cloth + "=force";
    cmd = cmdname + "," + (string)victimkey  + "," + cmd;
    llSay(relaychannel, cmd);
    debug(cmd);
}

Detach(string item)
{
    string cmd = "@detach:" + item + "=force";
    cmd = cmdname + "," + (string)victimkey  + "," + cmd;
    llSay(relaychannel, cmd);
    debug(cmd);
}

AttachMenu(key id)
{
    buttons = llList2List(attachpoints, page * pagesize, ((page + 1) * pagesize) - 1);
    buttons += [MORE];
    buttons += [UPMENU];
    string prompt = "Pick an attachment to remove";
    prompt += "  (Menu will time out in " + (string)timeout + " seconds.)";
    llSetTimerEvent(timeout);
    llListenRemove(listener);//belt and suspenders
    listener = llListen(attachchannel, "", id, "");
    buttons = RestackMenu(FillMenu(buttons));
    llDialog(id, prompt, buttons, attachchannel);
}

AnimMenu(key id)
{
    animations = [];
    anim_num = llGetInventoryNumber(INVENTORY_ANIMATION);
    for (i=0;i<anim_num;++i)
    {
        animations += llGetInventoryName(INVENTORY_ANIMATION,i);
    }
    buttons = llList2List(animations, page * pagesize, ((page + 1) * pagesize) - 1);
    if (anim_num > 11)
    {
        buttons += [MORE];
    }
    buttons += [UPMENU];
    string prompt = "Pick an animation";
    prompt += "  (Menu will time out in " + (string)timeout + " seconds.)";
    llSetTimerEvent(timeout);
    llListenRemove(listener);//belt and suspenders
    listener = llListen(animchannel, "", id, "");
    buttons = RestackMenu(FillMenu(buttons));
    llDialog(id, prompt, buttons, animchannel);
}

ClothMenu(key id)
{
    buttons = llList2List(clothpoints, page * pagesize, ((page + 1) * pagesize) - 1);
//buttons += [MORE];
    buttons += [UPMENU];
    string prompt = "Pick an article of clothing to remove";
    prompt += "  (Menu will time out in " + (string)timeout + " seconds.)";
    llSetTimerEvent(timeout);
    llListenRemove(listener);//belt and suspenders
    listener = llListen(clothchannel, "", id, "");
    buttons = RestackMenu(FillMenu(buttons));
    llDialog(id, prompt, buttons, clothchannel);
}

FollowDistMenu(key id)
{
    buttons = llList2List(followdistances, page * pagesize, ((page + 1) * pagesize) - 1);
//buttons += [MORE];
    buttons += [UPMENU];
    string prompt = "How closely will the cage follow you?";
    prompt += "  (Menu will time out in " + (string)timeout + " seconds.)";
    llSetTimerEvent(timeout);
    llListenRemove(listener);//belt and suspenders
    listener = llListen(followdistchannel, "", id, "");
    buttons = RestackMenu(FillMenu(buttons));
    llDialog(id, prompt, buttons, followdistchannel);
}

GrabAv(key id)
{
    llSay(relaychannel, cmdname + "," + (string)id + "," + "@sit:" + (string)llGetKey() + "=force");
}

ControlMenu(key id)
{
    buttons = [UNSIT, CLOTHMENU, ATTACHMENU, ANIMS, "Follow", "Stay", FOLLOWDIST];
    string prompt = "Pick an option.";
    prompt += "  (Menu will time out in " + (string)timeout + " seconds.)";
    llSetTimerEvent(timeout);
    llListenRemove(listener);
    listener = llListen(victimactionschannel, "", id, "");
    buttons = RestackMenu(FillMenu(buttons));
    llDialog(id, prompt, buttons, victimactionschannel);
}

default
{
    on_rez(integer whatever)
    {
        llResetScript();
    }
    
    state_entry()
    {
        cmdname = (string)llGetKey();//don't really know why the relay uses this name param, but at least this ensures uniqueness
        ping = "ping," + cmdname + ",ping,ping";
        listener = llListen(relaychannel, "", NULL_KEY, ping);//listen for pings
        oldanim = llGetInventoryName(INVENTORY_ANIMATION,0);
        anim_num = llGetInventoryNumber(INVENTORY_ANIMATION);
        for (i=0;i<anim_num;++i)
        {
            if(llGetInventoryName(INVENTORY_ANIMATION,i) == "shock")
            {
                shock = TRUE;
            }
        }
        owner = llGetOwner();
        llSitTarget(sit_offset,llEuler2Rot(sit_rotation*DEG_TO_RAD));
    }

    touch_start(integer num)
    {
        for (i=0;i < num;++i)
        {
            toucher = llDetectedKey(i);
            if (toucher == owner)
            {//give menu of things to do to victim
                ControlMenu(toucher);
            }
            else if (toucher == victimkey)
            {//seated av clicked.  Taunt them
                llInstantMessage(victimkey, "No menu for you, you're locked in now!");
                
                if(shock)
                {
                    llStopAnimation(oldanim);
                    llStartAnimation("shock");
                    llPlaySound("Electric_shock",1.0);
                    llSleep(2.0);
                    llStopAnimation("shock");
                    llStartAnimation(oldanim);
                }
                else
                {
                    llPlaySound("Electric_shock",1.0);
                }             
            }
            else
            {
                llWhisper(0,"Sorry " + llGetSubString(llKey2Name(toucher),0,(llSubStringIndex(llKey2Name(toucher)," ")-1)) + ", but only the owner of the " + llGetObjectName() + " can access the menu.");
            }
        }
    }

    link_message(integer sender_number, integer number, string message, key id)
    {
        if (llGetSubString(message,0,8) == "victimkey")
        {
            victimkey = (key)(llGetSubString(message,9,-1));
            GrabAv(victimkey);
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        llListenRemove(listener);
        llSetTimerEvent(0.0);
        if (channel == relaychannel)
        {
            if (message == ping && llAvatarOnSitTarget() == NULL_KEY)
            {
                //pong if no one sat
                string pong = "ping," + (string)llGetOwnerKey(id) + ",!pong";
                llSay(relaychannel, pong);
            }
        }
        else if (channel == victimactionschannel)
        {
            if (message == UNSIT)
            {
                string cmd = cmdname + "," + (string)llAvatarOnSitTarget()  + ",!release";
                llSay(relaychannel, cmd);
                llUnSit(llAvatarOnSitTarget());
            }
            else if (message == CLOTHMENU)
            {
                page = 0;
                ClothMenu(id);
            }
            else if (message == ATTACHMENU)
            {
                page = 0;
                AttachMenu(id);
            }
            else if (message == ANIMS)
            {
                page = 0;
                AnimMenu(id);
            }
            else if (message == FOLLOWDIST)
            {
                page = 0;
                FollowDistMenu(id);
            }

            else if (message == "Follow")
            {
                llMessageLinked(LINK_THIS,0,"follow",owner);
            }
            else if (message == "Stay")
            {
                llMessageLinked(LINK_THIS,0,"stay",owner);
            }
        }
        else if (channel == clothchannel)
        {//send cmd to remove clothing
            if (message == UPMENU)
            {
                ControlMenu(id);
            }
            else if (~llListFindList(clothpoints, [message]))
            {//send detach cmd
                TakeOff(llToLower(message));
                ClothMenu(id);
            }
            else if (message == MORE)
            {
                page++;
                if (page * pagesize > llGetListLength(clothpoints))
                {
                    page = 0;
                }
                ClothMenu(id);
            }
        }
        else if (channel == attachchannel)
        {
            if (message == UPMENU)
            {
                ControlMenu(id);
            }
            else if (~llListFindList(attachpoints, [message]))
            {//send detach cmd
                Detach(llToLower(message));
                AttachMenu(id);
            }
            else if (message == MORE)
            {
                page++;
                if (page * pagesize > llGetListLength(attachpoints))
                {
                    page = 0;
                }
                AttachMenu(id);
            }
        }
        else if (channel == animchannel)
        {
            if (message == UPMENU)
            {
                ControlMenu(id);
            }
            else if (~llListFindList(animations, [message]))
            {
                llStopAnimation(oldanim);
                llStartAnimation(message);
                oldanim = message;
                AnimMenu(id);
            }
            else if (message == MORE)
            {
                page++;
                if (page * pagesize > llGetListLength(animations))
                {
                    page = 0;
                }
                AnimMenu(id);
            }
        }
        else if (channel == followdistchannel)
        {
            if (message == UPMENU)
            {
                ControlMenu(id);
            }
            else if (~llListFindList(followdistances, [message]))
            {
                llMessageLinked(LINK_THIS,0,"followdist"+message,owner);
            }
            else if (message == MORE)
            {
                page++;
                if (page * pagesize > llGetListLength(followdistances))
                {
                    page = 0;
                }
                FollowDistMenu(id);
            }
        }

    }

    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            if (llAvatarOnSitTarget() == victimkey)
            {
                restraints += "|@sendim:"+(string)owner+"=add|@recvim:"+(string)owner+"=add";
                cmd = cmdname + "," + (string)victimkey  + "," + restraints;
                debug("this is sent to relay: " + cmd);
                llSay(relaychannel, cmd);
                llSleep(2.0);
                victim_name = llKey2Name(victimkey);
                first_name = llGetSubString(victim_name,0,llSubStringIndex(victim_name," ")-1);
                if (llAvatarOnSitTarget())  //evaluated as true if not NULL_KEY or invalid
                {
                    llSay(0,victim_name + " is captured now by " + llKey2Name(owner) + "'s " + llGetObjectName() + ".\n" + first_name + " is prevented from teleporting and sending or receiving IM's while captured.");
                    llMessageLinked(LINK_THIS,0,"caged",NULL_KEY);
                    llRequestPermissions(victimkey, PERMISSION_TRIGGER_ANIMATION);
                }
            }
            else if (llAvatarOnSitTarget() == NULL_KEY)
            {
                string cmd = cmdname + "," + (string)llAvatarOnSitTarget()  + ",!release";
                llSay(relaychannel, cmd);
                victimkey = NULL_KEY;
                llDie();
            }
        }
    }

    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            null=(string)NULL_KEY; 
            a=llGetAnimationList(llAvatarOnSitTarget()); 
            b; 
            for (b;b<llGetListLength(a);b++)
            { 
                //sometimes it gives you a null key, it's a bug and very annoying. remove if statement when fixed. 
                if (llList2String(a,b)!= null )
                {
                   if(llList2String(a,b) != "2408fe9e-df1d-1d7d-f4ff-1384fa7b350f")
                    { 
                    llStopAnimation(llList2String(a,b));
                    }
                }
            }
            llStartAnimation(oldanim);
            llSetText("",<0,0,0>,0.0);
        }
    }


    timer()
    {
        llSetTimerEvent(0.0);
        llListenRemove(listener);
    }
}
