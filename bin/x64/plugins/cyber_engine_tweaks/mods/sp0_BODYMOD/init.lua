--Script written by Spawn0
--Copyright (c) 2022 Spawn0

local menuon = 0
local menustate = 0
local file
local modenabled
local modenable
local runonce = 0
--local modenable = true

file = io.open("enabled", "r")
if file then
  modenabled = file:read("*all")
  file:close()
else
  modenabled = nil
end

if modenabled == "1" then
  modenable = 1
else
  modenable = 0
end

file = io.open("fcitizenrandom", "r")
if file then
  fcitizenrandom = file:read("*all")
  file:close()
else
  fcitizenrandom = nil
end

if fcitizenrandom == "1" then
  fcitizenrandom = 1
else
  fcitizenrandom = 0
end

math.randomseed(os.time())

if fcitizenrandom == 0 then
	fcitizenrandomchbfr01 = false
else
	fcitizenrandomchbfr01 = true
end

--------------------- V

local chbv01
local vtab

file = io.open("venabled", "r")
local vcontents
if file then
  vcontents = file:read("*all")
  file:close()
else
  vcontents = nil
end
if not vcontents then
  chbv01 = true
  vtab = 1
else
	if vcontents == "1" then
		chbv01 = true
		vtab = 1
	end
	if vcontents == "0" then
		chbv01 = false
		vtab = 0
	end
end


local uppercontents
local lowercontents
local loadedupperbodytype = 4
local loadedlowerbodytype = 4

------------------
function v_readfiles()
file = io.open("savedupperbodytype", "r")

if file then
  uppercontents = file:read("*all")
  file:close()
else
  uppercontents = nil
end
if not uppercontents then
  loadedupperbodytype = 4
else
	if uppercontents == "1" then
		loadedupperbodytype = 1
	end
	if uppercontents == "2" then
		loadedupperbodytype = 2
	end
	if uppercontents == "3" then
		loadedupperbodytype = 3
	end
	if uppercontents == "4" then
		loadedupperbodytype = 4
	end
end


file = io.open("savedlowerbodytype", "r")
if file then
  lowercontents = file:read("*all")
  file:close()
else
  lowercontents = nil
end
if not lowercontents then
  loadedlowerbodytype = 4
else
	if lowercontents == "1" then
		loadedlowerbodytype = 1
	end
	if lowercontents == "2" then
		loadedlowerbodytype = 2
	end
	if lowercontents == "3" then
		loadedlowerbodytype = 3
	end
	if lowercontents == "4" then
		loadedlowerbodytype = 4
	end
end

file = io.open("savedmuscular", "r")
if file then
  muscularcontents = file:read("*all")
  file:close()
else
  muscularcontents = nil
end
if not muscularcontents then
  fmus01 = 0
else
  	if muscularcontents == "0" then
		fmus01 = 0
	end
	if muscularcontents == "1" then
		fmus01 = 1
	end
end
end
------------------

v_readfiles()

local setupperbodytype = loadedupperbodytype
local setlowerbodytype = loadedlowerbodytype

local chbfn01
local chbfm01
local muscularbody
local muscularbodytext

if fmus01 == 0 then
	chbfn01 = true
	chbfm01 = false
	muscularbody = ""
	muscularbodytext = ""
end
if fmus01 == 1 then
	chbfn01 = false
	chbfm01 = true
	muscularbody = "m"
	muscularbodytext = ", muscular"
end

local settext = " "..setupperbodytype.." and "..setlowerbodytype
local savetext = ""


--------------------- Female Citizens

local fcitizenchbv01
local fcitizentab

file = io.open("fcitizenenabled", "r")
local fcitizencontents
if file then
  fcitizencontents = file:read("*all")
  file:close()
else
  fcitizencontents = nil
end
if not fcitizencontents then
  fcitizenchbv01 = true
  fcitizentab = 1
else
	if fcitizencontents == "1" then
		fcitizenchbv01 = true
		fcitizentab = 1
	end
	if fcitizencontents == "0" then
		fcitizenchbv01 = false
		fcitizentab = 0
	end
end

local fcitizenuppercontents
local fcitizenlowercontents
local fcitizenloadedupperbodytype = 4
local fcitizenloadedlowerbodytype = 4

------------
function fcitizen_readfiles()
file = io.open("fcitizensavedupperbodytype", "r")

if file then
  fcitizenuppercontents = file:read("*all")
  file:close()
else
  fcitizenuppercontents = nil
end
if not fcitizenuppercontents then
  fcitizenloadedupperbodytype = 4
else
	if fcitizenuppercontents == "1" then
		fcitizenloadedupperbodytype = 1
	end
	if fcitizenuppercontents == "2" then
		fcitizenloadedupperbodytype = 2
	end
	if fcitizenuppercontents == "3" then
		fcitizenloadedupperbodytype = 3
	end
	if fcitizenuppercontents == "4" then
		fcitizenloadedupperbodytype = 4
	end
end

file = io.open("fcitizensavedlowerbodytype", "r")
if file then
  fcitizenlowercontents = file:read("*all")
  file:close()
else
  fcitizenlowercontents = nil
end
if not fcitizenlowercontents then
  fcitizenloadedlowerbodytype = 4
else
	if fcitizenlowercontents == "1" then
		fcitizenloadedlowerbodytype = 1
	end
	if fcitizenlowercontents == "2" then
		fcitizenloadedlowerbodytype = 2
	end
	if fcitizenlowercontents == "3" then
		fcitizenloadedlowerbodytype = 3
	end
	if fcitizenlowercontents == "4" then
		fcitizenloadedlowerbodytype = 4
	end
end

file = io.open("fcitizensavedmuscular", "r")
local fcitizenmuscularcontents
if file then
  fcitizenmuscularcontents = file:read("*all")
  file:close()
else
  fcitizenmuscularcontents = nil
end
if not fcitizenmuscularcontents then
  fcitizenfmus01 = 0
else
  	if fcitizenmuscularcontents == "0" then
		fcitizenfmus01 = 0
	end
	if fcitizenmuscularcontents == "1" then
		fcitizenfmus01 = 1
	end
end
end
------------
fcitizen_readfiles()

local fcitizensetupperbodytype = fcitizenloadedupperbodytype
local fcitizensetlowerbodytype = fcitizenloadedlowerbodytype

local fcitizenchbfn01
local fcitizenchbfm01
local fcitizenmuscularbody
local fcitizenmuscularbodytext

if fcitizenfmus01 == 0 then
	fcitizenchbfn01 = true
	fcitizenchbfm01 = false
	fcitizenmuscularbody = ""
	fcitizenmuscularbodytext = ""
end
if fcitizenfmus01 == 1 then
	fcitizenchbfn01 = false
	fcitizenchbfm01 = true
	fcitizenmuscularbody = "m"
	fcitizenmuscularbodytext = ", muscular"
end

local fcitizensettext = ""
local fcitizensavetext = ""

if fcitizenrandom == 0 then
	fcitizensettext = " "..fcitizensetupperbodytype.." and "..fcitizensetlowerbodytype
	fcitizensavetext = ""
end
if fcitizenrandom == 1 then
	fcitizensettext = "random not muscular"
	fcitizensavetext = ""
end



--------------------- Panam

local panamchbv01
local panamtab

file = io.open("panamenabled", "r")
local panamcontents
if file then
  panamcontents = file:read("*all")
  file:close()
else
  panamcontents = nil
end
if not panamcontents then
  panamchbv01 = true
  panamtab = 1
else
	if panamcontents == "1" then
		panamchbv01 = true
		panamtab = 1
	end
	if panamcontents == "0" then
		panamchbv01 = false
		panamtab = 0
	end
end

local panamlowercontents
local panamuppercontents
local panamloadedupperbodytype = 4
local panamloadedlowerbodytype = 4

--------------
function panam_readfiles()
file = io.open("panamsavedupperbodytype", "r")
if file then
  panamuppercontents = file:read("*all")
  file:close()
else
  panamuppercontents = nil
end
if not panamuppercontents then
  panamloadedupperbodytype = 4
else
	if panamuppercontents == "1" then
		panamloadedupperbodytype = 1
	end
	if panamuppercontents == "2" then
		panamloadedupperbodytype = 2
	end
	if panamuppercontents == "3" then
		panamloadedupperbodytype = 3
	end
	if panamuppercontents == "4" then
		panamloadedupperbodytype = 4
	end
end

file = io.open("panamsavedlowerbodytype", "r")

if file then
  panamlowercontents = file:read("*all")
  file:close()
else
  panamlowercontents = nil
end
if not panamlowercontents then
  panamloadedlowerbodytype = 4
else
	if panamlowercontents == "1" then
		panamloadedlowerbodytype = 1
	end
	if panamlowercontents == "2" then
		panamloadedlowerbodytype = 2
	end
	if panamlowercontents == "3" then
		panamloadedlowerbodytype = 3
	end
	if panamlowercontents == "4" then
		panamloadedlowerbodytype = 4
	end
end

file = io.open("panamsavedmuscular", "r")
local panammuscularcontents
if file then
  panammuscularcontents = file:read("*all")
  file:close()
else
  panammuscularcontents = nil
end
if not panammuscularcontents then
  panamfmus01 = 0
else
  	if panammuscularcontents == "0" then
		panamfmus01 = 0
	end
	if panammuscularcontents == "1" then
		panamfmus01 = 1
	end
end
end
--------------

panam_readfiles()

local panamsetupperbodytype = panamloadedupperbodytype
local panamsetlowerbodytype = panamloadedlowerbodytype

local panamchbfn01
local panamchbfm01
local panammuscularbody
local panammuscularbodytext

if panamfmus01 == 0 then
	panamchbfn01 = true
	panamchbfm01 = false
	panammuscularbody = ""
	panammuscularbodytext = ""
end
if panamfmus01 == 1 then
	panamchbfn01 = false
	panamchbfm01 = true
	panammuscularbody = "m"
	panammuscularbodytext = ", muscular"
end

local panamsettext = " "..panamsetupperbodytype.." and "..panamsetlowerbodytype
local panamsavetext = ""

--------------------- Judy

local judychbv01
local judytab

file = io.open("judyenabled", "r")
local judycontents
if file then
  judycontents = file:read("*all")
  file:close()
else
  judycontents = nil
end
if not judycontents then
  judychbv01 = true
  judytab = 1
else
	if judycontents == "1" then
		judychbv01 = true
		judytab = 1
	end
	if judycontents == "0" then
		judychbv01 = false
		judytab = 0
	end
end

local judyuppercontents
local judylowercontents
local judyloadedupperbodytype = 4
local judyloadedlowerbodytype = 4

-----------------
function judy_readfiles()
file = io.open("judysavedupperbodytype", "r")
if file then
  judyuppercontents = file:read("*all")
  file:close()
else
  judyuppercontents = nil
end
if not judyuppercontents then
  judyloadedupperbodytype = 4
else
	if judyuppercontents == "1" then
		judyloadedupperbodytype = 1
	end
	if judyuppercontents == "2" then
		judyloadedupperbodytype = 2
	end
	if judyuppercontents == "3" then
		judyloadedupperbodytype = 3
	end
	if judyuppercontents == "4" then
		judyloadedupperbodytype = 4
	end
end

file = io.open("judysavedlowerbodytype", "r")
if file then
  judylowercontents = file:read("*all")
  file:close()
else
  judylowercontents = nil
end
if not judylowercontents then
  judyloadedlowerbodytype = 4
else
	if judylowercontents == "1" then
		judyloadedlowerbodytype = 1
	end
	if judylowercontents == "2" then
		judyloadedlowerbodytype = 2
	end
	if judylowercontents == "3" then
		judyloadedlowerbodytype = 3
	end
	if judylowercontents == "4" then
		judyloadedlowerbodytype = 4
	end
end

file = io.open("judysavedmuscular", "r")
local judymuscularcontents
if file then
  judymuscularcontents = file:read("*all")
  file:close()
else
  judymuscularcontents = nil
end
if not judymuscularcontents then
  judyfmus01 = 0
else
  	if judymuscularcontents == "0" then
		judyfmus01 = 0
	end
	if judymuscularcontents == "1" then
		judyfmus01 = 1
	end
end
end
--------------
judy_readfiles()

local judysetupperbodytype = judyloadedupperbodytype
local judysetlowerbodytype = judyloadedlowerbodytype

local judychbfn01
local judychbfm01
local judymuscularbody
local judymuscularbodytext

if judyfmus01 == 0 then
	judychbfn01 = true
	judychbfm01 = false
	judymuscularbody = ""
	judymuscularbodytext = ""
end
if judyfmus01 == 1 then
	judychbfn01 = false
	judychbfm01 = true
	judymuscularbody = "m"
	judymuscularbodytext = ", muscular"
end

local judysettext = " "..judysetupperbodytype.." and "..judysetlowerbodytype
local judysavetext = ""

--------------------- EVE

local evechbv01
local evetab

file = io.open("eveenabled", "r")
local evecontents
if file then
  evecontents = file:read("*all")
  file:close()
else
  evecontents = nil
end
if not evecontents then
  evechbv01 = true
  evetab = 1
else
	if evecontents == "1" then
		evechbv01 = true
		evetab = 1
	end
	if evecontents == "0" then
		evechbv01 = false
		evetab = 0
	end
end

local eveuppercontents
local evelowercontents
local eveloadedupperbodytype = 4
local eveloadedlowerbodytype = 4

--------------
function eve_readfiles()
file = io.open("evesavedupperbodytype", "r")
if file then
  eveuppercontents = file:read("*all")
  file:close()
else
  eveuppercontents = nil
end
if not eveuppercontents then
  eveloadedupperbodytype = 4
else
	if eveuppercontents == "1" then
		eveloadedupperbodytype = 1
	end
	if eveuppercontents == "2" then
		eveloadedupperbodytype = 2
	end
	if eveuppercontents == "3" then
		eveloadedupperbodytype = 3
	end
	if eveuppercontents == "4" then
		eveloadedupperbodytype = 4
	end
end

file = io.open("evesavedlowerbodytype", "r")
if file then
  evelowercontents = file:read("*all")
  file:close()
else
  evelowercontents = nil
end
if not evelowercontents then
  eveloadedlowerbodytype = 4
else
	if evelowercontents == "1" then
		eveloadedlowerbodytype = 1
	end
	if evelowercontents == "2" then
		eveloadedlowerbodytype = 2
	end
	if evelowercontents == "3" then
		eveloadedlowerbodytype = 3
	end
	if evelowercontents == "4" then
		eveloadedlowerbodytype = 4
	end
end

file = io.open("evesavedmuscular", "r")
local evemuscularcontents
if file then
  evemuscularcontents = file:read("*all")
  file:close()
else
  evemuscularcontents = nil
end
if not evemuscularcontents then
  evefmus01 = 0
else
  	if evemuscularcontents == "0" then
		evefmus01 = 0
	end
	if evemuscularcontents == "1" then
		evefmus01 = 1
	end
end
end
--------------
eve_readfiles()

local evesetupperbodytype = eveloadedupperbodytype
local evesetlowerbodytype = eveloadedlowerbodytype

local evechbfn01
local evechbfm01
local evemuscularbody
local evemuscularbodytext

if evefmus01 == 0 then
	evechbfn01 = true
	evechbfm01 = false
	evemuscularbody = ""
	evemuscularbodytext = ""
end
if evefmus01 == 1 then
	evechbfn01 = false
	evechbfm01 = true
	evemuscularbody = "m"
	evemuscularbodytext = ", muscular"
end

local evesettext = " "..evesetupperbodytype.." and "..evesetlowerbodytype
local evesavetext = ""


