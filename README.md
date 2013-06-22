Let's work on the Owner Hud!
===========================

New Goals: (3.900)

- New collar link direct to RLV main menu - Update linking into Un/Dress menu instead, Hud section written in - Done (NG)
-- Requested hook into Un/Dress Menu from Joy, along with change the main menu hook from "menuto" to "menu", this change will make the Owner hud incompatible with <3.840 collars (Joy has removed the old "menuto" code section as bad coding and rewritten) whole new "auth" system writen into collar, hud changed to reflect this. - Done (NG)
- Change llRegionSay and llSay -> llRegionSayTo - Done (NG)
- Remove all the AutoTP code since we no longer use this option in the Hud (Why did we have an option in the hud to turn AutoTP on and off?) - Done (NG)
- Adjusted the llOwnerSay string to be more descriptive by using Key2Name - EG when access to a sub called sub123, the main collar menu will respond - "Sending to Sub123 Resident's collar - menu" - Done (NG)
- Added "post" command to leash menu to bring up the collar "post menu" to display items to leash the collar to - Done (NG)
- ":" separator has been replaced with "\" so RLV commands from the HUD or cuffs are not chopped up before being actioned - Done (NG)
- removed colon from "command send" script and added to each button cmd string to enable easy TP to LM change - Done (NG)
- update cage rezzer script to use llRegionSayTo - Done (NG)
- Add leash post to cager menu
- Adjusted Animation timeout from the HUD from 30 to 60 seconds - Done (NG)

3.800 Owners hud finished items:
---------------------------------
- Updated the RLV strip code in the cages to add the extra attach/wear points - Done (NG)
- New leash/unleash/follow Menu system - Done (NG)
- Re do TP menu system working within SL limits - Done (NG)
- Clean up orphaned code in the scripts. ---- Some clean up done. (NG)
- Provide better commentary/documentation. ---- Extra help files added to hud and comments in code (NG)

- Arrange things to make it more easily for a broader spectrum of people with various skill levels to contribute to this project!
- Find someone else then wendy101 with greater skill in programming to take on pull requests, keep code in-sync with their disk and the in-world device.
- - Found someone else yes, greater programming skill no! (NG)
