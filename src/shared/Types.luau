--!strict
export type Loot = { Id: string, Variant: string }
export type Settings = { Music: number, Effects: number, ReducedMotion: boolean, Shake: boolean }
export type Profile = {
 Schema: number, Cash: number, Reputation: number, Upgrades: {[string]: number},
 Districts: {[string]: boolean}, Collection: {[string]: boolean}, Milestones: {[string]: boolean},
 Starter: number, StarterProgress: number, Daily: {Day: number, Progress: {[string]: number}, Claimed: {[string]: boolean}},
 Identities: number, Badges: {[string]: boolean}, Settings: Settings,
}
return {}