--------------------- ALT

local altchbv01
local alttab

file = io.open("altenabled", "r")
local altcontents
if file then
  altcontents = file:read("*all")
  file:close()
else
  altcontents = nil
end
if not altcontents then
  altchbv01 = true
  alttab = 1
else
	if altcontents == "1" then
		altchbv01 = true
		alttab = 1
	end
	if altcontents == "0" then
		altchbv01 = false
		alttab = 0
	end
end

local altuppercontents
local altlowercontents
local altloadedupperbodytype = 4
local altloadedlowerbodytype = 4

----------------
function alt_readfiles()
file = io.open("altsavedupperbodytype", "r")
if file then
  altuppercontents = file:read("*all")
  file:close()
else
  altuppercontents = nil
end
if not altuppercontents then
  altloadedupperbodytype = 4
else
	if altuppercontents == "1" then
		altloadedupperbodytype = 1
	end
	if altuppercontents == "2" then
		altloadedupperbodytype = 2
	end
	if altuppercontents == "3" then
		altloadedupperbodytype = 3
	end
	if altuppercontents == "4" then
		altloadedupperbodytype = 4
	end
end

file = io.open("altsavedlowerbodytype", "r")

if file then
  altlowercontents = file:read("*all")
  file:close()
else
  altlowercontents = nil
end
if not altlowercontents then
  altloadedlowerbodytype = 4
else
	if altlowercontents == "1" then
		altloadedlowerbodytype = 1
	end
	if altlowercontents == "2" then
		altloadedlowerbodytype = 2
	end
	if altlowercontents == "3" then
		altloadedlowerbodytype = 3
	end
	if altlowercontents == "4" then
		altloadedlowerbodytype = 4
	end
end

file = io.open("altsavedmuscular", "r")
local altmuscularcontents
if file then
  altmuscularcontents = file:read("*all")
  file:close()
else
  altmuscularcontents = nil
end
if not altmuscularcontents then
  altfmus01 = 0
else
  	if altmuscularcontents == "0" then
		altfmus01 = 0
	end
	if altmuscularcontents == "1" then
		altfmus01 = 1
	end
end
end
------------------

alt_readfiles()

local altsetupperbodytype = altloadedupperbodytype
local altsetlowerbodytype = altloadedlowerbodytype

local altchbfn01
local altchbfm01
local altmuscularbody
local altmuscularbodytext

if altfmus01 == 0 then
	altchbfn01 = true
	altchbfm01 = false
	altmuscularbody = ""
	altmuscularbodytext = ""
end
if altfmus01 == 1 then
	altchbfn01 = false
	altchbfm01 = true
	altmuscularbody = "m"
	altmuscularbodytext = ", muscular"
end

local altsettext = " "..altsetupperbodytype.." and "..altsetlowerbodytype
local altsavetext = ""


--------------------- Rogue

local roguechbv01
local roguetab

file = io.open("rogueenabled", "r")
local roguecontents
if file then
  roguecontents = file:read("*all")
  file:close()
else
  roguecontents = nil
end
if not roguecontents then
  roguechbv01 = true
  roguetab = 1
else
	if roguecontents == "1" then
		roguechbv01 = true
		roguetab = 1
	end
	if roguecontents == "0" then
		roguechbv01 = false
		roguetab = 0
	end
end

local rogueuppercontents
local roguelowercontents
local rogueloadedupperbodytype = 4
local rogueloadedlowerbodytype = 4

------------
function rogue_readlifes()
file = io.open("roguesavedupperbodytype", "r")

if file then
  rogueuppercontents = file:read("*all")
  file:close()
else
  rogueuppercontents = nil
end
if not rogueuppercontents then
  rogueloadedupperbodytype = 4
else
	if rogueuppercontents == "1" then
		rogueloadedupperbodytype = 1
	end
	if rogueuppercontents == "2" then
		rogueloadedupperbodytype = 2
	end
	if rogueuppercontents == "3" then
		rogueloadedupperbodytype = 3
	end
	if rogueuppercontents == "4" then
		rogueloadedupperbodytype = 4
	end
end

file = io.open("roguesavedlowerbodytype", "r")
if file then
  roguelowercontents = file:read("*all")
  file:close()
else
  roguelowercontents = nil
end
if not roguelowercontents then
  rogueloadedlowerbodytype = 4
else
	if roguelowercontents == "1" then
		rogueloadedlowerbodytype = 1
	end
	if roguelowercontents == "2" then
		rogueloadedlowerbodytype = 2
	end
	if roguelowercontents == "3" then
		rogueloadedlowerbodytype = 3
	end
	if roguelowercontents == "4" then
		rogueloadedlowerbodytype = 4
	end
end

file = io.open("roguesavedmuscular", "r")
local roguemuscularcontents
if file then
  roguemuscularcontents = file:read("*all")
  file:close()
else
  roguemuscularcontents = nil
end
if not roguemuscularcontents then
  roguefmus01 = 0
else
  	if roguemuscularcontents == "0" then
		roguefmus01 = 0
	end
	if roguemuscularcontents == "1" then
		roguefmus01 = 1
	end
end
end
------------
rogue_readlifes()

local roguesetupperbodytype = rogueloadedupperbodytype
local roguesetlowerbodytype = rogueloadedlowerbodytype

local roguechbfn01
local roguechbfm01
local roguemuscularbody
local roguemuscularbodytext

if roguefmus01 == 0 then
	roguechbfn01 = true
	roguechbfm01 = false
	roguemuscularbody = ""
	roguemuscularbodytext = ""
end
if roguefmus01 == 1 then
	roguechbfn01 = false
	roguechbfm01 = true
	roguemuscularbody = "m"
	roguemuscularbodytext = ", muscular"
end

local roguesettext = " "..roguesetupperbodytype.." and "..roguesetlowerbodytype
local roguesavetext = ""


--------------------- Hanako

local hanakochbv01
local hanakotab

file = io.open("hanakoenabled", "r")
local hanakocontents
if file then
  hanakocontents = file:read("*all")
  file:close()
else
  hanakocontents = nil
end
if not hanakocontents then
  hanakochbv01 = true
  hanakotab = 1
else
	if hanakocontents == "1" then
		hanakochbv01 = true
		hanakotab = 1
	end
	if hanakocontents == "0" then
		hanakochbv01 = false
		hanakotab = 0
	end
end

local hanakouppercontents
local hanakolowercontents
local hanakoloadedupperbodytype = 4
local hanakoloadedlowerbodytype = 4

-----------
function hanako_readfiles()
file = io.open("hanakosavedupperbodytype", "r")
if file then
  hanakouppercontents = file:read("*all")
  file:close()
else
  hanakouppercontents = nil
end
if not hanakouppercontents then
  hanakoloadedupperbodytype = 4
else
	if hanakouppercontents == "1" then
		hanakoloadedupperbodytype = 1
	end
	if hanakouppercontents == "2" then
		hanakoloadedupperbodytype = 2
	end
	if hanakouppercontents == "3" then
		hanakoloadedupperbodytype = 3
	end
	if hanakouppercontents == "4" then
		hanakoloadedupperbodytype = 4
	end
end

file = io.open("hanakosavedlowerbodytype", "r")
if file then
  hanakolowercontents = file:read("*all")
  file:close()
else
  hanakolowercontents = nil
end
if not hanakolowercontents then
  hanakoloadedlowerbodytype = 4
else
	if hanakolowercontents == "1" then
		hanakoloadedlowerbodytype = 1
	end
	if hanakolowercontents == "2" then
		hanakoloadedlowerbodytype = 2
	end
	if hanakolowercontents == "3" then
		hanakoloadedlowerbodytype = 3
	end
	if hanakolowercontents == "4" then
		hanakoloadedlowerbodytype = 4
	end
end

file = io.open("hanakosavedmuscular", "r")
local hanakomuscularcontents
if file then
  hanakomuscularcontents = file:read("*all")
  file:close()
else
  hanakomuscularcontents = nil
end
if not hanakomuscularcontents then
  hanakofmus01 = 0
else
  	if hanakomuscularcontents == "0" then
		hanakofmus01 = 0
	end
	if hanakomuscularcontents == "1" then
		hanakofmus01 = 1
	end
end
end
-----------------
hanako_readfiles()

local hanakosetupperbodytype = hanakoloadedupperbodytype
local hanakosetlowerbodytype = hanakoloadedlowerbodytype

local hanakochbfn01
local hanakochbfm01
local hanakomuscularbody
local hanakomuscularbodytext

if hanakofmus01 == 0 then
	hanakochbfn01 = true
	hanakochbfm01 = false
	hanakomuscularbody = ""
	hanakomuscularbodytext = ""
end
if hanakofmus01 == 1 then
	hanakochbfn01 = false
	hanakochbfm01 = true
	hanakomuscularbody = "m"
	hanakomuscularbodytext = ", muscular"
end

local hanakosettext = " "..hanakosetupperbodytype.." and "..hanakosetlowerbodytype
local hanakosavetext = ""


--------------------- Stout

local stoutchbv01
local stouttab

file = io.open("stoutenabled", "r")
local stoutcontents
if file then
  stoutcontents = file:read("*all")
  file:close()
else
  stoutcontents = nil
end
if not stoutcontents then
  stoutchbv01 = true
  stouttab = 1
else
	if stoutcontents == "1" then
		stoutchbv01 = true
		stouttab = 1
	end
	if stoutcontents == "0" then
		stoutchbv01 = false
		stouttab = 0
	end
end

local stoutuppercontents
local stoutlowercontents
local stoutloadedupperbodytype = 4
local stoutloadedlowerbodytype = 4

-------------
function stout_readfiles()
file = io.open("stoutsavedupperbodytype", "r")
if file then
  stoutuppercontents = file:read("*all")
  file:close()
else
  stoutuppercontents = nil
end
if not stoutuppercontents then
  stoutloadedupperbodytype = 4
else
	if stoutuppercontents == "1" then
		stoutloadedupperbodytype = 1
	end
	if stoutuppercontents == "2" then
		stoutloadedupperbodytype = 2
	end
	if stoutuppercontents == "3" then
		stoutloadedupperbodytype = 3
	end
	if stoutuppercontents == "4" then
		stoutloadedupperbodytype = 4
	end
end

file = io.open("stoutsavedlowerbodytype", "r")

if file then
  stoutlowercontents = file:read("*all")
  file:close()
else
  stoutlowercontents = nil
end
if not stoutlowercontents then
  stoutloadedlowerbodytype = 4
else
	if stoutlowercontents == "1" then
		stoutloadedlowerbodytype = 1
	end
	if stoutlowercontents == "2" then
		stoutloadedlowerbodytype = 2
	end
	if stoutlowercontents == "3" then
		stoutloadedlowerbodytype = 3
	end
	if stoutlowercontents == "4" then
		stoutloadedlowerbodytype = 4
	end
end

file = io.open("stoutsavedmuscular", "r")
local stoutmuscularcontents
if file then
  stoutmuscularcontents = file:read("*all")
  file:close()
else
  stoutmuscularcontents = nil
end
if not stoutmuscularcontents then
  stoutfmus01 = 0
else
  	if stoutmuscularcontents == "0" then
		stoutfmus01 = 0
	end
	if stoutmuscularcontents == "1" then
		stoutfmus01 = 1
	end
end
end
------------
stout_readfiles()

local stoutsetupperbodytype = stoutloadedupperbodytype
local stoutsetlowerbodytype = stoutloadedlowerbodytype

local stoutchbfn01
local stoutchbfm01
local stoutmuscularbody
local stoutmuscularbodytext

if stoutfmus01 == 0 then
	stoutchbfn01 = true
	stoutchbfm01 = false
	stoutmuscularbody = ""
	stoutmuscularbodytext = ""
end
if stoutfmus01 == 1 then
	stoutchbfn01 = false
	stoutchbfm01 = true
	stoutmuscularbody = "m"
	stoutmuscularbodytext = ", muscular"
end

local stoutsettext = " "..stoutsetupperbodytype.." and "..stoutsetlowerbodytype
local stoutsavetext = ""


-------------- Misty

local mistychbv01
local mistytab

file = io.open("mistyenabled", "r")
local mistycontents
if file then
  mistycontents = file:read("*all")
  file:close()
else
  mistycontents = nil
end
if not mistycontents then
  mistychbv01 = true
  mistytab = 1
else
	if mistycontents == "1" then
		mistychbv01 = true
		mistytab = 1
	end
	if mistycontents == "0" then
		mistychbv01 = false
		mistytab = 0
	end
end

local mistyuppercontents
local mistylowercontents
local mistyloadedupperbodytype = 4
local mistyloadedlowerbodytype = 4

-------------
function misty_readfiles()
file = io.open("mistysavedupperbodytype", "r")
if file then
  mistyuppercontents = file:read("*all")
  file:close()
else
  mistyuppercontents = nil
end
if not mistyuppercontents then
  mistyloadedupperbodytype = 4
else
	if mistyuppercontents == "1" then
		mistyloadedupperbodytype = 1
	end
	if mistyuppercontents == "2" then
		mistyloadedupperbodytype = 2
	end
	if mistyuppercontents == "3" then
		mistyloadedupperbodytype = 3
	end
	if mistyuppercontents == "4" then
		mistyloadedupperbodytype = 4
	end
end

file = io.open("mistysavedlowerbodytype", "r")

if file then
  mistylowercontents = file:read("*all")
  file:close()
else
  mistylowercontents = nil
end
if not mistylowercontents then
  mistyloadedlowerbodytype = 4
else
	if mistylowercontents == "1" then
		mistyloadedlowerbodytype = 1
	end
	if mistylowercontents == "2" then
		mistyloadedlowerbodytype = 2
	end
	if mistylowercontents == "3" then
		mistyloadedlowerbodytype = 3
	end
	if mistylowercontents == "4" then
		mistyloadedlowerbodytype = 4
	end
end

file = io.open("mistysavedmuscular", "r")
local mistymuscularcontents
if file then
  mistymuscularcontents = file:read("*all")
  file:close()
else
  mistymuscularcontents = nil
end
if not mistymuscularcontents then
  mistyfmus01 = 0
else
  	if mistymuscularcontents == "0" then
		mistyfmus01 = 0
	end
	if mistymuscularcontents == "1" then
		mistyfmus01 = 1
	end
end
end
------------
misty_readfiles()

local mistysetupperbodytype = mistyloadedupperbodytype
local mistysetlowerbodytype = mistyloadedlowerbodytype

local mistychbfn01
local mistychbfm01
local mistymuscularbody
local mistymuscularbodytext

if mistyfmus01 == 0 then
	mistychbfn01 = true
	mistychbfm01 = false
	mistymuscularbody = ""
	mistymuscularbodytext = ""
end
if mistyfmus01 == 1 then
	mistychbfn01 = false
	mistychbfm01 = true
	mistymuscularbody = "m"
	mistymuscularbodytext = ", muscular"
end

local mistysettext = " "..mistysetupperbodytype.." and "..mistysetlowerbodytype
local mistysavetext = ""

-------------- Claire

local clairechbv01
local clairetab

file = io.open("claireenabled", "r")
local clairecontents
if file then
  clairecontents = file:read("*all")
  file:close()
else
  clairecontents = nil
end
if not clairecontents then
  clairechbv01 = true
  clairetab = 1
else
	if clairecontents == "1" then
		clairechbv01 = true
		clairetab = 1
	end
	if clairecontents == "0" then
		clairechbv01 = false
		clairetab = 0
	end
end

