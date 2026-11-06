--!strict
local C = {}
C.Title = "CREDIT CARD STEALER"
C.Subtitle = "Small cards. Big cartoon trouble."
C.Schema = 1
C.StudioTestData = true -- Never opens the production store while true in Studio.
C.StoreName = "CCSS_Production_v1"
C.SaveInterval = 60
C.LeaseSeconds = 180
C.MaxPlayers = 12
C.InteractDistance = 13
C.TargetCooldown = 24
C.Inventory = { Base = 5, PerLevel = 2 }
C.Timing = { BaseDuration = 2.3, DistrictSpeed = 0.12, SleightSpeed = 0.04, BaseWidth = 0.29, DistrictWidth = 0.018, FocusWidth = 0.012, MinCenter = 0.33, MaxCenter = 0.74 }
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
 Focus = { BaseCost = 55, Growth = 1.9, Max = 8, Description = "Success window gains 1.2% per level." },
 Capacity = { BaseCost = 60, Growth = 1.9, Max = 8, Description = "Carry two more cards per level." },
 Sneakers = { BaseCost = 65, Growth = 1.9, Max = 6, Description = "+0.8 movement speed per level; capped at 20.8." },
 Disguise = { BaseCost = 50, Growth = 1.85, Max = 8, Description = "Suspicion rises 7% slower per level." },
 Terminal = { BaseCost = 75, Growth = 1.95, Max = 8, Description = "Bank cards for 6% more per level." },
}
C.UpgradeOrder = { "Sleight", "Focus", "Capacity", "Sneakers", "Disguise", "Terminal" }
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
 { Title = "A pocket-sized beginning", Text = "Meet a target near Crumb Mart and land the timing marker.", Kind = "success", Goal = 1, Cash = 30, Rep = 5 },
 { Title = "Bring it home", Text = "Return to the mint hideout terminal and bank your cards.", Kind = "bank", Goal = 20, Cash = 30, Rep = 5 },
 { Title = "A little finesse", Text = "Buy your first upgrade at the hideout.", Kind = "upgrade", Goal = 1, Cash = 40, Rep = 10 },
 { Title = "Stay cool", Text = "Collect three more cards. Heat fades in the hideout.", Kind = "collect", Goal = 3, Cash = 100, Rep = 10 },
 { Title = "Bigger sidewalks", Text = "Unlock Shopping Plaza from the Districts menu.", Kind = "district", Goal = 1, Cash = 100, Rep = 10 },
 { Title = "Lose the tail", Text = "Raise Heat to attract a guard, then break sight and escape.", Kind = "escape", Goal = 1, Cash = 200, Rep = 25 },
 { Title = "Clean sweep", Text = "Bank five cards in one trip without getting caught.", Kind = "clean", Goal = 5, Cash = 250, Rep = 25 },
}
C.DailyPool = {
 { Title = "Pocket parade", Kind = "collect", Goal = 12, Cash = 180, Rep = 15 },
 { Title = "A steady hand", Kind = "success", Goal = 10, Cash = 200, Rep = 15 },
 { Title = "Terminal velocity", Kind = "bank", Goal = 500, Cash = 220, Rep = 20 },
 { Title = "Rare occasion", Kind = "rarity", Goal = 3, Cash = 250, Rep = 20 },
 { Title = "See you later", Kind = "escape", Goal = 2, Cash = 250, Rep = 25 },
 { Title = "Vault tourist", Kind = "vault", Goal = 1, Cash = 300, Rep = 25 },
}
-- Add only audio assets you own or are permitted to use. Empty means intentionally silent.
C.Audio = { Music = "", Click = "", Success = "", Failure = "", Bank = "", Reveal = "", Alert = "", Capture = "" }
return C
