--!strict
local C = {}
C.Title = "CREDIT CARD STEALER"
C.Subtitle = "Small cards. Big cartoon trouble."
C.Schema = 4
C.Release = "CARD CITY / CITY SHIFT"
C.StudioTestData = true -- Never opens the production store while true in Studio.
C.StoreName = "CCSS_Production_v1"
C.SaveInterval = 60
C.LeaseSeconds = 180
C.MaxPlayers = 12
C.InteractDistance = 13
C.TargetCooldown = 24
C.Inventory = { Base = 5, PerLevel = 2 }
C.Timing = { BaseDuration = 2.4, DistrictSpeed = 0.16, SleightSpeed = 0.025, BaseWidth = 0.25, DistrictWidth = 0.024, FocusWidth = 0.009, MinCenter = 0.33, MaxCenter = 0.74 }
C.Suspicion = { Distance = 8, Rise = 12, Decay = 14, DisguiseReduction = 0.07, AlertHeat = 12 }
C.TerminalPerLevel = 0.06
C.InteractionLead = 0.8
C.LatencyAllowance = 0.18
C.CaptureFraction = 0.5
C.CaptureImmunity = 10
C.Heat = { Success = 9, Failure = 24, ChaseAt = 55, Decay = 2.4, SafeDecay = 14, QuietSeconds = 4 }
C.Prestige = { Cash = 100000, Reputation = 1000, BonusPerIdentity = 0.05, BonusCap = 0.5 }
C.Vault = { Duration = 65, Cooldown = 90, Rep = 90, Reward = 1200, MaxSlots = 12 }
C.Palette = { Charcoal = Color3.fromRGB(23,24,36), Panel = Color3.fromRGB(35,37,53), Purple = Color3.fromRGB(159,109,255), Mint = Color3.fromRGB(112,242,193), Gold = Color3.fromRGB(255,209,104), White = Color3.fromRGB(241,242,250), Muted = Color3.fromRGB(170,177,200), Danger = Color3.fromRGB(255,112,128) }
C.Rarities = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }
C.RarityColors = { Color3.fromRGB(187,194,210), Color3.fromRGB(112,242,193), Color3.fromRGB(104,177,255), Color3.fromRGB(179,121,255), Color3.fromRGB(255,209,104), Color3.fromRGB(255,117,191) }
C.Variants = { { Name = "Standard", Multiplier = 1, Weight = 88 }, { Name = "Foil", Multiplier = 1.5, Weight = 8 }, { Name = "Glitched", Multiplier = 2.2, Weight = 3 }, { Name = "Golden", Multiplier = 3.5, Weight = 1 } }
C.Upgrades = {
 Sleight = { BaseCost = 40, Growth = 1.85, Max = 8, Description = "Timing sweep is 4% shorter per level." },
 Focus = { BaseCost = 55, Growth = 1.9, Max = 8, Description = "Success window gains 0.6% per level, within skill-based limits." },
 Capacity = { BaseCost = 60, Growth = 1.9, Max = 8, Description = "Carry two more cards per level." },
 Sneakers = { BaseCost = 65, Growth = 1.9, Max = 6, Description = "+0.8 movement speed per level; capped at 20.8." },
 Disguise = { BaseCost = 50, Growth = 1.85, Max = 8, Description = "Suspicion rises 7% slower per level." },
 Terminal = { BaseCost = 75, Growth = 1.95, Max = 8, Description = "Bank cards for 6% more per level." },
}
C.Upgrades.Composure = { BaseCost = 90, Growth = 1.9, Max = 6, Description = "Reduces interaction Heat by 4% per level." }
C.Upgrades.Gadgets = { BaseCost = 125, Growth = 2.1, Max = 4, Description = "Unlocks a confetti decoy. Higher levels add charges and reduce cooldown." }
C.Upgrades.Appraisal = { BaseCost = 110, Growth = 1.95, Max = 6, Description = "Adds 4% rarity luck per level, weighted toward higher rarities." }
C.Upgrades.Sleight.Description = "Adds 1.8% phase time per level and opens harder districts' targets."
C.Upgrades.Press = {BaseCost=100,Growth=1.85,Max=6,Description="Pressing batches is 7% faster per level."}
C.Upgrades.Rinse = {BaseCost=120,Growth=1.85,Max=6,Description="Cartoon token rinsing is 7% faster per level."}
C.Upgrades.Yield = {BaseCost=180,Growth=1.95,Max=6,Description="Processing pays 4% more per level."}
C.Upgrades.VanSlots = {BaseCost=160,Growth=1.9,Max=6,Description="Adds four secured van storage slots per level."}
C.Upgrades.Engine = {BaseCost=200,Growth=1.9,Max=4,Description="Adds two studs/second to van cruising speed, capped at 26."}
C.UpgradeGroups = {
 {Name="Field gear",Tracks={"Sleight","Focus","Capacity","Sneakers","Disguise","Composure","Gadgets","Appraisal"}},
 {Name="Operations",Tracks={"Terminal","Press","Rinse","Yield"}},
 {Name="Van",Tracks={"VanSlots","Engine"}},
}
C.Streets={"Crumb Avenue","Market Way","Ledger Street","Crown Row","Exchange Avenue"}
C.City={DistrictSpacing=240,HalfWidth=120,HalfDepth=195,RoadHalfWidth=18,HideoutZ=108,HideoutX=-65}
C.Processing={PressSeconds=18,RinseSeconds=14,SpeedPerLevel=0.07,YieldPerLevel=0.04,QueueCapacity=200}
C.Van={Price=650,Reputation=30,BaseSlots=8,SlotsPerLevel=4,Speed=18,SpeedPerLevel=2,Acceleration=8,TurnRate=0.9,SummonCooldown=30}
C.Van.ReverseFraction=.4;C.Van.Braking=22;C.Van.Coast=5;C.Van.SteerAngle=.6;C.Van.Wheelbase=8.6;C.Van.AbandonSeconds=240;C.Van.InputTimeout=.6
C.NPC={NearDistance=180,NearInterval=.25,FarInterval=1.25,PathInterval=2.5,MaxPaths=2,StuckSeconds=9,CrossSpeed=6}
C.Speakers={
 Mara={Role="Workshop operator",District=1,X=72,Z=76,Lines={"Read the route before you commit. One clean card beats a rushed mistake.","Secure cards in the cabinet, press the batch, rinse the tokens, then collect the payout."}},
 Jax={Role="Courier mechanic",District=1,X=-94,Z=78,Lines={"Brake before a tight corner. Your rear doors are a saved mobile locker.","Garage bays need room. Stop before recovering a stuck van."}},
 Wren={Role="City guide",District=1,X=64,Z=82,Lines={"Every avenue has a service lane. Keep your eyes open, not glued to signs.","The map marks places you have found. Souvenirs still take a little exploring."}},
 Iris={Role="Night-shift coordinator",District=4,X=72,Z=76,Lines={"High stakes means reading changing lanes. A safe finish is still a win.","Vault gates follow their own rhythm. Watch a full pulse before crossing."}},
}
C.Traffic={Count=24,Speed=24,Acceleration=7,Braking=18,Gap=28,GreenSeconds=19,CrossingSeconds=9,Lane=8}
C.Weather={Duration=210,Transition=24,DaySeconds=1440,Order={"Clear","Overcast","Rain","Fog"},Profiles={
 Clear={Clouds=0.15,Density=0.22,Haze=0.5,Brightness=2.3,Rain=false,Drive=1,Visibility=1},
 Overcast={Clouds=0.8,Density=0.32,Haze=1.2,Brightness=1.4,Rain=false,Drive=1,Visibility=1},
 Rain={Clouds=0.95,Density=0.4,Haze=1.7,Brightness=1.1,Rain=true,Drive=0.8,Visibility=0.9},
 Fog={Clouds=0.6,Density=0.55,Haze=2.8,Brightness=1.4,Rain=false,Drive=0.9,Visibility=0.72},
}}
C.AssetTemplates={SedanBody="SedanBody",VanBody="VanBody",Wheel="Wheel",Sofa="Sofa",Chair="Chair",Locker="Locker",Tree="Tree",Streetlamp="Streetlamp",Dumpster="Dumpster"}
C.CosmeticSlots={"Head","Face","Back","Outfit"}
C.CosmeticOrder={"canvas_mint","canvas_gold","night_beanie","round_specs","gold_specs","courier_pack","plum_pack","mint_jacket","rust_jacket","night_jacket"}
C.Cosmetics={
 canvas_mint={Name="Mint Canvas Cap",Slot="Head",Model="CanvasCap",Price=75,Rep=0,Color=Color3.fromRGB(108,170,153)},
 canvas_gold={Name="Golden Hour Cap",Slot="Head",Model="CanvasCap",Price=220,Rep=25,Color=Color3.fromRGB(199,160,96)},
 night_beanie={Name="After Hours Beanie",Slot="Head",Model="Beanie",Price=180,Rep=15,Color=Color3.fromRGB(108,97,135)},
 round_specs={Name="Round Street Frames",Slot="Face",Model="RoundSpecs",Price=120,Rep=10,Color=Color3.fromRGB(49,61,68)},
 gold_specs={Name="Brass Round Frames",Slot="Face",Model="RoundSpecs",Price=350,Rep=50,Color=Color3.fromRGB(205,167,97)},
 courier_pack={Name="Courier Canvas Pack",Slot="Back",Model="Backpack",Price=260,Rep=25,Color=Color3.fromRGB(105,143,118)},
 plum_pack={Name="Plum Weekend Pack",Slot="Back",Model="Backpack",Price=420,Rep=60,Color=Color3.fromRGB(132,102,139)},
 mint_jacket={Name="Mint Workshop Jacket",Slot="Outfit",Model="Jacket",Price=300,Rep=30,Color=Color3.fromRGB(74,123,116)},
 rust_jacket={Name="Rust Utility Jacket",Slot="Outfit",Model="Jacket",Price=550,Rep=80,Color=Color3.fromRGB(160,102,74)},
 night_jacket={Name="Midnight Member Jacket",Slot="Outfit",Model="Jacket",Price=900,Rep=140,Color=Color3.fromRGB(61,69,91)},
}
C.MaterialAssets={} -- Optional published ColorMap/NormalMap/RoughnessMap IDs; native material detail works without these.
C.UpgradeOrder = { "Sleight", "Focus", "Capacity", "Sneakers", "Disguise", "Terminal", "Composure", "Gadgets", "Appraisal", "Press", "Rinse", "Yield", "VanSlots", "Engine" }
C.UpgradeRep = {0,0,20,50,100,200,400,650}
C.UpgradeRanks = {"DIY", "Streetwise", "Professional", "Legendary"}
C.Approaches = {
 Careful = { Width = 1.15, Duration = 1.12, Heat = 0.8, Value = 1, Luck = 1, Description = "Wider visible routes, one recovery, 20% less Heat." },
 Bold = { Width = 0.85, Duration = 0.9, Heat = 1.4, Value = 1.2, Luck = 1.15, Description = "Changing lanes, reversing patterns and later memory routes. +20% card quality, +15% rarity luck, 40% more Heat." },
}
C.TargetStyles = {
 Daydreamer = { Name = "Daydreamer", Stages = 1, Width = 1.08, Luck = 1, Value = 1, Speed = 3.4, Flavor = "Busy counting imaginary pigeons." },
 Commuter = { Name = "Commuter", Stages = 2, Width = 1, Luck = 1.1, Value = 1.05, Speed = 5, Flavor = "Late for a meeting about meetings." },
 Collector = { Name = "Card Collector", Stages = 2, Width = 0.95, Luck = 1.5, Value = 1.1, Speed = 3.8, Flavor = "Owns several extremely fictional cards." },
 VIP = { Name = "Fancy VIP", Stages = 3, Width = 0.9, Luck = 1.35, Value = 1.25, Speed = 4.2, Flavor = "Pays for everything with royal raccoon treats." },
}
C.Stealing = { StageLead = 0.6, Drift = 0.055, ComboCap = 5, ComboValue = 0.03, Composure = 0.04, Appraisal = 0.04, RaritySlope = 0.45, CancelHeat = 10 }
C.Round={Duration=3.25,Width=0.235,Lead=0.55,MaxBackdate=0.4,RecoveryQuality=0.8,BonusValue=0.15,BonusFailureQuality=0.75,DecisionSeconds=7,ErrorHeat=6}
C.ModeOrder={"Practice","Careful","Bold","DailyDrill","Vault"}
C.Modes={
 Practice={Name="Workshop practice",Start="Practice console",Objective="Read a route, match its lanes and lock in the mint zone.",Pressure="One recovery; no Heat or loot at risk.",Reward="Medals and a saved personal best; no money or cards.",Duration="10–20 seconds",Requirement="Any workshop",Gear="Focus widens zones; Sleight adds a little phase time."},
 Careful={Name="Street / careful",Start="Scout a citizen",Objective="Clear the route, recover one mistake, then secure your card.",Pressure="Nearby security and carried cards remain at risk.",Reward="One fictional collectible; optional +15% quality bonus.",Duration="8–20 seconds",Requirement="District access and Sleight rating",Gear="Focus, Sleight, Composure; one decoy can stabilize a phase."},
 Bold={Name="Street / high stakes",Start="Scout a citizen / choose Bold",Objective="Remember harder routes, change lanes and earn a stronger card.",Pressure="Tighter zones, reversed patterns, memory in later districts; +40% Heat.",Reward="+20% card quality, +15% rarity luck; optional bonus risk.",Duration="10–22 seconds",Requirement="District access and Sleight rating",Gear="Same controls; gear helps without choosing a lane for you."},
 DailyDrill={Name="Daily route drill",Start="Practice console",Objective="Master today's shared, seeded four-step route.",Pressure="High-stakes patterns with one recovery; no loot or Heat at risk.",Reward="Daily best and career medal only. Fast retries.",Duration="12–22 seconds",Requirement="Any workshop",Gear="Fixed training gear keeps the daily pattern comparable."},
 Vault={Name="Vault Run",Start="Starter workshop vault terminal",Objective="Move through five pulsing gates, collect the trophy, reach the exit.",Pressure="65-second course; active beams fail the run. Bank pockets first.",Reward="$1,200, 20 REP and a Golden collection discovery, once per completed run.",Duration="Up to 65 seconds",Requirement="90 REP, empty pockets, kiosk and available room",Gear="Movement skill; sneaker speed is bounded."},
}
C.MedalRanks={Retry=0,Bronze=1,Silver=2,Gold=3,Platinum=4}
C.Gadget = { BaseCharges = 1, ChargeLevels = 2, Cooldown = 28, CooldownPerLevel = 3, DistractSeconds = 3.5, HeatRelief = 12 }
C.HideoutOrder = {"Lounge", "Workshop", "Display", "Network"}
C.HideoutUpgrades = {
 Lounge = { Name = "Recovery Lounge", BaseCost = 90, Growth = 2.6, Max = 3, Rep = 0, Description = "+4 Heat recovery per second in safe rooms per level." },
 Workshop = { Name = "Gadget Workshop", BaseCost = 160, Growth = 2.6, Max = 3, Rep = 20, Description = "+1 decoy charge at the supply bench per level. Requires Gadgets to use." },
 Display = { Name = "Collector Gallery", BaseCost = 140, Growth = 2.6, Max = 3, Rep = 20, Description = "+2% banking value per level after five discoveries; adds personal trophy displays." },
 Network = { Name = "Courier Network", BaseCost = 220, Growth = 2.8, Max = 3, Rep = 30, Description = "Unlocks hideout travel. Level 2 reaches every open district; level 3 lowers fares further." },
}
C.Hideout = { Width = 64, Depth = 48, SafeRecovery = 4, DisplayBonus = 0.02, DisplayDiscoveries = 5, TravelHeat = 20, TravelFare = 20, TravelDiscount = 0.2 }
C.SecretNames = {"Lost Crumb", "Banana Blueprint", "Goblin Keepsake"}
C.SecretHints = {"Look behind the western storefront.", "Search the eastern courtyard.", "Follow the back lane past the shops."}
C.Secrets = {}
for district=1,5 do
 for n=1,3 do
  local id=string.format("S%d_%d",district,n)
  C.Secrets[id]={Name=C.SecretNames[n], District=district, Hint=C.SecretHints[n], Cash=35+district*25, Rep=4+district}
 end