local claireuppercontents
local clairelowercontents
local claireloadedupperbodytype = 4
local claireloadedlowerbodytype = 4

-------------
function claire_readfiles()
file = io.open("clairesavedupperbodytype", "r")
if file then
  claireuppercontents = file:read("*all")
  file:close()
else
  claireuppercontents = nil
end
if not claireuppercontents then
  claireloadedupperbodytype = 4
else
	if claireuppercontents == "1" then
		claireloadedupperbodytype = 1
	end
	if claireuppercontents == "2" then
		claireloadedupperbodytype = 2
	end
	if claireuppercontents == "3" then
		claireloadedupperbodytype = 3
	end
	if claireuppercontents == "4" then
		claireloadedupperbodytype = 4
	end
end

file = io.open("clairesavedlowerbodytype", "r")

if file then
  clairelowercontents = file:read("*all")
  file:close()
else
  clairelowercontents = nil
end
if not clairelowercontents then
  claireloadedlowerbodytype = 4
else
	if clairelowercontents == "1" then
		claireloadedlowerbodytype = 1
	end
	if clairelowercontents == "2" then
		claireloadedlowerbodytype = 2
	end
	if clairelowercontents == "3" then
		claireloadedlowerbodytype = 3
	end
	if clairelowercontents == "4" then
		claireloadedlowerbodytype = 4
	end
end

file = io.open("clairesavedmuscular", "r")
local clairemuscularcontents
if file then
  clairemuscularcontents = file:read("*all")
  file:close()
else
  clairemuscularcontents = nil
end
if not clairemuscularcontents then
  clairefmus01 = 0
else
  	if clairemuscularcontents == "0" then
		clairefmus01 = 0
	end
	if clairemuscularcontents == "1" then
		clairefmus01 = 1
	end
end
end
------------
claire_readfiles()

local clairesetupperbodytype = claireloadedupperbodytype
local clairesetlowerbodytype = claireloadedlowerbodytype

local clairechbfn01
local clairechbfm01
local clairemuscularbody
local clairemuscularbodytext

if clairefmus01 == 0 then
	clairechbfn01 = true
	clairechbfm01 = false
	clairemuscularbody = ""
	clairemuscularbodytext = ""
end
if clairefmus01 == 1 then
	clairechbfn01 = false
	clairechbfm01 = true
	clairemuscularbody = "m"
	clairemuscularbodytext = ", muscular"
end

local clairesettext = " "..clairesetupperbodytype.." and "..clairesetlowerbodytype
local clairesavetext = ""

------------

registerForEvent("onOverlayOpen", function()
	if menuon == 0 then 
		menustate = 1
		--print(menustate)
	end
end)

registerForEvent("onOverlayClose", function()
	if menuon == 1 then 
		menustate = 0
		menuon = 0
		--print(menustate)	
	end
end)


registerForEvent("onDraw", function()

	if menustate == 1 then
		runonce = 0
	
		ImGui.SetNextWindowPos(200, 200, ImGuiCond.FirstUseEver) -- set window position x, y
		ImGui.SetNextWindowSizeConstraints(1000, 670, 1200, 800)
		ImGui.SetNextWindowSize(600, 470, ImGuiCond.Appearing) -- set window size w, h

		ImGui.PushStyleColor(ImGuiCol.Border, ImGui.GetColorU32(1, 0.2, 0.2, 1))
		ImGui.PushStyleColor(ImGuiCol.TitleBg, ImGui.GetColorU32(0.2, 0.05, 0.05, 1))
		ImGui.PushStyleColor(ImGuiCol.TitleBgActive, ImGui.GetColorU32(0.4, 0.05, 0.05, 1))
		ImGui.PushStyleColor(ImGuiCol.Text, ImGui.GetColorU32(1, 0, 0, 1))
		ImGui.PushStyleColor(ImGuiCol.WindowBg, ImGui.GetColorU32(0.1, 0.05, 0.05, 1))
		
		ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 0)
		ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 20, 20)
		ImGui.PushStyleVar(ImGuiStyleVar.WindowBorderSize, 2)
		ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 10)
		
		ImGui.PushStyleColor(ImGuiCol.ScrollbarGrab, ImGui.GetColorU32(0.5, 0, 0, 1))
		ImGui.PushStyleVar(ImGuiStyleVar.ScrollbarSize, 10)
		
		ImGui.PushStyleColor(ImGuiCol.Button, ImGui.GetColorU32(0.5, 0, 0, 1))
		ImGui.PushStyleColor(ImGuiCol.ButtonActive, ImGui.GetColorU32(0.8, 0, 0, 1))
		ImGui.PushStyleColor(ImGuiCol.ButtonHovered, ImGui.GetColorU32(0.55, 0, 0, 1))
		
		ImGui.PushStyleColor(ImGuiCol.ResizeGrip, ImGui.GetColorU32(0.5, 0, 0, 1))
		ImGui.PushStyleColor(ImGuiCol.ResizeGripActive, ImGui.GetColorU32(0.8, 0, 0, 1))
		ImGui.PushStyleColor(ImGuiCol.ResizeGripHovered, ImGui.GetColorU32(0.55, 0, 0, 1))
		
		ImGui.PushStyleColor(ImGuiCol.CheckMark, ImGui.GetColorU32(1, 0, 0, 1))
		ImGui.PushStyleColor(ImGuiCol.FrameBg, ImGui.GetColorU32(0.5, 0, 0, 1))
		ImGui.PushStyleColor(ImGuiCol.FrameBgActive, ImGui.GetColorU32(0.2, 0, 0, 1))
		ImGui.PushStyleColor(ImGuiCol.FrameBgHovered, ImGui.GetColorU32(0.6, 0, 0, 1))
		
		ImGui.PushStyleColor(ImGuiCol.Tab, ImGui.GetColorU32(0.2, 0, 0, 1))
		ImGui.PushStyleColor(ImGuiCol.TabActive, ImGui.GetColorU32(0.5, 0, 0, 1))
		ImGui.PushStyleColor(ImGuiCol.TabHovered, ImGui.GetColorU32(0.6, 0, 0, 1))

	
		
		
		
		if (ImGui.Begin("SP0 BODYMOD")) then
		
			ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)

			ImGui.SameLine()
			ImGui.Dummy(505, 0)
			ImGui.SameLine()

			btnena = ImGui.Button("ENABLE MOD", 180, 30)
			ImGui.SameLine()
			btndis = ImGui.Button("DISABLE MOD", 180, 30)


			if modenable == 0 or modenable == "0" then
				ImGui.NewLine()
				ImGui.Text("All Bodies are set to default. Mod is disabled, and will not be enabled after restarting or loading game.")
				ImGui.Text("Press 'ENABLE MOD' to enable mod")
			end
	
			
			if modenable == 1 or modenable == "1" then
			
				ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
				
				if ImGui.BeginTabBar("Tabbar") then
				
					---------- V
					v_tab()
					
					---------- Female Citizens
					fcitizen_tab()
					
					---------- Panam
					panam_tab()
					
					---------- Judy
					judy_tab()
					
					---------- Evelyn
					evelyn_tab()
					
					---------- Alt
					alt_tab()
					
					---------- Rogue
					rogue_tab()
					
					---------- Hanako
					hanako_tab()

					---------- Stout
					stout_tab()
					
					---------- Misty
					misty_tab()
										
					---------- Claire
					claire_tab()
					
					------------
					
				end	
				
			end

			ImGui.PopStyleColor()
			ImGui.End()

		end
		
		menuon = 1

	end


end)



registerForEvent("onInit", function()
	
	if modenable == 1 then
	
		if vtab == 1 then
----------------		
			v_setcustom()
			print("SP0 BODYMOD: V set custom.")
		end
		
		if fcitizentab == 1 then
----------------
			fcitizen_setcustom()
			print("SP0 BODYMOD: Citizen set custom.")			
		end
		
		if panamtab == 1 then
---------------
			panam_setcustom()
			print("SP0 BODYMOD: Panam set custom.")			
		end
		
		if judytab == 1 then
----------------
			judy_setcustom()
			print("SP0 BODYMOD: Judy set custom.")			
		end
		
		if evetab == 1 then	
---------------		
			evelyn_setcustom()
			print("SP0 BODYMOD: Evelyn set custom.")			
		end
		
		if alttab == 1 then
--------------------		
			alt_setcustom()
			print("SP0 BODYMOD: Alt set custom.")			
		end
		
		if roguetab == 1 then
------------------
			rogue_setcustom()
			print("SP0 BODYMOD: Rogue set custom.")			
		end
		
		if hanakotab == 1 then
--------------		
		hanako_setcustom()
			print("SP0 BODYMOD: Hanako set custom.")		
		end
		
		if stouttab == 1 then
-----------------
		stout_setcustom()
			print("SP0 BODYMOD: Stout set custom.")		
		end
		
		if mistytab == 1 then
-----------------
		misty_setcustom()
			print("SP0 BODYMOD: Misty set custom.")		
		end
		
		if clairetab == 1 then
-----------------
		claire_setcustom()
			print("SP0 BODYMOD: Claire set custom.")		
		end
		
		print("SP0 BODYMOD ENABLED")
	else
		print("SP0 BODYMOD DISABLED")
	end


end) 


registerForEvent("onUpdate", function()
	
	if runonce == 0 then
	if btnena then
		modenable = 1
		runonce = 1

			file = io.open("enabled", "w")
			file:write(modenable)
			file:close()
			
			------------ V
			if vtab == 1 then
--------------------		
			v_readfiles()
					
			if fmus01 == 0 then
				chbfn01 = true
				chbfm01 = false
			end
			if fmus01 == 1 then
				chbfn01 = false
				chbfm01 = true
			end
			
			setupperbodytype = loadedupperbodytype
			setlowerbodytype = loadedlowerbodytype	
			
-------------------
			v_setcustom()

			settext = " "..setupperbodytype.." and "..setlowerbodytype
		end
		
		------------ Female NPC
		if fcitizentab == 1 then
--------------------
		fcitizen_readfiles()
		
		if fcitizenfmus01 == 0 then
			fcitizenchbfn01 = true
			fcitizenchbfm01 = false
		end
		if fcitizenfmus01 == 1 then
			fcitizenchbfn01 = false
			fcitizenchbfm01 = true
		end
		
		fcitizensetupperbodytype = fcitizenloadedupperbodytype
		fcitizensetlowerbodytype = fcitizenloadedlowerbodytype
		
----------------
		fcitizen_setcustom()
		fcitizensettext = " "..fcitizensetupperbodytype.." and "..fcitizensetlowerbodytype
		end
		
		------------ PANAM
		if panamtab == 1 then
-------------------	
		panam_readfiles()
		
		if panamfmus01 == 0 then
			panamchbfn01 = true
			panamchbfm01 = false
		end
		if panamfmus01 == 1 then
			panamchbfn01 = false
			panamchbfm01 = true
		end
		
		panamsetupperbodytype = panamloadedupperbodytype
		panamsetlowerbodytype = panamloadedlowerbodytype
		
-----------------------
		panam_setcustom()
			
		panamsettext = " "..panamsetupperbodytype.." and "..panamsetlowerbodytype
		end
		
		------------ JUDY
		if judytab == 1 then
-------------------
		judy_readfiles()
		
		if judyfmus01 == 0 then
			judychbfn01 = true
			judychbfm01 = false
		end
		if judyfmus01 == 1 then
			judychbfn01 = false
			judychbfm01 = true
		end
		
		judysetupperbodytype = judyloadedupperbodytype
		judysetlowerbodytype = judyloadedlowerbodytype
--------------	
		judy_setcustom()
			
		judysettext = " "..judysetupperbodytype.." and "..judysetlowerbodytype
		end
		
		------------ EVELYN
		if evetab == 1 then
---------------
		eve_readfiles()
		
		if evefmus01 == 0 then
			evechbfn01 = true
			evechbfm01 = false
		end
		if evefmus01 == 1 then
			evechbfn01 = false
			evechbfm01 = true
		end
		
		evesetupperbodytype = eveloadedupperbodytype
		evesetlowerbodytype = eveloadedlowerbodytype
		
------------------	
		evelyn_setcustom()
			
		evesettext = " "..evesetupperbodytype.." and "..evesetlowerbodytype
		end
		
		------------ Alt
		if alttab == 1 then
------------------
		alt_readfiles()
		
		if altfmus01 == 0 then
			altchbfn01 = true
			altchbfm01 = false
		end
		if altfmus01 == 1 then
			altchbfn01 = false
			altchbfm01 = true
		end
		
		altsetupperbodytype = altloadedupperbodytype
		altsetlowerbodytype = altloadedlowerbodytype
-------------		
		alt_setcustom()
			
		altsettext = " "..altsetupperbodytype.." and "..altsetlowerbodytype
		end
		
		
		------------ Rogue
		if roguetab == 1 then
---------------
		rogue_readlifes()
		
		if roguefmus01 == 0 then
			roguechbfn01 = true
			roguechbfm01 = false
		end
		if roguefmus01 == 1 then
			roguechbfn01 = false
			roguechbfm01 = true
		end
		
		roguesetupperbodytype = rogueloadedupperbodytype
		roguesetlowerbodytype = rogueloadedlowerbodytype
----------------	
		rogue_setcustom()
			
		roguesettext = " "..roguesetupperbodytype.." and "..roguesetlowerbodytype
		end
		
		
		------------ Hanako
		if hanakotab == 1 then
-------------------		
		hanako_readfiles()
		
		if hanakofmus01 == 0 then
			hanakochbfn01 = true
			hanakochbfm01 = false
		end
		if hanakofmus01 == 1 then
			hanakochbfn01 = false
			hanakochbfm01 = true
		end
		
		hanakosetupperbodytype = hanakoloadedupperbodytype
		hanakosetlowerbodytype = hanakoloadedlowerbodytype
----------------		
		hanako_setcustom()

		hanakosettext = " "..hanakosetupperbodytype.." and "..hanakosetlowerbodytype
		end
		
		------------ Stout
		if stouttab == 1 then
----------------
		stout_readfiles()
		
		if stoutfmus01 == 0 then
			stoutchbfn01 = true
			stoutchbfm01 = false
		end
		if stoutfmus01 == 1 then
			stoutchbfn01 = false
			stoutchbfm01 = true
		end
		
		stoutsetupperbodytype = stoutloadedupperbodytype
		stoutsetlowerbodytype = stoutloadedlowerbodytype
		
--------------		
		stout_setcustom()
			
		stoutsettext = " "..stoutsetupperbodytype.." and "..stoutsetlowerbodytype
		end
		
		
		------------ Misty
		if mistytab == 1 then
----------------
		misty_readfiles()
		
		if mistyfmus01 == 0 then
			mistychbfn01 = true
			mistychbfm01 = false
		end
		if mistyfmus01 == 1 then
			mistychbfn01 = false
			mistychbfm01 = true
		end
		
		mistysetupperbodytype = mistyloadedupperbodytype
		mistysetlowerbodytype = mistyloadedlowerbodytype
		
--------------		
		misty_setcustom()
			
		mistysettext = " "..mistysetupperbodytype.." and "..mistysetlowerbodytype
		end
		
		
		
		------------ Claire
		if clairetab == 1 then
----------------
		claire_readfiles()
		
		if clairefmus01 == 0 then
			clairechbfn01 = true
			clairechbfm01 = false
		end
		if clairefmus01 == 1 then
			clairechbfn01 = false
			clairechbfm01 = true
		end
		
		clairesetupperbodytype = claireloadedupperbodytype
		clairesetlowerbodytype = claireloadedlowerbodytype
		
--------------		
		claire_setcustom()
			
		clairesettext = " "..clairesetupperbodytype.." and "..clairesetlowerbodytype
		end
		
		-----------
		
		print("SP BODYMOD enabled")
    end
	
	if btndis then
		modenable = 0
		runonce = 1
		savetext = ""
-------------------
		v_setdefault()
		
		fcitizensavetext = ""
---------------
		fcitizen_setdefault()
		
		panamsavetext = ""
-------------------		
		panam_setdefault()
		
		judysavetext = ""
------------------		
		judy_setdefault()
		
		evesavetext = ""
------------------	
		evelyn_setdefault()
		
		altsavetext = ""
--------------------
		alt_setdefault()		
		
		roguesavetext = ""
----------------
		rogue_setdefault()
		
		hanakosavetext = ""
---------------
		hanako_setdefault()
		
		clairesavetext = ""
------------------
		claire_setdefault()
		
		stoutsavetext = ""
------------------
		stout_setdefault()

		
		file = io.open("enabled", "w")
		file:write(modenable)
		file:close()
		
		print("SP BODYMOD disabled")
    end
	runonce = 1
	end
	
end)


















