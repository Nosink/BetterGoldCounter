local _, ns = ...

ns.expansion = GetExpansionLevel()

ns.RegisterEnum("expansion", {
    CLASSIC = 0,
    BURNING_CRUSADE = 1,
    WRATH_OF_THE_LICH_KING = 2,
    CATACLYSM = 3,
    MISTS_OF_PANDARIA = 4,
    WARLORDS_OF_DRAENOR = 5,
    LEGION = 6,
    BATTLE_FOR_AZEROTH = 7,
    SHADOWLANDS = 8,
    DRAGONFLIGHT = 9,
    WAR_WITHIN = 10,
    MIDNIGHT = 11,
})