end
C.Districts = {
 { Name = "Starter Street", Rep = 0, Cash = 0, Difficulty = 1, Equipment = 0, Color = Color3.fromRGB(110,202,179), Landmark = "CRUMB MART", Weights = {74,22,4,0,0,0}, GuardSpeed = 13, Detection = 28 },
 { Name = "Shopping Plaza", Rep = 20, Cash = 120, Difficulty = 2, Equipment = 1, Color = Color3.fromRGB(229,157,117), Landmark = "BANANA ARCADE", Weights = {40,38,18,4,0,0}, GuardSpeed = 15, Detection = 33 },
 { Name = "Business District", Rep = 90, Cash = 900, Difficulty = 3, Equipment = 2, Color = Color3.fromRGB(123,163,205), Landmark = "MOONVAULT TRANSIT", Weights = {15,30,36,16,3,0}, GuardSpeed = 17, Detection = 37 },
 { Name = "Luxury Heights", Rep = 240, Cash = 4000, Difficulty = 4, Equipment = 4, Color = Color3.fromRGB(188,174,214), Landmark = "ROYAL RACCOON ESTATE", Weights = {0,15,34,35,14,2}, GuardSpeed = 18, Detection = 40 },
 { Name = "Neon Financial Center", Rep = 600, Cash = 14000, Difficulty = 5, Equipment = 6, Color = Color3.fromRGB(119,110,188), Landmark = "VOID UNLIMITED", Weights = {0,5,22,38,28,7}, GuardSpeed = 19, Detection = 44 },
}
C.Brands = { "Crumb Bank", "Banana Express", "Goblin Gold", "MoonVault", "Royal Raccoon", "Void Unlimited" }
C.CardNames = { "Pocket Crumbs", "Banana Split", "Goblin's Lunch", "Moon Dust", "Royal Treat", "Infinite Noodles" }
C.CardValues = { 24, 42, 85, 180, 450, 1100 }
C.Cards = {}
for district = 1, 5 do
 for rarity = 1, 6 do
  if C.Districts[district].Weights[rarity] == 0 then continue end
  local id = string.format("D%dR%d", district, rarity)
  C.Cards[id] = { Id = id, Name = C.CardNames[rarity] .. " / " .. C.Districts[district].Name, Brand = C.Brands[rarity], Rarity = rarity, District = district, Value = math.floor(C.CardValues[rarity] * (1 + (district-1)*0.7)), Theme = C.RarityColors[rarity] }
 end