registerHotkey('SP0_BODYMOD', 'placeholder', function()
	
		if menuon == 0 then 

			menustate = 1
			--print(menustate)

		end
		
		if menuon == 1 then 

			menustate = 0
			menuon = 0
			--print(menustate)
			
		end

end)



















------------------
function v_tab()
					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
				
					if ImGui.BeginTabItem(" Female V ") then
						
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
												
						ImGui.NewLine()
						
						
						chbv01, pressed = ImGui.Checkbox("Enable V", chbv01)
						
						if pressed == true then
							vtab = vtab + 1

							if vtab == 2 then
								vtab = 0
							end
							if vtab == 0 then
							
								chbv01 = false
								
-------------------
								v_setdefault()

							end
							if vtab == 1 then
							
								setupperbodytype = loadedupperbodytype
								setlowerbodytype = loadedlowerbodytype
								
								
								  	
								file = io.open("savedmuscular", "r")
								
								if file then
								  muscularcontents = file:read("*all")
								  file:close()
								else
								  muscularcontents = nil
								end
								
								if not muscularcontents then
								  fmus01 = 0
								else
									if muscularcontents == "0" then
										fmus01 = 0
									end
									if muscularcontents == "1" then
										fmus01 = 1
									end
								end

								if fmus01 == 0 then
									chbfn01 = true
									chbfm01 = false
									muscularbody = ""
									muscularbodytext = ""
								end
								if fmus01 == 1 then
									chbfn01 = false
									chbfm01 = true
									muscularbody = "m"
									muscularbodytext = ", muscular"
								end
								
-------------------
								v_setcustom()

							end
							
							file = io.open("venabled", "w")
							file:write(vtab)
							file:close()
							
						end
					
						if vtab == 1 then
						
						if uppercontents == nil then
							ImGui.Text("No saved configuration file found yet, setting upper body size to: "..loadedupperbodytype.." and lower body size: "..loadedlowerbodytype)
						end
						
						if uppercontents ~= nil then
							if	uppercontents == 1 then
								ImGui.Text("")
							else
								ImGui.Text("Previous body configuration found. Loaded upper body size "..loadedupperbodytype..", lower body size "..loadedlowerbodytype..muscularbodytext)
							end
						end

						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if setupperbodytype ~= 0 then
								setupperbodytype = setupperbodytype - 1
							end
							if setupperbodytype == 0 then
								setupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..setupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if setupperbodytype ~= 5 then
								setupperbodytype = setupperbodytype + 1
							end
							if setupperbodytype == 5 then
								setupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if setlowerbodytype ~= 0 then
								setlowerbodytype = setlowerbodytype - 1
							end
							if setlowerbodytype == 0 then
								setlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..setlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if setlowerbodytype ~= 5 then
								setlowerbodytype = setlowerbodytype + 1
							end
							if setlowerbodytype == 5 then
								setlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", chbfn01) then
							fmus01 = 0
							chbfn01 = true
							chbfm01 = false
							muscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", chbfm01) then
							fmus01 = 1
							chbfn01 = false
							chbfm01 = true
							muscularbody = "m"
						end
															
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then

-------------------
							v_setcustom()
							
							uppercontents = 1
							
							file = io.open("savedupperbodytype", "w")
							file:write(setupperbodytype)
							file:close()
									
							file = io.open("savedlowerbodytype", "w")
							file:write(setlowerbodytype)
							file:close()
							
							file = io.open("savedmuscular", "w")
							file:write(fmus01)
							file:close()
							
							loadedupperbodytype = setupperbodytype
							loadedlowerbodytype = setlowerbodytype
							
							if fmus01 == 1 then
								settext = " "..setupperbodytype.." and "..setlowerbodytype..", muscular"
							else
								settext = " "..setupperbodytype.." and "..setlowerbodytype
							end
							savetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..settext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..savetext)
						
						end
						
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
						
					end


end
-------------------
function v_setdefault()
								TweakDB:SetFlat("Character.Player_Puppet_Base_inline0.entity", "ep1\\characters\\entities\\player\\player_wa_fpp_ep1.ent")
								TweakDB:SetFlat("Character.Player_Puppet_Inventory_inline0.entity", "ep1\\characters\\entities\\player\\player_wa_tpp_ep1.ent")
								TweakDB:SetFlat("Character.TPP_Player_Cutscene_Female_inline0.entity", "base\\characters\\entities\\player\\player_wa_tpp_cutscene.ent")
								TweakDB:SetFlat("Character.q110_tpp_female_v.entityTemplatePath", "base\\characters\\entities\\player\\player_wa_tpp_reflexion.ent")
								TweakDB:SetFlat("Character.Player_Puppet_Photomode_inline0.entity", "ep1\\characters\\entities\\player\\photo_mode\\player_wa_photomode_ep1.ent")
								TweakDB:SetFlat("Character.Player_Puppet_Menu_inline0.entity", "base\\characters\\entities\\player\\player_wa_tpp.ent")
								
								TweakDB:SetFlat("AMM_Character.TPP_Player_Female.entityTemplatePath", "base\\amm_characters\\entity\\player_wa_tpp_walking.ent")
								TweakDB:SetFlat("AMM_Character.Player_Female.entityTemplatePath", "base\\amm_characters\\entity\\player_wa_tpp.ent")
								
								--TweakDB:SetFlat("Character.Player_Puppet_Base_inline0.entity", "base\\characters\\entities\\player\\player_wa_fpp.ent")
								--TweakDB:SetFlat("Character.Player_Puppet_Inventory_inline0.entity", "base\\characters\\entities\\player\\player_wa_tpp.ent")
								--TweakDB:SetFlat("Character.Player_Puppet_Photomode_inline0.entity", "base\\characters\\entities\\player\\photo_mode\\player_wa_photomode.ent")
