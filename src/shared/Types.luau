--!strict
export type Loot = { Id: string, Variant: string, Quality: number?, Clean: boolean? }
export type Settings = { Music: number, Effects: number, ReducedMotion: boolean, Shake: boolean, WeatherEffects: boolean }
export type Profile = {
 Cosmetics: any, Processing: any, Van: any, Contracts: any,
 Hideout: {[string]: number}, Secrets: {[string]: boolean}, Stats: {[string]: number},
 Schema: number, Cash: number, Reputation: number, Upgrades: {[string]: number},
 Districts: {[string]: boolean}, Collection: {[string]: boolean}, Milestones: {[string]: boolean},
 Starter: number, StarterProgress: number, Daily: {Day: number, Progress: {[string]: number}, Claimed: {[string]: boolean}},
 Identities: number, Badges: {[string]: boolean}, Settings: Settings,
}
return {}