end
C.Milestones = { {Count = 5, Cash = 100}, {Count = 15, Cash = 500}, {Count = 30, Cash = 2000}, {Count = 60, Cash = 8000} }
C.StarterMissions = {
 { Title = "A pocket-sized beginning", Text = "Leave the workshop door, turn left into the alley, and scout a citizen on the avenue.", Kind = "success", Goal = 1, Cash = 30, Rep = 5 },
 { Title = "Bring it home", Text = "Find the alley hideout. Deposit cards, press tokens, rinse, then claim the payout.", Kind = "bank", Goal = 20, Cash = 30, Rep = 5 },
 { Title = "A little finesse", Text = "Buy your first upgrade at the hideout.", Kind = "upgrade", Goal = 1, Cash = 40, Rep = 10 },
 { Title = "Stay cool", Text = "Collect three more cards. Heat fades in the hideout.", Kind = "collect", Goal = 3, Cash = 100, Rep = 10 },
 { Title = "Bigger sidewalks", Text = "Unlock Shopping Plaza from the Districts menu.", Kind = "district", Goal = 1, Cash = 100, Rep = 10 },
 { Title = "Lose the tail", Text = "Raise Heat to attract a guard, then break sight and escape.", Kind = "escape", Goal = 1, Cash = 200, Rep = 25 },
 { Title = "Clean sweep", Text = "Process five uncaught cards in one batch. Captured cards do not count.", Kind = "clean", Goal = 5, Cash = 250, Rep = 25 },
}
C.DailyPool = {
 { Title = "Pocket parade", Kind = "collect", Goal = 12, Cash = 180, Rep = 15 },
 { Title = "A steady hand", Kind = "success", Goal = 10, Cash = 200, Rep = 15 },
 { Title = "Terminal velocity", Kind = "bank", Goal = 500, Cash = 220, Rep = 20 },
 { Title = "Rare occasion", Kind = "rarity", Goal = 3, Cash = 250, Rep = 20 },
 { Title = "See you later", Kind = "escape", Goal = 2, Cash = 250, Rep = 25 },
 { Title = "Vault tourist", Kind = "vault", Goal = 1, Cash = 300, Rep = 25 },
}
C.Contracts = {
 mara_1={Speaker="Mara",Title="Welcome to the back room",Text="Collect three fictional cards for your first batch.",Kind="collect",Goal=3,Cash=90,Rep=10,District=1},
 mara_2={Speaker="Mara",Title="Spin cycle",Text="Finish a processing batch and claim its payout.",Kind="process",Goal=1,Cash=140,Rep=15,District=1,Previous="mara_1"},
 mara_3={Speaker="Mara",Title="A place of your own",Text="Improve two clubhouse facilities.",Kind="facility",Goal=2,Cash=300,Rep=20,District=1,Previous="mara_2"},
 jax_1={Speaker="Jax",Title="Keys to the city",Text="Buy the courier van at your hideout garage.",Kind="van",Goal=1,Cash=180,Rep=15,District=1},
 jax_2={Speaker="Jax",Title="Sunday driver",Text="Drive 300 studs in your own van.",Kind="drive",Goal=300,Cash=220,Rep=20,District=1,Previous="jax_1"},
 jax_3={Speaker="Jax",Title="Plaza drop-off",Text="Bring your van to the marked Shopping Plaza delivery bay and use its prompt.",Kind="delivery",Goal=1,Cash=500,Rep=35,District=2,Previous="jax_2"},
 wren_1={Speaker="Wren",Title="Back-lane discoveries",Text="Find three hidden city souvenirs.",Kind="secret",Goal=3,Cash=240,Rep=20,District=1},
 wren_2={Speaker="Wren",Title="Steady under pressure",Text="Complete three all-perfect tricks.",Kind="perfect",Goal=3,Cash=400,Rep=30,District=2,Previous="wren_1"},
 wren_3={Speaker="Wren",Title="City lights",Text="Secure five cards in the Business District.",Kind="collectD3",Goal=5,Cash=600,Rep=40,District=3,Previous="wren_2"},
 iris_1={Speaker="Iris",Title="Royal appointment",Text="Collect five cards in Luxury Heights.",Kind="collectD4",Goal=5,Cash=900,Rep=45,District=4},
 iris_2={Speaker="Iris",Title="No loose ends",Text="Escape three security pursuits.",Kind="escape",Goal=3,Cash=1000,Rep=50,District=4,Previous="iris_1"},
 iris_3={Speaker="Iris",Title="After-hours membership",Text="Finish two Vault Runs.",Kind="vault",Goal=2,Cash=1800,Rep=70,District=5,Previous="iris_2"},
}
C.ContractOrder={"mara_1","mara_2","mara_3","jax_1","jax_2","jax_3","wren_1","wren_2","wren_3","iris_1","iris_2","iris_3"}
-- Add only audio assets you own or are permitted to use. Empty means intentionally silent.
C.Audio = {Music="",Ambient="",Engine="",Machine="",Click="rbxasset://sounds/electronicpingshort.wav",Success="rbxasset://sounds/electronicpingshort.wav",Failure="rbxasset://sounds/electronicpingshort.wav",Bank="rbxasset://sounds/electronicpingshort.wav",Reveal="rbxasset://sounds/electronicpingshort.wav",Alert="rbxasset://sounds/electronicpingshort.wav",Capture="rbxasset://sounds/electronicpingshort.wav"}
return C