end
-------------------
function v_setcustom()
							TweakDB:SetFlat("Character.Player_Puppet_Base_inline0.entity", "ep1\\characters\\entities\\player\\player_wa_fpp_ep1"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
							TweakDB:SetFlat("Character.Player_Puppet_Inventory_inline0.entity", "ep1\\characters\\entities\\player\\player_wa_tpp_ep1"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
							TweakDB:SetFlat("Character.TPP_Player_Cutscene_Female_inline0.entity", "base\\characters\\entities\\player\\player_wa_tpp_cutscene"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
							TweakDB:SetFlat("Character.q110_tpp_female_v.entityTemplatePath", "base\\characters\\entities\\player\\player_wa_tpp_reflexion"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
							TweakDB:SetFlat("Character.Player_Puppet_Photomode_inline0.entity", "ep1\\characters\\entities\\player\\photo_mode\\player_wa_photomode_ep1"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
							TweakDB:SetFlat("Character.Player_Puppet_Menu_inline0.entity", "base\\characters\\entities\\player\\player_wa_tpp"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
							
							TweakDB:SetFlat("AMM_Character.TPP_Player_Female.entityTemplatePath", "base\\amm_characters\\entity\\player_wa_tpp_walking"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
							TweakDB:SetFlat("AMM_Character.Player_Female.entityTemplatePath", "base\\amm_characters\\entity\\player_wa_tpp"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
							
							--TweakDB:SetFlat("Character.Player_Puppet_Base_inline0.entity", "base\\characters\\entities\\player\\player_wa_fpp"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
							--TweakDB:SetFlat("Character.Player_Puppet_Inventory_inline0.entity", "base\\characters\\entities\\player\\player_wa_tpp"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
							--TweakDB:SetFlat("Character.Player_Puppet_Photomode_inline0.entity", "base\\characters\\entities\\player\\photo_mode\\player_wa_photomode"..setupperbodytype..setlowerbodytype..muscularbody..".ent")
end





-------------------
function panam_tab()

					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
					

					if ImGui.BeginTabItem(" Panam ") then
					
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
											
						ImGui.NewLine()
						
						
						panamchbv01, pressed = ImGui.Checkbox("Enable Panam", panamchbv01)
						
						if pressed == true then
							panamtab = panamtab + 1

							if panamtab == 2 then
								panamtab = 0
							end
							if panamtab == 0 then
							
								panamchbv01 = false
-----------------
								panam_setdefault()

							end
							if panamtab == 1 then
							
								panamsetupperbodytype = panamloadedupperbodytype
								panamsetlowerbodytype = panamloadedlowerbodytype
								
								
								  	
								file = io.open("panamsavedmuscular", "r")
								
								if file then
								  panammuscularcontents = file:read("*all")
								  file:close()
								else
								  panammuscularcontents = nil
								end
								
								if not panammuscularcontents then
								  panamfmus01 = 0
								else
									if panammuscularcontents == "0" then
										panamfmus01 = 0
									end
									if panammuscularcontents == "1" then
										panamfmus01 = 1
									end
								end

								if panamfmus01 == 0 then
									panamchbfn01 = true
									panamchbfm01 = false
									panammuscularbody = ""
									panammuscularbodytext = ""
								end
								if panamfmus01 == 1 then
									panamchbfn01 = false
									panamchbfm01 = true
									panammuscularbody = "m"
									panammuscularbodytext = ", muscular"
								end
----------------------
								panam_setcustom()
							end
							
							file = io.open("panamenabled", "w")
							file:write(panamtab)
							file:close()
							
						end
					
						if panamtab == 1 then
						
						if panamuppercontents == nil then
							ImGui.Text("No saved configuration file found yet, setting upper body size to: "..panamloadedupperbodytype.." and lower body size: "..panamloadedlowerbodytype)
						end
						
						if panamuppercontents ~= nil then
							if	panamuppercontents == 1 then
								ImGui.Text("")
							else
								ImGui.Text("Previous Panam body configuration found. Loaded upper body size "..panamloadedupperbodytype..", lower body size "..panamloadedlowerbodytype..panammuscularbodytext)
							end
						end

						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if panamsetupperbodytype ~= 0 then
								panamsetupperbodytype = panamsetupperbodytype - 1
							end
							if panamsetupperbodytype == 0 then
								panamsetupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..panamsetupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if panamsetupperbodytype ~= 5 then
								panamsetupperbodytype = panamsetupperbodytype + 1
							end
							if panamsetupperbodytype == 5 then
								panamsetupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if panamsetlowerbodytype ~= 0 then
								panamsetlowerbodytype = panamsetlowerbodytype - 1
							end
							if panamsetlowerbodytype == 0 then
								panamsetlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..panamsetlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if panamsetlowerbodytype ~= 5 then
								panamsetlowerbodytype = panamsetlowerbodytype + 1
							end
							if panamsetlowerbodytype == 5 then
								panamsetlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", panamchbfn01) then
							panamfmus01 = 0
							panamchbfn01 = true
							panamchbfm01 = false
							panammuscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", panamchbfm01) then
							panamfmus01 = 1
							panamchbfn01 = false
							panamchbfm01 = true
							panammuscularbody = "m"
						end
															
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then
----------------
							panam_setcustom()
							
							panamuppercontents = 1
							
							file = io.open("panamsavedupperbodytype", "w")
							file:write(panamsetupperbodytype)
							file:close()
									
							file = io.open("panamsavedlowerbodytype", "w")
							file:write(panamsetlowerbodytype)
							file:close()
							
							file = io.open("panamsavedmuscular", "w")
							file:write(panamfmus01)
							file:close()
							
							panamloadedupperbodytype = panamsetupperbodytype
							panamloadedlowerbodytype = panamsetlowerbodytype
							
							if panamfmus01 == 1 then
								panamsettext = " "..panamsetupperbodytype.." and "..panamsetlowerbodytype..", muscular"
							else
								panamsettext = " "..panamsetupperbodytype.." and "..panamsetlowerbodytype
							end
							panamsavetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..panamsettext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..panamsavetext)
						
						end
						
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
					end
end
-------------------
function panam_setdefault()
							TweakDB:SetFlat("Character.Panam.entityTemplatePath", "base\\quest\\primary_characters\\panam.ent")
							TweakDB:SetFlat("Character.Panam_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\panam_palmer\\panam_photomode.ent")
end

-------------------
function panam_setcustom()
							TweakDB:SetFlat("Character.Panam.entityTemplatePath", "base\\quest\\primary_characters\\panam"..panamsetupperbodytype..panamsetlowerbodytype..panammuscularbody..".ent")
							TweakDB:SetFlat("Character.Panam_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\panam_palmer\\panam_photomode"..panamsetupperbodytype..panamsetlowerbodytype..panammuscularbody..".ent")
end




-------------------
function judy_tab()
					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
					
					if ImGui.BeginTabItem(" Judy ") then
					
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
											
						ImGui.NewLine()
						
						judychbv01, pressed = ImGui.Checkbox("Enable Judy", judychbv01)
						
						if pressed == true then
							judytab = judytab + 1

							if judytab == 2 then
								judytab = 0
							end
							if judytab == 0 then
							
								judychbv01 = false
								
--------------
								judy_setdefault()

							end
							if judytab == 1 then
							
								judysetupperbodytype = judyloadedupperbodytype
								judysetlowerbodytype = judyloadedlowerbodytype
								
								
								  	
								file = io.open("judysavedmuscular", "r")
								
								if file then
								  judymuscularcontents = file:read("*all")
								  file:close()
								else
								  judymuscularcontents = nil
								end
								
								if not judymuscularcontents then
								  judyfmus01 = 0
								else
									if judymuscularcontents == "0" then
										judyfmus01 = 0
									end
									if judymuscularcontents == "1" then
										judyfmus01 = 1
									end
								end

								if judyfmus01 == 0 then
									judychbfn01 = true
									judychbfm01 = false
									judymuscularbody = ""
									judymuscularbodytext = ""
								end
								if judyfmus01 == 1 then
									judychbfn01 = false
									judychbfm01 = true
									judymuscularbody = "m"
									judymuscularbodytext = ", muscular"
								end
								
--------------	
								judy_setcustom()

							end
							
							file = io.open("judyenabled", "w")
							file:write(judytab)
							file:close()
							
						end
					
						if judytab == 1 then
						
						
						if judyuppercontents == nil then
							ImGui.Text("No saved configuration file found yet, setting upper body size to: "..judyloadedupperbodytype.." and lower body size: "..judyloadedlowerbodytype)
						end
						
						if judyuppercontents ~= nil then
							if	judyuppercontents == 1 then
								ImGui.Text("")
							else
								ImGui.Text("Previous Judy body configuration found. Loaded upper body size "..judyloadedupperbodytype..", lower body size "..judyloadedlowerbodytype..judymuscularbodytext)
							end
						end

						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if judysetupperbodytype ~= 0 then
								judysetupperbodytype = judysetupperbodytype - 1
							end
							if judysetupperbodytype == 0 then
								judysetupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..judysetupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if judysetupperbodytype ~= 5 then
								judysetupperbodytype = judysetupperbodytype + 1
							end
							if judysetupperbodytype == 5 then
								judysetupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if judysetlowerbodytype ~= 0 then
								judysetlowerbodytype = judysetlowerbodytype - 1
							end
							if judysetlowerbodytype == 0 then
								judysetlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..judysetlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if judysetlowerbodytype ~= 5 then
								judysetlowerbodytype = judysetlowerbodytype + 1
							end
							if judysetlowerbodytype == 5 then
								judysetlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", judychbfn01) then
							judyfmus01 = 0
							judychbfn01 = true
							judychbfm01 = false
							judymuscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", judychbfm01) then
							judyfmus01 = 1
							judychbfn01 = false
							judychbfm01 = true
							judymuscularbody = "m"
						end
															
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then
	
-------------	
							judy_setcustom()
							
							judyuppercontents = 1
							
							file = io.open("judysavedupperbodytype", "w")
							file:write(judysetupperbodytype)
							file:close()
									
							file = io.open("judysavedlowerbodytype", "w")
							file:write(judysetlowerbodytype)
							file:close()
							
							file = io.open("judysavedmuscular", "w")
							file:write(judyfmus01)
							file:close()
							
							judyloadedupperbodytype = judysetupperbodytype
							judyloadedlowerbodytype = judysetlowerbodytype
							
							if judyfmus01 == 1 then
								judysettext = " "..judysetupperbodytype.." and "..judysetlowerbodytype..", muscular"
							else
								judysettext = " "..judysetupperbodytype.." and "..judysetlowerbodytype
							end
							judysavetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..judysettext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..judysavetext)
						
						end
						
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
					end
end					
-------------------
function judy_setdefault()
							TweakDB:SetFlat("Character.Judy.entityTemplatePath", "base\\quest\\secondary_characters\\judy.ent")
							TweakDB:SetFlat("Character.Judy_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\judy_alvarez\\judy_photomode.ent")
end
-------------------
function judy_setcustom()
							TweakDB:SetFlat("Character.Judy.entityTemplatePath", "base\\quest\\secondary_characters\\judy"..judysetupperbodytype..judysetlowerbodytype..judymuscularbody..".ent")
							TweakDB:SetFlat("Character.Judy_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\judy_alvarez\\judy_photomode"..judysetupperbodytype..judysetlowerbodytype..judymuscularbody..".ent")
end




-------------------
function evelyn_tab()
					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
					
					if ImGui.BeginTabItem(" Evelyn ") then
					
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
											
						ImGui.NewLine()
						
						
						evechbv01, pressed = ImGui.Checkbox("Enable Evelyn", evechbv01)
						
						if pressed == true then
							evetab = evetab + 1

							if evetab == 2 then
								evetab = 0
							end
							if evetab == 0 then
							
								evechbv01 = false
---------------------
								evelyn_setdefault()

							end
							if evetab == 1 then
							
								evesetupperbodytype = eveloadedupperbodytype
								evesetlowerbodytype = eveloadedlowerbodytype
								
								
								  	
								file = io.open("evesavedmuscular", "r")
								
								if file then
								  evemuscularcontents = file:read("*all")
								  file:close()
								else
								  evemuscularcontents = nil
								end
								
								if not evemuscularcontents then
								  evefmus01 = 0
								else
									if evemuscularcontents == "0" then
										evefmus01 = 0
									end
									if evemuscularcontents == "1" then
										evefmus01 = 1
									end
								end

								if evefmus01 == 0 then
									evechbfn01 = true
									evechbfm01 = false
									evemuscularbody = ""
									evemuscularbodytext = ""
								end
								if evefmus01 == 1 then
									evechbfn01 = false
									evechbfm01 = true
									evemuscularbody = "m"
									evemuscularbodytext = ", muscular"
								end
---------------
								evelyn_setcustom()
							end
							
							file = io.open("eveenabled", "w")
							file:write(evetab)
							file:close()
							
						end
					
						if evetab == 1 then
						
						if eveuppercontents == nil then
							evet0=ImGui.Text("No saved configuration file found yet, setting upper body size to: "..eveloadedupperbodytype.." and lower body size: "..eveloadedlowerbodytype)
						end
						
						if eveuppercontents ~= nil then
							if	eveuppercontents == 1 then
								evet0=ImGui.Text("")
							else
								evet0=ImGui.Text("Previous Evelyn body configuration found. Loaded upper body size "..eveloadedupperbodytype..", lower body size "..eveloadedlowerbodytype..evemuscularbodytext)
							end
						end

						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if evesetupperbodytype ~= 0 then
								evesetupperbodytype = evesetupperbodytype - 1
							end
							if evesetupperbodytype == 0 then
								evesetupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..evesetupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if evesetupperbodytype ~= 5 then
								evesetupperbodytype = evesetupperbodytype + 1
							end
							if evesetupperbodytype == 5 then
								evesetupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if evesetlowerbodytype ~= 0 then
								evesetlowerbodytype = evesetlowerbodytype - 1
							end
							if evesetlowerbodytype == 0 then
								evesetlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..evesetlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if evesetlowerbodytype ~= 5 then
								evesetlowerbodytype = evesetlowerbodytype + 1
							end
							if evesetlowerbodytype == 5 then
								evesetlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", evechbfn01) then
							evefmus01 = 0
							evechbfn01 = true
							evechbfm01 = false
							evemuscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", evechbfm01) then
							evefmus01 = 1
							evechbfn01 = false
							evechbfm01 = true
							evemuscularbody = "m"
						end
															
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then
						
---------------
							evelyn_setcustom()
							
							eveuppercontents = 1
							
							file = io.open("evesavedupperbodytype", "w")
							file:write(evesetupperbodytype)
							file:close()
									
							file = io.open("evesavedlowerbodytype", "w")
							file:write(evesetlowerbodytype)
							file:close()
							
							file = io.open("evesavedmuscular", "w")
							file:write(evefmus01)
							file:close()
							
							eveloadedupperbodytype = evesetupperbodytype
							eveloadedlowerbodytype = evesetlowerbodytype
							
							if evefmus01 == 1 then
								evesettext = " "..evesetupperbodytype.." and "..evesetlowerbodytype..", muscular"
							else
								evesettext = " "..evesetupperbodytype.." and "..evesetlowerbodytype
							end
							evesavetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..evesettext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..evesavetext)
						
						end
						
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
					end	
end					
-------------------
function evelyn_setdefault()
							TweakDB:SetFlat("Character.Evelyn.entityTemplatePath", "base\\quest\\primary_characters\\evelyn.ent")
							TweakDB:SetFlat("Character.Evelyn_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\evelyn_parker\\evelyn_photomode.ent")
end
-------------------
function evelyn_setcustom()
							TweakDB:SetFlat("Character.Evelyn.entityTemplatePath", "base\\quest\\primary_characters\\evelyn"..evesetupperbodytype..evesetlowerbodytype..evemuscularbody..".ent")
							TweakDB:SetFlat("Character.Evelyn_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\evelyn_parker\\evelyn_photomode"..evesetupperbodytype..evesetlowerbodytype..evemuscularbody..".ent")
end






-------------------
function alt_tab()
					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
					
					if ImGui.BeginTabItem(" Alt ") then
					
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
											
						ImGui.NewLine()
						
						altchbv01, pressed = ImGui.Checkbox("Enable Alt", altchbv01)
						
						if pressed == true then
							alttab = alttab + 1

							if alttab == 2 then
								alttab = 0
							end
							if alttab == 0 then
							
								altchbv01 = false
---------------								
								alt_setdefault()
								
							end
							if alttab == 1 then
							
								altsetupperbodytype = altloadedupperbodytype
								altsetlowerbodytype = altloadedlowerbodytype
								
								
								  	
								file = io.open("altsavedmuscular", "r")
								
								if file then
								  altmuscularcontents = file:read("*all")
								  file:close()
								else
								  altmuscularcontents = nil
								end
								
								if not altmuscularcontents then
								  altfmus01 = 0
								else
									if altmuscularcontents == "0" then
										altfmus01 = 0
									end
									if altmuscularcontents == "1" then
										altfmus01 = 1
									end
								end

								if altfmus01 == 0 then
									altchbfn01 = true
									altchbfm01 = false
									altmuscularbody = ""
									altmuscularbodytext = ""
								end
								if altfmus01 == 1 then
									altchbfn01 = false
									altchbfm01 = true
									altmuscularbody = "m"
									altmuscularbodytext = ", muscular"
								end
----------------
								alt_setcustom()
							end
							
							file = io.open("altenabled", "w")
							file:write(alttab)
							file:close()
							
						end
					
						if alttab == 1 then
						
						
						if altuppercontents == nil then
							ImGui.Text("No saved configuration file found yet, setting upper body size to: "..altloadedupperbodytype.." and lower body size: "..altloadedlowerbodytype)
						end
						
						if altuppercontents ~= nil then
							if	altuppercontents == 1 then
								ImGui.Text("")
							else
								ImGui.Text("Previous Alt body configuration found. Loaded upper body size "..altloadedupperbodytype..", lower body size "..altloadedlowerbodytype..altmuscularbodytext)
							end
						end

						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if altsetupperbodytype ~= 0 then
								altsetupperbodytype = altsetupperbodytype - 1
							end
							if altsetupperbodytype == 0 then
								altsetupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..altsetupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if altsetupperbodytype ~= 5 then
								altsetupperbodytype = altsetupperbodytype + 1
							end
							if altsetupperbodytype == 5 then
								altsetupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if altsetlowerbodytype ~= 0 then
								altsetlowerbodytype = altsetlowerbodytype - 1
							end
							if altsetlowerbodytype == 0 then
								altsetlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..altsetlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if altsetlowerbodytype ~= 5 then
								altsetlowerbodytype = altsetlowerbodytype + 1
							end
							if altsetlowerbodytype == 5 then
								altsetlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", altchbfn01) then
							altfmus01 = 0
							altchbfn01 = true
							altchbfm01 = false
							altmuscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", altchbfm01) then
							altfmus01 = 1
							altchbfn01 = false
							altchbfm01 = true
							altmuscularbody = "m"
						end
															
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then
------------------
							alt_setcustom()
														
							altuppercontents = 1
							
							file = io.open("altsavedupperbodytype", "w")
							file:write(altsetupperbodytype)
							file:close()
									
							file = io.open("altsavedlowerbodytype", "w")
							file:write(altsetlowerbodytype)
							file:close()
							
							file = io.open("altsavedmuscular", "w")
							file:write(altfmus01)
							file:close()
							
							altloadedupperbodytype = altsetupperbodytype
							altloadedlowerbodytype = altsetlowerbodytype
							
							if altfmus01 == 1 then
								altsettext = " "..altsetupperbodytype.." and "..altsetlowerbodytype..", muscular"
							else
								altsettext = " "..altsetupperbodytype.." and "..altsetlowerbodytype
							end
							altsavetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..altsettext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..altsavetext)
						
						end
						
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
					end
end					
-------------------
function alt_setdefault()
							TweakDB:SetFlat("Character.Alt.entityTemplatePath", "base\\quest\\secondary_characters\\alt.ent")
							TweakDB:SetFlat("Character.Alt_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\alt_cunningham\\alt_photomode.ent")
end
-------------------
function alt_setcustom()
							TweakDB:SetFlat("Character.Alt.entityTemplatePath", "base\\quest\\secondary_characters\\alt"..altsetupperbodytype..altsetlowerbodytype..altmuscularbody..".ent")
							TweakDB:SetFlat("Character.Alt_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\alt_cunningham\\alt_photomode"..altsetupperbodytype..altsetlowerbodytype..altmuscularbody..".ent")
end






-------------------
function rogue_tab()

					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
					
					if ImGui.BeginTabItem(" Rogue ") then
					
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
											
						ImGui.NewLine()
						
						roguechbv01, pressed = ImGui.Checkbox("Enable Rogue", roguechbv01)
						
						if pressed == true then
							roguetab = roguetab + 1

							if roguetab == 2 then
								roguetab = 0
							end
							if roguetab == 0 then
							
								roguechbv01 = false
----------------------						
								rogue_setdefault()

							end
							if roguetab == 1 then
							
								roguesetupperbodytype = rogueloadedupperbodytype
								roguesetlowerbodytype = rogueloadedlowerbodytype
								
								
								  	
								file = io.open("roguesavedmuscular", "r")
								
								if file then
								  roguemuscularcontents = file:read("*all")
								  file:close()
								else
								  roguemuscularcontents = nil
								end
								
								if not roguemuscularcontents then
								  roguefmus01 = 0
								else
									if roguemuscularcontents == "0" then
										roguefmus01 = 0
									end
									if roguemuscularcontents == "1" then
										roguefmus01 = 1
									end
								end

								if roguefmus01 == 0 then
									roguechbfn01 = true
									roguechbfm01 = false
									roguemuscularbody = ""
									roguemuscularbodytext = ""
								end
								if roguefmus01 == 1 then
									roguechbfn01 = false
									roguechbfm01 = true
									roguemuscularbody = "m"
									roguemuscularbodytext = ", muscular"
								end
----------------
								rogue_setcustom()

							end
							
							file = io.open("rogueenabled", "w")
							file:write(roguetab)
							file:close()
							
						end
					
						if roguetab == 1 then
						
						
						if rogueuppercontents == nil then
							ImGui.Text("No saved configuration file found yet, setting upper body size to: "..rogueloadedupperbodytype.." and lower body size: "..rogueloadedlowerbodytype)
						end
						
						if rogueuppercontents ~= nil then
							if	rogueuppercontents == 1 then
								ImGui.Text("")
							else
								ImGui.Text("Previous Rogue body configuration found. Loaded upper body size "..rogueloadedupperbodytype..", lower body size "..rogueloadedlowerbodytype..roguemuscularbodytext)
							end
						end

						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if roguesetupperbodytype ~= 0 then
								roguesetupperbodytype = roguesetupperbodytype - 1
							end
							if roguesetupperbodytype == 0 then
								roguesetupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..roguesetupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if roguesetupperbodytype ~= 5 then
								roguesetupperbodytype = roguesetupperbodytype + 1
							end
							if roguesetupperbodytype == 5 then
								roguesetupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if roguesetlowerbodytype ~= 0 then
								roguesetlowerbodytype = roguesetlowerbodytype - 1
							end
							if roguesetlowerbodytype == 0 then
								roguesetlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..roguesetlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if roguesetlowerbodytype ~= 5 then
								roguesetlowerbodytype = roguesetlowerbodytype + 1
							end
							if roguesetlowerbodytype == 5 then
								roguesetlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", roguechbfn01) then
							roguefmus01 = 0
							roguechbfn01 = true
							roguechbfm01 = false
							roguemuscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", roguechbfm01) then
							roguefmus01 = 1
							roguechbfn01 = false
							roguechbfm01 = true
							roguemuscularbody = "m"
						end
															
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then
-------------				
							rogue_setcustom()

							
							rogueuppercontents = 1
							
							file = io.open("roguesavedupperbodytype", "w")
							file:write(roguesetupperbodytype)
							file:close()
									
							file = io.open("roguesavedlowerbodytype", "w")
							file:write(roguesetlowerbodytype)
							file:close()
							
							file = io.open("roguesavedmuscular", "w")
							file:write(roguefmus01)
							file:close()
							
							rogueloadedupperbodytype = roguesetupperbodytype
							rogueloadedlowerbodytype = roguesetlowerbodytype
							
							if roguefmus01 == 1 then
								roguesettext = " "..roguesetupperbodytype.." and "..roguesetlowerbodytype..", muscular"
							else
								roguesettext = " "..roguesetupperbodytype.." and "..roguesetlowerbodytype
							end
							roguesavetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..roguesettext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..roguesavetext)
						
						end
						
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
					end
					
end					
-------------------
function rogue_setdefault()
							TweakDB:SetFlat("Character.Rogue.entityTemplatePath", "base\\quest\\secondary_characters\\rogue.ent")
							TweakDB:SetFlat("Character.RogueOld_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\rogue_amendiares\\old_rogue_photomode.ent")
							TweakDB:SetFlat("Character.RogueYoung_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\rogue_amendiares\\young_rogue_photomode.ent")
end
-------------------
function rogue_setcustom()
							TweakDB:SetFlat("Character.Rogue.entityTemplatePath", "base\\quest\\secondary_characters\\rogue"..roguesetupperbodytype..roguesetlowerbodytype..roguemuscularbody..".ent")
							TweakDB:SetFlat("Character.RogueOld_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\rogue_amendiares\\old_rogue_photomode"..roguesetupperbodytype..roguesetlowerbodytype..roguemuscularbody..".ent")
							TweakDB:SetFlat("Character.RogueYoung_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\rogue_amendiares\\young_rogue_photomode"..roguesetupperbodytype..roguesetlowerbodytype..roguemuscularbody..".ent")
end






-------------------
function hanako_tab()
					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
					
					if ImGui.BeginTabItem(" Hanako ") then

						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
											
						ImGui.NewLine()
						
						hanakochbv01, pressed = ImGui.Checkbox("Enable Hanako", hanakochbv01)
	
						if pressed == true then
							hanakotab = hanakotab + 1

							if hanakotab == 2 then
								hanakotab = 0
							end
							if hanakotab == 0 then
							
								hanakochbv01 = false
------------------								
								hanako_setdefault()

							end
							if hanakotab == 1 then
							
								hanakosetupperbodytype = hanakoloadedupperbodytype
								hanakosetlowerbodytype = hanakoloadedlowerbodytype
								
								
								  	
								file = io.open("hanakosavedmuscular", "r")
								
								if file then
								  hanakomuscularcontents = file:read("*all")
								  file:close()
								else
								  hanakomuscularcontents = nil
								end
								
								if not hanakomuscularcontents then
								  hanakofmus01 = 0
								else
									if hanakomuscularcontents == "0" then
										hanakofmus01 = 0
									end
									if hanakomuscularcontents == "1" then
										hanakofmus01 = 1
									end
								end

								if hanakofmus01 == 0 then
									hanakochbfn01 = true
									hanakochbfm01 = false
									hanakomuscularbody = ""
									hanakomuscularbodytext = ""
								end
								if hanakofmus01 == 1 then
									hanakochbfn01 = false
									hanakochbfm01 = true
									hanakomuscularbody = "m"
									hanakomuscularbodytext = ", muscular"
								end
								
								TweakDB:SetFlat("Character.Hanako.entityTemplatePath", "base\\quest\\secondary_characters\\hanako"..hanakosetupperbodytype..hanakosetlowerbodytype..hanakomuscularbody..".ent")
							end
							
							file = io.open("hanakoenabled", "w")
							file:write(hanakotab)
							file:close()
							
						end
					
						if hanakotab == 1 then
						
						
						if hanakouppercontents == nil then
							ImGui.Text("No saved configuration file found yet, setting upper body size to: "..hanakoloadedupperbodytype.." and lower body size: "..hanakoloadedlowerbodytype)
						end
						
						if hanakouppercontents ~= nil then
							if	hanakouppercontents == 1 then
								ImGui.Text("")
							else
								ImGui.Text("Previous Hanako body configuration found. Loaded upper body size "..hanakoloadedupperbodytype..", lower body size "..hanakoloadedlowerbodytype..hanakomuscularbodytext)
							end
						end

						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if hanakosetupperbodytype ~= 0 then
								hanakosetupperbodytype = hanakosetupperbodytype - 1
							end
							if hanakosetupperbodytype == 0 then
								hanakosetupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..hanakosetupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if hanakosetupperbodytype ~= 5 then
								hanakosetupperbodytype = hanakosetupperbodytype + 1
							end
							if hanakosetupperbodytype == 5 then
								hanakosetupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if hanakosetlowerbodytype ~= 0 then
								hanakosetlowerbodytype = hanakosetlowerbodytype - 1
							end
							if hanakosetlowerbodytype == 0 then
								hanakosetlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..hanakosetlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if hanakosetlowerbodytype ~= 5 then
								hanakosetlowerbodytype = hanakosetlowerbodytype + 1
							end
							if hanakosetlowerbodytype == 5 then
								hanakosetlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", hanakochbfn01) then
							hanakofmus01 = 0
							hanakochbfn01 = true
							hanakochbfm01 = false
							hanakomuscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", hanakochbfm01) then
							hanakofmus01 = 1
							hanakochbfn01 = false
							hanakochbfm01 = true
							hanakomuscularbody = "m"
						end
															
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then
------------				
							hanako_setcustom()
														
							hanakouppercontents = 1
							
							file = io.open("hanakosavedupperbodytype", "w")
							file:write(hanakosetupperbodytype)
							file:close()
									
							file = io.open("hanakosavedlowerbodytype", "w")
							file:write(hanakosetlowerbodytype)
							file:close()
							
							file = io.open("hanakosavedmuscular", "w")
							file:write(hanakofmus01)
							file:close()
							
							hanakoloadedupperbodytype = hanakosetupperbodytype
							hanakoloadedlowerbodytype = hanakosetlowerbodytype
							
							if hanakofmus01 == 1 then
								hanakosettext = " "..hanakosetupperbodytype.." and "..hanakosetlowerbodytype..", muscular"
							else
								hanakosettext = " "..hanakosetupperbodytype.." and "..hanakosetlowerbodytype
							end
							hanakosavetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..hanakosettext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..hanakosavetext)

						end
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
					end			
end					
-------------------
function hanako_setdefault()
							TweakDB:SetFlat("Character.Hanako.entityTemplatePath", "base\\quest\\secondary_characters\\hanako.ent")
							TweakDB:SetFlat("Character.Hanako_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\hanako_arasaka\\hanako_photomode.ent")
end
-------------------
function hanako_setcustom()
							TweakDB:SetFlat("Character.Hanako.entityTemplatePath", "base\\quest\\secondary_characters\\hanako"..hanakosetupperbodytype..hanakosetlowerbodytype..hanakomuscularbody..".ent")
							TweakDB:SetFlat("Character.Hanako_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\hanako_arasaka\\hanako_photomode"..hanakosetupperbodytype..hanakosetlowerbodytype..hanakomuscularbody..".ent")
end






-------------------
function stout_tab()
					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
					
					if ImGui.BeginTabItem(" Stout ") then
					
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
											
						ImGui.NewLine()
						
						stoutchbv01, pressed = ImGui.Checkbox("Enable Stout", stoutchbv01)			
						
						if pressed == true then
							stouttab = stouttab + 1

							if stouttab == 2 then
								stouttab = 0
							end
							if stouttab == 0 then
							
								stoutchbv01 = false
-----------
								stout_setdefault()

							end
							if stouttab == 1 then
							
								stoutsetupperbodytype = stoutloadedupperbodytype
								stoutsetlowerbodytype = stoutloadedlowerbodytype
								
								
								  	
								file = io.open("stoutsavedmuscular", "r")
								
								if file then
								  stoutmuscularcontents = file:read("*all")
								  file:close()
								else
								  stoutmuscularcontents = nil
								end
								
								if not stoutmuscularcontents then
								  stoutfmus01 = 0
								else
									if stoutmuscularcontents == "0" then
										stoutfmus01 = 0
									end
									if stoutmuscularcontents == "1" then
										stoutfmus01 = 1
									end
								end

								if stoutfmus01 == 0 then
									stoutchbfn01 = true
									stoutchbfm01 = false
									stoutmuscularbody = ""
									stoutmuscularbodytext = ""
								end
								if stoutfmus01 == 1 then
									stoutchbfn01 = false
									stoutchbfm01 = true
									stoutmuscularbody = "m"
									stoutmuscularbodytext = ", muscular"
								end
--------------							
								stout_setcustom()
								
							end
						
							file = io.open("stoutenabled", "w")
							file:write(stouttab)
							file:close()
													
						end
	
						if stouttab == 1 then
						
						
						if stoutuppercontents == nil then
							ImGui.Text("No saved configuration file found yet, setting upper body size to: "..stoutloadedupperbodytype.." and lower body size: "..stoutloadedlowerbodytype)
						end
						
						if stoutuppercontents ~= nil then
							if	stoutuppercontents == 1 then
								ImGui.Text("")
							else
								ImGui.Text("Previous Stout body configuration found. Loaded upper body size "..stoutloadedupperbodytype..", lower body size "..stoutloadedlowerbodytype..stoutmuscularbodytext)
							end
						end

						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if stoutsetupperbodytype ~= 0 then
								stoutsetupperbodytype = stoutsetupperbodytype - 1
							end
							if stoutsetupperbodytype == 0 then
								stoutsetupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..stoutsetupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if stoutsetupperbodytype ~= 5 then
								stoutsetupperbodytype = stoutsetupperbodytype + 1
							end
							if stoutsetupperbodytype == 5 then
								stoutsetupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if stoutsetlowerbodytype ~= 0 then
								stoutsetlowerbodytype = stoutsetlowerbodytype - 1
							end
							if stoutsetlowerbodytype == 0 then
								stoutsetlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..stoutsetlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if stoutsetlowerbodytype ~= 5 then
								stoutsetlowerbodytype = stoutsetlowerbodytype + 1
							end
							if stoutsetlowerbodytype == 5 then
								stoutsetlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", stoutchbfn01) then
							stoutfmus01 = 0
							stoutchbfn01 = true
							stoutchbfm01 = false
							stoutmuscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", stoutchbfm01) then
							stoutfmus01 = 1
							stoutchbfn01 = false
							stoutchbfm01 = true
							stoutmuscularbody = "m"
						end
															
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then
----------------						
							stout_setcustom()
							
							stoutuppercontents = 1
							
							file = io.open("stoutsavedupperbodytype", "w")
							file:write(stoutsetupperbodytype)
							file:close()
									
							file = io.open("stoutsavedlowerbodytype", "w")
							file:write(stoutsetlowerbodytype)
							file:close()
							
							file = io.open("stoutsavedmuscular", "w")
							file:write(stoutfmus01)
							file:close()
							
							stoutloadedupperbodytype = stoutsetupperbodytype
							stoutloadedlowerbodytype = stoutsetlowerbodytype
							
							if stoutfmus01 == 1 then
								stoutsettext = " "..stoutsetupperbodytype.." and "..stoutsetlowerbodytype..", muscular"
							else
								stoutsettext = " "..stoutsetupperbodytype.." and "..stoutsetlowerbodytype
							end
							stoutsavetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..stoutsettext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..stoutsavetext)
						
						end
						
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
					end
end					
-------------------
function stout_setdefault()
							TweakDB:SetFlat("Character.Stout.entityTemplatePath", "base\\quest\\tertiary_characters\\stout.ent")
							TweakDB:SetFlat("Character.Meredith_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\meredith_stout\\meredith_photomode.ent")
end
-------------------
function stout_setcustom()
							TweakDB:SetFlat("Character.Stout.entityTemplatePath", "base\\quest\\tertiary_characters\\stout"..stoutsetupperbodytype..stoutsetlowerbodytype..stoutmuscularbody..".ent")
							TweakDB:SetFlat("Character.Meredith_Puppet_Photomode.entityTemplatePath", "base\\characters\\entities\\player\\photo_mode\\meredith_stout\\meredith_photomode"..stoutsetupperbodytype..stoutsetlowerbodytype..stoutmuscularbody..".ent")
end








-------------------
function misty_tab()
					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
					
					if ImGui.BeginTabItem(" Misty ") then
					
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
											
						ImGui.NewLine()
						
						mistychbv01, pressed = ImGui.Checkbox("Enable Misty", mistychbv01)			
						
						if pressed == true then
							mistytab = mistytab + 1

							if mistytab == 2 then
								mistytab = 0
							end
							if mistytab == 0 then
							
								mistychbv01 = false
-----------
								misty_setdefault()

							end
							if mistytab == 1 then
							
								mistysetupperbodytype = mistyloadedupperbodytype
								mistysetlowerbodytype = mistyloadedlowerbodytype
								
								
								  	
								file = io.open("mistysavedmuscular", "r")
								
								if file then
								  mistymuscularcontents = file:read("*all")
								  file:close()
								else
								  mistymuscularcontents = nil
								end
								
								if not mistymuscularcontents then
								  mistyfmus01 = 0
								else
									if mistymuscularcontents == "0" then
										mistyfmus01 = 0
									end
									if mistymuscularcontents == "1" then
										mistyfmus01 = 1
									end
								end

								if mistyfmus01 == 0 then
									mistychbfn01 = true
									mistychbfm01 = false
									mistymuscularbody = ""
									mistymuscularbodytext = ""
								end
								if mistyfmus01 == 1 then
									mistychbfn01 = false
									mistychbfm01 = true
									mistymuscularbody = "m"
									mistymuscularbodytext = ", muscular"
								end
--------------							
								misty_setcustom()
								
							end
						
							file = io.open("mistyenabled", "w")
							file:write(mistytab)
							file:close()
													
						end
	
						if mistytab == 1 then
						
						
						if mistyuppercontents == nil then
							ImGui.Text("No saved configuration file found yet, setting upper body size to: "..mistyloadedupperbodytype.." and lower body size: "..mistyloadedlowerbodytype)
						end
						
						if mistyuppercontents ~= nil then
							if	mistyuppercontents == 1 then
								ImGui.Text("")
							else
								ImGui.Text("Previous Misty body configuration found. Loaded upper body size "..mistyloadedupperbodytype..", lower body size "..mistyloadedlowerbodytype..mistymuscularbodytext)
							end
						end

						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if mistysetupperbodytype ~= 0 then
								mistysetupperbodytype = mistysetupperbodytype - 1
							end
							if mistysetupperbodytype == 0 then
								mistysetupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..mistysetupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if mistysetupperbodytype ~= 5 then
								mistysetupperbodytype = mistysetupperbodytype + 1
							end
							if mistysetupperbodytype == 5 then
								mistysetupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if mistysetlowerbodytype ~= 0 then
								mistysetlowerbodytype = mistysetlowerbodytype - 1
							end
							if mistysetlowerbodytype == 0 then
								mistysetlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..mistysetlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if mistysetlowerbodytype ~= 5 then
								mistysetlowerbodytype = mistysetlowerbodytype + 1
							end
							if mistysetlowerbodytype == 5 then
								mistysetlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", mistychbfn01) then
							mistyfmus01 = 0
							mistychbfn01 = true
							mistychbfm01 = false
							mistymuscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", mistychbfm01) then
							mistyfmus01 = 1
							mistychbfn01 = false
							mistychbfm01 = true
							mistymuscularbody = "m"
						end
															
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then
----------------						
							misty_setcustom()
							
							mistyuppercontents = 1
							
							file = io.open("mistysavedupperbodytype", "w")
							file:write(mistysetupperbodytype)
							file:close()
									
							file = io.open("mistysavedlowerbodytype", "w")
							file:write(mistysetlowerbodytype)
							file:close()
							
							file = io.open("mistysavedmuscular", "w")
							file:write(mistyfmus01)
							file:close()
							
							mistyloadedupperbodytype = mistysetupperbodytype
							mistyloadedlowerbodytype = mistysetlowerbodytype
							
							if mistyfmus01 == 1 then
								mistysettext = " "..mistysetupperbodytype.." and "..mistysetlowerbodytype..", muscular"
							else
								mistysettext = " "..mistysetupperbodytype.." and "..mistysetlowerbodytype
							end
							mistysavetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..mistysettext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..mistysavetext)
						
						end
						
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
					end
end					
-------------------
function misty_setdefault()
							TweakDB:SetFlat("Character.Misty.entityTemplatePath", "base\\quest\\tertiary_characters\\misty.ent")
end
-------------------
function misty_setcustom()
							TweakDB:SetFlat("Character.Misty.entityTemplatePath", "base\\quest\\tertiary_characters\\misty"..mistysetupperbodytype..mistysetlowerbodytype..mistymuscularbody..".ent")
end









-------------------
function claire_tab()
					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
					
					if ImGui.BeginTabItem(" Claire") then
					
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
											
						ImGui.NewLine()
						
						clairechbv01, pressed = ImGui.Checkbox("Enable Claire", clairechbv01)			
						
						if pressed == true then
							clairetab = clairetab + 1

							if clairetab == 2 then
								clairetab = 0
							end
							if clairetab == 0 then
							
								clairechbv01 = false
-----------
								claire_setdefault()

							end
							if clairetab == 1 then
							
								clairesetupperbodytype = claireloadedupperbodytype
								clairesetlowerbodytype = claireloadedlowerbodytype
								
								
								  	
								file = io.open("clairesavedmuscular", "r")
								
								if file then
								  clairemuscularcontents = file:read("*all")
								  file:close()
								else
								  clairemuscularcontents = nil
								end
								
								if not clairemuscularcontents then
								  clairefmus01 = 0
								else
									if clairemuscularcontents == "0" then
										clairefmus01 = 0
									end
									if clairemuscularcontents == "1" then
										clairefmus01 = 1
									end
								end

								if clairefmus01 == 0 then
									clairechbfn01 = true
									clairechbfm01 = false
									clairemuscularbody = ""
									clairemuscularbodytext = ""
								end
								if clairefmus01 == 1 then
									clairechbfn01 = false
									clairechbfm01 = true
									clairemuscularbody = "m"
									clairemuscularbodytext = ", muscular"
								end
--------------							
								claire_setcustom()
								
							end
						
							file = io.open("claireenabled", "w")
							file:write(clairetab)
							file:close()
													
						end
	
						if clairetab == 1 then
						
						
						if claireuppercontents == nil then
							ImGui.Text("No saved configuration file found yet, setting upper body size to: "..claireloadedupperbodytype.." and lower body size: "..claireloadedlowerbodytype)
						end
						
						if claireuppercontents ~= nil then
							if	claireuppercontents == 1 then
								ImGui.Text("")
							else
								ImGui.Text("Previous Claire body configuration found. Loaded upper body size "..claireloadedupperbodytype..", lower body size "..claireloadedlowerbodytype..clairemuscularbodytext)
							end
						end

						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if clairesetupperbodytype ~= 0 then
								clairesetupperbodytype = clairesetupperbodytype - 1
							end
							if clairesetupperbodytype == 0 then
								clairesetupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..clairesetupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if clairesetupperbodytype ~= 5 then
								clairesetupperbodytype = clairesetupperbodytype + 1
							end
							if clairesetupperbodytype == 5 then
								clairesetupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if clairesetlowerbodytype ~= 0 then
								clairesetlowerbodytype = clairesetlowerbodytype - 1
							end
							if clairesetlowerbodytype == 0 then
								clairesetlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..clairesetlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if clairesetlowerbodytype ~= 5 then
								clairesetlowerbodytype = clairesetlowerbodytype + 1
							end
							if clairesetlowerbodytype == 5 then
								clairesetlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", clairechbfn01) then
							clairefmus01 = 0
							clairechbfn01 = true
							clairechbfm01 = false
							clairemuscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", clairechbfm01) then
							clairefmus01 = 1
							clairechbfn01 = false
							clairechbfm01 = true
							clairemuscularbody = "m"
						end
															
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then
----------------						
							claire_setcustom()
							
							claireuppercontents = 1
							
							file = io.open("clairesavedupperbodytype", "w")
							file:write(clairesetupperbodytype)
							file:close()
									
							file = io.open("clairesavedlowerbodytype", "w")
							file:write(clairesetlowerbodytype)
							file:close()
							
							file = io.open("clairesavedmuscular", "w")
							file:write(clairefmus01)
							file:close()
							
							claireloadedupperbodytype = clairesetupperbodytype
							claireloadedlowerbodytype = clairesetlowerbodytype
							
							if clairefmus01 == 1 then
								clairesettext = " "..clairesetupperbodytype.." and "..clairesetlowerbodytype..", muscular"
							else
								clairesettext = " "..clairesetupperbodytype.." and "..clairesetlowerbodytype
							end
							clairesavetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..clairesettext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..clairesavetext)
						
						end
						
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
					end
end					
-------------------
function claire_setdefault()
							TweakDB:SetFlat("Character.Claire.entityTemplatePath", "base\\quest\\tertiary_characters\\claire.ent")
end
-------------------
function claire_setcustom()
							TweakDB:SetFlat("Character.Claire.entityTemplatePath", "base\\quest\\tertiary_characters\\claire"..clairesetupperbodytype..clairesetlowerbodytype..clairemuscularbody..".ent")
end




				



-------------------
function fcitizen_tab()

					ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 5, 5)
					
					if ImGui.BeginTabItem(" Female citizens ") then
					
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
											
						ImGui.NewLine()
						
						fcitizenchbv01, pressed = ImGui.Checkbox("Enable all female citizens", fcitizenchbv01)
						
						if pressed == true then
							fcitizentab = fcitizentab + 1

							if fcitizentab == 2 then
								fcitizentab = 0
							end
							if fcitizentab == 0 then
							
								fcitizenchbv01 = false
								
