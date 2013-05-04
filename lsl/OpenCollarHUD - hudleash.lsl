// Leashing script for the OpenCollar Project (c)
//Licensed under the GPLv2, with the additional requirement that these scripts remain "full perms" in Second Life.  See "OpenCollar License" for details.

//New Leash menu system added by North Glenwalker

integer timeout = 90;
//MESSAGE MAP
integer COMMAND_OWNER = 500;
integer COMMAND_WEARER = 503;
integer CHAT = 505;

integer POPUP_HELP = 1001;
integer MENUNAME_REQUEST = 3000;
integer MENUNAME_RESPONSE = 3001;
integer SUBMENU = 3002;
integer MENUNAME_REMOVE = 3003;

integer DIALOG = -9000;
integer DIALOG_RESPONSE = -9001;
integer DIALOG_TIMEOUT = -9002;

integer SET_SUB = -1000;
integer SEND_CMD = -1001;
integer SEND_CMD_PICK_SUB = -1002;
integer SEND_CMD_ALL_SUBS = -1003;

integer LOCALCMD_REQUEST = -2000;
integer LOCALCMD_RESPONSE = -2001;

//Strings
string UPMENU = "^";
string MORE = ">";
string parentmenu = "Main";
string submenu = "Leashmenu";
string leash = "leash";
string currentmenu;
string subName;

//Keys
key wearer;
key owner = NULL_KEY;
key menuid;

list settings;

key ShortKey()
{    // just pick 8 random hex digits and pad the rest with 0.  Good enough for dialog uniqueness.
    string chars = "0123456789abcdef";
    integer length = 16;
    string out;
    integer n;
    for (n = 0; n < 8; n++)
    {
        integer index = (integer)llFrand(16);//yes this is correct; an integer cast rounds towards 0.  See the llFrand wiki entry.
        out += llGetSubString(chars, index, index);
    }
     
    return (key)(out + "-0000-0000-0000-000000000000");
}

key Dialog(key rcpt, string prompt, list choices, list utilitybuttons, integer page)
{
    key id = ShortKey();
    llMessageLinked(LINK_SET, DIALOG, (string)rcpt + "|" + prompt + "|" + (string)page +
 "|" + llDumpList2String(choices, "`") + "|" + llDumpList2String(utilitybuttons, "`"), id);
    return id;
}


Dialogleash(key id)
{
    currentmenu = "leashmenu";
    list buttons ;
    string text = "Grab the leash of one or all subs\n";
    text += "UnLeash a/all subs you are attached to.\n";
    
    buttons += ["leash"];    
    buttons += ["Unleash"];    
    list utility = [UPMENU];
    menuid = Dialog(id, text, buttons, utility, 0);
}

SendIM(key id, string str)
{
    if (id != NULL_KEY)
    {
        llInstantMessage(id, str);
    }
}

SaveSettings(string str, key id)
{
    list temp = llParseString2List(str, [" "], []);
    string option = llList2String(temp, 0);
    string value = llList2String(temp, 1);
    integer index = llListFindList(settings, [option]);
    if(index == -1)
    {
        settings += temp;
    }
    else
    {
        settings = llListReplaceList(settings, [value], index + 1, index + 1);
    }
    string save = llDumpList2String(settings, ",");
    if(currentmenu == "Leashmenu")
    {
        llMessageLinked(LINK_SET, SUBMENU, submenu, id);
    }
}

default
{
    state_entry()
    {
        wearer = llGetOwner();//Lets get the ID of who is wearing us
        llSleep(1.0);
        llMessageLinked(LINK_SET, MENUNAME_RESPONSE, parentmenu + "|" + submenu, NULL_KEY);
    }
       
    link_message(integer sender, integer auth, string str, key id)
    {  //only the primary owner can use this !!
        if (auth == MENUNAME_REQUEST && str == parentmenu)
        {
            llMessageLinked(LINK_SET, MENUNAME_RESPONSE, parentmenu + "|" + submenu, NULL_KEY);
        }
        else if (auth == SUBMENU && str == submenu)
        {
            Dialogleash(id);
        }
        else if (auth == DIALOG_RESPONSE)
        {
            if (id == menuid)
            {
                
                list menuparams = llParseString2List(str, ["|"], []);
                id = (key)llList2String(menuparams, 0);
                string message = llList2String(menuparams, 1);
                integer page = (integer)llList2String(menuparams, 2);
                
                if(message == UPMENU)
                {//lets go up a menu
                    llMessageLinked(LINK_SET, SUBMENU, parentmenu, id);
                }
                
                if(message == leash)
                {//reformat the "message" to the correct format to leash someone then pick who.
                 string message = "leashto " + (string)wearer + " handle";
                 llMessageLinked(LINK_SET, SEND_CMD_PICK_SUB, llToLower(message), id);
                }
                
                else if(message != " ")
                {//everything else just send the command to the picked sub. 
                    llMessageLinked(LINK_SET, SEND_CMD_PICK_SUB, llToLower(message), id);
                }
            }
        }
        else if (auth == DIALOG_TIMEOUT)
        {
            if (id == menuid)
            {
                list menuparams = llParseString2List(str, ["|"], []);
                id = (key)llList2String(menuparams, 0);
                llInstantMessage(id,"Menu timed out!");
                menuid = NULL_KEY;
            }
        }
    }
    
    on_rez(integer param)
    {     //should reset on rez to make sure the parent menu gets populated with our button
        llResetScript();
    }
}
