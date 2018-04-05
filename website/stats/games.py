class GameInfo(object):
    def __init__(self, gid, name, db_log, db_ab, default_level_file):
        self.gid = gid
        self.name = name
        self.db_log = db_log
        self.db_ab = db_ab
        self.default_level_file = default_level_file

refraction = GameInfo(11, "refraction", "cgs_gm_refraction_log", None, "data/levels/SpecialLevels.json")
infiniterefr = GameInfo(13, "infiniterefr", "cgs_gm_infiniterefr_log", "cgs_gm_infiniterefr_ab", "data/levels/LSFall2012Levels.json")
numberline = GameInfo(22, "numberline", "cgs_gm_numberline_log", None, "data/levels/Numberline.xml")
dragonbox = GameInfo(14, "dragonbox", "cgs_gm_algebra_log", None, None)
cardgame = GameInfo(24, "cardgame", "cgs_gm_cardgame_log", None, None)
twilite = GameInfo(1, "twilite", "cgs_gm_twilite_log", None, None)
bpanyaa = GameInfo(25, "bpanyda", "cgs_gm_bpanyda_log", None, None)
generic = GameInfo(0, None, None, None, None)
tests = GameInfo(40, "tests", "cgs_gm_assessment_tests_log", None, None)
pipejam = GameInfo(23, "pipejam", "cgs_gm_pipejam_log", None, None)

infiniterefr_meta = GameInfo(13, "infiniterefr", "cgs_gm_infiniterefr", "cgs_gm_infiniterefr_ab", "data/levels/LSFall2012Levels.json")

games_by_name = {
    "refraction" : refraction,
    "infiniterefr" : infiniterefr,
    "numberline" : numberline,
    "dragonbox" : dragonbox,
    "twilite" : twilite,
    "cardgame" : cardgame,
    "tests" : tests,
    "bpanyaa": bpanyaa,
    "infiniterefr_meta" : infiniterefr_meta,
    "pipejam": pipejam
}