---------------
								fcitizen_setdefault()
								
							end
							if fcitizentab == 1 then
							
								fcitizensetupperbodytype = fcitizenloadedupperbodytype
								fcitizensetlowerbodytype = fcitizenloadedlowerbodytype
						
								file = io.open("fcitizensavedmuscular", "r")
								
								if file then
								  fcitizenmuscularcontents = file:read("*all")
								  file:close()
								else
								  fcitizenmuscularcontents = nil
								end
								
								if not fcitizenmuscularcontents then
								  fcitizenfmus01 = 0
								else
									if fcitizenmuscularcontents == "0" then
										fcitizenfmus01 = 0
									end
									if fcitizenmuscularcontents == "1" then
										fcitizenfmus01 = 1
									end
								end

								if fcitizenfmus01 == 0 then
									fcitizenchbfn01 = true
									fcitizenchbfm01 = false
									fcitizenmuscularbody = ""
									fcitizenmuscularbodytext = ""
								end
								if fcitizenfmus01 == 1 then
									fcitizenchbfn01 = false
									fcitizenchbfm01 = true
									fcitizenmuscularbody = "m"
									fcitizenmuscularbodytext = ", muscular"
								end
								
----------------
								fcitizen_setcustom()
								
								end
							
							file = io.open("fcitizenenabled", "w")
							file:write(fcitizentab)
							file:close()
							
						end
					
						if fcitizentab == 1 then
						
						if fcitizenrandom == 1 then
							ImGui.Text(" ")
						else
						
						if fcitizenuppercontents == nil then
							ImGui.Text("No saved configuration file found yet, setting upper body size to: "..fcitizenloadedupperbodytype.." and lower body size: "..fcitizenloadedlowerbodytype)
						end
						
						if fcitizenuppercontents ~= nil then
							if	fcitizenuppercontents == 1 then
								fcitizent0=ImGui.Text("")
							else
								ImGui.Text("Previous Female NPC body configuration found. Loaded upper body size "..fcitizenloadedupperbodytype..", lower body size "..fcitizenloadedlowerbodytype..fcitizenmuscularbodytext)
							end
						end
						end

						fcitizenrandomchbfr01, checked = ImGui.Checkbox("Random", fcitizenrandomchbfr01)
						
						if checked == true then
							fcitizenrandom = fcitizenrandom + 1
							
							--[[
							if fcitizenrandom == 1 then
								print(fcitizenrandom)
							end
							--]]
							if fcitizenrandom == 2 then
								fcitizenrandom = 0
								--print(fcitizenrandom)
							end
						end
						
						if fcitizenrandom == 0 then
																	
						ImGui.NewLine()

						ImGui.Text('Set upper body size')
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 10, 10)
						if ImGui.ArrowButton("u1", ImGuiDir.Left) then
							if fcitizensetupperbodytype ~= 0 then
								fcitizensetupperbodytype = fcitizensetupperbodytype - 1
							end
							if fcitizensetupperbodytype == 0 then
								fcitizensetupperbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..fcitizensetupperbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("u2", ImGuiDir.Right) then
							if fcitizensetupperbodytype ~= 5 then
								fcitizensetupperbodytype = fcitizensetupperbodytype + 1
							end
							if fcitizensetupperbodytype == 5 then
								fcitizensetupperbodytype = 4
							end
						end
							
						ImGui.Text('Set lower body size')
						
						if ImGui.ArrowButton("l1", ImGuiDir.Left) then
							if fcitizensetlowerbodytype ~= 0 then
								fcitizensetlowerbodytype = fcitizensetlowerbodytype - 1
							end
							if fcitizensetlowerbodytype == 0 then
								fcitizensetlowerbodytype = 1
							end
						end
						
						ImGui.SameLine()
						ImGui.Text("     "..fcitizensetlowerbodytype.."     ")
						ImGui.SameLine()
						
						if ImGui.ArrowButton("l2", ImGuiDir.Right) then
							if fcitizensetlowerbodytype ~= 5 then
								fcitizensetlowerbodytype = fcitizensetlowerbodytype + 1
							end
							if fcitizensetlowerbodytype == 5 then
								fcitizensetlowerbodytype = 4
							end
						end
						ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, 0, 0)
						
						ImGui.NewLine()
						
						if ImGui.Checkbox("Normal", fcitizenchbfn01) then
							fcitizenfmus01 = 0
							fcitizenchbfn01 = true
							fcitizenchbfm01 = false
							fcitizenmuscularbody = ""
						end
						ImGui.SameLine()
						if ImGui.Checkbox("Muscular", fcitizenchbfm01) then
							fcitizenfmus01 = 1
							fcitizenchbfn01 = false
							fcitizenchbfm01 = true
							fcitizenmuscularbody = "m"
						end
						
						end									
						ImGui.NewLine()
						
						if ImGui.Button("SET AND SAVE", 155, 30) then
						
