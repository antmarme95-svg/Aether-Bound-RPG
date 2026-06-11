// Path allegiance buffs — applied when the player picks a path in the Conqueror's Choice.

export const PATH_BUFFS = {
  kingdom:  { label: "Crown's Aegis", toast: "The Crown arms its blade", mods: { maxHealth: 25, physicalResist: 0.10 } },
  betrayal: { label: "Double Ledger", toast: "Payment received. Twice.", mods: { maxMagicka: 30, maxStamina: 15 } },
  rogue:    { label: "Unbound Fury", toast: "No leash. No limits.", mods: { damageMult: 1.15, maxStamina: 20 } },
};