----------------
							fcitizen_setcustom()
							
							fcitizenuppercontents = 1
							
							file = io.open("fcitizenrandom", "w")
							file:write(fcitizenrandom)
							file:close()
							
							if fcitizenrandom == 0 then
							file = io.open("fcitizensavedupperbodytype", "w")
							file:write(fcitizensetupperbodytype)
							file:close()
									
							file = io.open("fcitizensavedlowerbodytype", "w")
							file:write(fcitizensetlowerbodytype)
							file:close()
							
							file = io.open("fcitizensavedmuscular", "w")
							file:write(fcitizenfmus01)
							file:close()
							
							fcitizenloadedupperbodytype = fcitizensetupperbodytype
							fcitizenloadedlowerbodytype = fcitizensetlowerbodytype
							end
							

							if fcitizenrandom == 0 then
							if fcitizenfmus01 == 1 then
								fcitizensettext = " "..fcitizensetupperbodytype.." and "..fcitizensetlowerbodytype..", muscular"
							else
								fcitizensettext = " "..fcitizensetupperbodytype.." and "..fcitizensetlowerbodytype
							end
							end
							
							if fcitizenrandom == 1 then
								fcitizensettext = "random size not muscular"
							end
							
							
							fcitizensavetext = "Reload save game to see all changes. Body sizes saved to external file"

						end
						
						ImGui.SameLine()
										
						ImGui.NewLine()
						
						ImGui.TextColored(1, 0, 0, 1,"Body sizes set to: "..fcitizensettext)
						
						ImGui.NewLine()
						ImGui.TextColored(1, 0, 0, 1,""..fcitizensavetext)
						
						end
						
						ImGui.PopStyleVar()
						
						ImGui.EndTabItem()
					end
					
end

-------------------
function fcitizen_setdefault()

-------------------service

	TweakDB:SetFlat("Character.SexworkerFemale.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_sexworker_wa.ent")
	TweakDB:SetFlat("Character.SexworkerFemaleDE.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_sexworker_wa.ent")
	TweakDB:SetFlat("Character.SexworkerFemaleDoll.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_sexworker_wa.ent")	
	TweakDB:SetFlat("Character.sts_ep1_06_sexworker_city_wa.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_sexworker_wa.ent")
	TweakDB:SetFlat("Character.sts_ep1_06_sexworker_crowd_wa.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_sexworker_wa.ent")
	TweakDB:SetFlat("Character.sts_ep1_06_sexworker_wa_savable.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_sexworker_wa.ent")
	TweakDB:SetFlat("Character.ProstituteFemale.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_sexworker_wa.ent")
	TweakDB:SetFlat("Character.ProstituteFemaleDE.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_sexworker_wa.ent")


	TweakDB:SetFlat("Character.ServiceDancerFemale.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_dancer_wa.ent")
	TweakDB:SetFlat("Character.ServiceTubeDancerFemale.entityTemplatePath", "base\\characters\\entities\\service\\service_tubedancer_wa.ent")

	TweakDB:SetFlat("Character.MediaWoman.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_media_wa.ent")
	TweakDB:SetFlat("Character.MediaWomanDE.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_media_wa.ent")
	TweakDB:SetFlat("Character.wst_ep1_12_13_media.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_media_wa.ent")

	TweakDB:SetFlat("Character.MedicalFemale.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_medical_wa.ent")
	TweakDB:SetFlat("Character.NurseFemale.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_medical_wa.ent")

	TweakDB:SetFlat("Character.ReligiousFemale.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_religious_wa.ent")

	TweakDB:SetFlat("Character.cz_stadium_ripperdoc_nurse_01_wa.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_service_point_additional_wa.ent")

	TweakDB:SetFlat("Character.ServiceDiningWoman.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_dining_wa.ent")
	TweakDB:SetFlat("Character.Character.Waitress.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_dining_wa.ent")

	TweakDB:SetFlat("Character.VendorFemale.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_vendor_wa.ent")
	TweakDB:SetFlat("Character.VendorFemaleDE.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_vendor_wa.ent")
	TweakDB:SetFlat("Character.AsianVendorFemale.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_vendor_wa.ent")
	TweakDB:SetFlat("Character.CreoleVendorFemale.entityTemplatePath", "base\\characters\\entities\\service\\service__ep1_vendor_wa.ent")
	TweakDB:SetFlat("Character.Drinks_Woman.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.Grilled_Food_Woman.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.Kiosk_Woman.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.Market_Woman.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.Packed_Food_Woman.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")

	TweakDB:SetFlat("Character.bls_ina_se1_clothingshop_01.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.bls_ina_se1_gunsmith_02.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.bls_ina_se1_medicstore_01.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.bls_ina_se5_melee_01.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.hey_rey_netrunner_01.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.hey_spr_gunsmith_01.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.pac_cvi_clothingshop_01.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.std_arr_clothingshop_01.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.std_rcr_clothingshop_01.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
	TweakDB:SetFlat("Character.wbr_hil_clothingshop_01.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")




-------------------citizen


								TweakDB:SetFlat("Character.StoopQueenNoReaction.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_lowlife_wa")
								TweakDB:SetFlat("Character.StoopQueen.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_lowlife_wa")
								TweakDB:SetFlat("Character.mq012_ripperdoc_couch.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__nightlife_wa.ent")

								TweakDB:SetFlat("Character.CitizenAldecaldosFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_aldecaldos_wa.ent")
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_aldecaldos_wa.ent")
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleNomad.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_aldecaldos_wa.ent")
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleTeenager.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_aldecaldos_wa.ent")
								TweakDB:SetFlat("Character.CitizenBikerFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_biker_wa.ent")
								TweakDB:SetFlat("Character.CitizenRichFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_rich_wa.ent")
								TweakDB:SetFlat("Character.CitizenRichFemaleCasual.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_rich_wa.ent")
								TweakDB:SetFlat("Character.CitizenRichFemaleDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_rich_wa.ent")
								TweakDB:SetFlat("Character.CorpoWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanAfterWork.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanAfterWorkDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanArasaka.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_arasaka_corpo_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanArasakaDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_arasaka_corpo_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanCorporat.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanCorporatDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWoman_ow_city_scenes.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_corporat_wa.ent")
								TweakDB:SetFlat("Character.CreoleWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_creole_wa.ent")
								TweakDB:SetFlat("Character.CreoleWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_creole_wa.ent")
								TweakDB:SetFlat("Character.CreoleWoman_q112.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_creole_wa.ent")
								
								--TweakDB:SetFlat("Character.DefaultNCResidentFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_default_wa.ent")
								--TweakDB:SetFlat("Character.DefaultNCResidentFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__default_wa.ent")
								
								TweakDB:SetFlat("Character.FreakFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_freak_wa.ent")
								TweakDB:SetFlat("Character.FreakFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_freak_wa.ent")
								TweakDB:SetFlat("Character.FreakFemale_q112.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_freak_wa.ent")
								TweakDB:SetFlat("Character.HomelessFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_homeless_wa.ent")
								TweakDB:SetFlat("Character.HomelessFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_homeless_wa.ent")
								TweakDB:SetFlat("Character.JunkieFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_junkie_wa.ent")
								TweakDB:SetFlat("Character.JunkieFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_junkie_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanNoTalk.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanRedneck.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanRedneckDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanRedneckDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_lowlife_wa.ent")
								
								TweakDB:SetFlat("Character.Mallrat.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_mallrat_wa.ent")
								
								TweakDB:SetFlat("Character.NightlifeWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_nightlife_wa.ent")
								TweakDB:SetFlat("Character.NightlifeFemaleDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_nightlife_wa.ent")
								TweakDB:SetFlat("Character.TenantWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_tenant_wa.ent")
								TweakDB:SetFlat("Character.TenantWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_tenant_wa.ent")
								TweakDB:SetFlat("Character.WorkoutFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_workout_wa.ent")
								TweakDB:SetFlat("Character.YoungsterFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_youngster_wa.ent")
								TweakDB:SetFlat("Character.YoungsterFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_youngster_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBody.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen_ep1_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyCorpo.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen_ep1_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyNightlife.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen_ep1_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyPosh.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen_ep1_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyYoungster.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen_ep1_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.AsianFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_corporat_wa.ent")
								TweakDB:SetFlat("Character.AsianFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_corporat_wa.ent")
								TweakDB:SetFlat("Character.MorningCrowdWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_tenant_wa.ent")
								TweakDB:SetFlat("Character.MorningCrowdWoman_q112.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_tenant_wa.ent")						
								--TweakDB:SetFlat("Character.CreoleVendorFemale.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
								--TweakDB:SetFlat("Character.Tech_Junk_Woman.entityTemplatePath", "base\\characters\\entities\\service\\service__vendor_wa.ent")
--[[
---- before patch 2.0

								TweakDB:SetFlat("Character.CitizenAldecaldosFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__aldecaldos_wa.ent")
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__aldecaldos_wa.ent")
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleNomad.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__aldecaldos_wa.ent")
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleTeenager.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__aldecaldos_wa.ent")
								TweakDB:SetFlat("Character.CitizenBikerFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__biker_wa.ent")
								TweakDB:SetFlat("Character.CitizenRichFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__rich_wa.ent")
								TweakDB:SetFlat("Character.CitizenRichFemaleCasual.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__rich_wa.ent")
								TweakDB:SetFlat("Character.CitizenRichFemaleDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__rich_wa.ent")
								TweakDB:SetFlat("Character.CorpoWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanAfterWork.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanAfterWorkDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanArasaka.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__arasaka_corpo_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanArasakaDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__arasaka_corpo_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanCorporat.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanCorporatDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWoman_ow_city_scenes.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CreoleWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__creole_wa.ent")
								TweakDB:SetFlat("Character.CreoleWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__creole_wa.ent")
								TweakDB:SetFlat("Character.CreoleWoman_q112.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__creole_wa.ent")
								
								--TweakDB:SetFlat("Character.DefaultNCResidentFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__ep1_default_wa.ent")
								--TweakDB:SetFlat("Character.DefaultNCResidentFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__default_wa.ent")
								
								TweakDB:SetFlat("Character.FreakFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__freak_wa.ent")
								TweakDB:SetFlat("Character.FreakFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__freak_wa.ent")
								TweakDB:SetFlat("Character.FreakFemale_q112.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__freak_wa.ent")
								TweakDB:SetFlat("Character.HomelessFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__homeless_wa.ent")
								TweakDB:SetFlat("Character.HomelessFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__homeless_wa.ent")
								TweakDB:SetFlat("Character.JunkieFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__junkie_wa.ent")
								TweakDB:SetFlat("Character.JunkieFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__junkie_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanNoTalk.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanRedneck.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanRedneckDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanRedneckDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.Mallrat.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__mallrat_wa.ent")
								TweakDB:SetFlat("Character.NightlifeWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__nightlife_wa.ent")
								TweakDB:SetFlat("Character.NightlifeFemaleDriver.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__nightlife_wa.ent")
								TweakDB:SetFlat("Character.TenantWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__tenant_wa.ent")
								TweakDB:SetFlat("Character.TenantWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__tenant_wa.ent")
								TweakDB:SetFlat("Character.WorkoutFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__workout_wa.ent")
								TweakDB:SetFlat("Character.YoungsterFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__youngster_wa.ent")
								TweakDB:SetFlat("Character.YoungsterFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__youngster_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBody.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyCorpo.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyNightlife.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyPosh.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyYoungster.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.AsianFemale.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.AsianFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.MorningCrowdWoman.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__tenant_wa.ent")
								TweakDB:SetFlat("Character.MorningCrowdWoman_q112.entityTemplatePath", "base\\characters\\entities\\citizen\\citizen__tenant_wa.ent")						
]]							
								
end

-------------------
function fcitizen_setcustom()


-------------------service
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.SexworkerFemale.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_sexworker_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.SexworkerFemaleDE.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_sexworker_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.SexworkerFemaleDoll.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_sexworker_wa.ent")	
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.sts_ep1_06_sexworker_city_wa.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_sexworker_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.sts_ep1_06_sexworker_crowd_wa.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_sexworker_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.sts_ep1_06_sexworker_wa_savable.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_sexworker_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.ProstituteFemale.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_sexworker_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.ProstituteFemaleDE.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_sexworker_wa.ent")

	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.ServiceDancerFemale.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_dancer_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.ServiceTubeDancerFemale.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service_tubedancer_wa.ent")

	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.MediaWoman.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_media_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.MediaWomanDE.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_media_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.wst_ep1_12_13_media.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_media_wa.ent")

	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.MedicalFemale.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_medical_wa.ent")
	TweakDB:SetFlat("Character.NurseFemale.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_medical_wa.ent")

	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.ReligiousFemale.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_religious_wa.ent")

	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.cz_stadium_ripperdoc_nurse_01_wa.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_service_point_additional_wa.ent")

	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.ServiceDiningWoman.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_dining_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.Character.Waitress.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_dining_wa.ent")

	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.VendorFemale.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.VendorFemaleDE.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.AsianVendorFemale.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.CreoleVendorFemale.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__ep1_vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.Drinks_Woman.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.Grilled_Food_Woman.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.Kiosk_Woman.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.Market_Woman.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.Packed_Food_Woman.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")

	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.bls_ina_se1_clothingshop_01.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.bls_ina_se1_gunsmith_02.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.bls_ina_se1_medicstore_01.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.bls_ina_se5_melee_01.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.hey_rey_netrunner_01.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.hey_spr_gunsmith_01.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.pac_cvi_clothingshop_01.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.std_arr_clothingshop_01.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.std_rcr_clothingshop_01.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")
	if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
	TweakDB:SetFlat("Character.wbr_hil_clothingshop_01.entityTemplatePath", "base\\characters\\entities\\service"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\service__vendor_wa.ent")



-------------------citizen

								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.StoopQueenNoReaction.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_lowlife_wa")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.StoopQueen.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_lowlife_wa")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.mq012_ripperdoc_couch.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__nightlife_wa.ent")

								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CitizenAldecaldosFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_aldecaldos_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_aldecaldos_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleNomad.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_aldecaldos_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleTeenager.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_aldecaldos_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CitizenBikerFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_biker_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CitizenRichFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_rich_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CitizenRichFemaleCasual.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_rich_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CitizenRichFemaleDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_rich_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CorpoWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_corporat_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CorpoWomanAfterWork.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_corporat_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CorpoWomanAfterWorkDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_corporat_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CorpoWomanArasaka.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_arasaka_corpo_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CorpoWomanArasakaDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_arasaka_corpo_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CorpoWomanCorporat.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_corporat_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CorpoWomanCorporatDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_corporat_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CorpoWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_corporat_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CorpoWoman_ow_city_scenes.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_corporat_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CreoleWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_creole_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CreoleWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_creole_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.CreoleWoman_q112.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_creole_wa.ent")
							
								--TweakDB:SetFlat("Character.DefaultNCResidentFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_default_wa.ent")
								--TweakDB:SetFlat("Character.DefaultNCResidentFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__default_wa.ent")

								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.FreakFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_freak_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.FreakFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_freak_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.FreakFemale_q112.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_freak_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.HomelessFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_homeless_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.HomelessFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_homeless_wa.ent")
									
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.JunkieFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_junkie_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.JunkieFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_junkie_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.LowlifeWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_lowlife_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.LowlifeWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_lowlife_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.LowlifeWomanDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_lowlife_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.LowlifeWomanNoTalk.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_lowlife_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.LowlifeWomanRedneck.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_lowlife_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.LowlifeWomanRedneckDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_lowlife_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.LowlifeWomanRedneckDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_lowlife_wa.ent")
								
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.Mallrat.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_mallrat_wa.ent")
								
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.NightlifeWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_nightlife_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.NightlifeFemaleDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_nightlife_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.TenantWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_tenant_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.TenantWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_tenant_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.WorkoutFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_workout_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.YoungsterFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_youngster_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.YoungsterFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_youngster_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.NonBinaryFemaleBody.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_ep1_nonbinary_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyCorpo.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_ep1_nonbinary_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyNightlife.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_ep1_nonbinary_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyPosh.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_ep1_nonbinary_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyYoungster.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_ep1_nonbinary_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyYoungster.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_ep1_nonbinary_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.AsianFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_corporat_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.AsianFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_corporat_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.MorningCrowdWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_tenant_wa.ent")
								if fcitizenrandom == 1 then fcitizensetupperbodytype = math.random(1, 4) fcitizensetlowerbodytype = math.random(1, 4) end
								TweakDB:SetFlat("Character.MorningCrowdWoman_q112.entityTemplatePath", "base\\characters\\entities"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen\\citizen__ep1_tenant_wa.ent")

--[[
---- before patch 2.0

								TweakDB:SetFlat("Character.CitizenAldecaldosFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__aldecaldos_wa.ent")

								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__aldecaldos_wa.ent")
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleNomad.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__aldecaldos_wa.ent")
								TweakDB:SetFlat("Character.CitizenAldecaldosFemaleTeenager.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__aldecaldos_wa.ent")
												
								TweakDB:SetFlat("Character.CitizenBikerFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__biker_wa.ent")
								TweakDB:SetFlat("Character.CitizenRichFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__rich_wa.ent")
								TweakDB:SetFlat("Character.CitizenRichFemaleCasual.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__rich_wa.ent")
								TweakDB:SetFlat("Character.CitizenRichFemaleDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__rich_wa.ent")
					
								TweakDB:SetFlat("Character.CorpoWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanAfterWork.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanAfterWorkDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanArasaka.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__arasaka_corpo_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanArasakaDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__arasaka_corpo_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanCorporat.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanCorporatDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.CorpoWoman_ow_city_scenes.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__corporat_wa.ent")
								
								TweakDB:SetFlat("Character.CreoleWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__creole_wa.ent")
								TweakDB:SetFlat("Character.CreoleWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__creole_wa.ent")
								TweakDB:SetFlat("Character.CreoleWoman_q112.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__creole_wa.ent")
							
								--TweakDB:SetFlat("Character.DefaultNCResidentFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__ep1_default_wa.ent")
								--TweakDB:SetFlat("Character.DefaultNCResidentFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__default_wa.ent")

								TweakDB:SetFlat("Character.FreakFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__freak_wa.ent")
								TweakDB:SetFlat("Character.FreakFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__freak_wa.ent")
								TweakDB:SetFlat("Character.FreakFemale_q112.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__freak_wa.ent")
								TweakDB:SetFlat("Character.HomelessFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__homeless_wa.ent")
								TweakDB:SetFlat("Character.HomelessFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__homeless_wa.ent")
																
								TweakDB:SetFlat("Character.JunkieFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__junkie_wa.ent")
								TweakDB:SetFlat("Character.JunkieFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__junkie_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanNoTalk.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanRedneck.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanRedneckDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.LowlifeWomanRedneckDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__lowlife_wa.ent")
								TweakDB:SetFlat("Character.Mallrat.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__mallrat_wa.ent")
								TweakDB:SetFlat("Character.NightlifeWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__nightlife_wa.ent")
								TweakDB:SetFlat("Character.NightlifeFemaleDriver.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__nightlife_wa.ent")
								TweakDB:SetFlat("Character.TenantWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__tenant_wa.ent")
								TweakDB:SetFlat("Character.TenantWomanDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__tenant_wa.ent")
								TweakDB:SetFlat("Character.WorkoutFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__workout_wa.ent")
								TweakDB:SetFlat("Character.YoungsterFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__youngster_wa.ent")
								TweakDB:SetFlat("Character.YoungsterFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__youngster_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBody.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyCorpo.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyNightlife.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyPosh.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyYoungster.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.NonBinaryFemaleBodyYoungster.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen_nonbinary_wa.ent")
								TweakDB:SetFlat("Character.AsianFemale.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.AsianFemaleDE.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__corporat_wa.ent")
								TweakDB:SetFlat("Character.MorningCrowdWoman.entityTemplatePath", "base\\characters\\entities\\citizen"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen__tenant_wa.ent")
								TweakDB:SetFlat("Character.MorningCrowdWoman_q112.entityTemplatePath", "base\\characters\\entities"..fcitizensetupperbodytype..fcitizensetlowerbodytype..fcitizenmuscularbody.."\\citizen\\citizen__tenant_wa.ent")
]]
end
