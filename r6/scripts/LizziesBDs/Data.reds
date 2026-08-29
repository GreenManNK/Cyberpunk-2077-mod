// ************************************************************************************************
// ***  Lizzie's Braindances
// ***    Author: ArmanIII
// ***
// *** Please, if you will have unconquerable lust to edit this file (which I don't recommend),
// *** then please do not report any bugs you will encounter in the mod, because I don't want
// *** then spend X hours of searching of a bug which doesn't exist and in the end we find that
// *** it's all your fault. Help me save my nerves. Thanks.
// ***
// ************************************************************************************************

module LizziesBDs.Data

import LizziesBDs.Classes.*
import LizziesBDs.Resources.*

public enum GlobalniID {
	Prazdne = 999,

	Vzhledy_Base = 500,
	Postava_LokaceBezPostavy = 501,
	Postava_Vlastni_Zena = 6000,
	Postava_Vlastni_Muz = 7000,

	Postava_Female_V = 1000,
	Postava_Judy_Alvarez = 1001,
	Postava_Panam_Palmer = 1002,
	Postava_Skye = 1003,
	Postava_Meredith_Stout = 1060,
	Postava_Evelyn_Parker = 1004,
	Postava_Cheri_Nowlin = 1005,
	Postava_Altiera_Alt_Cunningham = 1006,
	Postava_Elizabeth_Peralez = 1007,
	Postava_Hanako_Arasaka = 1008,
	Postava_Ruby_Collins = 1009,
	Postava_Maiko_Maeda = 1010,
	Postava_T_Bug = 1011,
	Postava_Rogue_Amendiares = 1081,
	Postava_Misty_Olszewski = 1012,
	Postava_Iris_Tanner = 1013,
	Postava_Roxanne_Sumner = 1014,
	Postava_Karina_Lee = 1015,
	Postava_Gillean_Jordan = 1016,
	Postava_Sandra_Dorsett = 1017,
	Postava_Song_Songbird_So_Mi = 1083,
	Postava_Aurore_Cassel = 1018,
	Postava_Rosalind_Myers = 1019,
	Postava_Lina_Malina = 1020,
	Postava_Angelica_Angie_Whelan = 1021,
	Postava_Stella_Ramos = 1022,
	Postava_Claire_Russell = 1023,
	Postava_Rachel_Casich = 1024,
	Postava_Elisabeth_Lizzy_Wizzy_Wissenfurth = 1025,
	Postava_Alena_Alex_Xenakis = 1026,
	Postava_Georgina_Zembinsky = 1027,
	Postava_Ruth_Dzeng = 1028,
	Postava_Denny = 1029,
	Postava_Emilie_Massenat = 1030,
	Postava_Beatrice_Ellen_8ug8ear_Trieste = 1031,
	Postava_Dakota_Smith = 1032,
	Postava_Joss_Kutcher = 1033,
	Postava_Zuleikha_El_Ahmar = 1034,
	Postava_Lucyna_Lucy_Kushinada = 1035,
	Postava_Regina_Jones = 1036,
	Postava_Nika_Yankovich = 1037,
	Postava_Theo_Price = 1038,
	Postava_Melisa_Rory = 1039,
	Postava_Konpeki_Receptionist_01 = 1040,
	Postava_Nadia_Petrova = 1041,
	Postava_Joanne_Koch = 1042,
	Postava_Nadezhda_Tiurina = 1043,
	Postava_Anna_Hamill = 1044,
	Postava_Farida_Nazeri = 1045,
	Postava_Guadalupe_Alejandra_Welles = 1046,
	Postava_Clothing_Seller_Std_Arr = 1047,
	Postava_NCPD_Female_01 = 1048,
	Postava_Yawen_Packard = 1049,
	Postava_Nele_Springer = 1050,
	Postava_Lauren_Costigan = 1051,
	Postava_Jasmine_Dixon = 1052,
	Postava_Martha_Frakes = 1095,
	Postava_Maman_Mama_Brigitte = 1097,
	Postava_Helen_Wandoo = 1098,
	Postava_Imogen = 1099,
	Postava_Fiona_Vargas = 1101,
	Postava_Wakakos_Desk_Girl = 1102,
	Postava_Michiko_Arasaka = 1107,
	Postava_Rebeca_Price = 1109,
	Postava_Olga_Elisabeth_Longmead = 1110,
	Postava_Queen_Of_The_Stoop_12 = 1061,
	Postava_Dao_Hyunh = 1082,
	Postava_Zaria_Hughes = 1084,
	Postava_Yoko_Tsuru = 1100,
	Postava_Cynthia_Najarro = 1108,
	Postava_Sophia_Dupont = 1111,
	Postava_Tenant_Morning_Crowd_07 = 1112,
	Postava_Wakako_Okada = 1113,
	Postava_Bree_Whitney = 1114,
	Postava_Sachiko_Kusama = 1115,
	Postava_Dietlinde = 1116,
	Postava_Charlene_Fox = 1053,
	Postava_Brittany_Hayes = 1054,
	Postava_JigJig_Dancer_05 = 1055,
	Postava_Tasha_Rodriquez = 1056,
	Postava_Aoi_Blue_Moon_Tsuki = 1057,
	Postava_Purple_Force = 1058,
	Postava_Akai_Red_Menace_Kyoi = 1059,
	Postava_Rita_Wheeler = 1062,
	Postava_Susanna_Susie_Q_Quinn = 1065,
	Postava_Valentinos_Female_01 = 1066,
	Postava_Valentinos_Female_02 = 1067,
	Postava_Valentinos_Female_03 = 1068,
	Postava_Valentinos_Female_04 = 1069,
	Postava_6th_Street_Female_01 = 1070,
	Postava_6th_Street_Female_02 = 1071,
	Postava_6th_Street_Female_03 = 1072,
	Postava_6th_Street_Female_04 = 1073,
	Postava_6th_Street_Female_05 = 1074,
	Postava_6th_Street_Female_06 = 1103,
	Postava_Maelstrom_Female_01 = 1075,
	Postava_Maelstrom_Female_02 = 1076,
	Postava_Maelstrom_Female_03 = 1077,
	Postava_Aldecaldos_Female_01 = 1104,
	Postava_Aldecaldos_Female_02 = 1105,
	Postava_Aldecaldos_Female_03 = 1106,
	Postava_Ofelia_Patricia_Sirawian = 1096,
	Postava_Tyger_Claws_Female_01 = 1078,
	Postava_Tyger_Claws_Female_02 = 1079,
	Postava_Tyger_Claws_Female_03 = 1080,
	Postava_Mox_Female_01 = 1063,
	Postava_Mox_Female_02 = 1085,
	Postava_Mox_Female_03 = 1086,
	Postava_Mox_Female_04 = 1087,
	Postava_Mox_Female_05 = 1088,
	Postava_Mox_Female_06 = 1089,
	Postava_Mox_Female_Lvl_2_1 = 1090,
	Postava_Mox_Female_Lvl_2_2 = 1091,
	Postava_Mox_Female_Lvl_2_3 = 1092,
	Postava_Mox_Female_Lvl_3_1 = 1093,
	Postava_Mox_Female_Lvl_3_2 = 1064,
	Postava_Mox_Female_Lvl_3_3 = 1094,
	Postava_Shelma = 1117,
	Postava_Linh_Hyunh = 1118,
	Postava_Lowlife_Latino_01 = 1119,
	Postava_Rich_Female_12 = 1120,
	Postava_Sexworker_Doll_02 = 1121,
	Postava_Carol_Emeka = 1122,
	Postava_Vendor_03 = 1123,
	Postava_Caliente_Waitress_01 = 1124,
	Postava_Konpeki_Waitress_01 = 1125,
	Postava_Miranda_Lawson = 1126,
	Postava_Clothing_Seller_Wat_Nid = 1127,
	Postava_Queen_Of_The_Stoop_03 = 1128,
	Postava_Tourist_01 = 1129,
	Postava_Tourist_02 = 1130,
	Postava_Arasaka_Corpo_01 = 1131,
	Postava_Aldecaldos_Female_Driver_Lvl_3_3 = 1132,
	Postava_Arasaka_Netrunner_Lvl_2_3 = 1133,
	Postava_Veteran_Guard_01 = 1134,
	Postava_Tube_Dancer_08 = 1135,
	Postava_Song_So_Ri = 1136,
	Postava_Youngster_Slacker_14 = 1137,
	Postava_Rhino = 1138,
	Postava_Julia_Young = 1139,
	Postava_Grace_Karina_Voronova = 1140,
	Postava_Tyler_Zan = 1141,
	Postava_Yishen_Rhee = 1142,
	Postava_Dogtown_Joytoy_01 = 1143,
	Postava_Dogtown_Nightlife_02 = 1144,
	Postava_Dogtown_Nightlife_05 = 1145,
	Postava_Dogtown_Nightlife_10 = 1146,
	Postava_Heavy_Hearts_Waitress_02 = 1147,
	Postava_Nina_Kraviz = 1148,
	Postava_Lana_Prince = 1149,
	Postava_Animals_Female_01 = 1150,
	Postava_Animals_Female_02 = 1151,
	Postava_Animals_Female_03 = 1152,
	Postava_Dogtown_Joytoy_06 = 1153,
	Postava_Heavy_Hearts_Waitress_04 = 1154,
	Postava_Barghest_Female_01 = 1155,
	Postava_Barghest_Female_02 = 1156,
	Postava_Barghest_Female_03 = 1157,
	Postava_Barghest_Female_04 = 1158,
	Postava_Barghest_Female_05 = 1159,
	Postava_Scavengers_Female_01 = 1160,
	Postava_Scavengers_Female_02 = 1161,
	Postava_Scavengers_Female_03 = 1162,
	Postava_Scavengers_Female_04 = 1163,
	Postava_Wraiths_Female_01 = 1164,
	Postava_Wraiths_Female_02 = 1165,
	Postava_Wraiths_Female_03 = 1166,
	Postava_Wraiths_Female_04 = 1167,
	Postava_Mox_Bouncer_02 = 1168,
	Postava_Sofia_Rossi = 1169,
	Postava_E3_Female_V = 1170,
	Postava_Barbara_Babs_Okoye = 1171,
	Postava_Trigger = 1172,
	Postava_Godiva = 1173,
	Postava_Kissy = 1174,
	Postava_Roxxi = 1175,
	Postava_Paradise_Waitress_03 = 1176,
	Postava_Clothing_Seller_Bls_Ina = 1177,
	Postava_Barghest_Female_Guard_01 = 1178,
	Postava_Pacific_Female_06 = 1179,
	Postava_Susan_Abernathy = 1180,
	Postava_Heavy_Hearts_Waitress_01 = 1181,
	Postava_Heavy_Hearts_Waitress_03 = 1182,
	Postava_Heavy_Hearts_Waitress_05 = 1183,
	Postava_NCPD_Female_02 = 1184,
	Postava_Nightlife_Hottie_21 = 1185,
	Postava_Lizzies_Stripper_04 = 1186,
	Postava_Arasaka_Corpo_06 = 1187,
	Postava_Arabella_Spider_Murphy = 1188,
	Postava_Zoe_Alonzo = 1189,
	Postava_Yelena_Sidorova = 1190,
	Postava_Taki_Kenmochi = 1191,
	Postava_Lt_Mower = 1192,
	Postava_Tamara_Cosby = 1193,
	Postava_Rose_Horrigan = 1194,
	Postava_Aguilar_Nubiola_Female = 1195,
	Postava_Biker_Female_04 = 1196,
	Postava_Arasaka_Scientist = 1197,
	Postava_Nightlife_Hottie_15 = 1198,
	Postava_Pacific_Female_13 = 1199,
	Postava_Laura_May = 1200,
	Postava_Sofia_Ramirez = 1201,
	Postava_Food_Seller_Wbr_Jpn = 1202,
	Postava_Maggie_Isley = 1203,
	Postava_Ayo_Zarin = 1204,
	Postava_Journey_Ruiz = 1205,
	Postava_Sexworker_Prostitute_05 = 1206,
	Postava_Sexworker_Prostitute_07 = 1207,
	Postava_Sexworker_Doll_04 = 1208,
	Postava_Sexworker_Doll_08 = 1209,
	Postava_Sexworker_10 = 1210,
	Postava_Sexworker_02 = 1211,
	Postava_Nancy_Hartley = 1212,
	Postava_Griselda_Green_Cloud_Martinez = 1213,
	Postava_Lucy_Thackery = 1214,
	Postava_Voodoo_Boys_Female_01 = 1215,
	Postava_Voodoo_Boys_Female_02 = 1216,
	Postava_Voodoo_Boys_Female_03 = 1217,
	Postava_Voodoo_Boys_Female_04 = 1218,
	Postava_Voodoo_Boys_Female_05 = 1219,
	Postava_Voodoo_Boys_Female_06 = 1220,
	Postava_Scavengers_Female_05 = 1221,
	Postava_Scavengers_Female_06 = 1222,
	Postava_Scavengers_Female_07 = 1223,
	Postava_Scavengers_Female_08 = 1224,
	Postava_Mallrat_05 = 1225,
	Postava_Queen_Of_The_Stoop_16 = 1226,
	Postava_R3n0 = 1227,
	Postava_Rich_Female_25 = 1228,
	Postava_Mallrat_10 = 1229,
	Postava_District_Teen_01 = 1230,
	Postava_Sexworker_Doll_07 = 1231,
	Postava_Queen_Of_The_Stoop_07 = 1232,
	Postava_Voodoo_Boys_Female_07 = 1233,
	Postava_Linda_Spencer = 1234,
	Postava_Citizen_Corporat_01 = 1235,
	Postava_Citizen_Corporat_12 = 1236,
	Postava_Youngster_Slacker_05 = 1237,
	Postava_Youngster_Slacker_06 = 1238,
	Postava_Youngster_Slacker_08 = 1239,
	Postava_Micaela_Ruiz = 1240,
	Postava_Paradise_Client_02 = 1241,
	Postava_Pacific_Female_07 = 1242,
	Postava_Rich_Female_14 = 1243,
	Postava_Clothing_Seller_Std_Rcr = 1244,
	Postava_Hologram_Prostitute = 1245,
	Postava_Hologram_Pachinko_Girl = 1246,
	Postava_Hologram_VIP = 1247,
	Postava_Nova_MacCaster = 1248,
	Postava_Canon_FemV = 1249,
	Postava_Lowlife_Latino_07 = 1250,
	Postava_Clothing_Seller_Wbr_Jpn = 1251,
	Postava_Christine_Markov = 1252,

	Postava_Male_V = 2000,
	Postava_Kerry_Eurodyne = 2001,
	Postava_River_Ward = 2002,
	Postava_Angel = 2003,
	Postava_Mike_Tiny_Mike_Kowalski = 2004,
	Postava_Saul_Bright = 2005,
	Postava_Jackie_Welles = 2006,
	Postava_Victor_Vektor = 2007,
	Postava_Jefferson_Peralez = 2008,
	Postava_Tom_Caldera = 2009,
	Postava_Benjamin_Stone = 2010,
	Postava_Mitch_Anderson = 2011,
	Postava_Aymeric_Cassel = 2012,
	Postava_Paco_Torres = 2013,
	Postava_Placide = 2014,
	Postava_Goro_Takemura = 2015,
	Postava_Sandayu_Oda = 2016,
	Postava_Ozob_Bozo = 2017,
	Postava_Muamar_El_Capitan_Reyes = 2018,
	Postava_Jotaro_Shobo = 2019,
	Postava_Kurt_Hansen = 2020,
	Postava_Ayden_Daniels = 2021,
	Postava_NCPD_Male_01 = 2022,
	Postava_Arthur_Jenkins = 2047,
	Postava_Finn_Fingers_Gerstatt = 2048,
	Postava_Bryce_Mosley = 2049,
	Postava_Frank_Nostra = 2050,
	Postava_Wade_Mr_Hands_Bleecker = 2051,
	Postava_Sebastian_Padre_Ibarra = 2052,
	Postava_Declan_Brick_Griffin = 2053,
	Postava_Simon_Royce_Randall = 2054,
	Postava_Dum_Dum = 2055,
	Postava_Dusty_Lowe = 2023,
	Postava_Logan_Scott = 2024,
	Postava_Valentinos_Male_01 = 2025,
	Postava_Valentinos_Male_02 = 2026,
	Postava_Valentinos_Male_03 = 2027,
	Postava_6th_Street_Male_01 = 2028,
	Postava_6th_Street_Male_02 = 2029,
	Postava_6th_Street_Male_03 = 2030,
	Postava_6th_Street_Male_04 = 2031,
	Postava_Mateo_Thiago = 2032,
	Postava_Maelstrom_Male_01 = 2036,
	Postava_Maelstrom_Male_02 = 2037,
	Postava_Tyger_Claws_Male_01 = 2038,
	Postava_Tyger_Claws_Male_02 = 2039,
	Postava_Tyger_Claws_Male_03 = 2040,
	Postava_Mox_Male_01 = 2033,
	Postava_Mox_Male_02 = 2034,
	Postava_Mox_Male_03 = 2035,
	Postava_Mox_Male_04 = 2041,
	Postava_Mox_Male_05 = 2042,
	Postava_Mox_Male_06 = 2043,
	Postava_Mox_Male_07 = 2044,
	Postava_Mox_Male_08 = 2045,
	Postava_Mox_Male_09 = 2046,
	Postava_Dexter_Dex_DeShawn = 2056,
	Postava_Jake_Tim_Kelly = 2057,
	Postava_Ziggy_Q = 2058,
	Postava_Johnny_Silverhand = 2059,
	Postava_Solomon_Reed = 2060,
	Postava_Animals_Male_01 = 2061,
	Postava_Animals_Male_02 = 2062,
	Postava_Animals_Male_03 = 2063,
	Postava_Barghest_Male_01 = 2064,
	Postava_Barghest_Male_02 = 2065,
	Postava_Barghest_Male_03 = 2066,
	Postava_Scavengers_Male_01 = 2067,
	Postava_Scavengers_Male_02 = 2068,
	Postava_Scavengers_Male_03 = 2069,
	Postava_Scavengers_Male_04 = 2070,
	Postava_Wraiths_Male_01 = 2071,
	Postava_Wraiths_Male_02 = 2072,
	Postava_Wraiths_Male_03 = 2073,
	Postava_E3_Male_V = 2074,
	Postava_Pepe_Najarro = 2075,
	Postava_Dante_Caruso = 2076,
	Postava_Chester_Bennett = 2077,
	Postava_Yuri_Bychkov = 2078,
	Postava_Hideyoshi_Oshima = 2079,
	Postava_Aguilar_Nubiola_Male = 2080,
	Postava_Hasan_Demir = 2081,
	Postava_Edgar_TooLina_Tool = 2082,
	Postava_Adam_Smasher = 2083,
	Postava_Wilky_Slider_LaGuerre = 2084,
	Postava_Milko_Alexis = 2085,
	Postava_Yorinobu_Arasaka = 2086,
	Postava_Jago_Szabo = 2087,
	Postava_Robert_Wilson = 2088,
	Postava_Obese_Caribbean_01 = 2089,
	Postava_Mr_Blue_Eyes = 2090,
	Postava_Driss_Scorpion_Meriana = 2091,
	Postava_Henry = 2092,
	Postava_Theodore_Teddy_Simos = 2093,
	Postava_Nix = 2094,
	Postava_Lyle_Thompson = 2095,
	Postava_Cesar_Diego_Ruiz = 2096,
	Postava_Roy_Batty = 2097,
	Postava_Max_Jones = 2098,
	Postava_Odell_Blanco = 2099,
	Postava_Denzel_The_Brain_Cryer = 2100,
	Postava_Emmerick_Bronson = 2101,
	Postava_Peter_Sampson = 2102,
	Postava_Juan_Mendez = 2103,
	Postava_Leon_Rinder = 2104,
	Postava_Dino_Dinovic = 2105,
	Postava_Santiago_Aldecaldo = 2106,
	Postava_Albert_Murphy = 2107,
	Postava_Rafael_Perez = 2108,
	Postava_Nonbinary_Youngster_01 = 2109,
	Postava_Cassidy_Righter = 2110,
	Postava_Jax_Forgrave = 2111,
	Postava_Boris_Ribakov = 2112,
	Postava_Hwangbo_Dong_Gun = 2113,
	Postava_Barry_Lewis = 2114,
	Postava_Gustavo_Orta = 2115,
	Postava_Bob_Sagan = 2116,
	Postava_Satoshi_Ueno = 2117,

	Postava_Robot_Corpo = 8000,
	Postava_Robot_Gang_Maelstrom = 8001,
	Postava_Robot_Gang_Wraith = 8002,
	Postava_Robot_Gang_Scavenger = 8003,
	Postava_Robot_Gang_6th_Street = 8004,
	Postava_Robot_Training = 8005,
	Postava_Robot_Remote = 8006,
	Postava_Robot_Nusa = 8007,
	Postava_Robot_Moth_Barman = 8008,

	Kategorie01 = 4000,
	Kategorie02 = 4001,
	Kategorie03 = 4002,
	Kategorie04 = 4003,
	Kategorie05 = 4004,
	Kategorie06 = 4005,
	Kategorie07 = 4006,
	Kategorie08 = 4007,
	Kategorie09 = 4008,
	Kategorie10 = 4009,
	Kategorie11 = 4010,
	Kategorie12 = 4011,
	Kategorie13 = 4012,
	Kategorie14 = 4013,
	Kategorie15 = 4014,
	Kategorie16 = 4015,
	Kategorie17 = 4016,

	Nastaveni_Opt1 = 200,
	Nastaveni_Opt2 = 201,
	Nastaveni_Opt3 = 202,
	Nastaveni_Opt4 = 203,
	Nastaveni_Opt5 = 204,
	Nastaveni_Opt6 = 205,
	Nastaveni_Opt7 = 206,
	Nastaveni_Opt8 = 207,
	Nastaveni_Opt9 = 208,
	Nastaveni_Opt10 = 209,
	Nastaveni_Opt11 = 210,
	Nastaveni_Opt12 = 211,
	Nastaveni_Opt13 = 212,
	Nastaveni_Opt14 = 213,
	Nastaveni_Opt15 = 214,
	Nastaveni_Opt16 = 215,
	Nastaveni_Opt17 = 216,
	Nastaveni_Opt18 = 217,
	Nastaveni_Opt19 = 218,
	Nastaveni_Opt20 = 219,
	Nastaveni_Opt21 = 220,
	Nastaveni_Opt22 = 221,
	Nastaveni_Opt23 = 222,
	Nastaveni_Opt24 = 223,
	Nastaveni_Opt25 = 224,
	Nastaveni_Opt26 = 225,
	Nastaveni_Opt27 = 226,
	Nastaveni_Opt28 = 227,
	Nastaveni_Opt29 = 228,
	Nastaveni_Opt30 = 229,
	Nastaveni_Opt31 = 230,
	Nastaveni_Opt32 = 231,
	Nastaveni_Opt33 = 232,
	Nastaveni_Opt34 = 233,
	Nastaveni_Opt35 = 234,
	Nastaveni_Opt36 = 235,
	Nastaveni_Opt37 = 236,
	Nastaveni_Opt38 = 237,
	Nastaveni_Opt39 = 238,
	Nastaveni_Opt40 = 239,
	Nastaveni_Opt41 = 240,
	Nastaveni_Opt42 = 241,
	Nastaveni_Opt43 = 242,
	Nastaveni_Opt44 = 243,
	Nastaveni_Opt45 = 244,
	Nastaveni_Opt46 = 245,
	Nastaveni_Opt47 = 246,
	Nastaveni_Opt48 = 247,
	Nastaveni_Opt49 = 248,
	Nastaveni_Opt50 = 249,
	Nastaveni_Opt51 = 250,
	Nastaveni_Opt52 = 251,

	Lokace_JigJig = 1,
	Lokace_DarkMatter = 2,
	Lokace_ArasakaEstate = 3,
	Lokace_LagunaBend = 4,
	Lokace_NoTellMotel = 5,
	Lokace_TrailerPark = 6,
	//Lokace_Zen = 7,
	Lokace_Backstage = 8,
	//Lokace_Ostatni = 9,
	Lokace_Basilisk = 10,
	Lokace_Poledance_JigJig = 11,
	Lokace_Hangout_VPenthouse = 12,
	Lokace_Bar = 13,
	Lokace_Rollercoaster = 14,
	Lokace_DoubleAction_JigJig = 15,
	Lokace_Moon = 16,
	Lokace_Poledance_Triple = 17,
	Lokace_Cinema = 18,
	Lokace_BoatRomance = 19,
	Lokace_CinemaKissing = 20,
	Lokace_BoatGuitar = 21,
	Lokace_Hangout_Boat = 22,
	Lokace_Konpeki = 23,
	Lokace_Camping = 24,
	Lokace_Dollhouse = 25,
	Lokace_Hangout_Konpeki = 26,
	Lokace_Date_Empathy = 27,
	Lokace_DoubleAction_DarkMatter = 28,
	Lokace_Concert_RedDirt = 29,
	Lokace_Beach = 30,
	Lokace_MoonExt = 31,
	Lokace_Hangout_Priv_Megabuilding = 32,
	Lokace_Hangout_Priv_Downtown = 33,
	Lokace_Hangout_Priv_Heywood = 34,
	Lokace_Hangout_Priv_Japantown = 35,
	Lokace_Hangout_Priv_Northside = 36,
	Lokace_PONC_JigJig = 37,
	Lokace_SunsetMotel = 38,
	Lokace_PONC_DarkMatter = 39,
	Lokace_FerrisWheel = 40,
	Lokace_Hangout_Priv_EdenPlaza = 41,
	Lokace_AV = 42,
	Lokace_Cyberpsycho_Hey_Spr_04 = 43,
	Lokace_KonpekiJoytoy = 44,
	Lokace_ApartsJoytoy_Megabuilding = 45,
	Lokace_ApartsJoytoy_Downtown = 46,
	Lokace_ApartsJoytoy_Heywood = 47,
	Lokace_ApartsJoytoy_Japantown = 48,
	Lokace_ApartsJoytoy_Northside = 49,
	Lokace_ApartsJoytoy_EdenPlaza = 50,
	Lokace_Hangout_Dwelling = 51,
	Lokace_Hangout_Priv_SantoSerenity = 52,

	Lokace_Zen_Earth = 3000,
	Lokace_Zen_Water = 3001,
	Lokace_Zen_Fire = 3002,
	Lokace_Zen_Air = 3003,

	Lokace_Ostatni_Edgerunners = 5000,
	Lokace_Ostatni_Lizzy = 5001,
	Lokace_Ostatni_LetYouDown = 5002,
	Lokace_Ostatni_IReallyWantToStayAtYourHouse = 5003,
	Lokace_Ostatni_Ambush = 5004,
	Lokace_Ostatni_DashiParade = 5005,
	Lokace_Ostatni_UsCracks = 5006,
	Lokace_Ostatni_Tutorial = 5007,
	Lokace_Ostatni_RoofPic = 5008,
	Lokace_Ostatni_CHIAA = 5009,

	Lokace_Kont_Joytoy = 600,
	Lokace_Kont_DoubleAction = 601,
	Lokace_Kont_PoleDancing = 602,
	Lokace_Kont_Hangout = 603,
	Lokace_Kont_Date = 604,
	Lokace_Kont_Romantic = 605,
	Lokace_Kont_Relaxing = 606,
	Lokace_Kont_Various = 607,
	Lokace_Kont_Concert = 608,
	Lokace_Kont_PONC = 609,
	Lokace_Kont_Cyberpsycho = 610,

	BarLokace_Wbr_Hil_01 = 700,
	BarLokace_Hey_Spr_01 = 701,
	BarLokace_Cct_Dtn_01 = 702,
	BarLokace_Wat_Kab_01 = 703,
	BarLokace_Hey_Spr_02 = 704,
	BarLokace_Cct_Cpz_01 = 705,
	BarLokace_Std_Rcr_01 = 706,
	BarLokace_Wbr_Jpn_01 = 707,
	BarLokace_Pac_EP1_01 = 708,
	BarLokace_Wbr_Jpn_02 = 709,
	BarLokace_Wbr_Jpn_03 = 710,
}

public func DataPolePostav() -> array<ref<DataPostavy>> = [
	DataPostavy.Postava(GlobalniID.Postava_LokaceBezPostavy, GenderType.None, "-", "", "", false, InkAtlasSoubor.Prazdne, n"", 0, "", false, []),

	DataPostavy.Kateg(GlobalniID.Kategorie01, MenuStrankaTyp.Kateg_Hracky, "LocKey#15144007", "joytoy_grp", false, InkAtlasSoubor.Prazdne, n"", 0, true, true, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie02, MenuStrankaTyp.Kateg_Prcinky, "LocKey#15144008", "uscracks_grp", false, InkAtlasSoubor.Assets_03, n"c_uscracks_full", 0.65, true, false, false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Kateg(GlobalniID.Kategorie03, MenuStrankaTyp.Kateg_Mox, "LocKey#15144010", "mox_grp", false, InkAtlasSoubor.GangLogos, n"logo_themox", 1.5, true, true, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie04, MenuStrankaTyp.Kateg_Valentinos, "LocKey#15144011", "val_grp", false, InkAtlasSoubor.GangLogos, n"logo_valentinos", 1.5, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie05, MenuStrankaTyp.Kateg_Sesta_ulice, "LocKey#15144012", "6th_grp", false, InkAtlasSoubor.GangLogos, n"logo_6thstreet", 1.5, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie06, MenuStrankaTyp.Kateg_Maelstrom, "LocKey#15144013", "mstrm_grp", false, InkAtlasSoubor.GangLogos, n"logo_maelstrom", 1.5, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie07, MenuStrankaTyp.Kateg_Tygri_spary, "LocKey#15144009", "tyger_grp", false, InkAtlasSoubor.GangLogos, n"logo_tygerclaws", 1.5, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie08, MenuStrankaTyp.Kateg_Aldecaldos, "LocKey#15144055", "aldec_grp", false, InkAtlasSoubor.GangLogos, n"logo_aldecados", 1.5, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie09, MenuStrankaTyp.Kateg_Dogtown, "LocKey#15144084", "dogtown_grp", true, InkAtlasSoubor.Prazdne, n"", 0, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie10, MenuStrankaTyp.Kateg_Zvirata, "LocKey#15144085", "animals_grp", false, InkAtlasSoubor.GangLogos, n"logo_animals", 1.5, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie11, MenuStrankaTyp.Kateg_Barghest, "LocKey#15144091", "barghest_grp", true, InkAtlasSoubor.GangLogos, n"logo_barghest", 1.5, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie12, MenuStrankaTyp.Kateg_Mrchozrouti, "LocKey#15144092", "scavengers_grp", false, InkAtlasSoubor.GangLogos, n"logo_scavengers", 1.5, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie13, MenuStrankaTyp.Kateg_Prizraky, "LocKey#15144093", "wraiths_grp", false, InkAtlasSoubor.GangLogos, n"logo_wraiths", 1.5, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie16, MenuStrankaTyp.Kateg_Voodoo, "LocKey#15144132", "voodoo_grp", false, InkAtlasSoubor.GangLogos, n"logo_voodooboys", 1.5, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie17, MenuStrankaTyp.Kateg_Roboti, "LocKey#15144152", "robots_grp", false, InkAtlasSoubor.Prazdne, n"", 0, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie14, MenuStrankaTyp.Kateg_Specialni, "LocKey#15144086", "special_grp", false, InkAtlasSoubor.Prazdne, n"", 0, true, false, true, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Kateg(GlobalniID.Kategorie15, MenuStrankaTyp.Kateg_Vlastni, "LocKey#15144058", "custom_grp", false, InkAtlasSoubor.Prazdne, n"", 0, true, false, false, [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi, MenuStrankaTyp.Menu_ZenyPouzeMox, MenuStrankaTyp.Menu_MuziPouzeMox]),

	DataPostavy.Specialni(GlobalniID.Postava_Johnny_Silverhand, GenderType.Male, "LocKey#15143232", "Male_Johnny_Silverhand", "johnnysilverhand", false, InkAtlasSoubor.Assets_02, n"c_johnny_silverhand_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Specialni], []),
	DataPostavy.Specialni(GlobalniID.Postava_Solomon_Reed, GenderType.Male, "LocKey#15143233", "Male_Solomon_Reed", "solomonreed", true, InkAtlasSoubor.Assets_EP1_11, n"c_reed_full", 0.65, "", true, [MenuStrankaTyp.Kateg_Specialni], []),
	DataPostavy.Specialni(GlobalniID.Postava_Hideyoshi_Oshima, GenderType.Male, "LocKey#15143383", "Male_Hideyoshi_Oshima", "hideyoshioshima", false, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_hideyoshioshima", 0, "", false, [MenuStrankaTyp.Kateg_Specialni], []),
	DataPostavy.Specialni(GlobalniID.Postava_Nina_Kraviz, GenderType.Female, "LocKey#15143234", "Female_Nina_Kraviz", "ninakraviz", false, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_ninakraviz", 0, "", false, [MenuStrankaTyp.Kateg_Specialni], []),
	DataPostavy.Specialni(GlobalniID.Postava_Lana_Prince, GenderType.Female, "LocKey#15143235", "Female_Lana_Prince", "lanaprince", false, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_lanaprince", 0, "", false, [MenuStrankaTyp.Kateg_Specialni], []),

	DataPostavy.Postava(GlobalniID.Postava_Charlene_Fox, GenderType.Female, "LocKey#15143001", "Female_Charlene_Fox", "joytoy_poor", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_joytoy_poor", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Brittany_Hayes, GenderType.Female, "LocKey#15143026", "Female_Brittany_Hayes", "joytoy_rich", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_joytoy_rich", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_JigJig_Dancer_05, GenderType.Female, "LocKey#15143058", "Female_JigJig_Dancer_05", "jigjig_dancer", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_jigjig_dancer", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Tasha_Rodriquez, GenderType.Female, "LocKey#15143059", "Female_Tasha_Rodriquez", "tasha", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_tasha", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Lizzies_Stripper_04, GenderType.Female, "LocKey#15143373", "Female_Lizzies_Stripper_04", "stripper_04", false, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_stripper_04", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Sexworker_Doll_02, GenderType.Female, "LocKey#15143186", "Female_Sexworker_Doll_02", "sexworkerdoll02", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_sexworkerdoll02", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Sexworker_Prostitute_05, GenderType.Female, "LocKey#15143424", "Female_Sexworker_Prostitute_05", "sexworker_prostitute_05", false, InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_sexworker_prostitute_05", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Sexworker_Prostitute_07, GenderType.Female, "LocKey#15143425", "Female_Sexworker_Prostitute_07", "sexworker_prostitute_07", false, InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_sexworker_prostitute_07", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Sexworker_Doll_04, GenderType.Female, "LocKey#15143426", "Female_Sexworker_Doll_04", "sexworker_doll_04", false, InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_sexworker_doll_04", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Sexworker_Doll_08, GenderType.Female, "LocKey#15143427", "Female_Sexworker_Doll_08", "sexworker_doll_08", false, InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_sexworker_doll_08", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Sexworker_10, GenderType.Female, "LocKey#15143428", "Female_Sexworker_10", "sexworker_10", false, InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_sexworker_10", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Sexworker_02, GenderType.Female, "LocKey#15143429", "Female_Sexworker_02", "sexworker_02", false, InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_sexworker_02", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Sexworker_Doll_07, GenderType.Female, "LocKey#15143462", "Female_Sexworker_Doll_07", "sexworkerdoll07", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_sexworkerdoll07", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Hologram_Prostitute, GenderType.Female, "LocKey#15143509", "Female_Hologram_Prostitute", "hologramprostitute", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_hologramprostitute", 0, "", false, [MenuStrankaTyp.Kateg_Hracky], [
		DataVzhled.Vytvorit("LocKey#15143512", "", InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_hologramprostitute", 0)
	]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Hologram_Pachinko_Girl, GenderType.Female, "LocKey#15143510", "Female_Hologram_Pachinko_Girl", "hologrampachinkogirl", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_hologrampachinkogirl", 0, "", false, [MenuStrankaTyp.Kateg_Hracky], [
		DataVzhled.Vytvorit("LocKey#15143512", "", InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_hologrampachinkogirl", 0)
	]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Hologram_VIP, GenderType.Female, "LocKey#15143511", "Female_Hologram_VIP", "hologramvip", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_hologramvip", 0, "", false, [MenuStrankaTyp.Kateg_Hracky], [
		DataVzhled.Vytvorit("LocKey#15143512", "", InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_hologramvip", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Aoi_Blue_Moon_Tsuki, GenderType.Female, "LocKey#15143006", "Female_Aoi_Blue_Moon_Tsuki", "bluemoon", false, InkAtlasSoubor.Assets_04, n"c_blue_moon_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Prcinky]),
	DataPostavy.Postava(GlobalniID.Postava_Purple_Force, GenderType.Female, "LocKey#15143096", "Female_Purple_Force", "purpleforce", false, InkAtlasSoubor.Assets_10, n"c_purple_force_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Prcinky]),
	DataPostavy.Postava(GlobalniID.Postava_Akai_Red_Menace_Kyoi, GenderType.Female, "LocKey#15143095", "Female_Akai_Red_Menace_Kyoi", "redmenace", false, InkAtlasSoubor.Assets_06, n"c_red_menace_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Prcinky]),
	DataPostavy.Postava(GlobalniID.Postava_Rita_Wheeler, GenderType.Female, "LocKey#15143009", "Female_Rita_Wheeler", "rita", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_rita", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Susanna_Susie_Q_Quinn, GenderType.Female, "LocKey#15143039", "Female_Susanna_Susie_Q_Quinn", "susieq", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_susieq", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Bouncer_02, GenderType.Female, "LocKey#15143348", "Female_Mox_Bouncer_02", "moxbouncer02", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_moxbouncer02", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Mox_Female_01, GenderType.Female, "LocKey#15143074", "Female_Mox_01", "mox_fem_01", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_01", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox], [
		DataVzhled.Vytvorit("LocKey#15143165", "", InkAtlasSoubor.LizziesBDs_Postavy_Staff_02, n"key_mox_01_1", 0),
		DataVzhled.Vytvorit("LocKey#15143422", "", InkAtlasSoubor.LizziesBDs_Postavy_Staff_02, n"key_mox_01_1_1", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_02, GenderType.Female, "LocKey#15143075", "Female_Mox_02", "mox_fem_02", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_02", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_03, GenderType.Female, "LocKey#15143076", "Female_Mox_03", "mox_fem_03", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_03", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_04, GenderType.Female, "LocKey#15143077", "Female_Mox_04", "mox_fem_04", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_04", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_05, GenderType.Female, "LocKey#15143078", "Female_Mox_05", "mox_fem_05", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_05", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_06, GenderType.Female, "LocKey#15143079", "Female_Mox_06", "mox_fem_06", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_06", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_Lvl_2_1, GenderType.Female, "LocKey#15143080", "Female_Mox_Lvl_2_1", "mox_fem_lvl_2_1", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_lvl_2_1", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_Lvl_2_2, GenderType.Female, "LocKey#15143081", "Female_Mox_Lvl_2_2", "mox_fem_lvl_2_2", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_lvl_2_2", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_Lvl_2_3, GenderType.Female, "LocKey#15143082", "Female_Mox_Lvl_2_3", "mox_fem_lvl_2_3", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_lvl_2_3", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_Lvl_3_1, GenderType.Female, "LocKey#15143083", "Female_Mox_Lvl_3_1", "mox_fem_lvl_3_1", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_lvl_3_1", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_Lvl_3_2, GenderType.Female, "LocKey#15143084", "Female_Mox_Lvl_3_2", "mox_fem_lvl_3_2", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_lvl_3_2", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Female_Lvl_3_3, GenderType.Female, "LocKey#15143085", "Female_Mox_Lvl_3_3", "mox_fem_lvl_3_3", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_lvl_3_3", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_ZenyPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Valentinos_Female_01, GenderType.Female, "LocKey#15143110", "Female_Valentinos_01", "valentinos_female_01", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_valentinos_female_01", 0, "", false, [MenuStrankaTyp.Kateg_Valentinos]),
	DataPostavy.Postava(GlobalniID.Postava_Valentinos_Female_02, GenderType.Female, "LocKey#15143111", "Female_Valentinos_02", "valentinos_female_02", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_valentinos_female_02", 0, "", false, [MenuStrankaTyp.Kateg_Valentinos]),
	DataPostavy.Postava(GlobalniID.Postava_Valentinos_Female_03, GenderType.Female, "LocKey#15143112", "Female_Valentinos_03", "valentinos_female_03", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_valentinos_female_03", 0, "", false, [MenuStrankaTyp.Kateg_Valentinos]),
	DataPostavy.Postava(GlobalniID.Postava_Valentinos_Female_04, GenderType.Female, "LocKey#15143113", "Female_Valentinos_04", "valentinos_female_04", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_valentinos_female_04", 0, "", false, [MenuStrankaTyp.Kateg_Valentinos]),
	DataPostavy.Postava(GlobalniID.Postava_6th_Street_Female_01, GenderType.Female, "LocKey#15143117", "Female_6th_Street_01", "6thstreet_female_01", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_6thstreet_female_01", 0, "", false, [MenuStrankaTyp.Kateg_Sesta_ulice]),
	DataPostavy.Postava(GlobalniID.Postava_6th_Street_Female_02, GenderType.Female, "LocKey#15143118", "Female_6th_Street_02", "6thstreet_female_02", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_6thstreet_female_02", 0, "", false, [MenuStrankaTyp.Kateg_Sesta_ulice]),
	DataPostavy.Postava(GlobalniID.Postava_6th_Street_Female_03, GenderType.Female, "LocKey#15143119", "Female_6th_Street_03", "6thstreet_female_03", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_6thstreet_female_03", 0, "", false, [MenuStrankaTyp.Kateg_Sesta_ulice]),
	DataPostavy.Postava(GlobalniID.Postava_6th_Street_Female_04, GenderType.Female, "LocKey#15143120", "Female_6th_Street_04", "6thstreet_female_04", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_6thstreet_female_04", 0, "", false, [MenuStrankaTyp.Kateg_Sesta_ulice]),
	DataPostavy.Postava(GlobalniID.Postava_6th_Street_Female_05, GenderType.Female, "LocKey#15143121", "Female_6th_Street_05", "6thstreet_female_05", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_6thstreet_female_05", 0, "", false, [MenuStrankaTyp.Kateg_Sesta_ulice]),
	DataPostavy.Postava(GlobalniID.Postava_6th_Street_Female_06, GenderType.Female, "LocKey#15143153", "Female_6th_Street_06", "6thstreet_female_06", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_6thstreet_female_06", 0, "", false, [MenuStrankaTyp.Kateg_Sesta_ulice]),
	DataPostavy.Postava(GlobalniID.Postava_Dietlinde, GenderType.Female, "LocKey#15143178", "Female_Dietlinde", "dietlinde", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_dietlinde", 0, "", false, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Ofelia_Patricia_Sirawian, GenderType.Female, "LocKey#15143145", "Female_Ofelia_Patricia_Sirawian", "patricia", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_patricia", 0, "", false, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Maelstrom_Female_01, GenderType.Female, "LocKey#15143128", "Female_Maelstrom_01", "maelstrom_female_01", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_maelstrom_female_01", 0, "", false, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Maelstrom_Female_02, GenderType.Female, "LocKey#15143129", "Female_Maelstrom_02", "maelstrom_female_02", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_maelstrom_female_02", 0, "", false, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Maelstrom_Female_03, GenderType.Female, "LocKey#15143130", "Female_Maelstrom_03", "maelstrom_female_03", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_maelstrom_female_03", 0, "", false, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Nova_MacCaster, GenderType.Female, "LocKey#15143515", "Female_Nova_MacCaster", "novamaccaster", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_novamaccaster", 0, "", false, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Carol_Emeka, GenderType.Female, "LocKey#15143187", "Female_Carol_Emeka", "carol", false, InkAtlasSoubor.Assets_35, n"c_carol_emeka_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Aldecaldos]),
	DataPostavy.Postava(GlobalniID.Postava_Aldecaldos_Female_01, GenderType.Female, "LocKey#15143154", "Female_Aldecaldos_01", "aldecaldos_female_01", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_aldecaldos_female_01", 0, "", false, [MenuStrankaTyp.Kateg_Aldecaldos]),
	DataPostavy.Postava(GlobalniID.Postava_Aldecaldos_Female_02, GenderType.Female, "LocKey#15143155", "Female_Aldecaldos_02", "aldecaldos_female_02", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_aldecaldos_female_02", 0, "", false, [MenuStrankaTyp.Kateg_Aldecaldos]),
	DataPostavy.Postava(GlobalniID.Postava_Aldecaldos_Female_03, GenderType.Female, "LocKey#15143156", "Female_Aldecaldos_03", "aldecaldos_female_03", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_aldecaldos_female_03", 0, "", false, [MenuStrankaTyp.Kateg_Aldecaldos]),
	DataPostavy.Postava(GlobalniID.Postava_Aldecaldos_Female_Driver_Lvl_3_3, GenderType.Female, "LocKey#15143197", "Female_Aldecaldos_Female_Driver_Lvl_3_3", "aldecaldosdriver01", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_aldecaldosdriver01", 0, "", false, [MenuStrankaTyp.Kateg_Aldecaldos]),
	DataPostavy.Postava(GlobalniID.Postava_Maiko_Maeda, GenderType.Female, "LocKey#15143021", "Female_Maiko_Maeda", "maiko", false, InkAtlasSoubor.Assets_00, n"c_maiko_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Tygri_spary]),
	DataPostavy.Postava(GlobalniID.Postava_Wakako_Okada, GenderType.Female, "LocKey#15143173", "Female_Wakako_Okada", "wakako", false, InkAtlasSoubor.Assets_10, n"c_wakako_okada_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Tygri_spary]),
	DataPostavy.Postava(GlobalniID.Postava_Tyger_Claws_Female_01, GenderType.Female, "LocKey#15143133", "Female_Tyger_Claws_01", "tyger_female_01", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_tyger_female_01", 0, "", false, [MenuStrankaTyp.Kateg_Tygri_spary]),
	DataPostavy.Postava(GlobalniID.Postava_Tyger_Claws_Female_02, GenderType.Female, "LocKey#15143134", "Female_Tyger_Claws_02", "tyger_female_02", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_tyger_female_02", 0, "", false, [MenuStrankaTyp.Kateg_Tygri_spary]),
	DataPostavy.Postava(GlobalniID.Postava_Tyger_Claws_Female_03, GenderType.Female, "LocKey#15143135", "Female_Tyger_Claws_03", "tyger_female_03", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_tyger_female_03", 0, "", false, [MenuStrankaTyp.Kateg_Tygri_spary]),
	DataPostavy.Postava(GlobalniID.Postava_Angelica_Angie_Whelan, GenderType.Female, "LocKey#15143046", "Female_Angelica_Angie_Whelan", "whelan", true, InkAtlasSoubor.Assets_EP1_14, n"c_angelica_wayland_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Zvirata]),
	DataPostavy.Postava(GlobalniID.Postava_Rhino, GenderType.Female, "LocKey#15143220", "Female_Rhino", "rhino", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_rhino", 0, "", true, [MenuStrankaTyp.Kateg_Zvirata]),
	DataPostavy.Postava(GlobalniID.Postava_Animals_Female_01, GenderType.Female, "LocKey#15143236", "Female_Animals_01", "animalsfemale01", false, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_animalsfemale01", 0, "", true, [MenuStrankaTyp.Kateg_Zvirata]),
	DataPostavy.Postava(GlobalniID.Postava_Animals_Female_02, GenderType.Female, "LocKey#15143237", "Female_Animals_02", "animalsfemale02", false, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_animalsfemale02", 0, "", true, [MenuStrankaTyp.Kateg_Zvirata]),
	DataPostavy.Postava(GlobalniID.Postava_Animals_Female_03, GenderType.Female, "LocKey#15143238", "Female_Animals_03", "animalsfemale03", false, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_animalsfemale03", 0, "", true, [MenuStrankaTyp.Kateg_Zvirata]),
	DataPostavy.Postava(GlobalniID.Postava_Barbara_Babs_Okoye, GenderType.Female, "LocKey#15143352", "Female_Barbara_Babs_Okoye", "barbaraokoye", false, InkAtlasSoubor.Assets_EP1_07, n"c_babs_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Barghest_Female_01, GenderType.Female, "LocKey#15143324", "Female_Barghest_01", "barghestfemale01", true, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_barghestfemale01", 0, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Barghest_Female_02, GenderType.Female, "LocKey#15143325", "Female_Barghest_02", "barghestfemale02", true, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_barghestfemale02", 0, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Barghest_Female_03, GenderType.Female, "LocKey#15143326", "Female_Barghest_03", "barghestfemale03", true, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_barghestfemale03", 0, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Barghest_Female_04, GenderType.Female, "LocKey#15143327", "Female_Barghest_04", "barghestfemale04", true, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_barghestfemale04", 0, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Barghest_Female_05, GenderType.Female, "LocKey#15143328", "Female_Barghest_05", "barghestfemale05", true, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_barghestfemale05", 0, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Barghest_Female_Guard_01, GenderType.Female, "LocKey#15143365", "Female_Barghest_Guard_01", "barghestfemaleguard01", true, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_barghestfemaleguard01", 0, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Female_01, GenderType.Female, "LocKey#15143332", "Female_Scavengers_01", "scavengersfemale01", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_scavengersfemale01", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Female_02, GenderType.Female, "LocKey#15143333", "Female_Scavengers_02", "scavengersfemale02", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_scavengersfemale02", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Female_03, GenderType.Female, "LocKey#15143334", "Female_Scavengers_03", "scavengersfemale03", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_scavengersfemale03", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Female_04, GenderType.Female, "LocKey#15143335", "Female_Scavengers_04", "scavengersfemale04", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_scavengersfemale04", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Female_05, GenderType.Female, "LocKey#15143442", "Female_Scavengers_05", "scavengersfemale05", true, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_scavengersfemale05", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Female_06, GenderType.Female, "LocKey#15143443", "Female_Scavengers_06", "scavengersfemale06", true, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_scavengersfemale06", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Female_07, GenderType.Female, "LocKey#15143444", "Female_Scavengers_07", "scavengersfemale07", true, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_scavengersfemale07", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Female_08, GenderType.Female, "LocKey#15143445", "Female_Scavengers_08", "scavengersfemale08", true, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_scavengersfemale08", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Wraiths_Female_01, GenderType.Female, "LocKey#15143340", "Female_Wraiths_01", "wraithsfemale01", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_wraithsfemale01", 0, "", false, [MenuStrankaTyp.Kateg_Prizraky]),
	DataPostavy.Postava(GlobalniID.Postava_Wraiths_Female_02, GenderType.Female, "LocKey#15143341", "Female_Wraiths_02", "wraithsfemale02", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_wraithsfemale02", 0, "", false, [MenuStrankaTyp.Kateg_Prizraky]),
	DataPostavy.Postava(GlobalniID.Postava_Wraiths_Female_03, GenderType.Female, "LocKey#15143342", "Female_Wraiths_03", "wraithsfemale03", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_wraithsfemale03", 0, "", false, [MenuStrankaTyp.Kateg_Prizraky]),
	DataPostavy.Postava(GlobalniID.Postava_Wraiths_Female_04, GenderType.Female, "LocKey#15143343", "Female_Wraiths_04", "wraithsfemale04", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_wraithsfemale04", 0, "", false, [MenuStrankaTyp.Kateg_Prizraky]),
	DataPostavy.Postava(GlobalniID.Postava_Lina_Malina, GenderType.Female, "LocKey#15143044", "Female_Lina_Malina", "malina", true, InkAtlasSoubor.Assets_EP1_09, n"c_lina_malina_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Helen_Wandoo, GenderType.Female, "LocKey#15143148", "Female_Helen_Wandoo", "helen", true, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_helen", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Imogen, GenderType.Female, "LocKey#15143149", "Female_Imogen", "imogen", true, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_imogen", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Julia_Young, GenderType.Female, "LocKey#15143219", "Female_Julia_Young", "julia", true, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_julia", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown], [
		DataVzhled.Vytvorit("LocKey#15143224", "", InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_julia_cl", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Tyler_Zan, GenderType.Female, "LocKey#15143231", "Female_Tyler_Zan", "tyler", true, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_tyler", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Dogtown_Joytoy_01, GenderType.Female, "LocKey#15143226", "Female_Dogtown_Joytoy_01", "dogtownjoytoy01", true, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_dogtownjoytoy01", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Dogtown_Joytoy_06, GenderType.Female, "LocKey#15143245", "Female_Dogtown_Joytoy_06", "dogtownjoytoy06", true, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_dogtownjoytoy06", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Dogtown_Nightlife_02, GenderType.Female, "LocKey#15143227", "Female_Dogtown_Nightlife_02", "dogtownnightlife02", true, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_dogtownnightlife02", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Dogtown_Nightlife_05, GenderType.Female, "LocKey#15143228", "Female_Dogtown_Nightlife_05", "dogtownnightlife05", true, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_dogtownnightlife05", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Dogtown_Nightlife_10, GenderType.Female, "LocKey#15143229", "Female_Dogtown_Nightlife_10", "dogtownnightlife10", true, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_dogtownnightlife10", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Heavy_Hearts_Waitress_01, GenderType.Female, "LocKey#15143368", "Female_Heavy_Hearts_Waitress_01", "heavyheartswaitress01", true, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_heavyheartswaitress01", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Heavy_Hearts_Waitress_02, GenderType.Female, "LocKey#15143230", "Female_Heavy_Hearts_Waitress_02", "heavyheartswaitress02", true, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_heavyheartswaitress02", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Heavy_Hearts_Waitress_03, GenderType.Female, "LocKey#15143369", "Female_Heavy_Hearts_Waitress_03", "heavyheartswaitress03", true, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_heavyheartswaitress03", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Heavy_Hearts_Waitress_04, GenderType.Female, "LocKey#15143073", "Female_Heavy_Hearts_Waitress_04", "heavyheartswaitress04", true, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_heavyheartswaitress04", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Heavy_Hearts_Waitress_05, GenderType.Female, "LocKey#15143370", "Female_Heavy_Hearts_Waitress_05", "heavyheartswaitress05", true, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_heavyheartswaitress05", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Paradise_Waitress_03, GenderType.Female, "LocKey#15143357", "Female_Paradise_Waitress_03", "paradisewaitress03", true, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_paradisewaitress03", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Pacific_Female_06, GenderType.Female, "LocKey#15143366", "Female_Pacific_Female_06", "pacificfemale06", true, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_pacificfemale06", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Pacific_Female_13, GenderType.Female, "LocKey#15143391", "Female_Pacific_Female_13", "pacificfemale13", true, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_pacificfemale13", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Laura_May, GenderType.Female, "LocKey#15143392", "Female_Laura_May", "lauramay", true, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_lauramay", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Maggie_Isley, GenderType.Female, "LocKey#15143414", "Female_Maggie_Isley", "maggieisley", true, InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_maggieisley", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Paradise_Client_02, GenderType.Female, "LocKey#15143501", "Female_Paradise_Client_02", "paradiseclient02", true, InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_paradiseclient02", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown], [
		DataVzhled.Vytvorit("LocKey#15143165", "", InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_paradiseclient02_2", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Pacific_Female_07, GenderType.Female, "LocKey#15143502", "Female_Pacific_Female_07", "pacificfemale07", true, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_pacificfemale07", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Ayo_Zarin, GenderType.Female, "LocKey#15143415", "Female_Ayo_Zarin", "ayozarin", true, InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_ayozarin", 0, "", false, [MenuStrankaTyp.Kateg_Voodoo]),
	DataPostavy.Postava(GlobalniID.Postava_Maman_Mama_Brigitte, GenderType.Female, "LocKey#15143147", "Female_Maman_Mama_Brigitte", "brigitte", false, InkAtlasSoubor.Assets_05, n"c_brigitte_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Voodoo]),
	DataPostavy.Postava(GlobalniID.Postava_Voodoo_Boys_Female_01, GenderType.Female, "LocKey#15143436", "Female_Voodoo_Boys_01", "femalevoodooboys01", false, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_femalevoodooboys01", 0, "", false, [MenuStrankaTyp.Kateg_Voodoo]),
	DataPostavy.Postava(GlobalniID.Postava_Voodoo_Boys_Female_02, GenderType.Female, "LocKey#15143437", "Female_Voodoo_Boys_02", "femalevoodooboys02", false, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_femalevoodooboys02", 0, "", false, [MenuStrankaTyp.Kateg_Voodoo]),
	DataPostavy.Postava(GlobalniID.Postava_Voodoo_Boys_Female_03, GenderType.Female, "LocKey#15143438", "Female_Voodoo_Boys_03", "femalevoodooboys03", false, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_femalevoodooboys03", 0, "", false, [MenuStrankaTyp.Kateg_Voodoo]),
	DataPostavy.Postava(GlobalniID.Postava_Voodoo_Boys_Female_04, GenderType.Female, "LocKey#15143439", "Female_Voodoo_Boys_04", "femalevoodooboys04", true, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_femalevoodooboys04", 0, "", false, [MenuStrankaTyp.Kateg_Voodoo]),
	DataPostavy.Postava(GlobalniID.Postava_Voodoo_Boys_Female_05, GenderType.Female, "LocKey#15143440", "Female_Voodoo_Boys_05", "femalevoodooboys05", true, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_femalevoodooboys05", 0, "", false, [MenuStrankaTyp.Kateg_Voodoo]),
	DataPostavy.Postava(GlobalniID.Postava_Voodoo_Boys_Female_06, GenderType.Female, "LocKey#15143441", "Female_Voodoo_Boys_06", "femalevoodooboys06", true, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_femalevoodooboys06", 0, "", false, [MenuStrankaTyp.Kateg_Voodoo]),
	DataPostavy.Postava(GlobalniID.Postava_Voodoo_Boys_Female_07, GenderType.Female, "LocKey#15143484", "Female_Voodoo_Boys_07", "femalevoodooboys07", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_femalevoodooboys07", 0, "", false, [MenuStrankaTyp.Kateg_Voodoo]),
	DataPostavy.Postava(GlobalniID.Postava_Female_V, GenderType.Female, "LocKey#15143143", "V", "v", false, InkAtlasSoubor.Assets_10, n"c_v_female_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Judy_Alvarez, GenderType.Female, "LocKey#15143002", "Female_Judy_Alvarez", "judy", false, InkAtlasSoubor.Assets_00, n"c_judy_alvarez_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143421", "", InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_judy_2079", 0),
		DataVzhled.Vytvorit("LocKey#15143024", "", InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_judy_2079_official", 0),
		DataVzhled.Vytvorit("LocKey#15143213", "", InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_judy_panties", 0),
		DataVzhled.Vytvorit("LocKey#15143204", "", InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_judy_apartment", 0),
		DataVzhled.Vytvorit("LocKey#15143406", "", InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_judy_diving_suit", 0),
		DataVzhled.Vytvorit("LocKey#15143430", "", InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_judy_diving_suit_mask", 0),
		DataVzhled.Vytvorit("LocKey#15143161", "", InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_judy_crying", 0),
		DataVzhled.Vytvorit("LocKey#15143166", "", InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_judy_without_bra", 0)
	]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Panam_Palmer, GenderType.Female, "LocKey#15143003", "Female_Panam_Palmer", "panam", false, InkAtlasSoubor.Assets_00, n"c_panam_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143493", "", InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_panam_underwear", 0),
		DataVzhled.Vytvorit("LocKey#15143494", "", InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_panam_nojacket", 0),
		DataVzhled.Vytvorit("LocKey#15143495", "", InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_panam_underweartop", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Skye, GenderType.Female, "LocKey#15143004", "Female_Skye", "skye", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_skye", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Meredith_Stout, GenderType.Female, "LocKey#15143007", "Female_Meredith_Stout", "meredith", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_meredith", 0, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143060", "", InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_meredith", 0)
	]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Evelyn_Parker, GenderType.Female, "LocKey#15143005", "Female_Evelyn_Parker", "evelyn", false, InkAtlasSoubor.Assets_06, n"c_evelyn_parker_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143244", "", InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_evelyn_no_coat", 0),
		DataVzhled.Vytvorit("LocKey#15143072", "", InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_evelyn_braindance", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Cheri_Nowlin, GenderType.Female, "LocKey#15143008", "Female_Cheri_Nowlin", "cheri", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_cheri", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Altiera_Alt_Cunningham, GenderType.Female, "LocKey#15143014", "Female_Altiera_Alt_Cunningham", "alt", false, InkAtlasSoubor.Assets_01, n"c_alt_cunningham_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Elizabeth_Peralez, GenderType.Female, "LocKey#15143015", "Female_Elizabeth_Peralez", "elizabeth", false, InkAtlasSoubor.Assets_08, n"c_elizabeth_peralez_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Hanako_Arasaka, GenderType.Female, "LocKey#15143016", "Female_Hanako_Arasaka", "hanako", false, InkAtlasSoubor.Assets_09, n"c_hanako_arasaka_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143364", "", InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_hanako_coat", 0),
		DataVzhled.Vytvorit("LocKey#15143362", "", InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_hanako_parade", 0),
		DataVzhled.Vytvorit("LocKey#15143363", "", InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_hanako_parade_no_coat", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Ruby_Collins, GenderType.Female, "LocKey#15143020", "Female_Ruby_Collins", "ruby", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_ruby", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_T_Bug, GenderType.Female, "LocKey#15143022", "Female_T_Bug", "tbug", false, InkAtlasSoubor.Assets_08, n"c_tbug_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Rogue_Amendiares, GenderType.Female, "LocKey#15143023", "Female_Rogue_Amendiares", "rogue", false, InkAtlasSoubor.Assets_10, n"c_rogue_old_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143420", "", InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_rogue_young", 0),
		DataVzhled.Vytvorit("LocKey#15143419", "", InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_rogue_2013", 0),
		DataVzhled.Vytvorit("LocKey#15143205", "", InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_rogue_date", 0),
		DataVzhled.Vytvorit("LocKey#15143494", "", InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_rogue_date_nojacket", 0)
	]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Misty_Olszewski, GenderType.Female, "LocKey#15143028", "Female_Misty_Olszewski", "misty", false, InkAtlasSoubor.Assets_01, n"c_misty_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143421", "", InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_misty_2079", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Iris_Tanner, GenderType.Female, "LocKey#15143030", "Female_Iris_Tanner", "tanner", false, InkAtlasSoubor.Assets_07, n"c_iris_tanner_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Roxanne_Sumner, GenderType.Female, "LocKey#15143033", "Female_Roxanne_Sumner", "roxanne", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_roxanne", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Karina_Lee, GenderType.Female, "LocKey#15143035", "Female_Karina_Lee", "karina", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_karina", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Gillean_Jordan, GenderType.Female, "LocKey#15143036", "Female_Gillean_Jordan", "gillean", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_gillean", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Sandra_Dorsett, GenderType.Female, "LocKey#15143037", "Female_Sandra_Dorsett", "dorsett", true, InkAtlasSoubor.Assets_35, n"c_sandra_dorsett_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Song_Songbird_So_Mi, GenderType.Female, "LocKey#15143040", "Female_Song_Songbird_So_Mi", "songbird", true, InkAtlasSoubor.Assets_EP1_11, n"c_songbird_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143041", "", InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_songbird", 0),
		DataVzhled.Vytvorit("LocKey#15143420", "", InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_songbird_young_6", 0),
		DataVzhled.Vytvorit("LocKey#15143242", "", InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_songbird_paradise", 0),
		DataVzhled.Vytvorit("LocKey#15143407", "", InkAtlasSoubor.Assets_EP1_11, n"c_songbird_full", 0.65),
		DataVzhled.Vytvorit("LocKey#15143422", "", InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_songbird_q306", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Aurore_Cassel, GenderType.Female, "LocKey#15143042", "Female_Aurore_Cassel", "aurore", true, InkAtlasSoubor.Assets_EP1_06, n"c_aurore_cassel_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Rosalind_Myers, GenderType.Female, "LocKey#15143043", "Female_Rosalind_Myers", "myers", true, InkAtlasSoubor.Assets_EP1_10, n"c_myers_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143246", "", InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_myers_disquise", 0),
		DataVzhled.Vytvorit("LocKey#15143224", "", InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_myers_clean", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Stella_Ramos, GenderType.Female, "LocKey#15143047", "Female_Stella_Ramos", "stella", true, InkAtlasSoubor.Assets_EP1_11, n"c_stella_ramos_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Claire_Russell, GenderType.Female, "LocKey#15143049", "Female_Claire_Russell", "claire", false, InkAtlasSoubor.Assets_07, n"c_claire_russell_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Rachel_Casich, GenderType.Female, "LocKey#15143031", "Female_Rachel_Casich", "rachel", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_rachel", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Elisabeth_Lizzy_Wizzy_Wissenfurth, GenderType.Female, "LocKey#15143050", "Female_Elisabeth_Lizzy_Wizzy_Wissenfurth", "lizzy", false, InkAtlasSoubor.Assets_34, n"c_lizzywizzy_full", 0.6, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Alena_Alex_Xenakis, GenderType.Female, "LocKey#15143051", "Female_Alena_Alex_Xenakis", "alex", true, InkAtlasSoubor.Assets_EP1_06, n"c_alex_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143243", "", InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_alex_bartender", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Georgina_Zembinsky, GenderType.Female, "LocKey#15143052", "Female_Georgina_Zembinsky", "georgina", true, InkAtlasSoubor.Assets_EP1_09, n"c_georgina_zembinsky_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Ruth_Dzeng, GenderType.Female, "LocKey#15143055", "Female_Ruth_Dzeng", "dzeng", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_dzeng", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Denny, GenderType.Female, "LocKey#15143057", "Female_Denny", "denny", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_denny", 0, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143446", "", InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_denny_2020", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Emilie_Massenat, GenderType.Female, "LocKey#15143061", "Female_Emilie_Massenat", "emilie", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_emilie", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Beatrice_Ellen_8ug8ear_Trieste, GenderType.Female, "LocKey#15143064", "Female_Beatrice_Ellen_8ug8ear_Trieste", "8ug8ear", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_8ug8ear", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Dakota_Smith, GenderType.Female, "LocKey#15143065", "Female_Dakota_Smith", "dakota", false, InkAtlasSoubor.Assets_06, n"c_dakota_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Joss_Kutcher, GenderType.Female, "LocKey#15143066", "Female_Joss_Kutcher", "joss", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_joss", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Zuleikha_El_Ahmar, GenderType.Female, "LocKey#15143067", "Female_Zuleikha_El_Ahmar", "zuleikha", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_zuleikha", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Lucyna_Lucy_Kushinada, GenderType.Female, "LocKey#15143068", "Female_Lucyna_Lucy_Kushinada", "lucyna", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_lucyna", 0, "xBaebsae", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143494", "", InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_lucyna_no_jacket", 0),
		DataVzhled.Vytvorit("LocKey#15143432", "", InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_lucyna_david_jacket", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Regina_Jones, GenderType.Female, "LocKey#15143069", "Female_Regina_Jones", "regina", false, InkAtlasSoubor.Assets_08, n"c_regina_jones_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Nika_Yankovich, GenderType.Female, "LocKey#15143070", "Female_Nika_Yankovich", "nika", true, InkAtlasSoubor.Assets_EP1_14, n"c_nika_yankovich_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Theo_Price, GenderType.Female, "LocKey#15143071", "Female_Theo_Price", "theo", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_theo", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Melisa_Rory, GenderType.Female, "LocKey#15143097", "Female_Melisa_Rory", "melisa", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_melisa", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Konpeki_Receptionist_01, GenderType.Female, "LocKey#15143098", "Female_Konpeki_Receptionist_01", "konpeki_recp", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_konpeki_recp", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Nadia_Petrova, GenderType.Female, "LocKey#15143099", "Female_Nadia_Petrova", "nadia", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_nadia", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Joanne_Koch, GenderType.Female, "LocKey#15143100", "Female_Joanne_Koch", "joanne", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_joanne", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Nadezhda_Tiurina, GenderType.Female, "LocKey#15143104", "Female_Nadezhda_Tiurina", "nadezhda", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_nadezhda", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Anna_Hamill, GenderType.Female, "LocKey#15143106", "Female_Anna_Hamill", "anna", false, InkAtlasSoubor.Assets_08, n"c_anna_hamill_full", 0.65, "kobalis", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Farida_Nazeri, GenderType.Female, "LocKey#15143107", "Female_Farida_Nazeri", "farida", true, InkAtlasSoubor.Assets_EP1_12, n"c_farida_full", 0.65, "kobalis", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Guadalupe_Alejandra_Welles, GenderType.Female, "LocKey#15143108", "Female_Guadalupe_Alejandra_Welles", "welles", false, InkAtlasSoubor.Assets_05, n"c_mama_full", 0.65, "kobalis", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Clothing_Seller_Std_Arr, GenderType.Female, "LocKey#15143109", "Female_Clothing_Seller_Std_Arr", "clothing_std_arr", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_clothing_seller", 0, "kobalis", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_NCPD_Female_01, GenderType.Female, "LocKey#15143126", "Female_NCPD_01", "ncpd_female_01", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_ncpd_female_01", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Yawen_Packard, GenderType.Female, "LocKey#15143139", "Female_Yawen_Packard", "yawen", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_yawen", 0, "kobalis", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Nele_Springer, GenderType.Female, "LocKey#15143140", "Female_Nele_Springer", "nele", true, InkAtlasSoubor.Assets_EP1_10, n"c_nele_spranger_full", 0.65, "kobalis", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Lauren_Costigan, GenderType.Female, "LocKey#15143141", "Female_Lauren_Costigan", "lauren", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_lauren", 0, "kobalis", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Jasmine_Dixon, GenderType.Female, "LocKey#15143142", "Female_Jasmine_Dixon", "jasmine", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_jasmine", 0, "kobalis", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Martha_Frakes, GenderType.Female, "LocKey#15143144", "Female_Martha_Frakes", "martha", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_martha", 0, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143150", "", InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_martha_young", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Fiona_Vargas, GenderType.Female, "LocKey#15143151", "Female_Fiona_Vargas", "fiona", false, InkAtlasSoubor.Assets_EP1_08, n"c_fiona_vargas_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Wakakos_Desk_Girl, GenderType.Female, "LocKey#15143152", "Female_Wakakos_Desk_Girl", "deskgirl", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_deskgirl", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Michiko_Arasaka, GenderType.Female, "LocKey#15143158", "Female_Michiko_Arasaka", "michiko", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_michiko", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Rebeca_Price, GenderType.Female, "LocKey#15143162", "Female_Rebeca_Price", "rebeca", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_rebeca", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Olga_Elisabeth_Longmead, GenderType.Female, "LocKey#15143163", "Female_Olga_Elisabeth_Longmead", "olga", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_olga", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Queen_Of_The_Stoop_12, GenderType.Female, "LocKey#15143164", "Female_Queen_Of_The_Stoop_12", "queenstoop12", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_queen_of_the_stoop", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Dao_Hyunh, GenderType.Female, "LocKey#15143167", "Female_Dao_Hyunh", "daohyunh", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_dao", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Linh_Hyunh, GenderType.Female, "LocKey#15143182", "Female_Linh_Hyunh", "linhhyunh", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_linhhyunh", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Zaria_Hughes, GenderType.Female, "LocKey#15143168", "Female_Zaria_Hughes", "zaria", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_zaria", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Yoko_Tsuru, GenderType.Female, "LocKey#15143169", "Female_Yoko_Tsuru", "yoko", false, InkAtlasSoubor.Assets_35, n"c_yoko_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Cynthia_Najarro, GenderType.Female, "LocKey#15143170", "Female_Cynthia_Najarro", "cynthia", true, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_cynthia", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Sophia_Dupont, GenderType.Female, "LocKey#15143171", "Female_Sophia_Dupont", "dupont", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_dupont", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Tenant_Morning_Crowd_07, GenderType.Female, "LocKey#15143172", "Female_Tenant_Morning_Crowd_07", "tenantvalentino", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_tenantvalentino", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Bree_Whitney, GenderType.Female, "LocKey#15143176", "Female_Bree_Whitney", "bree", true, InkAtlasSoubor.Assets_EP1_07, n"c_bree_whitney_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Sachiko_Kusama, GenderType.Female, "LocKey#15143177", "Female_Sachiko_Kusama", "kusama", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_kusama", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Shelma, GenderType.Female, "LocKey#15143183", "Female_Shelma", "shelma", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_shelma", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Lowlife_Latino_01, GenderType.Female, "LocKey#15143184", "Female_Lowlife_Latino_01", "lowlifelatino01", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_lowlifelatino01", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Rich_Female_12, GenderType.Female, "LocKey#15143185", "Female_Rich_12", "richfemale12", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_rich12", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Vendor_03, GenderType.Female, "LocKey#15143188", "Female_Vendor_03", "foodvendor03", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_foodvendor03", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Caliente_Waitress_01, GenderType.Female, "LocKey#15143189", "Female_Caliente_Waitress_01", "calientewaitress", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_calientewaitress", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Konpeki_Waitress_01, GenderType.Female, "LocKey#15143190", "Female_Konpeki_Waitress_01", "konpekiwaitress", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_konpekiwaitress", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Miranda_Lawson, GenderType.Female, "LocKey#15143191", "Female_Miranda_Lawson", "mirandalawson", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_mirandalawson", 0, "NightCitySins", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Clothing_Seller_Wat_Nid, GenderType.Female, "LocKey#15143192", "Female_Clothing_Seller_Wat_Nid", "northsideclothing", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_northsideclothing", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Queen_Of_The_Stoop_03, GenderType.Female, "LocKey#15143193", "Female_Queen_Of_The_Stoop_03", "queenstoop03", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_queenstoop03", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Tourist_01, GenderType.Female, "LocKey#15143194", "Female_Tourist_01", "tourist01", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_tourist01", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Tourist_02, GenderType.Female, "LocKey#15143195", "Female_Tourist_02", "tourist02", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_tourist02", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Arasaka_Corpo_01, GenderType.Female, "LocKey#15143196", "Female_Arasaka_Corpo_01", "arasakacorpo01", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_arasakacorpo01", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Arasaka_Netrunner_Lvl_2_3, GenderType.Female, "LocKey#15143198", "Female_Arasaka_Netrunner_Lvl_2_3", "arasakanetrunner01", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_arasakanetrunner01", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Veteran_Guard_01, GenderType.Female, "LocKey#15143199", "Female_Veteran_Guard_01", "veteranguard01", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_veteranguard01", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Tube_Dancer_08, GenderType.Female, "LocKey#15143200", "Female_Tube_Dancer_08", "dancer01", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_dancer01", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Song_So_Ri, GenderType.Female, "LocKey#15143201", "Female_Song_So_Ri", "songsori", false, InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_default", 0, "MaximiliumM", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143202", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_casual", 0),
		DataVzhled.Vytvorit("LocKey#15143203", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_casual_alt", 0),
		DataVzhled.Vytvorit("LocKey#15143204", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_home", 0),
		DataVzhled.Vytvorit("LocKey#15143205", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_date", 0),
		DataVzhled.Vytvorit("LocKey#15143206", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_night_out", 0),
		DataVzhled.Vytvorit("LocKey#15143207", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_sport", 0),
		DataVzhled.Vytvorit("LocKey#15143208", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_netrunner", 0),
		DataVzhled.Vytvorit("LocKey#15143209", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_kimono", 0),
		DataVzhled.Vytvorit("LocKey#15143210", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_bdsm", 0),
		DataVzhled.Vytvorit("LocKey#15143211", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_bikini", 0),
		DataVzhled.Vytvorit("LocKey#15143212", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_halloween", 0),
		DataVzhled.Vytvorit("LocKey#15143213", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_panties", 0),
		DataVzhled.Vytvorit("LocKey#15143214", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_lingerie", 0),
		DataVzhled.Vytvorit("LocKey#15143215", "", InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi, n"key_towel", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Youngster_Slacker_14, GenderType.Female, "LocKey#15143216", "Female_Youngster_Slacker_14", "youngsterslacker14", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_youngsterslacker14", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Grace_Karina_Voronova, GenderType.Female, "LocKey#15143221", "Female_Grace_Karina_Voronova", "grace", false, InkAtlasSoubor.LizziesBDs_Postavy_05, n"key_grace", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Sofia_Rossi, GenderType.Female, "LocKey#15143349", "Female_Sofia_Rossi", "sofia", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_sofiarossi", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_E3_Female_V, GenderType.Female, "LocKey#15143350", "Female_E3_Female_V", "e3vfemale", false, InkAtlasSoubor.LizziesBDs_Postavy_E3V, n"key_female_default", 0, "MaximiliumM", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143202", "", InkAtlasSoubor.LizziesBDs_Postavy_E3V, n"key_female_casual", 0),
		DataVzhled.Vytvorit("LocKey#15143213", "", InkAtlasSoubor.LizziesBDs_Postavy_E3V, n"key_female_panties", 0),
		DataVzhled.Vytvorit("LocKey#15143205", "", InkAtlasSoubor.LizziesBDs_Postavy_E3V, n"key_female_date", 0),
		DataVzhled.Vytvorit("LocKey#15143351", "", InkAtlasSoubor.LizziesBDs_Postavy_E3V, n"key_female_combat", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Yishen_Rhee, GenderType.Female, "LocKey#15143225", "Female_Yishen_Rhee", "yishen", false, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_yishen", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Trigger, GenderType.Female, "LocKey#15143353", "Female_Trigger", "trigger", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_trigger", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Godiva, GenderType.Female, "LocKey#15143354", "Female_Godiva", "godiva", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_godiva", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Kissy, GenderType.Female, "LocKey#15143355", "Female_Kissy", "kissy", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_kissy", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Roxxi, GenderType.Female, "LocKey#15143356", "Female_Roxxi", "roxxi", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_roxxi", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Clothing_Seller_Bls_Ina, GenderType.Female, "LocKey#15143358", "Female_Clothing_Seller_Bls_Ina", "clothing_bls_ina", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_clothing_bls_ina", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Susan_Abernathy, GenderType.Female, "LocKey#15143367", "Female_Susan_Abernathy", "abernathy", false, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_abernathy", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_NCPD_Female_02, GenderType.Female, "LocKey#15143371", "Female_NCPD_02", "ncpd_female_02", false, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_ncpd_female_02", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Nightlife_Hottie_21, GenderType.Female, "LocKey#15143372", "Female_Nightlife_Hottie_21", "nightlife_hottie_21", false, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_nightlife_hottie_21", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Arasaka_Corpo_06, GenderType.Female, "LocKey#15143374", "Female_Arasaka_Corpo_06", "arasakacorpo02", false, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_arasakacorpo02", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Arabella_Spider_Murphy, GenderType.Female, "LocKey#15143375", "Female_Arabella_Spider_Murphy", "spidermurphy", false, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_spidermurphy", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Zoe_Alonzo, GenderType.Female, "LocKey#15143376", "Female_Zoe_Alonzo", "zoealonzo", false, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_zoealonzo", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Yelena_Sidorova, GenderType.Female, "LocKey#15143377", "Female_Yelena_Sidorova", "yelenasidorova", false, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_yelenasidorova", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Taki_Kenmochi, GenderType.Female, "LocKey#15143378", "Female_Taki_Kenmochi", "takikenmochi", false, InkAtlasSoubor.LizziesBDs_Postavy_13, n"key_takikenmochi", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Lt_Mower, GenderType.Female, "LocKey#15143379", "Female_Lt_Mower", "ltmower", false, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_ltmower", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Tamara_Cosby, GenderType.Female, "LocKey#15143380", "Female_Tamara_Cosby", "tamaracosby", false, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_tamaracosby", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Rose_Horrigan, GenderType.Female, "LocKey#15143381", "Female_Rose_Horrigan", "rosehorrigan", false, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_rosehorrigan", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Aguilar_Nubiola_Female, GenderType.Female, "LocKey#15143384", "Aguilar_Nubiola", "aguilarnubiola", true, InkAtlasSoubor.Assets_EP1_06, n"c_aguilar_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Biker_Female_04, GenderType.Female, "LocKey#15143385", "Female_Biker_04", "bikerfemale04", false, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_biker04", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Arasaka_Scientist, GenderType.Female, "LocKey#15143386", "Female_Arasaka_Scientist", "arasakascientist", false, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_arasakascientist", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Nightlife_Hottie_15, GenderType.Female, "LocKey#15143390", "Female_Nightlife_Hottie_15", "nightlife_hottie_15", false, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_nightlife_hottie_15", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Sofia_Ramirez, GenderType.Female, "LocKey#15143410", "Female_Sofia_Ramirez", "sofiaramirez", false, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_sofiaramirez", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Food_Seller_Wbr_Jpn, GenderType.Female, "LocKey#15143413", "Female_Food_Seller_Wbr_Jpn", "ramenjointvendor", false, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_ramenjointvendor", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Journey_Ruiz, GenderType.Female, "LocKey#15143423", "Female_Journey_Ruiz", "journeyruiz", false, InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_journeyruiz", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Nancy_Hartley, GenderType.Female, "LocKey#15143433", "Female_Nancy_Hartley", "nancyhartley", false, InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_nancyhartley", 0, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143446", "", InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_nancyhartley2020", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Griselda_Green_Cloud_Martinez, GenderType.Female, "LocKey#15143434", "Female_Griselda_Green_Cloud_Martinez", "griseldamartinez", false, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_griseldamartinez", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Lucy_Thackery, GenderType.Female, "LocKey#15143435", "Female_Lucy_Thackery", "lucythackery", false, InkAtlasSoubor.Assets_07, n"c_lucy_thackery_full", 0.65, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Mallrat_05, GenderType.Female, "LocKey#15143447", "Female_Mallrat_05", "mallrat05", false, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_mallrat_05", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Queen_Of_The_Stoop_16, GenderType.Female, "LocKey#15143448", "Female_Queen_Of_The_Stoop_16", "queenstoop16", false, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_queenstoop16", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_R3n0, GenderType.Female, "LocKey#15143449", "Female_R3n0", "r3n0", false, InkAtlasSoubor.LizziesBDs_Postavy_16, n"key_r3n0", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Rich_Female_25, GenderType.Female, "LocKey#15143454", "Female_Rich_25", "richfemale25", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_rich25", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Mallrat_10, GenderType.Female, "LocKey#15143460", "Female_Mallrat_10", "mallrat10", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_mallrat10", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_District_Teen_01, GenderType.Female, "LocKey#15143461", "Female_District_Teen_01", "districtteen01", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_districtteen01", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Queen_Of_The_Stoop_07, GenderType.Female, "LocKey#15143464", "Female_Queen_Of_The_Stoop_07", "queenstoop07", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_queenstoop07", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Linda_Spencer, GenderType.Female, "LocKey#15143486", "Female_Linda_Spencer", "lindaspencer", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_lindaspencer_opened", 0, "", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("LocKey#15143202", "", InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_lindaspencer_closed", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Citizen_Corporat_01, GenderType.Female, "LocKey#15143488", "Female_Citizen_Corporat_01", "citizencorporat01", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_citizencorporat01", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Citizen_Corporat_12, GenderType.Female, "LocKey#15143489", "Female_Citizen_Corporat_12", "citizencorporat12", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_citizencorporat12", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Youngster_Slacker_05, GenderType.Female, "LocKey#15143490", "Female_Youngster_Slacker_05", "youngsterslacker05", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_youngsterslacker05", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Youngster_Slacker_06, GenderType.Female, "LocKey#15143491", "Female_Youngster_Slacker_06", "youngsterslacker06", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_youngsterslacker06", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Youngster_Slacker_08, GenderType.Female, "LocKey#15143492", "Female_Youngster_Slacker_08", "youngsterslacker08", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_youngsterslacker08", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Micaela_Ruiz, GenderType.Female, "LocKey#15143500", "Female_Micaela_Ruiz", "micaelaruiz", false, InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_micaelaruiz", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Rich_Female_14, GenderType.Female, "LocKey#15143503", "Female_Rich_14", "richfemale14", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_rich14", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Clothing_Seller_Std_Rcr, GenderType.Female, "LocKey#15143505", "Female_Clothing_Seller_Std_Rcr", "clothing_std_rcr", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_clothing_std_rcr", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Canon_FemV, GenderType.Female, "LocKey#15143523", "Female_Canon_FemV", "canonfemv", false, InkAtlasSoubor.LizziesBDs_Postavy_CanonFemV, n"key_main", 0, "rockergirlfriend", false, [MenuStrankaTyp.Menu_Zeny], [
		DataVzhled.Vytvorit("Corpo", "", InkAtlasSoubor.LizziesBDs_Postavy_CanonFemV, n"key_corpo", 0),
		DataVzhled.Vytvorit("Nomad", "", InkAtlasSoubor.LizziesBDs_Postavy_CanonFemV, n"key_nomad", 0),
		DataVzhled.Vytvorit("Street Kid", "", InkAtlasSoubor.LizziesBDs_Postavy_CanonFemV, n"key_street_kid", 0),
		DataVzhled.Vytvorit("Fortnite", "", InkAtlasSoubor.LizziesBDs_Postavy_CanonFemV, n"key_fortnite", 0),
		DataVzhled.Vytvorit("Fortnite v2", "", InkAtlasSoubor.LizziesBDs_Postavy_CanonFemV, n"key_fortnite_v2", 0),
		DataVzhled.Vytvorit("Phantom Liberty", "", InkAtlasSoubor.LizziesBDs_Postavy_CanonFemV, n"key_phantom_liberty", 0),
		DataVzhled.Vytvorit("Phantom Liberty v2", "", InkAtlasSoubor.LizziesBDs_Postavy_CanonFemV, n"key_phantom_liberty_v2", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Lowlife_Latino_07, GenderType.Female, "LocKey#15143524", "Female_Lowlife_Latino_07", "lowlifelatino07", false, InkAtlasSoubor.LizziesBDs_Postavy_21, n"key_lowlifelatino07", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Clothing_Seller_Wbr_Jpn, GenderType.Female, "LocKey#15143525", "Female_Clothing_Seller_Wbr_Jpn", "clothingsellerwbrjpn", false, InkAtlasSoubor.LizziesBDs_Postavy_21, n"key_clothingsellerwbrjpn", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),
	DataPostavy.Postava(GlobalniID.Postava_Christine_Markov, GenderType.Female, "LocKey#15143526", "Female_Christine_Markov", "christinemarkov", false, InkAtlasSoubor.LizziesBDs_Postavy_21, n"key_christinemarkov", 0, "", false, [MenuStrankaTyp.Menu_Zeny]),

	DataPostavy.Postava(GlobalniID.Postava_Dusty_Lowe, GenderType.Male, "LocKey#15143010", "Male_Dusty_Lowe", "joytoy_m_poor", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_joytoy_m_poor", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Logan_Scott, GenderType.Male, "LocKey#15143027", "Male_Logan_Scott", "joytoy_m_rich", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_joytoy_m_rich", 0, "", false, [MenuStrankaTyp.Kateg_Hracky]),
	DataPostavy.Postava(GlobalniID.Postava_Gustavo_Orta, GenderType.Male, "LocKey#15143520", "Male_Gustavo_Orta", "barrylewis", false, InkAtlasSoubor.Assets_01, n"c_gustavo_orta_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Valentinos]),
	DataPostavy.Postava(GlobalniID.Postava_Valentinos_Male_01, GenderType.Male, "LocKey#15143114", "Male_Valentinos_01", "valentinos_male_01", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_valentinos_male_01", 0, "", false, [MenuStrankaTyp.Kateg_Valentinos]),
	DataPostavy.Postava(GlobalniID.Postava_Valentinos_Male_02, GenderType.Male, "LocKey#15143115", "Male_Valentinos_02", "valentinos_male_02", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_valentinos_male_02", 0, "", false, [MenuStrankaTyp.Kateg_Valentinos]),
	DataPostavy.Postava(GlobalniID.Postava_Valentinos_Male_03, GenderType.Male, "LocKey#15143116", "Male_Valentinos_03", "valentinos_male_03", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_valentinos_male_03", 0, "", false, [MenuStrankaTyp.Kateg_Valentinos]),
	DataPostavy.Postava(GlobalniID.Postava_6th_Street_Male_01, GenderType.Male, "LocKey#15143122", "Male_6th_Street_01", "6thstreet_male_01", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_6thstreet_male_01", 0, "", false, [MenuStrankaTyp.Kateg_Sesta_ulice]),
	DataPostavy.Postava(GlobalniID.Postava_6th_Street_Male_02, GenderType.Male, "LocKey#15143123", "Male_6th_Street_02", "6thstreet_male_02", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_6thstreet_male_02", 0, "", false, [MenuStrankaTyp.Kateg_Sesta_ulice]),
	DataPostavy.Postava(GlobalniID.Postava_6th_Street_Male_03, GenderType.Male, "LocKey#15143124", "Male_6th_Street_03", "6thstreet_male_03", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_6thstreet_male_03", 0, "", false, [MenuStrankaTyp.Kateg_Sesta_ulice]),
	DataPostavy.Postava(GlobalniID.Postava_6th_Street_Male_04, GenderType.Male, "LocKey#15143125", "Male_6th_Street_04", "6thstreet_male_04", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_6thstreet_male_04", 0, "", false, [MenuStrankaTyp.Kateg_Sesta_ulice]),
	DataPostavy.Postava(GlobalniID.Postava_Mateo_Thiago, GenderType.Male, "LocKey#15143105", "Male_Mateo_Thiago", "mateo", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_mateo", 0, "", false, [MenuStrankaTyp.Kateg_Mox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Male_01, GenderType.Male, "LocKey#15143086", "Male_Mox_01", "mox_male_01", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_01_m", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_MuziPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Male_02, GenderType.Male, "LocKey#15143087", "Male_Mox_02", "mox_male_02", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_02_m", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_MuziPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Male_03, GenderType.Male, "LocKey#15143088", "Male_Mox_03", "mox_male_03", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01, n"key_mox_03_m", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_MuziPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Male_04, GenderType.Male, "LocKey#15143089", "Male_Mox_04", "mox_male_04", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_02, n"key_mox_04_m", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_MuziPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Male_05, GenderType.Male, "LocKey#15143090", "Male_Mox_05", "mox_male_05", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_02, n"key_mox_05_m", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_MuziPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Male_06, GenderType.Male, "LocKey#15143091", "Male_Mox_06", "mox_male_06", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_02, n"key_mox_06_m", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_MuziPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Male_07, GenderType.Male, "LocKey#15143092", "Male_Mox_07", "mox_male_07", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_02, n"key_mox_07_m", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_MuziPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Male_08, GenderType.Male, "LocKey#15143093", "Male_Mox_08", "mox_male_08", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_02, n"key_mox_08_m", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_MuziPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Mox_Male_09, GenderType.Male, "LocKey#15143094", "Male_Mox_09", "mox_male_09", false, InkAtlasSoubor.LizziesBDs_Postavy_Staff_02, n"key_mox_09_m", 0, "", false, [MenuStrankaTyp.Kateg_Mox, MenuStrankaTyp.Menu_MuziPouzeMox]),
	DataPostavy.Postava(GlobalniID.Postava_Declan_Brick_Griffin, GenderType.Male, "LocKey#15143179", "Male_Declan_Brick_Griffin", "brick", false, InkAtlasSoubor.Assets_09, n"c_brick_full", 0.65, "", true, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Simon_Royce_Randall, GenderType.Male, "LocKey#15143180", "Male_Simon_Royce_Randall", "royce", false, InkAtlasSoubor.Assets_02, n"c_royce_full", 0.65, "", true, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Dum_Dum, GenderType.Male, "LocKey#15143181", "Male_Dum_Dum", "dumdum", false, InkAtlasSoubor.LizziesBDs_Postavy_04, n"key_dumdum", 0, "", false, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Maelstrom_Male_01, GenderType.Male, "LocKey#15143131", "Male_Maelstrom_01", "maelstrom_male_01", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_maelstrom_male_01", 0, "", false, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Maelstrom_Male_02, GenderType.Male, "LocKey#15143132", "Male_Maelstrom_02", "maelstrom_male_02", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_maelstrom_male_02", 0, "", false, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Jax_Forgrave, GenderType.Male, "LocKey#15143516", "Male_Jax_Forgrave", "jaxforgrave", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_jaxforgrave", 0, "", true, [MenuStrankaTyp.Kateg_Maelstrom]),
	DataPostavy.Postava(GlobalniID.Postava_Tyger_Claws_Male_01, GenderType.Male, "LocKey#15143136", "Male_Tyger_Claws_01", "tyger_male_01", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_tyger_male_01", 0, "", false, [MenuStrankaTyp.Kateg_Tygri_spary]),
	DataPostavy.Postava(GlobalniID.Postava_Tyger_Claws_Male_02, GenderType.Male, "LocKey#15143137", "Male_Tyger_Claws_02", "tyger_male_02", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_tyger_male_02", 0, "", false, [MenuStrankaTyp.Kateg_Tygri_spary]),
	DataPostavy.Postava(GlobalniID.Postava_Tyger_Claws_Male_03, GenderType.Male, "LocKey#15143138", "Male_Tyger_Claws_03", "tyger_male_03", false, InkAtlasSoubor.LizziesBDs_Postavy_08, n"key_tyger_male_03", 0, "", false, [MenuStrankaTyp.Kateg_Tygri_spary]),
	DataPostavy.Postava(GlobalniID.Postava_Animals_Male_01, GenderType.Male, "LocKey#15143239", "Male_Animals_01", "animalsmale01", false, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_animalsmale01", 0, "", true, [MenuStrankaTyp.Kateg_Zvirata]),
	DataPostavy.Postava(GlobalniID.Postava_Animals_Male_02, GenderType.Male, "LocKey#15143240", "Male_Animals_02", "animalsmale02", false, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_animalsmale02", 0, "", true, [MenuStrankaTyp.Kateg_Zvirata]),
	DataPostavy.Postava(GlobalniID.Postava_Animals_Male_03, GenderType.Male, "LocKey#15143241", "Male_Animals_03", "animalsmale03", false, InkAtlasSoubor.LizziesBDs_Postavy_10, n"key_animalsmale03", 0, "", true, [MenuStrankaTyp.Kateg_Zvirata]),
	DataPostavy.Postava(GlobalniID.Postava_Saul_Bright, GenderType.Male, "LocKey#15143018", "Male_Saul_Bright", "saul", false, InkAtlasSoubor.Assets_01, n"c_saul_bright_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Aldecaldos]),
	DataPostavy.Postava(GlobalniID.Postava_Mitch_Anderson, GenderType.Male, "LocKey#15143038", "Male_Mitch_Anderson", "mitch", false, InkAtlasSoubor.Assets_04, n"c_mitch_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Aldecaldos]),
	DataPostavy.Postava(GlobalniID.Postava_Santiago_Aldecaldo, GenderType.Male, "LocKey#15143506", "Male_Santiago_Aldecaldo", "santiagoaldecaldo", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_santiagoaldecaldo", 0, "", true, [MenuStrankaTyp.Kateg_Aldecaldos]),
	DataPostavy.Postava(GlobalniID.Postava_Cassidy_Righter, GenderType.Male, "LocKey#15143514", "Male_Cassidy_Righter", "cassidyrighter", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_cassidyrighter", 0, "", false, [MenuStrankaTyp.Kateg_Aldecaldos]),
	DataPostavy.Postava(GlobalniID.Postava_Bob_Sagan, GenderType.Male, "LocKey#15143521", "Male_Bob_Sagan", "bobsagan", false, InkAtlasSoubor.LizziesBDs_Postavy_21, n"key_bobsagan", 0, "", false, [MenuStrankaTyp.Kateg_Aldecaldos]),
	DataPostavy.Postava(GlobalniID.Postava_Kurt_Hansen, GenderType.Male, "LocKey#15143102", "Male_Kurt_Hansen", "kurt", true, InkAtlasSoubor.Assets_EP1_09, n"c_kurt_full", 0.65, "", true, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Paco_Torres, GenderType.Male, "LocKey#15143048", "Male_Paco_Torres", "paco", true, InkAtlasSoubor.Assets_EP1_11, n"c_paco_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Barghest_Male_01, GenderType.Male, "LocKey#15143329", "Male_Barghest_01", "barghestmale01", true, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_barghestmale01", 0, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Barghest_Male_02, GenderType.Male, "LocKey#15143330", "Male_Barghest_02", "barghestmale02", true, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_barghestmale02", 0, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Barghest_Male_03, GenderType.Male, "LocKey#15143331", "Male_Barghest_03", "barghestmale03", true, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_barghestmale03", 0, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Chester_Bennett, GenderType.Male, "LocKey#15143361", "Male_Chester_Bennett", "chesterbennett", true, InkAtlasSoubor.Assets_EP1_14, n"c_bennett_full", 0.65, "", true, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Yuri_Bychkov, GenderType.Male, "LocKey#15143382", "Male_Yuri_Bychkov", "yuribychkov", true, InkAtlasSoubor.Assets_EP1_09, n"c_jurij_bychkov_full", 0.65, "", true, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Jago_Szabo, GenderType.Male, "LocKey#15143431", "Male_Jago_Szabo", "jagoszabo", true, InkAtlasSoubor.Assets_EP1_09, n"c_jago_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Leon_Rinder, GenderType.Male, "LocKey#15143499", "Male_Leon_Rinder", "leonrinder", true, InkAtlasSoubor.Assets_EP1_09, n"c_leon_rinder_full", 0, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Albert_Murphy, GenderType.Male, "LocKey#15143507", "Male_Albert_Murphy", "albertmurphy", true, InkAtlasSoubor.Assets_EP1_13, n"c_murphy_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Barghest]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Male_01, GenderType.Male, "LocKey#15143336", "Male_Scavengers_01", "scavengersmale01", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_scavengersmale01", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Male_02, GenderType.Male, "LocKey#15143337", "Male_Scavengers_02", "scavengersmale02", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_scavengersmale02", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Male_03, GenderType.Male, "LocKey#15143338", "Male_Scavengers_03", "scavengersmale03", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_scavengersmale03", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Scavengers_Male_04, GenderType.Male, "LocKey#15143339", "Male_Scavengers_04", "scavengersmale04", false, InkAtlasSoubor.LizziesBDs_Postavy_11, n"key_scavengersmale04", 0, "", false, [MenuStrankaTyp.Kateg_Mrchozrouti]),
	DataPostavy.Postava(GlobalniID.Postava_Wraiths_Male_01, GenderType.Male, "LocKey#15143344", "Male_Wraiths_01", "wraithsmale01", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_wraithsmale01", 0, "", false, [MenuStrankaTyp.Kateg_Prizraky]),
	DataPostavy.Postava(GlobalniID.Postava_Wraiths_Male_02, GenderType.Male, "LocKey#15143345", "Male_Wraiths_02", "wraithsmale02", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_wraithsmale02", 0, "", false, [MenuStrankaTyp.Kateg_Prizraky]),
	DataPostavy.Postava(GlobalniID.Postava_Wraiths_Male_03, GenderType.Male, "LocKey#15143346", "Male_Wraiths_03", "wraithsmale03", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_wraithsmale03", 0, "", false, [MenuStrankaTyp.Kateg_Prizraky]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Hasan_Demir, GenderType.Male, "LocKey#15143387", "Male_Hasan_Demir", "hasandemir", true, InkAtlasSoubor.Assets_EP1_13, n"c_hasan_demir_full", 0.6, "", false, [MenuStrankaTyp.Kateg_Dogtown], [
		DataVzhled.Vytvorit("LocKey#15143388", "", InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_hasandemir_stac", 0),
		DataVzhled.Vytvorit("LocKey#15143389", "", InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_hasandemir_squat", 0)
	]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Edgar_TooLina_Tool, GenderType.Male, "LocKey#15143393", "Male_Edgar_TooLina_Tool", "edgartool", true, InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_edgartool", 0, "", true, [MenuStrankaTyp.Kateg_Dogtown], [
		DataVzhled.Vytvorit("LocKey#15143394", "", InkAtlasSoubor.LizziesBDs_Postavy_14, n"key_edgartool_first", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Wilky_Slider_LaGuerre, GenderType.Male, "LocKey#15143416", "Male_Wilky_Slider_LaGuerre", "wilkylaguerre", true, InkAtlasSoubor.Assets_EP1_14, n"c_slider_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Milko_Alexis, GenderType.Male, "LocKey#15143417", "Male_Milko_Alexis", "milkoalexis", true, InkAtlasSoubor.Assets_EP1_10, n"c_milko_alexis_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Satoshi_Ueno, GenderType.Male, "LocKey#15143522", "Male_Satoshi_Ueno", "satoshiueno", true, InkAtlasSoubor.LizziesBDs_Postavy_21, n"key_satoshiueno", 0, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Male_V, GenderType.Male, "LocKey#15143143", "V", "v", false, InkAtlasSoubor.Assets_09, n"c_v_male_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Kerry_Eurodyne, GenderType.Male, "LocKey#15143011", "Male_Kerry_Eurodyne", "kerry", false, InkAtlasSoubor.Assets_02, n"c_kerry_old_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi], [
		DataVzhled.Vytvorit("LocKey#15143419", "", InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_kerry_young_2013", 0),
		DataVzhled.Vytvorit("LocKey#15143420", "", InkAtlasSoubor.Assets_00, n"c_kerry_young_full", 0.65),
		DataVzhled.Vytvorit("LocKey#15143421", "", InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_kerry_2079", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_River_Ward, GenderType.Male, "LocKey#15143012", "Male_River_Ward", "river", false, InkAtlasSoubor.Assets_01, n"c_river_ward_full", 0.65, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Angel, GenderType.Male, "LocKey#15143013", "Male_Angel", "angel", false, InkAtlasSoubor.LizziesBDs_Postavy_01, n"key_angel", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Mike_Tiny_Mike_Kowalski, GenderType.Male, "LocKey#15143017", "Male_Mike_Tiny_Mike_Kowalski", "mike", false, InkAtlasSoubor.Assets_05, n"c_tiny_mike_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Jackie_Welles, GenderType.Male, "LocKey#15143019", "Male_Jackie_Welles", "jackie", false, InkAtlasSoubor.Assets_03, n"c_jackie_welles_full", 0.65, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Victor_Vektor, GenderType.Male, "LocKey#15143025", "Male_Victor_Vektor", "victor_vector", false, InkAtlasSoubor.Assets_00, n"c_victor_vector_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Jefferson_Peralez, GenderType.Male, "LocKey#15143029", "Male_Jefferson_Peralez", "jefferson", false, InkAtlasSoubor.Assets_05, n"c_jefferson_peralez_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Tom_Caldera, GenderType.Male, "LocKey#15143032", "Male_Tom_Caldera", "tom", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_tom", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Benjamin_Stone, GenderType.Male, "LocKey#15143034", "Male_Benjamin_Stone", "stone", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_stone", 0, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Aymeric_Cassel, GenderType.Male, "LocKey#15143045", "Male_Aymeric_Cassel", "aymeric", true, InkAtlasSoubor.Assets_EP1_07, n"c_aymeric_cassel_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Placide, GenderType.Male, "LocKey#15143053", "Male_Placide", "placide", false, InkAtlasSoubor.Assets_00, n"c_placide_full", 0.65, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Goro_Takemura, GenderType.Male, "LocKey#15143054", "Male_Goro_Takemura", "takemura", false, InkAtlasSoubor.Assets_05, n"c_goro_takemura_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi], [
		DataVzhled.Vytvorit("LocKey#15143421", "", InkAtlasSoubor.LizziesBDs_Postavy_15, n"key_takemura_2079", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Sandayu_Oda, GenderType.Male, "LocKey#15143056", "Male_Sandayu_Oda", "oda", false, InkAtlasSoubor.Assets_02, n"c_oda_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Ozob_Bozo, GenderType.Male, "LocKey#15143062", "Male_Ozob_Bozo", "ozob", false, InkAtlasSoubor.LizziesBDs_Postavy_03, n"key_ozob", 0, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Muamar_El_Capitan_Reyes, GenderType.Male, "LocKey#15143063", "Male_Muamar_El_Capitan_Reyes", "reyes", false, InkAtlasSoubor.Assets_07, n"c_captain_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Jotaro_Shobo, GenderType.Male, "LocKey#15143101", "Male_Jotaro_Shobo", "jotaro", false, InkAtlasSoubor.Assets_04, n"c_jotaro_shobo_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Ayden_Daniels, GenderType.Male, "LocKey#15143103", "Male_Ayden_Daniels", "ayden", true, InkAtlasSoubor.Assets_EP1_13, n"c_daniels_clayton_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_NCPD_Male_01, GenderType.Male, "LocKey#15143127", "Male_NCPD_01", "ncpd_male_01", false, InkAtlasSoubor.LizziesBDs_Postavy_07, n"key_ncpd_male_01", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Arthur_Jenkins, GenderType.Male, "LocKey#15143146", "Male_Arthur_Jenkins", "jenkins", false, InkAtlasSoubor.LizziesBDs_Postavy_06, n"key_jenkins", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Finn_Fingers_Gerstatt, GenderType.Male, "LocKey#15143157", "Male_Finn_Fingers_Gerstatt", "fingers", false, InkAtlasSoubor.Assets_07, n"c_finn_fingers_gerstatt_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Bryce_Mosley, GenderType.Male, "LocKey#15143159", "Male_Bryce_Mosley", "mosley", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_mosley", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Frank_Nostra, GenderType.Male, "LocKey#15143160", "Male_Frank_Nostra", "nostra", false, InkAtlasSoubor.LizziesBDs_Postavy_02, n"key_nostra", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Wade_Mr_Hands_Bleecker, GenderType.Male, "LocKey#15143174", "Male_Wade_Mr_Hands_Bleecker", "mrhands", true, InkAtlasSoubor.Assets_EP1_12, n"c_mr_hands_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Sebastian_Padre_Ibarra, GenderType.Male, "LocKey#15143175", "Male_Sebastian_Padre_Ibarra", "padre", false, InkAtlasSoubor.Assets_05, n"c_padre_sebasitan_perez_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Dexter_Dex_DeShawn, GenderType.Male, "LocKey#15143218", "Male_Dexter_Dex_DeShawn", "dex", false, InkAtlasSoubor.Assets_09, n"c_dexter_deshawn_full", 0.65, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Jake_Tim_Kelly, GenderType.Male, "LocKey#15143222", "Male_Jake_Tim_Kelly", "jake", false, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_jake", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Ziggy_Q, GenderType.Male, "LocKey#15143223", "Male_Ziggy_Q", "ziggyq", false, InkAtlasSoubor.LizziesBDs_Postavy_09, n"key_ziggyq", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_E3_Male_V, GenderType.Male, "LocKey#15143350", "Male_E3_Male_V", "e3vmale", false, InkAtlasSoubor.LizziesBDs_Postavy_E3V, n"key_male_default", 0, "MaximiliumM", false, [MenuStrankaTyp.Menu_Muzi], [
		DataVzhled.Vytvorit("LocKey#15143202", "", InkAtlasSoubor.LizziesBDs_Postavy_E3V, n"key_male_casual", 0),
		DataVzhled.Vytvorit("LocKey#15143213", "", InkAtlasSoubor.LizziesBDs_Postavy_E3V, n"key_male_panties", 0),
		DataVzhled.Vytvorit("LocKey#15143205", "", InkAtlasSoubor.LizziesBDs_Postavy_E3V, n"key_male_date", 0),
		DataVzhled.Vytvorit("LocKey#15143351", "", InkAtlasSoubor.LizziesBDs_Postavy_E3V, n"key_male_combat", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Pepe_Najarro, GenderType.Male, "LocKey#15143359", "Male_Pepe_Najarro", "pepenajarro", false, InkAtlasSoubor.LizziesBDs_Postavy_12, n"key_pepenajarro", 0, "", true, [MenuStrankaTyp.Menu_Muzi]),
	//DataPostavy.Postava(GlobalniID.Postava_Dante_Caruso, GenderType.Male, "LocKey#15143360", "Male_Dante_Caruso", "dantecaruso", true, InkAtlasSoubor.Assets_EP1_08, n"c_dante_caruso_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Aguilar_Nubiola_Male, GenderType.Male, "LocKey#15143384", "Aguilar_Nubiola", "aguilarnubiola", true, InkAtlasSoubor.Assets_EP1_14, n"c_aguilar_male_full", 0.6, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Adam_Smasher, GenderType.Male, "LocKey#15143408", "Male_Adam_Smasher", "adamsmasher", false, InkAtlasSoubor.Assets_07, n"c_adam_smasher_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Yorinobu_Arasaka, GenderType.Male, "LocKey#15143418", "Male_Yorinobu_Arasaka", "yorinobuarasaka", false, InkAtlasSoubor.Assets_07, n"c_yorinobu_arasaka_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Robert_Wilson, GenderType.Male, "LocKey#15143450", "Male_Robert_Wilson", "robertwilson", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_robertwilson", 0, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Obese_Caribbean_01, GenderType.Male, "LocKey#15143451", "Male_Obese_Caribbean_01", "obesecaribbean01", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_obesecaribbean01", 0, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Mr_Blue_Eyes, GenderType.Male, "LocKey#15143452", "Male_Mr_Blue_Eyes", "mrblueeyes", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_mrblueeyes", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Driss_Scorpion_Meriana, GenderType.Male, "LocKey#15143453", "Male_Driss_Scorpion_Meriana", "drissscorpionmeriana", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_drissscorpionmeriana", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Henry, GenderType.Male, "LocKey#15143455", "Male_Henry", "henry", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_henry_2070_drug", 0, "", false, [MenuStrankaTyp.Menu_Muzi], [
		DataVzhled.Vytvorit("LocKey#15143456", "", InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_henry_2070_rockerboy", 0),
		DataVzhled.Vytvorit("LocKey#15143457", "", InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_henry_2020_rockerboy", 0),
		DataVzhled.Vytvorit("LocKey#15143458", "", InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_henry_2020_rockerboy_2", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Theodore_Teddy_Simos, GenderType.Male, "LocKey#15143463", "Male_Theodore_Teddy_Simos", "theodoreteddysimos", false, InkAtlasSoubor.LizziesBDs_Postavy_17, n"key_theodoreteddysimos", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Nix, GenderType.Male, "LocKey#15143465", "Male_Nix", "nix", false, InkAtlasSoubor.Assets_35, n"c_nix_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Lyle_Thompson, GenderType.Male, "LocKey#15143466", "Male_Lyle_Thompson", "lylethompson", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_lylethompson", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Cesar_Diego_Ruiz, GenderType.Male, "LocKey#15143482", "Male_Cesar_Diego_Ruiz", "cesardiegoruiz", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_cesardiegoruiz", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Roy_Batty, GenderType.Male, "LocKey#15143483", "Male_Roy_Batty", "roybatty", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_roybatty", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Max_Jones, GenderType.Male, "LocKey#15143485", "Male_Max_Jones", "maxjones", false, InkAtlasSoubor.Assets_02, n"c_max_jones_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Odell_Blanco, GenderType.Male, "LocKey#15143487", "Male_Odell_Blanco", "odellblanco", true, InkAtlasSoubor.Assets_EP1_11, n"c_odel_bailey_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Denzel_The_Brain_Cryer, GenderType.Male, "LocKey#15143496", "Male_Denzel_The_Brain_Cryer", "denzelthebraincryer", false, InkAtlasSoubor.LizziesBDs_Postavy_18, n"key_denzelthebraincryer", 0, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Emmerick_Bronson, GenderType.Male, "LocKey#15143217", "Male_Emmerick_Bronson", "emmerickbronson", false, InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_emmerickbronson", 0, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.PostavaVzhledy(GlobalniID.Postava_Peter_Sampson, GenderType.Male, "LocKey#15143247", "Male_Peter_Sampson", "petersampson", false, InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_petersampson", 0, "", false, [MenuStrankaTyp.Menu_Muzi], [
		DataVzhled.Vytvorit("LocKey#15143347", "", InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_petersampson_racing", 0),
		DataVzhled.Vytvorit("LocKey#15143497", "", InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_petersampson_racing_nohelmet", 0)
	]),
	DataPostavy.Postava(GlobalniID.Postava_Juan_Mendez, GenderType.Male, "LocKey#15143498", "Male_Juan_Mendez", "juanmendez", false, InkAtlasSoubor.LizziesBDs_Postavy_19, n"key_juanmendez", 0, "", true, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Dino_Dinovic, GenderType.Male, "LocKey#15143504", "Male_Dino_Dinovic", "dinodinovic", false, InkAtlasSoubor.Assets_05, n"c_dino_dinovic_full", 0.65, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Rafael_Perez, GenderType.Male, "LocKey#15143508", "Male_Rafael_Perez", "rafaelperez", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_rafaelperez", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Nonbinary_Youngster_01, GenderType.Male, "LocKey#15143513", "Male_Nonbinary_Youngster_01", "nonbinaryyoungster01", false, InkAtlasSoubor.LizziesBDs_Postavy_20, n"key_nonbinaryyoungster01", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Boris_Ribakov, GenderType.Male, "LocKey#15143517", "Male_Boris_Ribakov", "borisribakov", true, InkAtlasSoubor.Assets_EP1_07, n"c_boris_ribakov_full", 0.65, "", false, [MenuStrankaTyp.Kateg_Dogtown]),
	DataPostavy.Postava(GlobalniID.Postava_Hwangbo_Dong_Gun, GenderType.Male, "LocKey#15143518", "Male_Hwangbo_Dong_Gun", "hwangbodonggun", false, InkAtlasSoubor.LizziesBDs_Postavy_21, n"key_hwangbodonggun", 0, "", false, [MenuStrankaTyp.Menu_Muzi]),
	DataPostavy.Postava(GlobalniID.Postava_Barry_Lewis, GenderType.Male, "LocKey#15143519", "Male_Barry_Lewis", "barrylewis", false, InkAtlasSoubor.LizziesBDs_Postavy_21, n"key_barrylewis", 0, "", true, [MenuStrankaTyp.Menu_Muzi]),

	DataPostavy.PostavaRobot(GlobalniID.Postava_Robot_Corpo, GenderType.Robot, "LocKey#15143467", "Robot_Corpo", "robotcorpo", false, InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_corpo_arasaka", 0, "", false, [MenuStrankaTyp.Kateg_Roboti], [
		DataVzhled.Vytvorit("LocKey#15143468", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_corpo_ncpd", 0),
		DataVzhled.Vytvorit("LocKey#15143469", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_corpo_militech", 0),
		DataVzhled.Vytvorit("LocKey#15143470", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_corpo_maxtac", 0),
		DataVzhled.Vytvorit("LocKey#15143471", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_corpo_kangtao", 0),
		DataVzhled.Vytvorit("LocKey#15143472", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_corpo_kiroshi", 0),
		DataVzhled.Vytvorit("LocKey#15143472", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_corpo_kiroshi_comm", 0)
	]),
	DataPostavy.PostavaRobot(GlobalniID.Postava_Robot_Gang_Maelstrom, GenderType.Robot, "LocKey#15143473", "Robot_Gang", "robotgangmaelstrom", false, InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_gang_maelstrom_01", 0, "", false, [MenuStrankaTyp.Kateg_Roboti], [
		DataVzhled.Vytvorit("LocKey#15143473", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_gang_maelstrom_02", 0),
		DataVzhled.Vytvorit("LocKey#15143473", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_gang_maelstrom_03", 0),
		DataVzhled.Vytvorit("LocKey#15143473", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_gang_maelstrom_04", 0)
	]),
	DataPostavy.PostavaRobot(GlobalniID.Postava_Robot_Gang_Wraith, GenderType.Robot, "LocKey#15143474", "Robot_Gang", "robotgangwraith", false, InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_gang_wraith_01", 0, "", false, [MenuStrankaTyp.Kateg_Roboti], [
		DataVzhled.Vytvorit("LocKey#15143474", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_gang_wraith_02", 0),
		DataVzhled.Vytvorit("LocKey#15143474", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_gang_wraith_03", 0),
		DataVzhled.Vytvorit("LocKey#15143474", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_01, n"key_gang_wraith_04", 0),
		DataVzhled.Vytvorit("LocKey#15143474", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_wraith_05", 0)
	]),
	DataPostavy.PostavaRobot(GlobalniID.Postava_Robot_Gang_Scavenger, GenderType.Robot, "LocKey#15143475", "Robot_Gang", "robotgangscavenger", false, InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_scavenger_01", 0, "", false, [MenuStrankaTyp.Kateg_Roboti], [
		DataVzhled.Vytvorit("LocKey#15143475", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_scavenger_02", 0),
		DataVzhled.Vytvorit("LocKey#15143475", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_scavenger_03", 0),
		DataVzhled.Vytvorit("LocKey#15143475", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_scavenger_04", 0),
		DataVzhled.Vytvorit("LocKey#15143475", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_scavenger_05", 0),
		DataVzhled.Vytvorit("LocKey#15143475", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_scavenger_06", 0)
	]),
	DataPostavy.PostavaRobot(GlobalniID.Postava_Robot_Gang_6th_Street, GenderType.Robot, "LocKey#15143476", "Robot_Gang", "robotgang6thstreet", false, InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_6thstreet_01", 0, "", false, [MenuStrankaTyp.Kateg_Roboti], [
		DataVzhled.Vytvorit("LocKey#15143476", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_6thstreet_02", 0),
		DataVzhled.Vytvorit("LocKey#15143476", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_6thstreet_03", 0),
		DataVzhled.Vytvorit("LocKey#15143476", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_6thstreet_04", 0),
		DataVzhled.Vytvorit("LocKey#15143476", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_6thstreet_05", 0),
		DataVzhled.Vytvorit("LocKey#15143476", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_gang_6thstreet_06", 0)
	]),
	DataPostavy.PostavaRobot(GlobalniID.Postava_Robot_Training, GenderType.Robot, "LocKey#15143477", "Robot_Training", "robottraining", false, InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_training_01", 0, "", false, [MenuStrankaTyp.Kateg_Roboti], [
		DataVzhled.Vytvorit("LocKey#15143477", "", InkAtlasSoubor.LizziesBDs_Postavy_Robots_02, n"key_training_02", 0)
	]),
	DataPostavy.PostavaRobot(GlobalniID.Postava_Robot_Remote, GenderType.Robot, "LocKey#15143478", "Robot_Remote", "robotremote", false, InkAtlasSoubor.LizziesBDs_Postavy_Robots_03, n"key_remote", 0, "", false, [MenuStrankaTyp.Kateg_Roboti], []),
	DataPostavy.PostavaRobot(GlobalniID.Postava_Robot_Nusa, GenderType.Robot, "LocKey#15143479", "Robot_Nusa", "robotnusa", false, InkAtlasSoubor.LizziesBDs_Postavy_Robots_03, n"key_nusa", 0, "", false, [MenuStrankaTyp.Kateg_Roboti], []),
	DataPostavy.PostavaRobot(GlobalniID.Postava_Robot_Moth_Barman, GenderType.Robot, "LocKey#15143480", "Robot_Moth_Barman", "robotmothbarman", false, InkAtlasSoubor.LizziesBDs_Postavy_Robots_03, n"key_barman_moth", 0, "", false, [MenuStrankaTyp.Kateg_Roboti], [])
];

public func DataPoleNastaveni(nahotaJePovolena: Bool) -> array<DataNastaveni> {
	let pole: array<DataNastaveni> = [
		new DataNastaveni(GlobalniID.Nastaveni_Opt2, GetLocalizedText("LocKey#15144029"), NastaveniTyp.Globalni, nahotaJePovolena, "laguna_bend_ext", n"lizzies_bds_sett_laguna", GetLocalizedText("LocKey#15144030"), 0, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt3, GetLocalizedText("LocKey#15144031"), NastaveniTyp.Globalni, true, "only_staff", Konstanty.FaktPouzeMox(), GetLocalizedText("LocKey#15144032"), 0, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt4, GetLocalizedText("LocKey#15144033"), NastaveniTyp.Globalni, true, "bd_anims", n"lizzies_bds_sett_anims", GetLocalizedText("LocKey#15144034"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt5, GetLocalizedText("LocKey#15144035"), NastaveniTyp.Globalni, true, "bd_editor_overlay", n"lizzies_bds_sett_bdeditor_overlay", GetLocalizedText("LocKey#15144036"), 0, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt6, GetLocalizedText("LocKey#15144037"), NastaveniTyp.Globalni, true, "replay", n"lizzies_bds_sett_replay_disabled", GetLocalizedText("LocKey#15144038"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt9, GetLocalizedText("LocKey#15144046"), NastaveniTyp.Globalni, nahotaJePovolena, "npc_clothes", Konstanty.FaktNastaveniNPCObleceni(), GetLocalizedText("LocKey#15144047"), 0, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt8, GetLocalizedText("LocKey#15144041"), NastaveniTyp.Globalni, true, "only_gender", Konstanty.FaktZobrazitPohlavi(), GetLocalizedText("LocKey#15144042"), 10, [GetLocalizedText("LocKey#15144043"), GetLocalizedText("LocKey#15144044"), GetLocalizedText("LocKey#15144045")]),
		new DataNastaveni(GlobalniID.Nastaveni_Opt12, GetLocalizedText("LocKey#15144056"), NastaveniTyp.Globalni, true, "cam_filter", n"lizzies_bds_sett_disable_cam_overlay", GetLocalizedText("LocKey#15144057"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt13, GetLocalizedText("LocKey#15144061"), NastaveniTyp.Globalni, true, "menu_nav", Konstanty.FaktZakladniNavigace(), GetLocalizedText("LocKey#15144062"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt14, GetLocalizedText("LocKey#15144065"), NastaveniTyp.Globalni, true, "world_prefetch", n"lizzies_bds_sett_disable_world_prefetch", GetLocalizedText("LocKey#15144066"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt15, GetLocalizedText("LocKey#15144068"), NastaveniTyp.Globalni, true, "more_mox", n"lizzies_bds_sett_more_mox", GetLocalizedText("LocKey#15144069"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt16, GetLocalizedText("LocKey#15144075"), NastaveniTyp.Globalni, nahotaJePovolena, "the_hammer_ext", n"lizzies_bds_sett_thehammer", GetLocalizedText("LocKey#15144076"), 0, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt17, GetLocalizedText("LocKey#15144077"), NastaveniTyp.Globalni, nahotaJePovolena, "hangout_short", n"lizzies_bds_sett_hangout_short", GetLocalizedText("LocKey#15144078"), 0, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt19, GetLocalizedText("LocKey#15144081"), NastaveniTyp.Globalni, true, "dis_tuts", n"lizzies_bds_sett_dis_tuts", GetLocalizedText("LocKey#15144082"), 0, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt20, GetLocalizedText("LocKey#15144087"), NastaveniTyp.Globalni, true, "bd_anywhere", n"lizzies_bds_bd_anywhere_disabled", GetLocalizedText("LocKey#15144088"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt21, GetLocalizedText("LocKey#15144094"), NastaveniTyp.Globalni, nahotaJePovolena, "holo_dancer", n"lizzies_bds_sett_holo", GetLocalizedText("LocKey#15144095"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt23, GetLocalizedText("LocKey#15144106"), NastaveniTyp.Globalni, true, "events", Konstanty.FaktEventy(), GetLocalizedText("LocKey#15144107"), 1, [GetLocalizedText("LocKey#15142054"), GetLocalizedText("LocKey#15142055"), GetLocalizedText("LocKey#15144108"), GetLocalizedText("LocKey#15144109")]),
		new DataNastaveni(GlobalniID.Nastaveni_Opt24, GetLocalizedText("LocKey#15144110"), NastaveniTyp.Globalni, true, "plr_car", n"lizzies_bds_sett_plr_car", GetLocalizedText("LocKey#15144111"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt25, GetLocalizedText("LocKey#15144112"), NastaveniTyp.Globalni, true, "cartridges", n"lizzies_bds_cartridges", GetLocalizedText("LocKey#15144113"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt22, GetLocalizedText("LocKey#15144116"), NastaveniTyp.Globalni, true, "dynprew_cam", Konstanty.FaktNastaveniDynNahled(), GetLocalizedText("LocKey#15144117"), 2, [GetLocalizedText("LocKey#15144118"), GetLocalizedText("LocKey#15144119"), GetLocalizedText("LocKey#15142055")]),
		new DataNastaveni(GlobalniID.Nastaveni_Opt26, GetLocalizedText("LocKey#15144120"), NastaveniTyp.Globalni, true, "dynprew_background", n"lizzies_bds_sett_dynamic_preview_bg", GetLocalizedText("LocKey#15144121"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt27, GetLocalizedText("LocKey#15144122"), NastaveniTyp.Globalni, true, "dynprew_quality", Konstanty.FaktNastaveniDynNahledKvalita(), GetLocalizedText("LocKey#15144123"), 10, [GetLocalizedText("LocKey#15144124"), GetLocalizedText("LocKey#15144129"), GetLocalizedText("LocKey#15144128"), GetLocalizedText("LocKey#15144125")]),
		new DataNastaveni(GlobalniID.Nastaveni_Opt28, GetLocalizedText("LocKey#15144126"), NastaveniTyp.Globalni, nahotaJePovolena, "dynprew_nude", n"lizzies_bds_sett_dynamic_preview_nude", GetLocalizedText("LocKey#15144127"), 0, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt29, GetLocalizedText("LocKey#15144130"), NastaveniTyp.Globalni, true, "dynprew_torso", n"lizzies_bds_sett_dynamic_preview_torso", GetLocalizedText("LocKey#15144131"), 0, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt31, GetLocalizedText("LocKey#15144141"), NastaveniTyp.Globalni, true, "sort", Konstanty.FaktNastaveniSerazeni(), GetLocalizedText("LocKey#15144142"), 10, [GetLocalizedText("LocKey#15144124"), GetLocalizedText("LocKey#15144144"), GetLocalizedText("LocKey#15144145")]),
		new DataNastaveni(GlobalniID.Nastaveni_Opt32, GetLocalizedText("LocKey#15144146"), NastaveniTyp.Globalni, true, "sort_categ", Konstanty.FaktNastaveniSerazeniKateg(), GetLocalizedText("LocKey#15144147"), 0, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt34, GetLocalizedText("LocKey#15144153"), NastaveniTyp.Globalni, true, "invite", n"lizzies_bds_sett_invite", GetLocalizedText("LocKey#15144154"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt46, GetLocalizedText("LocKey#15144188"), NastaveniTyp.Globalni, true, "advert_h10", n"lizzies_bds_sett_ads", GetLocalizedText("LocKey#15144189"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt47, GetLocalizedText("LocKey#15144190"), NastaveniTyp.Globalni, true, "extended_reality", n"lizzies_bds_er_disabled", GetLocalizedText("LocKey#15144191"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt48, GetLocalizedText("LocKey#15144192"), NastaveniTyp.Globalni, true, "keep_settings", Konstanty.FaktNastaveniZachovatNst(), GetLocalizedText("LocKey#15144193"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt49, GetLocalizedText("LocKey#15144194"), NastaveniTyp.Globalni, true, "ui_notifs", Konstanty.FaktNastaveniUINotif(), GetLocalizedText("LocKey#15144195"), 1, []),
		new DataNastaveni(GlobalniID.Nastaveni_Opt50, GetLocalizedText("LocKey#15144196"), NastaveniTyp.Globalni, true, "streaming_icons", n"lizzies_bds_mappins_disable", GetLocalizedText("LocKey#15144197"), 1, [])
	];

	return pole;
}

public func DataPoleNastaveniOblicej() -> array<DataNastaveni> = [
	new DataNastaveni(GlobalniID.Nastaveni_Opt38, GetLocalizedText("LocKey#15142286"), NastaveniTyp.PV, true, "", StringToName(Konstanty.FaktVybranyOblicejKlidVaha()), GetLocalizedText("LocKey#15142287"), -1, ["100%", "90%", "80%", "70%", "60%", "50%", "40%", "30%", "20%", "10%"]),
	new DataNastaveni(GlobalniID.Nastaveni_Opt39, GetLocalizedText("LocKey#15142288"), NastaveniTyp.PV, true, "", StringToName(Konstanty.FaktVybranyOblicejPozaVaha()), GetLocalizedText("LocKey#15142287"), -1, ["100%", "90%", "80%", "70%", "60%", "50%", "40%", "30%", "20%", "10%"])
];

public func DataPoleNastaveniPostavy(jeHrac: Bool, nahotaJePovolena: Bool, bodData: Bool, jeZena: Bool) -> array<DataNastaveni> {
	let pole: array<DataNastaveni> = [];
	ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt33, GetLocalizedText("LocKey#15144148"), NastaveniTyp.Postava, nahotaJePovolena, "", StringToName(Konstanty.FaktVybranyMoaning()), GetLocalizedText("LocKey#15144149"), 10, [GetLocalizedText("LocKey#15144052"), GetLocalizedText("LocKey#15144150"), GetLocalizedText("LocKey#15144151"), GetLocalizedText("LocKey#15144186"), GetLocalizedText("LocKey#15144206"), GetLocalizedText("LocKey#15144187")]));
	if !jeHrac {
		ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt40, GetLocalizedText("LocKey#15144167"), NastaveniTyp.Postava, nahotaJePovolena && jeZena, "", StringToName(Konstanty.FaktVybranyStrapon()), GetLocalizedText("LocKey#15144168"), 0, [GetLocalizedText("LocKey#15142055"), GetLocalizedText("LocKey#15144105"), GetLocalizedText("LocKey#15144173")]));
		ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt41, GetLocalizedText("LocKey#15144169"), NastaveniTyp.Postava, jeZena, "", StringToName(Konstanty.FaktVybranyFishnet()), GetLocalizedText("LocKey#15144170"), 0, [GetLocalizedText("LocKey#15142055"), GetLocalizedText("LocKey#15144177"), GetLocalizedText("LocKey#15144178")]));
		ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt42, GetLocalizedText("LocKey#15144171"), NastaveniTyp.Postava, true, "", StringToName(Konstanty.FaktVybranyChoker()), GetLocalizedText("LocKey#15144172"), 0, [GetLocalizedText("LocKey#15142055"), GetLocalizedText("LocKey#15144174"), GetLocalizedText("LocKey#15144175"), GetLocalizedText("LocKey#15144176")]));
		ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt35, GetLocalizedText("LocKey#15144053"), NastaveniTyp.Postava, nahotaJePovolena && bodData, "", StringToName(Konstanty.FaktVybranyBODSize()), GetLocalizedText("LocKey#15144054"), 3, [GetLocalizedText("LocKey#15144155"), GetLocalizedText("LocKey#15144156"), GetLocalizedText("LocKey#15144157"), GetLocalizedText("LocKey#15144158")]));
		ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt36, GetLocalizedText("LocKey#15144159"), NastaveniTyp.Postava, nahotaJePovolena && bodData, "", StringToName(Konstanty.FaktVybranyBODVariant()), GetLocalizedText("LocKey#15144160"), 10, [GetLocalizedText("LocKey#15144161"), GetLocalizedText("LocKey#15144162"), GetLocalizedText("LocKey#15144163"), GetLocalizedText("LocKey#15144164")]));
		ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt37, GetLocalizedText("LocKey#15144165"), NastaveniTyp.Postava, nahotaJePovolena && bodData && jeZena, "", StringToName(Konstanty.FaktVybranyBODFem()), GetLocalizedText("LocKey#15144166"), 0, []));
	}
	return pole;
};

public func DataPoleNastaveniLokace(nahotaJePovolena: Bool, jeZena: Bool, eexVyb: Bool, eexOutfityStr: array<String>, replacer: Bool) -> array<DataNastaveni> {
	let pole: array<DataNastaveni> = [];
	ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt30, GetLocalizedText("LocKey#15144136"), NastaveniTyp.Lokace, nahotaJePovolena, "", n"lizzies_bds_sett_genitals_manager", GetLocalizedText("LocKey#15144137"), 10, [GetLocalizedText("LocKey#15144138"), GetLocalizedText("LocKey#15144139"), GetLocalizedText("LocKey#15144140")]));
	ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt7, GetLocalizedText("LocKey#15144039"), NastaveniTyp.Lokace, nahotaJePovolena, "", Konstanty.FaktObleceniPlr(), GetLocalizedText("LocKey#15144040"), 10, [GetLocalizedText("LocKey#15144133"), GetLocalizedText("LocKey#15144134"), GetLocalizedText("LocKey#15144135"), GetLocalizedText("LocKey#15144179")]));
	ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt40, GetLocalizedText("LocKey#15144167"), NastaveniTyp.Lokace, nahotaJePovolena && jeZena, "", Konstanty.FaktStraponPlr(), GetLocalizedText("LocKey#15144168"), 0, [GetLocalizedText("LocKey#15142055"), GetLocalizedText("LocKey#15142054"), GetLocalizedText("LocKey#15144173")]));
	ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt43, GetLocalizedText("LocKey#15144180"), NastaveniTyp.Lokace, nahotaJePovolena && eexVyb, "", Konstanty.FaktEEXOutfit(), GetLocalizedText("LocKey#15144181"), 100, eexOutfityStr));
	ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt44, GetLocalizedText("LocKey#15144182"), NastaveniTyp.Lokace, nahotaJePovolena && eexVyb, "", Konstanty.FaktEEXOutfitNaked(), GetLocalizedText("LocKey#15144183"), 100, eexOutfityStr));
	ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt51, GetLocalizedText("LocKey#15144198"), NastaveniTyp.Lokace, replacer, "", Konstanty.FaktReplacer(), GetLocalizedText("LocKey#15144199"), 100, [GetLocalizedText("LocKey#15144200"), GetLocalizedText("LocKey#15144202"), GetLocalizedText("LocKey#15144201")]));
	ArrayPush(pole, new DataNastaveni(GlobalniID.Nastaveni_Opt52, GetLocalizedText("LocKey#15144203"), NastaveniTyp.Lokace, replacer, "", n"lizzies_bds_replacer_app", GetLocalizedText("LocKey#15144204"), 100, [GetLocalizedText("LocKey#15144205")]));
	return pole;
};

public func DataPoleNastaveniKatalog(nahotaJePovolena: Bool) -> array<DataNastaveni> = [
	new DataNastaveni(GlobalniID.Nastaveni_Opt1, GetLocalizedText("LocKey#15144027"), NastaveniTyp.Globalni, nahotaJePovolena, "", Konstanty.FaktAudioHlasitost(), GetLocalizedText("LocKey#15144028"), 10, ["100%", "90%", "80%", "70%", "60%", "50%", "40%", "30%", "20%", "10%", GetLocalizedText("LocKey#15144097")]), //GetLocalizedText("LocKey#15144096"), GetLocalizedText("LocKey#15144097"), GetLocalizedText("LocKey#15144098"), GetLocalizedText("LocKey#15144099")
	new DataNastaveni(GlobalniID.Nastaveni_Opt11, GetLocalizedText("LocKey#15144099"), NastaveniTyp.Globalni, nahotaJePovolena, "", Konstanty.FaktAudioHlasitost2(), GetLocalizedText("LocKey#15144100"), 10, ["100%", "90%", "80%", "70%", "60%", "50%", "40%", "30%", "20%", "10%", GetLocalizedText("LocKey#15144097")]),
	new DataNastaveni(GlobalniID.Nastaveni_Opt10, GetLocalizedText("LocKey#15144048"), NastaveniTyp.Globalni, nahotaJePovolena, "", n"lizzies_bds_sett_anim_type", GetLocalizedText("LocKey#15144049"), 10, [GetLocalizedText("LocKey#15144052"), GetLocalizedText("LocKey#15144050"), GetLocalizedText("LocKey#15144051")]),
	new DataNastaveni(GlobalniID.Nastaveni_Opt18, GetLocalizedText("LocKey#15144079"), NastaveniTyp.Globalni, nahotaJePovolena, "", n"lizzies_bds_sett_f_ext", GetLocalizedText("LocKey#15144080"), 0, []),
	new DataNastaveni(GlobalniID.Nastaveni_Opt45, GetLocalizedText("LocKey#15144184"), NastaveniTyp.Globalni, nahotaJePovolena, "", n"lizzies_bds_sett_joytoy_rnd", GetLocalizedText("LocKey#15144185"), 1, [])
];

public func DataPoleLokaci(game: GameInstance, questsSystem: wref<QuestsSystem>, resources: wref<LizziesBDsResources>, nahotaJePovolena: Bool, peveckaAktivni: Bool, ep1JeInstalovane: Bool) -> array<ref<DataLokace>> {
	let bezPodminek: Bool = questsSystem.GetFact(Konstanty.FaktBezPodminek()) == 0;
	let zobrazitPohlavi: Int32 = questsSystem.GetFact(Konstanty.FaktZobrazitPohlavi());
	let rollercoasterOpraven: Bool = bezPodminek && questsSystem.GetFact(n"mq006_roller_coaster_fixed") == 0;
	let akt1Dokoncen: Bool = bezPodminek && questsSystem.GetFact(n"q005_done") == 0;
	let cinemaCond: Bool = bezPodminek && (!(questsSystem.GetFact(n"sq031_done") == 0 || (questsSystem.GetFact(n"sq031_done") == 1 && questsSystem.GetFact(n"de_wbr_nok_01_finished") == 1)));
	let sts_cct_dtn_03: Bool = bezPodminek && questsSystem.GetFact(n"dtn_03_finished") == 0;
	let mq301_finished: Bool = bezPodminek && questsSystem.GetFact(n"mq301_finished") == 0;
	let q112_done: Bool = bezPodminek && questsSystem.GetFact(n"q112_done") == 0;
	let letYouDownData: Bool = bezPodminek && !resources.letYouDownDataInstalovan;
	let irwtsayhData: Bool = bezPodminek && !resources.irwtsayhDataInstalovan;
	let q105_done: Bool = bezPodminek && questsSystem.GetFact(n"q105_done") == 0;
	let uscracksCond: Bool = bezPodminek && (!(questsSystem.GetFact(n"mq019_03_active") == 0 && questsSystem.GetFact(n"sq017_done") == 1 && questsSystem.GetFact(n"sq017_us_cracks_no_deal") == 0 && questsSystem.GetFact(n"mq028_bluemoon_killed") == 0));
	let sq011_active: Bool = bezPodminek && questsSystem.GetFact(n"sq011_active") == 1;
	let kab_04: Bool = bezPodminek && (!(questsSystem.GetFact(n"kab_04_activated") == 0 || (questsSystem.GetFact(n"kab_04_activated") > 0 && questsSystem.GetFact(n"kab_04_finished") > 0)));
	let privBDMegabuilding: Bool = questsSystem.GetFact(Konstanty.FaktSoukromePVMegabuilding()) == 2;
	let privBDDowntown: Bool = questsSystem.GetFact(Konstanty.FaktSoukromePVDowntown()) == 2;
	let privBDHeywood: Bool = questsSystem.GetFact(Konstanty.FaktSoukromePVHeywood()) == 2;
	let privBDJapantown: Bool = questsSystem.GetFact(Konstanty.FaktSoukromePVJapantown()) == 2;
	let privBDNorthside: Bool = questsSystem.GetFact(Konstanty.FaktSoukromePVNorthside()) == 2;
	let privBDEdenPlaza: Bool = questsSystem.GetFact(Konstanty.FaktSoukromePVEdenPlaza()) == 2;
	let privBDSantoSerenity: Bool = questsSystem.GetFact(Konstanty.FaktSoukromePVSantoSerenity()) == 2;
	let q303_done: Bool = bezPodminek && questsSystem.GetFact(n"q303_done") == 0;
	let poncData: Bool = bezPodminek && questsSystem.GetFact(Konstanty.FaktFeatPONC()) == 1;
	let ma_pac_cvi_12_finished: Bool = bezPodminek && questsSystem.GetFact(n"ma_pac_cvi_12_finished") == 0;
	let chiaaData: Bool = bezPodminek && !resources.chiaaDataInstalovan;
	let ma_hey_spr_04_done: Bool = bezPodminek && questsSystem.GetFact(n"ma_spr_04_done") == 0;
	let sq030_active: Bool = bezPodminek && questsSystem.GetFact(n"sq030_active") > 0;

	let journalManager: wref<JournalManager> = GameInstance.GetJournalManager(game);
	let journalEntry: wref<JournalEntry> = journalManager.GetEntryByString("quests/main_quest/prologue/q003_stout/stout/01_go_to_notell", "gameJournalQuestObjective");
	let q003_stout: Bool = bezPodminek && Equals(journalManager.GetEntryState(journalEntry), gameJournalEntryState.Active);

	let pole: array<ref<DataLokace>> = [
		DataLokace.Kt(GlobalniID.Lokace_Kont_Joytoy, GetLocalizedText("LocKey#15142223"), GetLocalizedText("LocKey#15142224"), nahotaJePovolena, InkAtlasSoubor.LizziesBDs_Lokace_K_01, n"key_joytoy", true, false, false, [
			DataLokace.Lk(GlobalniID.Lokace_JigJig, GetLocalizedText("LocKey#15142007"), GetLocalizedText("LocKey#15142059"), nahotaJePovolena, InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_jigjig", true, true, false, 1, false, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_DarkMatter, GetLocalizedText("LocKey#15142008"), GetLocalizedText("LocKey#15142060"), nahotaJePovolena, InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_darkmatter", true, true, false, 1, false, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_ArasakaEstate, GetLocalizedText("LocKey#15142009"), GetLocalizedText("LocKey#15142061"), nahotaJePovolena, InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_arasakaestate", true, true, false, 1, false, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_NoTellMotel, GetLocalizedText("LocKey#15142011"), GetLocalizedText("LocKey#15142063"), nahotaJePovolena, InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_notellmotel", true, true, q003_stout, 1, false, GenderType.None, false, 5, false),
			DataLokace.Lk(GlobalniID.Lokace_SunsetMotel, GetLocalizedText("LocKey#15142328"), GetLocalizedText("LocKey#15142329"), nahotaJePovolena && !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_02, n"key_sunsetmotel", true, true, false, 1, false, GenderType.Female, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_KonpekiJoytoy, GetLocalizedText("LocKey#15142366"), GetLocalizedText("LocKey#15142367"), nahotaJePovolena && !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_04, n"key_konpeki_joytoy", true, true, akt1Dokoncen, 1, false, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_ApartsJoytoy_Megabuilding, GetLocalizedText("LocKey#15142292"), GetLocalizedText("LocKey#15142293"), nahotaJePovolena && !peveckaAktivni && privBDMegabuilding, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, false, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_ApartsJoytoy_Downtown, GetLocalizedText("LocKey#15142300"), GetLocalizedText("LocKey#15142293"), nahotaJePovolena && !peveckaAktivni && privBDDowntown, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, false, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_ApartsJoytoy_Heywood, GetLocalizedText("LocKey#15142301"), GetLocalizedText("LocKey#15142293"), nahotaJePovolena && !peveckaAktivni && privBDHeywood, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, false, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_ApartsJoytoy_Japantown, GetLocalizedText("LocKey#15142302"), GetLocalizedText("LocKey#15142293"), nahotaJePovolena && !peveckaAktivni && privBDJapantown, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, false, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_ApartsJoytoy_Northside, GetLocalizedText("LocKey#15142303"), GetLocalizedText("LocKey#15142293"), nahotaJePovolena && !peveckaAktivni && privBDNorthside, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, false, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_ApartsJoytoy_EdenPlaza, GetLocalizedText("LocKey#15142333"), GetLocalizedText("LocKey#15142293"), nahotaJePovolena && !peveckaAktivni && privBDEdenPlaza, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, false, GenderType.None, false, 3, false)
		]),
		DataLokace.Kt(GlobalniID.Lokace_Kont_DoubleAction, GetLocalizedText("LocKey#15142225"), GetLocalizedText("LocKey#15142226"), nahotaJePovolena && !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_01, n"key_doubleaction", false, false, false, [
			DataLokace.Lk(GlobalniID.Lokace_DoubleAction_JigJig, GetLocalizedText("LocKey#15142007"), "", nahotaJePovolena, InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_jigjig", true, true, false, 2, false, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_DoubleAction_DarkMatter, GetLocalizedText("LocKey#15142008"), "", nahotaJePovolena, InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_darkmatter", true, true, false, 2, false, GenderType.None, false, 3, false)
		]),
		DataLokace.Kt(GlobalniID.Lokace_Kont_PoleDancing, GetLocalizedText("LocKey#15142227"), GetLocalizedText("LocKey#15142228"), nahotaJePovolena && !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_01, n"key_poledancing", false, true, false, [
			DataLokace.Lk(GlobalniID.Lokace_Poledance_JigJig, GetLocalizedText("LocKey#15142007"), "", nahotaJePovolena, InkAtlasSoubor.LizziesBDs_Lokace_02, n"key_jigjig_poledance", false, true, false, 1, true, GenderType.None, false, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_Poledance_Triple, GetLocalizedText("LocKey#15142136"), "", nahotaJePovolena, InkAtlasSoubor.LizziesBDs_Lokace_02, n"key_poledance_triple", false, true, kab_04, 3, true, GenderType.None, false, 3, false)
		]),
		DataLokace.Kt(GlobalniID.Lokace_Kont_Hangout, GetLocalizedText("LocKey#15142229"), GetLocalizedText("LocKey#15142230"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_01, n"key_hangout", false, true, false, [
			DataLokace.Lk(GlobalniID.Lokace_Hangout_VPenthouse, GetLocalizedText("LocKey#15142096"), GetLocalizedText("LocKey#15142097"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_02, n"key_vpenthouse", true, true, false, 1, true, GenderType.None, false, 1, true),
			DataLokace.Lk(GlobalniID.Lokace_Hangout_Konpeki, GetLocalizedText("LocKey#15142207"), GetLocalizedText("LocKey#15142208"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_03, n"key_konpeki_hangout", true, true, akt1Dokoncen, 1, true, GenderType.None, false, 1, true),
			DataLokace.Lk(GlobalniID.Lokace_Hangout_Boat, GetLocalizedText("LocKey#15142171"), GetLocalizedText("LocKey#15142172"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_03, n"key_hangout_boat", false, true, akt1Dokoncen, 1, true, GenderType.None, false, 1, true),
			DataLokace.Lk(GlobalniID.Lokace_Hangout_Dwelling, GetLocalizedText("LocKey#15142368"), GetLocalizedText("LocKey#15142369"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_04, n"key_hangout_dwelling", true, true, sq030_active, 1, true, GenderType.None, false, 1, true),
			DataLokace.Lk(GlobalniID.Lokace_Hangout_Priv_Megabuilding, GetLocalizedText("LocKey#15142292"), GetLocalizedText("LocKey#15142293"), !peveckaAktivni && privBDMegabuilding, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, true, GenderType.None, false, 1, true),
			DataLokace.Lk(GlobalniID.Lokace_Hangout_Priv_Downtown, GetLocalizedText("LocKey#15142300"), GetLocalizedText("LocKey#15142293"), !peveckaAktivni && privBDDowntown, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, true, GenderType.None, false, 1, true),
			DataLokace.Lk(GlobalniID.Lokace_Hangout_Priv_Heywood, GetLocalizedText("LocKey#15142301"), GetLocalizedText("LocKey#15142293"), !peveckaAktivni && privBDHeywood, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, true, GenderType.None, false, 1, true),
			DataLokace.Lk(GlobalniID.Lokace_Hangout_Priv_Japantown, GetLocalizedText("LocKey#15142302"), GetLocalizedText("LocKey#15142293"), !peveckaAktivni && privBDJapantown, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, true, GenderType.None, false, 1, true),
			DataLokace.Lk(GlobalniID.Lokace_Hangout_Priv_Northside, GetLocalizedText("LocKey#15142303"), GetLocalizedText("LocKey#15142293"), !peveckaAktivni && privBDNorthside, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, true, GenderType.None, false, 1, true),
			DataLokace.Lk(GlobalniID.Lokace_Hangout_Priv_EdenPlaza, GetLocalizedText("LocKey#15142333"), GetLocalizedText("LocKey#15142293"), !peveckaAktivni && privBDEdenPlaza, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, true, GenderType.None, false, 1, true),
			DataLokace.Lk(GlobalniID.Lokace_Hangout_Priv_SantoSerenity, GetLocalizedText("LocKey#15142370"), GetLocalizedText("LocKey#15142293"), !peveckaAktivni && privBDSantoSerenity, InkAtlasSoubor.Prazdne, n"", true, true, false, 1, true, GenderType.None, false, 1, true)
		]),
		DataLokace.Kt(GlobalniID.Lokace_Kont_Date, GetLocalizedText("LocKey#15142231"), GetLocalizedText("LocKey#15142232"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_02, n"key_date", false, true, false, [
			DataLokace.Lk(GlobalniID.Lokace_Date_Empathy, GetLocalizedText("LocKey#15142215"), GetLocalizedText("LocKey#15142216"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_03, n"key_date_empathy", false, true, sts_cct_dtn_03, 1, true, GenderType.None, false, -1, true)
		]),
		DataLokace.Kt(GlobalniID.Lokace_Kont_Romantic, GetLocalizedText("LocKey#15142233"), GetLocalizedText("LocKey#15142234"), true, InkAtlasSoubor.LizziesBDs_Lokace_K_02, n"key_romantic", false, false, false, [
			DataLokace.Lk(GlobalniID.Lokace_LagunaBend, GetLocalizedText("LocKey#15142010"), GetLocalizedText("LocKey#15142062"), nahotaJePovolena && (zobrazitPohlavi != 1), InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_sq030", true, false, sq030_active, 1, false, GenderType.Female, false, 4, false),
			DataLokace.Lk(GlobalniID.Lokace_TrailerPark, GetLocalizedText("LocKey#15142058"), GetLocalizedText("LocKey#15142064"), nahotaJePovolena && !peveckaAktivni && (zobrazitPohlavi != 2), InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_sq029", false, true, false, 1, false, GenderType.Male, false, -1, false),
			DataLokace.Lk(GlobalniID.Lokace_Backstage, GetLocalizedText("LocKey#15142079"), GetLocalizedText("LocKey#15142080"), nahotaJePovolena && !peveckaAktivni && (zobrazitPohlavi != 1), InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_q108", false, false, false, 1, false, GenderType.Female, false, 9, false),
			DataLokace.Lk(GlobalniID.Lokace_Basilisk, GetLocalizedText("LocKey#15142091"), GetLocalizedText("LocKey#15142092"), nahotaJePovolena && !peveckaAktivni && (zobrazitPohlavi != 1), InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_sq027", false, false, false, 1, false, GenderType.Female, false, 10, false),
			DataLokace.Lk(GlobalniID.Lokace_Cinema, GetLocalizedText("LocKey#15142138"), GetLocalizedText("LocKey#15142139"), nahotaJePovolena && !peveckaAktivni && (zobrazitPohlavi != 1), InkAtlasSoubor.LizziesBDs_Lokace_02, n"key_cinema", true, false, cinemaCond, 1, false, GenderType.Female, false, 6, false),
			DataLokace.Lk(GlobalniID.Lokace_CinemaKissing, GetLocalizedText("LocKey#15142142"), GetLocalizedText("LocKey#15142143"), !peveckaAktivni && (zobrazitPohlavi != 1), InkAtlasSoubor.LizziesBDs_Lokace_02, n"key_cinema", false, false, cinemaCond, 1, false, GenderType.Female, false, 6, false),
			DataLokace.Lk(GlobalniID.Lokace_BoatRomance, GetLocalizedText("LocKey#15142140"), GetLocalizedText("LocKey#15142141"), nahotaJePovolena && !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_02, n"key_sq028", false, true, akt1Dokoncen, 1, false, GenderType.None, false, -1, false),
			DataLokace.Lk(GlobalniID.Lokace_Konpeki, GetLocalizedText("LocKey#15142175"), GetLocalizedText("LocKey#15142176"), nahotaJePovolena && !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_03, n"key_konpeki", true, true, akt1Dokoncen, 1, false, GenderType.None, false, 6, false),
			DataLokace.Lk(GlobalniID.Lokace_BoatGuitar, GetLocalizedText("LocKey#15142173"), GetLocalizedText("LocKey#15142174"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_03, n"key_boat_guitar", false, false, false, 1, true, GenderType.None, false, -1, true),
			DataLokace.Lk(GlobalniID.Lokace_Camping, GetLocalizedText("LocKey#15142190"), GetLocalizedText("LocKey#15142191"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_03, n"key_camping", false, false, false, 1, true, GenderType.Female, false, -1, true)
		]),
		DataLokace.Kt(GlobalniID.Lokace_Kont_Concert, GetLocalizedText("LocKey#15142241"), GetLocalizedText("LocKey#15142242"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_03, n"key_concert", false, true, false, [
			DataLokace.Lk(GlobalniID.Lokace_Concert_RedDirt, GetLocalizedText("LocKey#15142243"), "", !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_03, n"key_concert_reddirt", false, true, sq011_active, 4, false, GenderType.None, true, -1, true)
		]),

		DataLokace.Lk(GlobalniID.Lokace_Beach, GetLocalizedText("LocKey#15142253"), GetLocalizedText("LocKey#15142254"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_05, n"key_beach", false, true, false, 6, true, GenderType.None, true, -1, true),
		DataLokace.Lk(GlobalniID.Lokace_Bar, GetLocalizedText("LocKey#15142099"), GetLocalizedText("LocKey#15142100"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_02, n"key_bar", false, true, false, 1, true, GenderType.None, false, -1, true),
		DataLokace.Lk(GlobalniID.Lokace_Rollercoaster, GetLocalizedText("LocKey#15142122"), GetLocalizedText("LocKey#15142123"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_02, n"key_rollercoaster", false, false, rollercoasterOpraven, 1, true, GenderType.None, false, -1, true),
		DataLokace.Lk(GlobalniID.Lokace_Moon, GetLocalizedText("LocKey#15142134"), GetLocalizedText("LocKey#15142135"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_03, n"key_moon", false, false, false, 1, true, GenderType.None, false, 7, true),
		DataLokace.Lk(GlobalniID.Lokace_MoonExt, GetLocalizedText("LocKey#15142264"), GetLocalizedText("LocKey#15142265"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_06, n"key_moon_ext", false, true, false, 1, true, GenderType.None, false, 7, true),
		DataLokace.Lk(GlobalniID.Lokace_Dollhouse, GetLocalizedText("LocKey#15142192"), GetLocalizedText("LocKey#15142193"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_03, n"key_dollhouse", false, false, q105_done, 1, true, GenderType.None, false, -1, true),
		DataLokace.Lk(GlobalniID.Lokace_FerrisWheel, GetLocalizedText("LocKey#15142331"), GetLocalizedText("LocKey#15142332"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_06, n"key_ferriswheel", false, false, ma_pac_cvi_12_finished, 1, true, GenderType.None, false, -1, true),
		DataLokace.Lk(GlobalniID.Lokace_AV, GetLocalizedText("LocKey#15142359"), GetLocalizedText("LocKey#15142360"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_07, n"key_av", false, false, false, 1, true, GenderType.None, false, -1, true),
	
		DataLokace.Kt(GlobalniID.Lokace_Kont_PONC, GetLocalizedText("LocKey#15142322"), GetLocalizedText("LocKey#15142323"), poncData && nahotaJePovolena && !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_06, n"key_ponc", false, true, false, [
			DataLokace.Lk(GlobalniID.Lokace_PONC_JigJig, GetLocalizedText("LocKey#15142007"), "", nahotaJePovolena && !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_jigjig", false, false, false, 2, false, GenderType.None, true, 3, false),
			DataLokace.Lk(GlobalniID.Lokace_PONC_DarkMatter, GetLocalizedText("LocKey#15142008"), "", nahotaJePovolena && !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_01, n"key_darkmatter", false, false, false, 2, false, GenderType.None, true, 3, false)
		]),
		DataLokace.Kt(GlobalniID.Lokace_Kont_Cyberpsycho, GetLocalizedText("LocKey#15142361"), GetLocalizedText("LocKey#15142362"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_07, n"key_cyberpsycho", false, true, false, [
			DataLokace.LS(GlobalniID.Lokace_Cyberpsycho_Hey_Spr_04, GetLocalizedText("LocKey#15142363"), GetLocalizedText("LocKey#15805"), true, InkAtlasSoubor.LizziesBDs_Lokace_Psycho_01, n"key_cyberpsycho_hey_spr_04", ma_hey_spr_04_done, false, "Others_Edgerunners", true)
		]),
		DataLokace.Kt(GlobalniID.Lokace_Kont_Relaxing, GetLocalizedText("LocKey#15142072"), GetLocalizedText("LocKey#15142078"), !peveckaAktivni, InkAtlasSoubor.LizziesBDs_Lokace_K_03, n"key_relaxing", false, false, false, [
			DataLokace.LS(GlobalniID.Lokace_Zen_Earth, GetLocalizedText("LocKey#15142073"), "", true, InkAtlasSoubor.LizziesBDs_Lokace_Zen, n"key_earth", false, false, "Zen_Earth", false),
			DataLokace.LS(GlobalniID.Lokace_Zen_Water, GetLocalizedText("LocKey#15142074"), "", true, InkAtlasSoubor.LizziesBDs_Lokace_Zen, n"key_water", false, false, "Zen_Water", false),
			DataLokace.LS(GlobalniID.Lokace_Zen_Fire, GetLocalizedText("LocKey#15142075"), "", true, InkAtlasSoubor.LizziesBDs_Lokace_Zen, n"key_fire", false, false, "Zen_Fire", false),
			DataLokace.LS(GlobalniID.Lokace_Zen_Air, GetLocalizedText("LocKey#15142076"), "", true, InkAtlasSoubor.LizziesBDs_Lokace_Zen, n"key_air", false, false, "Zen_Air", false)
		]),
		DataLokace.Kt(GlobalniID.Lokace_Kont_Various, GetLocalizedText("LocKey#15142081"), GetLocalizedText("LocKey#15142082"), !peveckaAktivni, InkAtlasSoubor.Prazdne, n"", false, false, false, [
			DataLokace.LS(GlobalniID.Lokace_Ostatni_Edgerunners, GetLocalizedText("LocKey#15142083"), GetLocalizedText("LocKey#15142084"), true, InkAtlasSoubor.LizziesBDs_Lokace_K_04, n"key_edgerunners", false, false, "Others_Edgerunners", false),
			DataLokace.LS(GlobalniID.Lokace_Ostatni_Lizzy, GetLocalizedText("LocKey#15142085"), GetLocalizedText("LocKey#15142086"), true, InkAtlasSoubor.LizziesBDs_Lokace_K_04, n"key_lizzy", q303_done, false, "Others_Lizzy", false),
			DataLokace.LS(GlobalniID.Lokace_Ostatni_LetYouDown, GetLocalizedText("LocKey#15142178"), GetLocalizedText("LocKey#15142179"), true, InkAtlasSoubor.LizziesBDs_Lokace_K_04, n"key_letyoudown", false, letYouDownData, "Others_LetYouDown", false),
			DataLokace.LS(GlobalniID.Lokace_Ostatni_IReallyWantToStayAtYourHouse, GetLocalizedText("LocKey#15142182"), GetLocalizedText("LocKey#15142183"), true, InkAtlasSoubor.LizziesBDs_Lokace_K_04, n"key_ireallywanttostayatyourhouse", false, irwtsayhData, "Others_IReallyWantToStayAtYourHouse", false),
			DataLokace.LS(GlobalniID.Lokace_Ostatni_Ambush, GetLocalizedText("LocKey#15142188"), GetLocalizedText("LocKey#15142189"), ep1JeInstalovane, InkAtlasSoubor.LizziesBDs_Lokace_K_05, n"key_ambush", mq301_finished, false, "Others_Ambush", true),
			DataLokace.LS(GlobalniID.Lokace_Ostatni_DashiParade, GetLocalizedText("LocKey#15142219"), GetLocalizedText("LocKey#15142220"), true, InkAtlasSoubor.LizziesBDs_Lokace_K_05, n"key_dashiparade", q112_done, false, "Others_DashiParade", true),
			DataLokace.LS(GlobalniID.Lokace_Ostatni_UsCracks, GetLocalizedText("LocKey#15142221"), GetLocalizedText("LocKey#15142222"), ep1JeInstalovane, InkAtlasSoubor.LizziesBDs_Lokace_K_05, n"key_uscracks", uscracksCond, false, "Others_UsCracks", true),
			DataLokace.LS(GlobalniID.Lokace_Ostatni_Tutorial, GetLocalizedText("LocKey#15142275"), GetLocalizedText("LocKey#15142276"), true, InkAtlasSoubor.LizziesBDs_Lokace_K_06, n"key_tutorial", false, false, "Others_Tutorial", true),
			DataLokace.LL(GlobalniID.Lokace_Ostatni_RoofPic, GetLocalizedText("LocKey#15142290"), GetLocalizedText("LocKey#15142291"), 7),
			DataLokace.LS(GlobalniID.Lokace_Ostatni_CHIAA, GetLocalizedText("LocKey#15142334"), GetLocalizedText("LocKey#15142335"), true, InkAtlasSoubor.LizziesBDs_Lokace_K_07, n"key_chiaa", false, chiaaData, "Others_CHIAA", true)
		])
	];

	return pole;
}

public func DataPoleBarLokace(ep1JeInstalovane: Bool, questsSystem: wref<QuestsSystem>) -> array<ref<DataLokace>> {
	let bezPodminek: Bool = questsSystem.GetFact(n"lizzies_bds_no_conds") == 0;
	let sts_ep1_06_active: Bool = bezPodminek && questsSystem.GetFact(n"sts_ep1_06_active") == 1;

	let pole: array<ref<DataLokace>> = [
		DataLokace.LB(GlobalniID.BarLokace_Wbr_Hil_01, GetLocalizedText("LocKey#15142119"), InkAtlasSoubor.LizziesBDs_Lokace_Bar, n"key_charterhill_01", true, false),
		DataLokace.LB(GlobalniID.BarLokace_Hey_Spr_01, GetLocalizedText("LocKey#15142118"), InkAtlasSoubor.LizziesBDs_Lokace_Bar, n"key_wellsprings_01", true, false),
		DataLokace.LB(GlobalniID.BarLokace_Cct_Dtn_01, GetLocalizedText("LocKey#15142121"), InkAtlasSoubor.LizziesBDs_Lokace_Bar, n"key_downtown_01", true, false),
		DataLokace.LB(GlobalniID.BarLokace_Wat_Kab_01, GetLocalizedText("LocKey#15142177"), InkAtlasSoubor.Assets_27, n"l_afterlife_full", true, false),
		DataLokace.LB(GlobalniID.BarLokace_Hey_Spr_02, GetLocalizedText("LocKey#15142184"), InkAtlasSoubor.LizziesBDs_Lokace_Bar, n"key_wellsprings_02", true, false),
		DataLokace.LB(GlobalniID.BarLokace_Cct_Cpz_01, GetLocalizedText("LocKey#15142185"), InkAtlasSoubor.LizziesBDs_Lokace_Bar, n"key_corpo_plaza_01", true, false),
		DataLokace.LB(GlobalniID.BarLokace_Std_Rcr_01, GetLocalizedText("LocKey#15142186"), InkAtlasSoubor.LizziesBDs_Lokace_Bar, n"key_rancho_coronado_01", true, false),
		DataLokace.LB(GlobalniID.BarLokace_Wbr_Jpn_01, GetLocalizedText("LocKey#15142187"), InkAtlasSoubor.LizziesBDs_Lokace_Bar, n"key_japantown_01", true, false),
		DataLokace.LB(GlobalniID.BarLokace_Pac_EP1_01, GetLocalizedText("LocKey#15142320"), InkAtlasSoubor.Assets_EP1_10, n"l_heavy_hearts_full", ep1JeInstalovane, sts_ep1_06_active),
		DataLokace.LB(GlobalniID.BarLokace_Wbr_Jpn_02, GetLocalizedText("LocKey#15142321"), InkAtlasSoubor.Assets_27, n"l_atlantis_full", true, false),
		DataLokace.LB(GlobalniID.BarLokace_Wbr_Jpn_03, GetLocalizedText("LocKey#15142330"), InkAtlasSoubor.LizziesBDs_Lokace_Bar, n"key_japantown_03", true, false)
	];

	return pole;
};

public func DataPoleHudba() -> array<ref<DataHudby>> = [
	DataHudby.Pridat(-1, "", false),
	//new DataHudby(0, GetLocalizedText("LocKey#15143395"), false), //Vychozi
	DataHudby.Pridat(1, GetLocalizedText("LocKey#15143396"), true), //Pokracovat
	DataHudby.Pridat(2, GetLocalizedText("LocKey#15143397"), false), //Bez hudby
	DataHudby.Pridat(3, GetLocalizedText("LocKey#15143398"), false), //Midnight Eye
	DataHudby.Pridat(4, GetLocalizedText("LocKey#15143399"), false), //Laguna Bend
	DataHudby.Pridat(5, GetLocalizedText("LocKey#15143400"), false), //Hole In The Sun
	DataHudby.Pridat(6, GetLocalizedText("LocKey#15143401"), false), //Blistering Love
	DataHudby.Pridat(7, GetLocalizedText("LocKey#15143402"), false), //I Really Want To Stay At Your House
	DataHudby.Pridat(8, GetLocalizedText("LocKey#15143403"), false), //Let You Down
	DataHudby.Pridat(9, GetLocalizedText("LocKey#15143404"), false), //Hammer Backstage
	DataHudby.Pridat(10, GetLocalizedText("LocKey#15143405"), false), //Basilisk
	DataHudby.Pridat(11, GetLocalizedText("LocKey#15143395"), false), //This Fffire
	DataHudby.Pridat(12, GetLocalizedText("LocKey#15143409"), false), //Zen
	DataHudby.Pridat(13, GetLocalizedText("LocKey#15143411"), false), //Bells of Laguna Bend
	DataHudby.Pridat(14, GetLocalizedText("LocKey#15143412"), false), //Dollhouse
	DataHudby.Pridat(15, GetLocalizedText("LocKey#15143459"), false), //Dive
	DataHudby.Pridat(16, GetLocalizedText("LocKey#15143481"), false) //Circus Minimus
];

public func DataPoleOblicejeNazvy() -> DataObliceje {
	let d: DataObliceje;
	
	d.KlidNazev = [
		GetLocalizedText("LocKey#15143248"), //"Fear reaction");
		GetLocalizedText("LocKey#15143249"), //"Dead");
		GetLocalizedText("LocKey#15143250"), //"Interested");
		GetLocalizedText("LocKey#15143251"), //"Disappointed");
		GetLocalizedText("LocKey#15143252"), //"Sadness");
		GetLocalizedText("LocKey#15143253"), //"Pain");
		GetLocalizedText("LocKey#15143254"), //"Tiredness");
		GetLocalizedText("LocKey#15143255"), //"Neutral");
		GetLocalizedText("LocKey#15143256"), //"Disgust");
		GetLocalizedText("LocKey#15143257"), //"Disinterested");
		GetLocalizedText("LocKey#15143258"), //"Anger");
		GetLocalizedText("LocKey#15143259"), //"Aggression");
		GetLocalizedText("LocKey#15143260"), //"Exertion");
		GetLocalizedText("LocKey#15143261"), //"Fear");
		GetLocalizedText("LocKey#15143262"), //"Happy");
		GetLocalizedText("LocKey#15143263"), //"Joy");
		GetLocalizedText("LocKey#15143264"), //"Nervous");
		GetLocalizedText("LocKey#15143265"), //"Surprise");
		GetLocalizedText("LocKey#15143266"), //"Unconscious");
		GetLocalizedText("LocKey#15143267") //"Sex");
	];

	d.PozaNazev = [
		GetLocalizedText("LocKey#15143268"), //"None");
		GetLocalizedText("LocKey#15143269"), //"Joy - Pleased");
		GetLocalizedText("LocKey#15143270"), //"Joy - Full");
		GetLocalizedText("LocKey#15143271"), //"Joy - Fake smile");
		GetLocalizedText("LocKey#15143272"), //"Joy - Default");
		GetLocalizedText("LocKey#15143273"), //"Sadness - Full");
		GetLocalizedText("LocKey#15143274"), //"Sadness - Overwhelmed");
		GetLocalizedText("LocKey#15143275"), //"Sadness - Bored");
		GetLocalizedText("LocKey#15143276"), //"Sadness - Default");
		GetLocalizedText("LocKey#15143277"), //"Disgust - Repulsion");
		GetLocalizedText("LocKey#15143278"), //"Disgust - Contempt");
		GetLocalizedText("LocKey#15143279"), //"Disgust - Default");
		GetLocalizedText("LocKey#15143280"), //"Disappointed - Offended");
		GetLocalizedText("LocKey#15143281"), //"Disappointed - Default");
		GetLocalizedText("LocKey#15143282"), //"Nervous - Full");
		GetLocalizedText("LocKey#15143283"), //"Nervous - Default");
		GetLocalizedText("LocKey#15143284"), //"Interested - Awed");
		GetLocalizedText("LocKey#15143285"), //"Interested - Focused");
		GetLocalizedText("LocKey#15143286"), //"Interested - Confident");
		GetLocalizedText("LocKey#15143287"), //"Interested - Cautious");
		GetLocalizedText("LocKey#15143288"), //"Interested - Respectful");
		GetLocalizedText("LocKey#15143289"), //"Interested - Suspicious");
		GetLocalizedText("LocKey#15143290"), //"Interested - Aiming weapon");
		GetLocalizedText("LocKey#15143291"), //"Interested - Default");
		GetLocalizedText("LocKey#15143292"), //"Unconscious - Braindance");
		GetLocalizedText("LocKey#15143293"), //"Unconscious - Drunk");
		GetLocalizedText("LocKey#15143294"), //"Unconscious - Stoned");
		GetLocalizedText("LocKey#15143295"), //"Unconscious - Default");
		GetLocalizedText("LocKey#15143296"), //"Tiredness - Sleeping");
		GetLocalizedText("LocKey#15143297"), //"Tiredness - Default");
		GetLocalizedText("LocKey#15143298"), //"Neutral - Default");
		GetLocalizedText("LocKey#15143299"), //"Pain - Default");
		GetLocalizedText("LocKey#15143300"), //"Pain - Agony");
		GetLocalizedText("LocKey#15143301"), //"Exertion - Default");
		GetLocalizedText("LocKey#15143302"), //"Exertion - Full");
		GetLocalizedText("LocKey#15143303"), //"Disinterested - Default");
		GetLocalizedText("LocKey#15143304"), //"Disinterested - Uncertain");
		GetLocalizedText("LocKey#15143305"), //"Disinterested - Sceptical");
		GetLocalizedText("LocKey#15143306"), //"Fear - Default");
		GetLocalizedText("LocKey#15143307"), //"Fear - Before death");
		GetLocalizedText("LocKey#15143308"), //"Fear - Worried");
		GetLocalizedText("LocKey#15143309"), //"Fear - Paralyzed");
		GetLocalizedText("LocKey#15143310"), //"Surprise - Default");
		GetLocalizedText("LocKey#15143311"), //"Surprise - Shock");
		GetLocalizedText("LocKey#15143312"), //"Aggression - Default");
		GetLocalizedText("LocKey#15143313"), //"Aggression - Furious");
		GetLocalizedText("LocKey#15143314"), //"Anger - Default");
		GetLocalizedText("LocKey#15143315"), //"Anger - Defensive");
		GetLocalizedText("LocKey#15143316"), //"Anger - Full");
		GetLocalizedText("LocKey#15143317"), //"Happy - Default");
		GetLocalizedText("LocKey#15143318"), //"Happy - Charming");
		GetLocalizedText("LocKey#15143319"), //"Happy - Excited");
		GetLocalizedText("LocKey#15143320"), //"Happy - Thrilled");
		GetLocalizedText("LocKey#15143321"), //"Sex - Default");
		GetLocalizedText("LocKey#15143322"), //"Sex - Intense");
		GetLocalizedText("LocKey#15143323") //"Dead - Default");
	];

	return d;
}

public func DataPoleOblicejeAnimace(klid: Int32, poza: Int32) -> array<CName> {
	let klidAnimaceZena: CName;
	let klidAnimaceMuz: CName;
	let pozaAnimaceZena: CName;
	let pozaAnimaceMuz: CName;

	switch klid {
		case 0: klidAnimaceZena = n"idle__fear_reaction__female"; klidAnimaceMuz = n"idle__fear_reaction__male"; break;
		case 1: klidAnimaceZena = n"idle__dead__female"; klidAnimaceMuz = n"idle__dead__male"; break;
		case 2: klidAnimaceZena = n"idle__interested__female"; klidAnimaceMuz = n"idle__interested__male"; break;
		case 3: klidAnimaceZena = n"idle__disappointed__female"; klidAnimaceMuz = n"idle__disappointed__male"; break;
		case 4: klidAnimaceZena = n"idle__sadness__female"; klidAnimaceMuz = n"idle__sadness__male"; break;
		case 5: klidAnimaceZena = n"idle__pain__female"; klidAnimaceMuz = n"idle__pain__male"; break;
		case 6: klidAnimaceZena = n"idle__tiredness__female"; klidAnimaceMuz = n"idle__tiredness__male"; break;
		case 7: klidAnimaceZena = n"idle__neutral__female"; klidAnimaceMuz = n"idle__neutral__male"; break;
		case 8: klidAnimaceZena = n"idle__disgust__female"; klidAnimaceMuz = n"idle__disgust__male"; break;
		case 9: klidAnimaceZena = n"idle__disinterested__female"; klidAnimaceMuz = n"idle__disinterested__male"; break;
		case 10: klidAnimaceZena = n"idle__anger__female"; klidAnimaceMuz = n"idle__anger__male"; break;
		case 11: klidAnimaceZena = n"idle__aggression__female"; klidAnimaceMuz = n"idle__aggression__male"; break;
		case 12: klidAnimaceZena = n"idle__exertion__female"; klidAnimaceMuz = n"idle__exertion__male"; break;
		case 13: klidAnimaceZena = n"idle__fear__female"; klidAnimaceMuz = n"idle__fear__male"; break;
		case 14: klidAnimaceZena = n"idle__happy__female"; klidAnimaceMuz = n"idle__happy__male"; break;
		case 15: klidAnimaceZena = n"idle__joy__female"; klidAnimaceMuz = n"idle__joy__male"; break;
		case 16: klidAnimaceZena = n"idle__nervous__female"; klidAnimaceMuz = n"idle__nervous__male"; break;
		case 17: klidAnimaceZena = n"idle__surprise__female"; klidAnimaceMuz = n"idle__surprise__male"; break;
		case 18: klidAnimaceZena = n"idle__unconscious__female"; klidAnimaceMuz = n"idle__unconscious__male"; break;
		case 19: klidAnimaceZena = n"idle__sex__female"; klidAnimaceMuz = n"idle__sex__male"; break;
	}

	switch poza {
		case 0: pozaAnimaceZena = n"None"; pozaAnimaceMuz = n"None"; break;
		case 1: pozaAnimaceZena = n"idle__joy__female__pleased"; pozaAnimaceMuz = n"idle__joy__male__pleased"; break;
		case 2: pozaAnimaceZena = n"idle__joy__female__full"; pozaAnimaceMuz = n"idle__joy__male__full"; break;
		case 3: pozaAnimaceZena = n"idle__joy__female__fake_smile"; pozaAnimaceMuz = n"idle__joy__male__fake_smile"; break;
		case 4: pozaAnimaceZena = n"idle__joy__female__default"; pozaAnimaceMuz = n"idle__joy__male__default"; break;
		case 5: pozaAnimaceZena = n"idle__sadness__female__full"; pozaAnimaceMuz = n"idle__sadness__male__full"; break;
		case 6: pozaAnimaceZena = n"idle__sadness__female__overwhelmed"; pozaAnimaceMuz = n"idle__sadness__male__overwhelmed"; break;
		case 7: pozaAnimaceZena = n"idle__sadness__female__bored"; pozaAnimaceMuz = n"idle__sadness__male__bored"; break;
		case 8: pozaAnimaceZena = n"idle__sadness__female__default"; pozaAnimaceMuz = n"idle__sadness__male__default"; break;
		case 9: pozaAnimaceZena = n"idle__disgust__female__repulsion"; pozaAnimaceMuz = n"idle__disgust__male__repulsion"; break;
		case 10: pozaAnimaceZena = n"idle__disgust__female__contempt"; pozaAnimaceMuz = n"idle__disgust__male__contempt"; break;
		case 11: pozaAnimaceZena = n"idle__disgust__female__default"; pozaAnimaceMuz = n"idle__disgust__male__default"; break;
		case 12: pozaAnimaceZena = n"idle__disappointed__female__offended"; pozaAnimaceMuz = n"idle__disappointed__male__offended"; break;
		case 13: pozaAnimaceZena = n"idle__disappointed__female__default"; pozaAnimaceMuz = n"idle__disappointed__male__default"; break;
		case 14: pozaAnimaceZena = n"idle__nervous__female__full"; pozaAnimaceMuz = n"idle__nervous__male__full"; break;
		case 15: pozaAnimaceZena = n"idle__nervous__female__default"; pozaAnimaceMuz = n"idle__nervous__male__default"; break;
		case 16: pozaAnimaceZena = n"idle__interested__female__awed"; pozaAnimaceMuz = n"idle__interested__male__awed"; break;
		case 17: pozaAnimaceZena = n"idle__interested__female__focused"; pozaAnimaceMuz = n"idle__interested__male__focused"; break;
		case 18: pozaAnimaceZena = n"idle__interested__female__confident"; pozaAnimaceMuz = n"idle__interested__male__confident"; break;
		case 19: pozaAnimaceZena = n"idle__interested__female__cautious"; pozaAnimaceMuz = n"idle__interested__male__cautious"; break;
		case 20: pozaAnimaceZena = n"idle__interested__female__respectful"; pozaAnimaceMuz = n"idle__interested__male__respectful"; break;
		case 21: pozaAnimaceZena = n"idle__interested__female__suspicious"; pozaAnimaceMuz = n"idle__interested__male__suspicious"; break;
		case 22: pozaAnimaceZena = n"idle__interested__female__aiming_weapon"; pozaAnimaceMuz = n"idle__interested__male__aiming_weapon"; break;
		case 23: pozaAnimaceZena = n"idle__interested__female__default"; pozaAnimaceMuz = n"idle__interested__male__default"; break;
		case 24: pozaAnimaceZena = n"idle__unconscious__female__braindance"; pozaAnimaceMuz = n"idle__unconscious__male__braindance"; break;
		case 25: pozaAnimaceZena = n"idle__unconscious__female__drunk"; pozaAnimaceMuz = n"idle__unconscious__male__drunk"; break;
		case 26: pozaAnimaceZena = n"idle__unconscious__female__stoned"; pozaAnimaceMuz = n"idle__unconscious__male__stoned"; break;
		case 27: pozaAnimaceZena = n"idle__unconscious__female__default"; pozaAnimaceMuz = n"idle__unconscious__male__default"; break;
		case 28: pozaAnimaceZena = n"idle__tiredness__female__sleeping"; pozaAnimaceMuz = n"idle__tiredness__male__sleeping"; break;
		case 29: pozaAnimaceZena = n"idle__tiredness__female__default"; pozaAnimaceMuz = n"idle__tiredness__male__default"; break;
		case 30: pozaAnimaceZena = n"idle__neutral__female__default"; pozaAnimaceMuz = n"idle__neutral__male__default"; break;
		case 31: pozaAnimaceZena = n"idle__pain__female__default"; pozaAnimaceMuz = n"idle__pain__male__default"; break;
		case 32: pozaAnimaceZena = n"idle__pain__female__agony"; pozaAnimaceMuz = n"idle__pain__male__agony"; break;
		case 33: pozaAnimaceZena = n"idle__exertion__female__default"; pozaAnimaceMuz = n"idle__exertion__male__default"; break;
		case 34: pozaAnimaceZena = n"idle__exertion__female__full"; pozaAnimaceMuz = n"idle__exertion__male__full"; break;
		case 35: pozaAnimaceZena = n"idle__disinterested__female__default"; pozaAnimaceMuz = n"idle__disinterested__male__default"; break;
		case 36: pozaAnimaceZena = n"idle__disinterested__female__uncertain"; pozaAnimaceMuz = n"idle__disinterested__male__uncertain"; break;
		case 37: pozaAnimaceZena = n"idle__disinterested__female__sceptical"; pozaAnimaceMuz = n"idle__disinterested__male__sceptical"; break;
		case 38: pozaAnimaceZena = n"idle__fear__female__default"; pozaAnimaceMuz = n"idle__fear__male__default"; break;
		case 39: pozaAnimaceZena = n"idle__fear__female__before_death"; pozaAnimaceMuz = n"idle__fear__male__before_death"; break;
		case 40: pozaAnimaceZena = n"idle__fear__female__worried"; pozaAnimaceMuz = n"idle__fear__male__worried"; break;
		case 41: pozaAnimaceZena = n"idle__fear__female__paralyzed"; pozaAnimaceMuz = n"idle__fear__male__paralyzed"; break;
		case 42: pozaAnimaceZena = n"idle__surprise__female__default"; pozaAnimaceMuz = n"idle__surprise__male__default"; break;
		case 43: pozaAnimaceZena = n"idle__surprise__female__shock"; pozaAnimaceMuz = n"idle__surprise__male__shock"; break;
		case 44: pozaAnimaceZena = n"idle__aggression__female__default"; pozaAnimaceMuz = n"idle__aggression__male__default"; break;
		case 45: pozaAnimaceZena = n"idle__aggression__female__furious"; pozaAnimaceMuz = n"idle__aggression__male__furious"; break;
		case 46: pozaAnimaceZena = n"idle__anger__female__default"; pozaAnimaceMuz = n"idle__anger__male__default"; break;
		case 47: pozaAnimaceZena = n"idle__anger__female__defensive"; pozaAnimaceMuz = n"idle__anger__male__defensive"; break;
		case 48: pozaAnimaceZena = n"idle__anger__female__full"; pozaAnimaceMuz = n"idle__anger__male__full"; break;
		case 49: pozaAnimaceZena = n"idle__happy__female__default"; pozaAnimaceMuz = n"idle__happy__male__default"; break;
		case 50: pozaAnimaceZena = n"idle__happy__female__charming"; pozaAnimaceMuz = n"idle__happy__male__charming"; break;
		case 51: pozaAnimaceZena = n"idle__happy__female__excited"; pozaAnimaceMuz = n"idle__happy__male__excited"; break;
		case 52: pozaAnimaceZena = n"idle__happy__female__thrilled"; pozaAnimaceMuz = n"idle__happy__male__thrilled"; break;
		case 53: pozaAnimaceZena = n"idle__sex__female__default"; pozaAnimaceMuz = n"idle__sex__male__default"; break;
		case 54: pozaAnimaceZena = n"idle__sex__female__intense"; pozaAnimaceMuz = n"idle__sex__male__intense"; break;
		case 55: pozaAnimaceZena = n"idle__dead__female__default"; pozaAnimaceMuz = n"idle__dead__male__default"; break;
		//case 56: pozaAnimaceZena = n""; pozaAnimaceMuz = n"idle__disinterested__male__dismissive"; break;
	}

	return [klidAnimaceZena, klidAnimaceMuz, pozaAnimaceZena, pozaAnimaceMuz];
}

public func DataEntit(vybranaPostava: GlobalniID, vybranyVzhled: Int32, pohlavi: GenderType) -> ResRef {
	let cestaKEnt: ResRef = r"";

	switch vybranaPostava {
		case GlobalniID.Postava_Female_V: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\player\\player_wa_tpp_cutscene.ent"; break;
		case GlobalniID.Postava_Judy_Alvarez: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\judy.ent"; break;
		case GlobalniID.Postava_Panam_Palmer: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\panam.ent"; break;
		case GlobalniID.Postava_Skye: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q105_yakuza_dolls_fem_01.ent"; break;
		case GlobalniID.Postava_Evelyn_Parker: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\evelyn.ent"; break;
		case GlobalniID.Postava_Cheri_Nowlin: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q105_yakuza_manager.ent"; break;
		case GlobalniID.Postava_Altiera_Alt_Cunningham: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\alt.ent"; break;
		case GlobalniID.Postava_Elizabeth_Peralez: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\elizabeth_peralez.ent"; break;
		case GlobalniID.Postava_Hanako_Arasaka: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\hanako.ent"; break;
		case GlobalniID.Postava_Ruby_Collins: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sq031_streapper.ent"; break;
		case GlobalniID.Postava_Maiko_Maeda: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\maiko.ent"; break;
		case GlobalniID.Postava_T_Bug: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\tbug.ent"; break;
		case GlobalniID.Postava_Misty_Olszewski: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\misty.ent"; break;
		case GlobalniID.Postava_Iris_Tanner: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_bls_ina_06_tanner.ent"; break;
		case GlobalniID.Postava_Roxanne_Sumner: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\roxanne.ent"; break;
		case GlobalniID.Postava_Karina_Lee: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\karina_lee.ent"; break;
		case GlobalniID.Postava_Gillean_Jordan: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gillean_jordan.ent"; break;
		case GlobalniID.Postava_Sandra_Dorsett: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\q305_sandra_dorsett_ep1.ent"; break;
		case GlobalniID.Postava_Aurore_Cassel: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\bella.ent"; break;
		case GlobalniID.Postava_Rosalind_Myers: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\myers.ent"; break;
		case GlobalniID.Postava_Lina_Malina: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\mq303_ent_lina.ent"; break;
		case GlobalniID.Postava_Angelica_Angie_Whelan: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\mq306_angie.ent"; break;
		case GlobalniID.Postava_Stella_Ramos: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_10_informer.ent"; break;
		case GlobalniID.Postava_Claire_Russell: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\claire.ent"; break;
		case GlobalniID.Postava_Rachel_Casich: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sq023_rachel.ent"; break;
		case GlobalniID.Postava_Elisabeth_Lizzy_Wizzy_Wissenfurth: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\lizzy_wizzy.ent"; break;
		case GlobalniID.Postava_Alena_Alex_Xenakis: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\alex.ent"; break;
		case GlobalniID.Postava_Georgina_Zembinsky: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_06_georgina.ent"; break;
		case GlobalniID.Postava_Ruth_Dzeng: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ruth_dzeng.ent"; break;
		case GlobalniID.Postava_Denny: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\denny.ent"; break;
		case GlobalniID.Postava_Emilie_Massenat: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q110_placide_girlfriend.ent"; break;
		case GlobalniID.Postava_Beatrice_Ellen_8ug8ear_Trieste: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_hey_rey_09_net.ent"; break;
		case GlobalniID.Postava_Dakota_Smith: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\dakota_smith.ent"; break;
		case GlobalniID.Postava_Joss_Kutcher: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sq021_joss.ent"; break;
		case GlobalniID.Postava_Zuleikha_El_Ahmar: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sq023_mariah.ent"; break;
		case GlobalniID.Postava_Lucyna_Lucy_Kushinada: cestaKEnt = r"base\\characters\\custom_npc\\edgerunners_lucy\\_core\\edgerunners_lucy.ent"; break;
		case GlobalniID.Postava_Regina_Jones: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\reggie.ent"; break;
		case GlobalniID.Postava_Nika_Yankovich: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_01_nika.ent"; break;
		case GlobalniID.Postava_Theo_Price: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq037_girlfriend.ent"; break;
		case GlobalniID.Postava_Melisa_Rory: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq030_melisa.ent"; break;
		case GlobalniID.Postava_Konpeki_Receptionist_01: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q005_hotel_receptionist.ent"; break;
		case GlobalniID.Postava_Nadia_Petrova: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq010_policewoman.ent"; break;
		case GlobalniID.Postava_Joanne_Koch: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_cct_dtn_04_billy.ent"; break;
		case GlobalniID.Postava_Nadezhda_Tiurina: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\kab_04_ryoko.ent"; break;
		case GlobalniID.Postava_Anna_Hamill: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\collab\\kobalis\\sts_kab_08_anna_hamill.ent"; break;
		case GlobalniID.Postava_Farida_Nazeri: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\collab\\kobalis\\farida.ent"; break;
		case GlobalniID.Postava_Guadalupe_Alejandra_Welles: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\collab\\kobalis\\mama_welles.ent"; break;
		case GlobalniID.Postava_Clothing_Seller_Std_Arr: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\collab\\kobalis\\std_arr_clothingshop_01.ent"; break;
		case GlobalniID.Postava_NCPD_Female_01:
		case GlobalniID.Postava_NCPD_Female_02: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\corpo__ncpd_wa.ent"; break;
		case GlobalniID.Postava_Yawen_Packard: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\collab\\kobalis\\sq021_dr_mitsuko.ent"; break;
		case GlobalniID.Postava_Nele_Springer: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\collab\\kobalis\\kayla_moseki.ent"; break;
		case GlobalniID.Postava_Lauren_Costigan: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\collab\\kobalis\\sts_wbr_jpn_02_billy.ent"; break;
		case GlobalniID.Postava_Jasmine_Dixon: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\collab\\kobalis\\sts_std_rcr_02_jason_dixon.ent"; break;
		case GlobalniID.Postava_Charlene_Fox: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\wbr_jpn_prostitute_female.ent"; break;
		case GlobalniID.Postava_Brittany_Hayes: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\hey_gle_prostitute_female.ent"; break;
		case GlobalniID.Postava_JigJig_Dancer_05: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q105_jigjig_dancer.ent"; break;
		case GlobalniID.Postava_Tasha_Rodriquez: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q105_fingers_patient.ent"; break;
		case GlobalniID.Postava_Aoi_Blue_Moon_Tsuki: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sq017_blue_moon.ent"; break;
		case GlobalniID.Postava_Purple_Force: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sq017_purple_force.ent"; break;
		case GlobalniID.Postava_Akai_Red_Menace_Kyoi: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sq017_red_menace.ent"; break;
		case GlobalniID.Postava_Meredith_Stout: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\stout.ent"; break;
		case GlobalniID.Postava_Queen_Of_The_Stoop_03:
		case GlobalniID.Postava_Queen_Of_The_Stoop_07:
		case GlobalniID.Postava_Queen_Of_The_Stoop_16:
		case GlobalniID.Postava_Lowlife_Latino_01:
		case GlobalniID.Postava_Lowlife_Latino_07:
		case GlobalniID.Postava_Queen_Of_The_Stoop_12: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen__lowlife_wa.ent"; break;
		case GlobalniID.Postava_Rita_Wheeler: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\lizzies_bouncer.ent"; break;
		case GlobalniID.Postava_Susanna_Susie_Q_Quinn: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q105_lizzies_boss.ent"; break;
		case GlobalniID.Postava_Valentinos_Female_01:
		case GlobalniID.Postava_Valentinos_Female_02:
		case GlobalniID.Postava_Valentinos_Female_03:
		case GlobalniID.Postava_Valentinos_Female_04: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__valentinos_wa.ent"; break;
		case GlobalniID.Postava_6th_Street_Female_01:
		case GlobalniID.Postava_6th_Street_Female_02:
		case GlobalniID.Postava_6th_Street_Female_03:
		case GlobalniID.Postava_6th_Street_Female_04:
		case GlobalniID.Postava_6th_Street_Female_05:
		case GlobalniID.Postava_6th_Street_Female_06: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__6thstreet_wa.ent"; break;
		case GlobalniID.Postava_Nova_MacCaster:
		case GlobalniID.Postava_Maelstrom_Female_01:
		case GlobalniID.Postava_Maelstrom_Female_02:
		case GlobalniID.Postava_Maelstrom_Female_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__maelstrom_wa.ent"; break;
		case GlobalniID.Postava_Tyger_Claws_Female_01:
		case GlobalniID.Postava_Tyger_Claws_Female_02:
		case GlobalniID.Postava_Tyger_Claws_Female_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__tyger_wa.ent"; break;
		case GlobalniID.Postava_Rogue_Amendiares: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\rogue.ent"; break;
		case GlobalniID.Postava_Dao_Hyunh: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ma_hey_spr_04_ent_psycho.ent"; break;
		case GlobalniID.Postava_Song_Songbird_So_Mi: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\songbird.ent"; break;
		case GlobalniID.Postava_Zaria_Hughes: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ma_wat_nid_15_ent_psycho.ent"; break;
		case GlobalniID.Postava_Mox_Bouncer_02: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q000_corpo_mox_bouncer.ent"; break;
		case GlobalniID.Postava_Mox_Female_01:
		case GlobalniID.Postava_Mox_Female_Lvl_3_2:
		case GlobalniID.Postava_Mox_Female_02:
		case GlobalniID.Postava_Mox_Female_03:
		case GlobalniID.Postava_Mox_Female_04:
		case GlobalniID.Postava_Mox_Female_05:
		case GlobalniID.Postava_Mox_Female_06: 
		case GlobalniID.Postava_Mox_Female_Lvl_2_1: 
		case GlobalniID.Postava_Mox_Female_Lvl_2_2: 
		case GlobalniID.Postava_Mox_Female_Lvl_2_3: 
		case GlobalniID.Postava_Mox_Female_Lvl_3_1: 
		case GlobalniID.Postava_Mox_Female_Lvl_3_3: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\lizzies_mox_female.ent"; break;
		case GlobalniID.Postava_Martha_Frakes: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_hey_rey_01_martha.ent"; break;
		case GlobalniID.Postava_Ofelia_Patricia_Sirawian: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sq011_patricia.ent"; break;
		case GlobalniID.Postava_Maman_Mama_Brigitte: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\voodoo_queen.ent"; break;
		case GlobalniID.Postava_Helen_Wandoo: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_06_waitress.ent"; break;
		case GlobalniID.Postava_Dogtown_Nightlife_02:
		case GlobalniID.Postava_Dogtown_Nightlife_05:
		case GlobalniID.Postava_Dogtown_Nightlife_10:
		case GlobalniID.Postava_Imogen: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\citizen__ep1_combat_zone_nightlife_wa.ent"; break;
		case GlobalniID.Postava_Clothing_Seller_Bls_Ina:
		case GlobalniID.Postava_Yoko_Tsuru:
		case GlobalniID.Postava_Vendor_03:
		case GlobalniID.Postava_Food_Seller_Wbr_Jpn:
		case GlobalniID.Postava_Clothing_Seller_Std_Rcr:
		case GlobalniID.Postava_Clothing_Seller_Wbr_Jpn:
		case GlobalniID.Postava_Christine_Markov:
		case GlobalniID.Postava_Clothing_Seller_Wat_Nid: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\service__vendor_wa.ent"; break;
		case GlobalniID.Postava_Fiona_Vargas: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_13_fiona_wa.ent"; break;
		case GlobalniID.Postava_Wakakos_Desk_Girl: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\crowd__westbrook_japantown_wa.ent"; break;
		case GlobalniID.Postava_Aldecaldos_Female_Driver_Lvl_3_3:
		case GlobalniID.Postava_Aldecaldos_Female_01: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__aldecaldos_wa.ent"; break;
		case GlobalniID.Postava_Aldecaldos_Female_02:
		case GlobalniID.Postava_Aldecaldos_Female_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen__aldecaldos_wa.ent"; break;
		case GlobalniID.Postava_Michiko_Arasaka: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\michiko.ent"; break;
		case GlobalniID.Postava_Cynthia_Najarro: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\mq040_wife.ent"; break;
		case GlobalniID.Postava_Rebeca_Price: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_hey_spr_06_rebeca_price.ent"; break;
		case GlobalniID.Postava_Olga_Elisabeth_Longmead: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\olga_elisabeth_longmead.ent"; break;
		case GlobalniID.Postava_Laura_May:
		case GlobalniID.Postava_Sophia_Dupont: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\service__ep1_service_point_wa.ent"; break;
		case GlobalniID.Postava_Tenant_Morning_Crowd_07: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen__tenant_wa.ent"; break;
		case GlobalniID.Postava_Wakako_Okada: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\wakako_okada.ent"; break;
		case GlobalniID.Postava_Bree_Whitney: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\bree.ent"; break;
		case GlobalniID.Postava_Sachiko_Kusama: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q201_doctor_scientist.ent"; break;
		case GlobalniID.Postava_Dietlinde: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\wat_nid_foodshop_02.ent"; break;
		case GlobalniID.Postava_Aguilar_Nubiola_Female:
		case GlobalniID.Postava_Shelma:
		case GlobalniID.Postava_Sofia_Ramirez:
		case GlobalniID.Postava_Linh_Hyunh: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\____test_female.ent"; break;
		case GlobalniID.Postava_Rich_Female_14:
		case GlobalniID.Postava_Rich_Female_25:
		case GlobalniID.Postava_Rich_Female_12: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen__rich_wa.ent"; break;
		case GlobalniID.Postava_Sexworker_Prostitute_05:
		case GlobalniID.Postava_Sexworker_Prostitute_07:
		case GlobalniID.Postava_Sexworker_Doll_04:
		case GlobalniID.Postava_Sexworker_Doll_08:
		case GlobalniID.Postava_Sexworker_Doll_07:
		case GlobalniID.Postava_Sexworker_10:
		case GlobalniID.Postava_Sexworker_02:
		case GlobalniID.Postava_Sexworker_Doll_02: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\service__sexworker_wa.ent"; break;
		case GlobalniID.Postava_Carol_Emeka: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\carol.ent"; break;
		case GlobalniID.Postava_Caliente_Waitress_01: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sq017_caliente_waitress.ent"; break;
		case GlobalniID.Postava_Konpeki_Waitress_01: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q005_hotel_waitress.ent"; break;
		case GlobalniID.Postava_Miranda_Lawson: cestaKEnt = r"base\\1a_apps\\npv_ncs_mirandalawson.ent"; break;
		case GlobalniID.Postava_Tourist_01:
		case GlobalniID.Postava_Tourist_02: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq026_ent_tourists.ent"; break;
		case GlobalniID.Postava_Arasaka_Corpo_01:
		case GlobalniID.Postava_Arasaka_Corpo_06: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q000_corpo_arasaka_f_corporate.ent"; break;
		case GlobalniID.Postava_Arasaka_Netrunner_Lvl_2_3: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\corpo__arasaka_wa.ent"; break;
		case GlobalniID.Postava_Veteran_Guard_01: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\corpo__generic_wa.ent"; break;
		case GlobalniID.Postava_Tube_Dancer_08: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\service_dancer_wa.ent"; break;
		case GlobalniID.Postava_Song_So_Ri: cestaKEnt = r"base\\amm_characters\\entity\\songbird.ent"; break;
		case GlobalniID.Postava_Youngster_Slacker_05:
		case GlobalniID.Postava_Youngster_Slacker_06:
		case GlobalniID.Postava_Youngster_Slacker_08:
		case GlobalniID.Postava_Youngster_Slacker_14: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen__youngster_wa.ent"; break;
		case GlobalniID.Postava_Rhino: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq025_rhino.ent"; break;
		case GlobalniID.Postava_Julia_Young: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\citizen__ep1_combat_zone_outcast_wa.ent"; break;
		case GlobalniID.Postava_Grace_Karina_Voronova: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\grace.ent"; break;
		case GlobalniID.Postava_Tyler_Zan: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\q307_ent_new_merc.ent"; break;
		case GlobalniID.Postava_Trigger:
		case GlobalniID.Postava_Godiva:
		case GlobalniID.Postava_Kissy:
		case GlobalniID.Postava_Roxxi:
		case GlobalniID.Postava_Yishen_Rhee: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q108_mercenary_fa.ent"; break;
		case GlobalniID.Postava_Dogtown_Joytoy_01:
		case GlobalniID.Postava_Dogtown_Joytoy_06: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\service__ep1_combat_zone_sexworker_wa.ent"; break;
		case GlobalniID.Postava_Heavy_Hearts_Waitress_01:
		case GlobalniID.Postava_Heavy_Hearts_Waitress_02:
		case GlobalniID.Postava_Heavy_Hearts_Waitress_03:
		case GlobalniID.Postava_Heavy_Hearts_Waitress_04:
		case GlobalniID.Postava_Heavy_Hearts_Waitress_05: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_06_waitress.ent"; break;
		case GlobalniID.Postava_Nina_Kraviz: cestaKEnt = r"base\\open_world\\characters\\vendors\\wbr_hil_ripdoc_female.ent"; break;
		case GlobalniID.Postava_Lana_Prince: cestaKEnt = r"base\\quest\\minor_quests\\mq042\\characters\\mq042_nomad_alice.ent"; break;
		case GlobalniID.Postava_Animals_Female_01:
		case GlobalniID.Postava_Animals_Female_02:
		case GlobalniID.Postava_Animals_Female_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__animals_wba.ent"; break;
		case GlobalniID.Postava_Barghest_Female_01:
		case GlobalniID.Postava_Barghest_Female_02:
		case GlobalniID.Postava_Barghest_Female_03:
		case GlobalniID.Postava_Barghest_Female_04: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\gang__kurtz_army_wa.ent"; break;
		case GlobalniID.Postava_Barghest_Female_05: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\citizen__ep1_combat_zone_barghest_wa.ent"; break;
		case GlobalniID.Postava_Scavengers_Female_01:
		case GlobalniID.Postava_Scavengers_Female_02:
		case GlobalniID.Postava_Scavengers_Female_03:
		case GlobalniID.Postava_Scavengers_Female_04: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__scavenger_wa.ent"; break;
		case GlobalniID.Postava_Wraiths_Female_01:
		case GlobalniID.Postava_Wraiths_Female_02:
		case GlobalniID.Postava_Wraiths_Female_03:
		case GlobalniID.Postava_Wraiths_Female_04: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__wraith_wa.ent"; break;
		case GlobalniID.Postava_Sofia_Rossi: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q000_kid_hooker.ent"; break;
		case GlobalniID.Postava_E3_Female_V: cestaKEnt = r"base\\amm_characters\\entity\\e3_v_female.ent"; break;
		case GlobalniID.Postava_Barbara_Babs_Okoye: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\babs.ent"; break;
		case GlobalniID.Postava_Paradise_Waitress_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\q303_paradise_service_wa.ent"; break;
		case GlobalniID.Postava_Barghest_Female_Guard_01: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_06_kurtz_guard_hh_wa.ent"; break;
		case GlobalniID.Postava_Pacific_Female_07:
		case GlobalniID.Postava_Pacific_Female_13:
		case GlobalniID.Postava_Pacific_Female_06: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\citizen__ep1_combat_zone_pacific_wa.ent"; break;
		case GlobalniID.Postava_Susan_Abernathy: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q000_corpo_abernathy.ent"; break;
		case GlobalniID.Postava_Nightlife_Hottie_15:
		case GlobalniID.Postava_Nightlife_Hottie_21: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen__nightlife_wa.ent"; break;
		case GlobalniID.Postava_Lizzies_Stripper_04: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q004_prostitute.ent"; break;
		case GlobalniID.Postava_Arabella_Spider_Murphy: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q101_spider_murphy.ent"; break;
		case GlobalniID.Postava_Zoe_Alonzo: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\zoe_alonzo.ent"; break;
		case GlobalniID.Postava_Yelena_Sidorova: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\yelena_sidorova.ent"; break;
		case GlobalniID.Postava_Taki_Kenmochi: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_wat_kab_107_duraido_chikin.ent"; break;
		case GlobalniID.Postava_Lt_Mower: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ma_wat_kab_08_cyberpsycho.ent"; break;
		case GlobalniID.Postava_Tamara_Cosby: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\special__cyberpsycho_wa.ent"; break;
		case GlobalniID.Postava_Rose_Horrigan: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_std_rcr_05_cyberpsycho.ent"; break;
		case GlobalniID.Postava_Biker_Female_04: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen__biker_wa.ent"; break;
		case GlobalniID.Postava_Arasaka_Scientist: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q101_arasaka_scientist_female.ent"; break;
		case GlobalniID.Postava_Maggie_Isley: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\cbj_ep1_02_enemy.ent"; break;
		case GlobalniID.Postava_Ayo_Zarin: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\we_ep1_05_boss_wa.ent"; break;
		case GlobalniID.Postava_Journey_Ruiz: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q204_music_store_owner.ent"; break;
		case GlobalniID.Postava_Nancy_Hartley: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\nancy.ent"; break;
		case GlobalniID.Postava_Griselda_Green_Cloud_Martinez: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq028_ent_herring_girl.ent"; break;
		case GlobalniID.Postava_Lucy_Thackery: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\service__ripperdoc_wa.ent"; break;
		case GlobalniID.Postava_Voodoo_Boys_Female_01:
		case GlobalniID.Postava_Voodoo_Boys_Female_02:
		case GlobalniID.Postava_Voodoo_Boys_Female_07:
		case GlobalniID.Postava_Voodoo_Boys_Female_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__voodoo_wa.ent"; break;
		case GlobalniID.Postava_Voodoo_Boys_Female_04:
		case GlobalniID.Postava_Voodoo_Boys_Female_05:
		case GlobalniID.Postava_Voodoo_Boys_Female_06: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\gang__voodoo_wa.ent"; break;
		case GlobalniID.Postava_Scavengers_Female_05:
		case GlobalniID.Postava_Scavengers_Female_06:
		case GlobalniID.Postava_Scavengers_Female_07:
		case GlobalniID.Postava_Scavengers_Female_08: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\gang__scavenger_wa.ent"; break;
		case GlobalniID.Postava_Mallrat_10:
		case GlobalniID.Postava_Mallrat_05: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen__mallrat_wa.ent"; break;
		case GlobalniID.Postava_R3n0: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq015_seller.ent"; break;
		case GlobalniID.Postava_District_Teen_01: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\crowd__heywood_glen_wa.ent"; break;
		case GlobalniID.Postava_Linda_Spencer: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq019_fa_club_staff.ent"; break;
		case GlobalniID.Postava_Citizen_Corporat_01:
		case GlobalniID.Postava_Citizen_Corporat_12: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen__corporat_wa.ent"; break;
		case GlobalniID.Postava_Micaela_Ruiz: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq025_cesars_girl.ent"; break;
		case GlobalniID.Postava_Paradise_Client_02: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\q303_paradise_client_wa.ent"; break;
		case GlobalniID.Postava_Hologram_Prostitute:
		case GlobalniID.Postava_Hologram_Pachinko_Girl:
		case GlobalniID.Postava_Hologram_VIP: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\special__hologram_wa.ent"; break;
		case GlobalniID.Postava_Canon_FemV: cestaKEnt = r"zxr_npv\\v_just_v\\valerie\\ent\\v_npv.ent"; break;

		case GlobalniID.Postava_Male_V: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\player\\player_ma_tpp_cutscene.ent"; break;
		case GlobalniID.Postava_Kerry_Eurodyne: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\kerry.ent"; break;
		case GlobalniID.Postava_River_Ward: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sobchak.ent"; break;
		case GlobalniID.Postava_Angel: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q105_yakuza_dolls_male_02.ent"; break;
		case GlobalniID.Postava_Mike_Tiny_Mike_Kowalski: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_wat_kab_01_tiny_mike.ent"; break;
		case GlobalniID.Postava_Saul_Bright: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\saul.ent"; break;
		case GlobalniID.Postava_Jackie_Welles: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\jackie.ent"; break;
		case GlobalniID.Postava_Victor_Vektor: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\victor_vector.ent"; break;
		case GlobalniID.Postava_Jefferson_Peralez: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\jefferson_peralez.ent"; break;
		case GlobalniID.Postava_Tom_Caldera: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\tom.ent"; break;
		case GlobalniID.Postava_Benjamin_Stone: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q000_basketballer_02.ent"; break;
		case GlobalniID.Postava_Mitch_Anderson: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\Mitch.ent"; break;
		case GlobalniID.Postava_Aymeric_Cassel: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\theo.ent"; break;
		case GlobalniID.Postava_Paco_Torres: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\paco.ent"; break;
		case GlobalniID.Postava_Placide: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\placide.ent"; break;
		case GlobalniID.Postava_Goro_Takemura: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\takemura.ent"; break;
		case GlobalniID.Postava_Sandayu_Oda: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\cyberninja_oda.ent"; break;
		case GlobalniID.Postava_Ozob_Bozo: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ozob.ent"; break;
		case GlobalniID.Postava_Muamar_El_Capitan_Reyes: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\muamar_reyes.ent"; break;
		case GlobalniID.Postava_Jotaro_Shobo: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_wat_kab_07_jotaro.ent"; break;
		case GlobalniID.Postava_Kurt_Hansen: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\kurtz.ent"; break;
		case GlobalniID.Postava_Ayden_Daniels: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sa_ep1_courier_outro_daniels_ncpd_ma.ent"; break;
		case GlobalniID.Postava_NCPD_Male_01: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\corpo__ncpd_ma.ent"; break;
		case GlobalniID.Postava_Dusty_Lowe: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\wbr_jpn_prostitute_male.ent"; break;
		case GlobalniID.Postava_Logan_Scott: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\hey_gle_prostitute_male.ent"; break;
		case GlobalniID.Postava_Valentinos_Male_01:
		case GlobalniID.Postava_Valentinos_Male_02:
		case GlobalniID.Postava_Valentinos_Male_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__valentinos_ma.ent"; break;
		case GlobalniID.Postava_6th_Street_Male_01:
		case GlobalniID.Postava_6th_Street_Male_02:
		case GlobalniID.Postava_6th_Street_Male_03:
		case GlobalniID.Postava_6th_Street_Male_04: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__6thstreet_ma.ent"; break;
		case GlobalniID.Postava_Mateo_Thiago: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\lizzies_barman.ent"; break;
		case GlobalniID.Postava_Maelstrom_Male_01:
		case GlobalniID.Postava_Maelstrom_Male_02: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__maelstrom_ma.ent"; break;
		case GlobalniID.Postava_Tyger_Claws_Male_01:
		case GlobalniID.Postava_Tyger_Claws_Male_02:
		case GlobalniID.Postava_Tyger_Claws_Male_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__tyger_ma.ent"; break;
		case GlobalniID.Postava_Mox_Male_01:
		case GlobalniID.Postava_Mox_Male_02:
		case GlobalniID.Postava_Mox_Male_03:
		case GlobalniID.Postava_Mox_Male_04:
		case GlobalniID.Postava_Mox_Male_05:
		case GlobalniID.Postava_Mox_Male_06:
		case GlobalniID.Postava_Mox_Male_07:
		case GlobalniID.Postava_Mox_Male_08:
		case GlobalniID.Postava_Mox_Male_09: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\lizzies_mox_male.ent"; break;
		case GlobalniID.Postava_Arthur_Jenkins: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q000_corpo_jenkins.ent"; break;
		case GlobalniID.Postava_Finn_Fingers_Gerstatt: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\fingers.ent"; break;
		case GlobalniID.Postava_Bryce_Mosley: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q110_netwatch_agent.ent"; break;
		case GlobalniID.Postava_Frank_Nostra: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q000_corpo_friend.ent"; break;
		case GlobalniID.Postava_Wade_Mr_Hands_Bleecker: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\mr_hands_ep1.ent"; break;
		case GlobalniID.Postava_Sebastian_Padre_Ibarra: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\padre.ent"; break;
		case GlobalniID.Postava_Declan_Brick_Griffin: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\brick.ent"; break;
		case GlobalniID.Postava_Simon_Royce_Randall: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\royce.ent"; break;
		case GlobalniID.Postava_Dum_Dum: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\dumdum.ent"; break;
		case GlobalniID.Postava_Dexter_Dex_DeShawn: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\dex.ent"; break;
		case GlobalniID.Postava_Jake_Tim_Kelly: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\jake.ent"; break;
		case GlobalniID.Postava_Ziggy_Q: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ziggy_q.ent"; break;
		case GlobalniID.Postava_Johnny_Silverhand: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\johnny_mvb.ent"; break;
		case GlobalniID.Postava_Solomon_Reed: cestaKEnt = r"ep1\\quest\\primary_characters\\reed.ent"; break;
		case GlobalniID.Postava_Animals_Male_01:
		case GlobalniID.Postava_Animals_Male_02:
		case GlobalniID.Postava_Animals_Male_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__animals_mba.ent"; break;
		case GlobalniID.Postava_Barghest_Male_01:
		case GlobalniID.Postava_Barghest_Male_02:
		case GlobalniID.Postava_Barghest_Male_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\gang__kurtz_army_ma.ent"; break;
		case GlobalniID.Postava_Scavengers_Male_01:
		case GlobalniID.Postava_Scavengers_Male_02:
		case GlobalniID.Postava_Scavengers_Male_03:
		case GlobalniID.Postava_Scavengers_Male_04: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__scavenger_ma.ent"; break;
		case GlobalniID.Postava_Wraiths_Male_01:
		case GlobalniID.Postava_Wraiths_Male_02:
		case GlobalniID.Postava_Wraiths_Male_03: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__wraith_ma.ent"; break;
		case GlobalniID.Postava_E3_Male_V: cestaKEnt = r"base\\amm_characters\\entity\\e3_v_male.ent"; break;
		case GlobalniID.Postava_Pepe_Najarro: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\elcoyote_barman.ent"; break;
		case GlobalniID.Postava_Dante_Caruso: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\dante.ent"; break;
		case GlobalniID.Postava_Chester_Bennett: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\mq304_ent_bennett.ent"; break;
		case GlobalniID.Postava_Yuri_Bychkov: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\jurij.ent"; break;
		case GlobalniID.Postava_Hideyoshi_Oshima: cestaKEnt = r"base\\quest\\main_quests\\prologue\\q005\\characters\\q005_hideyoshi_oshima.ent"; break;
		case GlobalniID.Postava_Aguilar_Nubiola_Male: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\____test_male.ent"; break;
		case GlobalniID.Postava_Hasan_Demir: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_04_hasan.ent"; break;
		case GlobalniID.Postava_Edgar_TooLina_Tool: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\mq303_ent_tool.ent"; break;
		case GlobalniID.Postava_Adam_Smasher: cestaKEnt = r"base\\characters\\entities\\boss\\adam_smasher.ent"; break;
		case GlobalniID.Postava_Wilky_Slider_LaGuerre: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\baron.ent"; break;
		case GlobalniID.Postava_Milko_Alexis: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_12_milko_alexis.ent"; break;
		case GlobalniID.Postava_Yorinobu_Arasaka: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\yorinobu.ent"; break;
		case GlobalniID.Postava_Jago_Szabo: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\mq304_ent_jago.ent"; break;
		case GlobalniID.Postava_Robert_Wilson: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\wilson.ent"; break;
		case GlobalniID.Postava_Obese_Caribbean_01: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen__obese_mf.ent"; break;
		case GlobalniID.Postava_Mr_Blue_Eyes: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\q203_mr_x.ent"; break;
		case GlobalniID.Postava_Driss_Scorpion_Meriana: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\scorpion.ent"; break;
		case GlobalniID.Postava_Henry: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\henry.ent"; break;
		case GlobalniID.Postava_Theodore_Teddy_Simos: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\teddy.ent"; break;
		case GlobalniID.Postava_Nix: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\nix.ent"; break;
		case GlobalniID.Postava_Lyle_Thompson: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\thompson.ent"; break;
		case GlobalniID.Postava_Cesar_Diego_Ruiz: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq025_cesar.ent"; break;
		case GlobalniID.Postava_Roy_Batty: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\batty.ent"; break;
		case GlobalniID.Postava_Max_Jones: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_wat_nid_12_max_jones.ent"; break;
		case GlobalniID.Postava_Odell_Blanco: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_01_odel.ent"; break;
		case GlobalniID.Postava_Denzel_The_Brain_Cryer: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\denzel_cryer.ent"; break;
		case GlobalniID.Postava_Emmerick_Bronson: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\emmerick.ent"; break;
		case GlobalniID.Postava_Peter_Sampson: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sq024_dominic.ent"; break;
		case GlobalniID.Postava_Juan_Mendez: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq010_policeman.ent"; break;
		case GlobalniID.Postava_Leon_Rinder: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\wagner.ent"; break;
		case GlobalniID.Postava_Dino_Dinovic: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\dyno.ent"; break;
		case GlobalniID.Postava_Santiago_Aldecaldo: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\santiago.ent"; break;
		case GlobalniID.Postava_Albert_Murphy: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\kruger.ent"; break;
		case GlobalniID.Postava_Rafael_Perez: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\service__ripperdoc_ma.ent"; break;
		case GlobalniID.Postava_Nonbinary_Youngster_01: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\citizen_nonbinary_ma.ent"; break;
		case GlobalniID.Postava_Cassidy_Righter: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\cassidy.ent"; break;
		case GlobalniID.Postava_Jax_Forgrave: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\gang__maelstrom_mb.ent"; break;
		case GlobalniID.Postava_Boris_Ribakov: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\sts_ep1_08_kgb_boss.ent"; break;
		case GlobalniID.Postava_Hwangbo_Dong_Gun: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_wat_nid_03_haruo.ent"; break;
		case GlobalniID.Postava_Barry_Lewis: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\mq010_barry.ent"; break;
		case GlobalniID.Postava_Gustavo_Orta: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\sts_hey_rey_01_gustavo.ent"; break;
		case GlobalniID.Postava_Bob_Sagan: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\bob.ent"; break;
		case GlobalniID.Postava_Satoshi_Ueno: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\ep1\\service__ep1_service_point_ma.ent"; break;
	};

	if Equals(pohlavi, GenderType.Female) {
		switch vybranaPostava {
			case GlobalniID.Postava_Robot_Corpo: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\corpo__android_wa.ent"; break;
			case GlobalniID.Postava_Robot_Gang_Maelstrom:
			case GlobalniID.Postava_Robot_Gang_Wraith:
			case GlobalniID.Postava_Robot_Gang_Scavenger:
			case GlobalniID.Postava_Robot_Gang_6th_Street: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\gang__android_wa.ent"; break;
			case GlobalniID.Postava_Robot_Training: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\q000_vr_enemy_wa_fistfight.ent"; break;
			case GlobalniID.Postava_Robot_Remote: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\sts_ep1_13_android_wa.ent"; break;
			case GlobalniID.Postava_Robot_Nusa: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\q301_ss_android_wa.ent"; break;
			case GlobalniID.Postava_Robot_Moth_Barman: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\q303_droid_wa.ent"; break;
		};
	} else {
		switch vybranaPostava {
			case GlobalniID.Postava_Robot_Corpo: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\corpo__android_ma.ent"; break;
			case GlobalniID.Postava_Robot_Gang_Maelstrom:
			case GlobalniID.Postava_Robot_Gang_Wraith:
			case GlobalniID.Postava_Robot_Gang_Scavenger:
			case GlobalniID.Postava_Robot_Gang_6th_Street: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\gang__android_ma.ent"; break;
			case GlobalniID.Postava_Robot_Training: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\q000_vr_enemy_ma_fistfight.ent"; break;
			case GlobalniID.Postava_Robot_Remote: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\sts_ep1_13_android_ma.ent"; break;
			case GlobalniID.Postava_Robot_Nusa: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\q301_ss_android.ent"; break;
			case GlobalniID.Postava_Robot_Moth_Barman: cestaKEnt = r"mod\\arman3_lizzies_bds\\characters\\entities\\robots\\q303_droid.ent"; break;
		};
	}

	return cestaKEnt;
}

public func DataVzhledu(vybranaPostava: GlobalniID, vybranyVzhled: Int32) -> array<CName> {
	let vzhled: CName = n"";
	let vzhledBez: CName = n"";
	
	switch vybranaPostava {
		case GlobalniID.Postava_Judy_Alvarez:
			if vybranyVzhled == 1 { vzhled = n"judy_ep__q307__two_years_later_btm"; vzhledBez = n"judy_ep__q307__two_years_later_btm_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"judy_ep__q307__two_years_later_official"; vzhledBez = n"judy_ep__q307__two_years_later_btm_naked"; }
			else if vybranyVzhled == 3 { vzhled = n"judy_panties"; vzhledBez = n"judy_nude"; }
			else if vybranyVzhled == 4 { vzhled = n"judy__mq055__apartment_01"; vzhledBez = n"judy_nude"; }
			else if vybranyVzhled == 5 { vzhled = n"judy_diving_suit"; vzhledBez = n"judy_nude"; }
			else if vybranyVzhled == 6 { vzhled = n"judy_diving_suit_mask"; vzhledBez = n"judy_nude"; }
			else if vybranyVzhled == 7 { vzhled = n"judy_crying"; vzhledBez = n"judy_nude"; }
			else if vybranyVzhled == 8 { vzhled = n"judy__q203__after_shower"; vzhledBez = n"judy_nude"; }
			else { vzhled = n"judy_default"; vzhledBez = n"judy_nude"; }
			break;
		case GlobalniID.Postava_Panam_Palmer:
			if vybranyVzhled == 1 { vzhled = n"panam__mq055__apartment_02"; vzhledBez = n"panam_nude"; }
			else if vybranyVzhled == 2 { vzhled = n"panam_no_jacket_and_harness"; vzhledBez = n"panam_nude"; }
			else if vybranyVzhled == 3 { vzhled = n"panam_underwear"; vzhledBez = n"panam_nude"; }
			else { vzhled = n"panam_default"; vzhledBez = n"panam_nude"; }
			break;
		case GlobalniID.Postava_Skye: vzhled = n"service__sexworker_wa__q105__skye"; vzhledBez = n"service__sexworker_wa__q105__skye_naked"; break;
		case GlobalniID.Postava_Evelyn_Parker:
			if vybranyVzhled == 1 { vzhled = n"evelyn_no_coat"; vzhledBez = n"evelyn_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"evelyn_braindance"; vzhledBez = n"evelyn_braindance_naked"; }
			else { vzhled = n"evelyn_default"; vzhledBez = n"evelyn_naked"; }
			break;
		case GlobalniID.Postava_Cheri_Nowlin: vzhled = n"service__sexworker_wa__q105__yakuza_receptionist"; vzhledBez = n"service__sexworker_wa__q105__yakuza_receptionist_naked"; break;
		case GlobalniID.Postava_Altiera_Alt_Cunningham: vzhled = n"alt_default"; vzhledBez = n"alt_naked"; break;
		case GlobalniID.Postava_Elizabeth_Peralez: vzhled = n"elizabeth_peralez_default"; vzhledBez = n"elizabeth_peralez_naked"; break;
		case GlobalniID.Postava_Hanako_Arasaka:
			if vybranyVzhled == 1 { vzhled = n"hanako_default"; vzhledBez = n"hanako_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"hanako_parade"; vzhledBez = n"hanako_parade_naked"; }
			else if vybranyVzhled == 3 { vzhled = n"hanako_parade_no_coat"; vzhledBez = n"hanako_parade_naked"; }
			else { vzhled = n"hanako_no_coat"; vzhledBez = n"hanako_naked"; }
			break;
		case GlobalniID.Postava_Ruby_Collins: vzhled = n"sq031__stripper_bra"; vzhledBez = n"sq031__stripper_naked"; break;
		case GlobalniID.Postava_Maiko_Maeda: vzhled = n"citizen__rich_wa__sq026__maiko"; vzhledBez = n"citizen__rich_wa__sq026__maiko_naked"; break;
		case GlobalniID.Postava_T_Bug: vzhled = n"t_bug_default"; vzhledBez = n"t_bug_naked"; break;
		case GlobalniID.Postava_Misty_Olszewski:
			if vybranyVzhled == 1 { vzhled = n"misty_ep__q307__two_years_later"; vzhledBez = n"misty_ep__q307__two_years_later_naked"; }
			else { vzhled = n"misty_default"; vzhledBez = n"misty_naked"; }
			break;
		case GlobalniID.Postava_Iris_Tanner: vzhled = n"gang__aldecaldos_wa__sts_bls_ina_06_iris_tanner"; vzhledBez = n"gang__aldecaldos_wa__sts_bls_ina_06_iris_tanner_naked"; break;
		case GlobalniID.Postava_Roxanne_Sumner: vzhled = n"gang__tyger_wa__sq026__roxanne_casual"; vzhledBez = n"gang__tyger_wa__sq026__roxanne_naked"; break;
		case GlobalniID.Postava_Karina_Lee: vzhled = n"service__media_wa__tvhost_wns__karina_lee"; vzhledBez = n"service__media_wa__tvhost_wns__karina_lee_naked"; break;
		case GlobalniID.Postava_Gillean_Jordan: vzhled = n"service__media_wa__tvhost_n54__gillean_jordan"; vzhledBez = n"service__media_wa__tvhost_n54__gillean_jordan_naked"; break;
		case GlobalniID.Postava_Sandra_Dorsett: vzhled = n"sandra_dorset__q000__sandra_dorset"; vzhledBez = n"sandra_dorset__q000__sandra_dorset_naked"; break;
		case GlobalniID.Postava_Aurore_Cassel: vzhled = n"bella_default"; vzhledBez = n"bella_naked"; break;
		case GlobalniID.Postava_Rosalind_Myers:
			if vybranyVzhled == 1 { vzhled = n"president_myers_disquise"; vzhledBez = n"president_myers_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"president_myers_border_crossing"; vzhledBez = n"president_myers_border_crossing_naked"; }
			else { vzhled = n"president_myers_default"; vzhledBez = n"president_myers_naked"; }
			break;
		case GlobalniID.Postava_Lina_Malina: vzhled = n"woman_average__mq303__lina_malina"; vzhledBez = n"woman_average__mq303__lina_malina_naked"; break;
		case GlobalniID.Postava_Angelica_Angie_Whelan: vzhled = n"woman_average__mq306__angie_default"; vzhledBez = n"woman_average__mq306__angie_naked"; break;
		case GlobalniID.Postava_Stella_Ramos: vzhled = n"woman_average__sts_ep1_10__stella"; vzhledBez = n"woman_average__sts_ep1_10__stella_naked"; break;
		case GlobalniID.Postava_Claire_Russell: vzhled = n"clair_default"; vzhledBez = n"clair_naked"; break;
		case GlobalniID.Postava_Rachel_Casich: vzhled = n"service__specialist_wa__sq023__bd_producer"; vzhledBez = n"service__specialist_wa__sq023__bd_producer_naked"; break;
		case GlobalniID.Postava_Elisabeth_Lizzy_Wizzy_Wissenfurth: vzhled = n"celebrity_chrome_default"; vzhledBez = n"celebrity_chrome_naked"; break;
		case GlobalniID.Postava_Alena_Alex_Xenakis:
			if vybranyVzhled == 1 { vzhled = n"alex_bartender_no"; vzhledBez = n"alex_bartender_naked"; }
			else { vzhled = n"alex_default"; vzhledBez = n"alex_naked"; }
			break;
		case GlobalniID.Postava_Georgina_Zembinsky: vzhled = n"woman_average__sts_ep1_06__georgina"; vzhledBez = n"woman_average__sts_ep1_06__georgina_naked"; break;
		case GlobalniID.Postava_Ruth_Dzeng: vzhled = n"service__media_wa__tvhost_dms__ruth_dzeng"; vzhledBez = n"service__media_wa__tvhost_dms__ruth_dzeng_naked"; break;
		case GlobalniID.Postava_Denny:
			if vybranyVzhled == 1 { vzhled = n"denny_denny_2020"; vzhledBez = n"denny_denny_2020_naked"; }
			else { vzhled = n"denny_denny"; vzhledBez = n"denny_denny_naked"; }
			break;
		case GlobalniID.Postava_Emilie_Massenat: vzhled = n"service__sexworker_wa__q110__placides_girlfriend"; vzhledBez = n"service__sexworker_wa__q110__placides_girlfriend_naked"; break;
		case GlobalniID.Postava_Beatrice_Ellen_8ug8ear_Trieste: vzhled = n"8ug8ear_default"; vzhledBez = n"8ug8ear_naked"; break;
		case GlobalniID.Postava_Dakota_Smith: vzhled = n"dakota_smith_default"; vzhledBez = n"dakota_smith_naked"; break;
		case GlobalniID.Postava_Joss_Kutcher: vzhled = n"citizen__lowlife_wa__sq029__joss"; vzhledBez = n"citizen__lowlife_wa__sq029__joss_naked"; break;
		case GlobalniID.Postava_Zuleikha_El_Ahmar: vzhled = n"citizen__tenant_wa__sq023__zuleikha"; vzhledBez = n"citizen__tenant_wa__sq023__zuleikha_naked"; break;
		case GlobalniID.Postava_Lucyna_Lucy_Kushinada:
			if vybranyVzhled == 1 { vzhled = n"edgerunners_lucy_no_jacket"; vzhledBez = n"edgerunners_lucy_nude"; }
			else if vybranyVzhled == 2 { vzhled = n"edgerunners_lucy_david_jacket"; vzhledBez = n"edgerunners_lucy_nude"; }
			else { vzhled = n"edgerunners_lucy_default"; vzhledBez = n"edgerunners_lucy_nude"; }
			break;
		case GlobalniID.Postava_Regina_Jones: vzhled = n"service__fixer_wa__regina_jones"; vzhledBez = n"service__fixer_wa__regina_jones_naked"; break;
		case GlobalniID.Postava_Nika_Yankovich: vzhled = n"woman_average__sts_ep1_01__nika"; vzhledBez = n"woman_average__sts_ep1_01__nika_naked"; break;
		case GlobalniID.Postava_Theo_Price: vzhled = n"citizen__youngster_wa__mq037__theo"; vzhledBez = n"citizen__youngster_wa__mq037__theo_naked"; break;
		case GlobalniID.Postava_Melisa_Rory: vzhled = n"max_tac_wa__mq030__melisa"; vzhledBez = n"max_tac_wa__mq030__melisa_naked"; break;
		case GlobalniID.Postava_Konpeki_Receptionist_01: vzhled = n"citizen__arasaka_corpo_wa__q004__konpeki_receptionist_01"; vzhledBez = n"citizen__arasaka_corpo_wa__q004__konpeki_receptionist_01_naked"; break;
		case GlobalniID.Postava_Nadia_Petrova: vzhled = n"corpo__ncpd_wa__mq010__petrova"; vzhledBez = n"corpo__ncpd_wa__mq010__petrova_naked"; break;
		case GlobalniID.Postava_Joanne_Koch: vzhled = n"service__specialist_wa__sts_cct_dtn_04_joanne_koch"; vzhledBez = n"service__specialist_wa__sts_cct_dtn_04_joanne_koch_naked"; break;
		case GlobalniID.Postava_Nadezhda_Tiurina: vzhled = n"corpo__generic_wa__sts_wat_kab_04_nadezhda"; vzhledBez = n"corpo__generic_wa__sts_wat_kab_04_nadezhda_naked"; break;
		case GlobalniID.Postava_Anna_Hamill: vzhled = n"corpo__ncpd_wa__sts_wa_kab_08__anna_hamil"; vzhledBez = n"corpo__ncpd_wa__sts_wa_kab_08__anna_hamil_naked"; break;
		case GlobalniID.Postava_Farida_Nazeri: vzhled = n"farida_default"; vzhledBez = n"farida_default_naked"; break;
		case GlobalniID.Postava_Guadalupe_Alejandra_Welles: vzhled = n"gang__valentinos_wa__sq018__mama_welles"; vzhledBez = n"gang__valentinos_wa__sq018__mama_welles_naked"; break;
		case GlobalniID.Postava_Clothing_Seller_Std_Arr: vzhled = n"service__vendor_wa__std_arr_clothingshop_01"; vzhledBez = n"service__vendor_wa__std_arr_clothingshop_01_naked"; break;
		case GlobalniID.Postava_NCPD_Female_01: vzhled = n"corpo__ncpd_wa_ncpd_police_wa_07"; vzhledBez = n"corpo__ncpd_wa_ncpd_police_wa_07_naked"; break;
		case GlobalniID.Postava_Yawen_Packard: vzhled = n"service__medical_wa__sq021__yawen_packard"; vzhledBez = n"service__medical_wa__sq021__yawen_packard_naked"; break;
		case GlobalniID.Postava_Nele_Springer: vzhled = n"woman_average__sts_ep1_07__nele"; vzhledBez = n"woman_average__sts_ep1_07__nele_naked"; break;
		case GlobalniID.Postava_Lauren_Costigan: vzhled = n"citizen__lowlife_wa__sts_wbr_jpn_02_lauren_costigan"; vzhledBez = n"citizen__lowlife_wa__sts_wbr_jpn_02_lauren_costigan_naked"; break;
		case GlobalniID.Postava_Jasmine_Dixon: vzhled = n"corpo__ncpd_wa__sts_std_rcr_02_jasmine_dixon"; vzhledBez = n"corpo__ncpd_wa__sts_std_rcr_02_jasmine_dixon_naked"; break;
		case GlobalniID.Postava_Charlene_Fox: vzhled = n"service__sexworker_wa__ow__poor_01_no_coat"; vzhledBez = n"service__sexworker_wa__ow__poor_01_naked"; break;
		case GlobalniID.Postava_Brittany_Hayes: vzhled = n"service__sexworker_wa__ow__luxury_01"; vzhledBez = n"service__sexworker_wa__ow__luxury_01_naked"; break;
		case GlobalniID.Postava_JigJig_Dancer_05: vzhled = n"service__tubedancer_wa_tube_dancer_05_ground"; vzhledBez = n"service__tubedancer_wa_tube_dancer_05_ground_naked"; break;
		case GlobalniID.Postava_Tasha_Rodriquez: vzhled = n"service__sexworker_wa__q105__cyberface_face"; vzhledBez = n"service__sexworker_wa__q105__cyberface_face_naked"; break;
		case GlobalniID.Postava_Aoi_Blue_Moon_Tsuki: vzhled = n"us_cracks_band_blue_moon__default"; vzhledBez = n"us_cracks_band_blue_moon__naked"; break;
		case GlobalniID.Postava_Purple_Force: vzhled = n"us_cracks_band_purple_force__default"; vzhledBez = n"us_cracks_band_purple_force__naked"; break;
		case GlobalniID.Postava_Akai_Red_Menace_Kyoi: vzhled = n"us_cracks_band_red_menace__default"; vzhledBez = n"us_cracks_band_red_menace__naked"; break;
		case GlobalniID.Postava_Meredith_Stout: 
			if vybranyVzhled == 1 { vzhled = n"meredith_stout_default"; vzhledBez = n"meredith_stout_naked"; }
			else { vzhled = n"meredith_stout_default"; vzhledBez = n"meredith_stout_bdsm_no_pants"; }
			break;
		case GlobalniID.Postava_Queen_Of_The_Stoop_12: vzhled = n"queen_of_the_stoop_wa_queen_of_the_stoop_wa_12"; vzhledBez = n"queen_of_the_stoop_wa_queen_of_the_stoop_wa_12_naked"; break;
		case GlobalniID.Postava_Rita_Wheeler: vzhled = n"gang__mox_wa__beyond_bouncer_01"; vzhledBez = n"gang__mox_wa__beyond_bouncer_01_naked"; break;
		case GlobalniID.Postava_Mox_Female_01:
			if vybranyVzhled == 1 { vzhled = n"gang__mox_wa_mox_01_1"; vzhledBez = n"gang__mox_wa_mox_01_1_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"gang__mox_wa_mox_01_1_1"; vzhledBez = n"gang__mox_wa_mox_01_1_1_naked"; }
			else { vzhled = n"gang__mox_wa_mox_01"; vzhledBez = n"gang__mox_wa_mox_01_naked"; }
			break;
		case GlobalniID.Postava_Mox_Female_Lvl_3_2: vzhled = n"gang__mox_wa_elite__lvl3_02"; vzhledBez = n"gang__mox_wa_elite__lvl3_02_naked"; break;
		case GlobalniID.Postava_Susanna_Susie_Q_Quinn: vzhled = n"gang__mox_wa_lizzies_boss"; vzhledBez = n"gang__mox_wa_lizzies_boss_naked"; break;
		case GlobalniID.Postava_Valentinos_Female_01: vzhled = n"gang__valentinos_wa_grunt__lvl2_06"; vzhledBez = n"gang__valentinos_wa_grunt__lvl2_06_naked"; break;
		case GlobalniID.Postava_Valentinos_Female_02: vzhled = n"gang__valentinos_wa_grunt__lvl2_02"; vzhledBez = n"gang__valentinos_wa_grunt__lvl2_02_naked"; break;
		case GlobalniID.Postava_Valentinos_Female_03: vzhled = n"gang__valentinos_wa_elite__lvl2_06"; vzhledBez = n"gang__valentinos_wa_elite__lvl2_06_naked"; break;
		case GlobalniID.Postava_Valentinos_Female_04: vzhled = n"gang__valentinos_wa_grunt__lvl1_02"; vzhledBez = n"gang__valentinos_wa_grunt__lvl1_02_naked"; break;
		case GlobalniID.Postava_6th_Street_Female_01: vzhled = n"gang__6thstreet_wa_hooligan__lvl1_04"; vzhledBez = n"gang__6thstreet_wa_hooligan__lvl1_04_naked"; break;
		case GlobalniID.Postava_6th_Street_Female_02: vzhled = n"gang__6thstreet_wa_party_01"; vzhledBez = n"gang__6thstreet_wa_party_01_naked"; break;
		case GlobalniID.Postava_6th_Street_Female_03: vzhled = n"gang__6thstreet_wa_party_04"; vzhledBez = n"gang__6thstreet_wa_party_04_naked"; break;
		case GlobalniID.Postava_6th_Street_Female_04: vzhled = n"gang__6thstreet_wa_party_10"; vzhledBez = n"gang__6thstreet_wa_party_10_naked"; break;
		case GlobalniID.Postava_6th_Street_Female_05: vzhled = n"gang__6thstreet_wa_party_11"; vzhledBez = n"gang__6thstreet_wa_party_11_naked"; break;
		case GlobalniID.Postava_Maelstrom_Female_01: vzhled = n"gang__maelstrom_wa_grunt__lvl1_01"; vzhledBez = n"gang__maelstrom_wa_grunt__lvl1_01_naked"; break;
		case GlobalniID.Postava_Maelstrom_Female_02: vzhled = n"gang__maelstrom_wa_grunt__lvl1_02"; vzhledBez = n"gang__maelstrom_wa_grunt__lvl1_02_naked"; break;
		case GlobalniID.Postava_Maelstrom_Female_03: vzhled = n"gang__maelstrom_wa_grunt__lvl2_03"; vzhledBez = n"gang__maelstrom_wa_grunt__lvl2_03_naked"; break;
		case GlobalniID.Postava_Tyger_Claws_Female_01: vzhled = n"gang__tyger_wa_biker__lvl1_05"; vzhledBez = n"gang__tyger_wa_biker__lvl1_05_naked"; break;
		case GlobalniID.Postava_Tyger_Claws_Female_02: vzhled = n"gang__tyger_wa_gangster__lvl2_04"; vzhledBez = n"gang__tyger_wa_gangster__lvl2_04_naked"; break;
		case GlobalniID.Postava_Tyger_Claws_Female_03: vzhled = n"gang__tyger_wa_kunoichi__lvl3_01"; vzhledBez = n"gang__tyger_wa_kunoichi__lvl3_01_naked"; break;
		case GlobalniID.Postava_Rogue_Amendiares:
			if vybranyVzhled == 1 { vzhled = n"rogue_rogue_young"; vzhledBez = n"rogue_rogue_young_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"rogue_rogue_young_2013"; vzhledBez = n"rogue_rogue_young_2013_naked"; }
			else if vybranyVzhled == 3 { vzhled = n"rogue_rogue_date"; vzhledBez = n"rogue_rogue_date_naked"; }
			else if vybranyVzhled == 4 { vzhled = n"rogue_rogue_date_nojacket"; vzhledBez = n"rogue_rogue_date_naked"; }
			else { vzhled = n"rogue_rogue_old_solo"; vzhledBez = n"rogue_rogue_old_solo_naked"; }
			break;
		case GlobalniID.Postava_Dao_Hyunh: vzhled = n"special__cyberpsycho_wa_ma_hey_spr_04"; vzhledBez = n"special__cyberpsycho_wa_ma_hey_spr_04_naked"; break;
		case GlobalniID.Postava_Song_Songbird_So_Mi:
			if vybranyVzhled == 1 { vzhled = n"songbird_default"; vzhledBez = n"songbird_default_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"songbird_young_6"; vzhledBez = n"songbird_young_6_naked"; }
			else if vybranyVzhled == 3 { vzhled = n"songbird_paradise"; vzhledBez = n"songbird_paradise_naked"; }
			else if vybranyVzhled == 4 { vzhled = n"songbird_blendable_nb_freckles"; vzhledBez = n"songbird_blendable_freckles_naked"; }
			else if vybranyVzhled == 5 { vzhled = n"songbird__q306__exhausted_lizzies_bds"; vzhledBez = n"songbird_default_naked"; }
			else { vzhled = n"songbird_blendable_nb"; vzhledBez = n"songbird_blendable_naked"; }
			break;
		case GlobalniID.Postava_Zaria_Hughes: vzhled = n"special__cyberpsycho_wa_ma_wat_nid_15"; vzhledBez = n"special__cyberpsycho_wa_ma_wat_nid_15_naked"; break;
		case GlobalniID.Postava_Mox_Female_02: vzhled = n"gang__mox_wa_mox_02"; vzhledBez = n"gang__mox_wa_mox_02_naked"; break;
		case GlobalniID.Postava_Mox_Female_03: vzhled = n"gang__mox_wa_mox_03"; vzhledBez = n"gang__mox_wa_mox_03_naked"; break;
		case GlobalniID.Postava_Mox_Female_04: vzhled = n"gang__mox_wa_mox_04"; vzhledBez = n"gang__mox_wa_mox_04_naked"; break;
		case GlobalniID.Postava_Mox_Female_05: vzhled = n"gang__mox_wa_mox_05"; vzhledBez = n"gang__mox_wa_mox_05_naked"; break;
		case GlobalniID.Postava_Mox_Female_06: vzhled = n"gang__mox_wa_mox_06"; vzhledBez = n"gang__mox_wa_mox_06_naked"; break;
		case GlobalniID.Postava_Mox_Female_Lvl_2_1: vzhled = n"gang__mox_wa_elite__lvl2_01"; vzhledBez = n"gang__mox_wa_elite__lvl2_01_naked"; break;
		case GlobalniID.Postava_Mox_Female_Lvl_2_2: vzhled = n"gang__mox_wa_elite__lvl2_02"; vzhledBez = n"gang__mox_wa_elite__lvl2_02_naked"; break;
		case GlobalniID.Postava_Mox_Female_Lvl_2_3: vzhled = n"gang__mox_wa_elite__lvl2_03"; vzhledBez = n"gang__mox_wa_elite__lvl2_03_naked"; break;
		case GlobalniID.Postava_Mox_Female_Lvl_3_1: vzhled = n"gang__mox_wa_elite__lvl3_01"; vzhledBez = n"gang__mox_wa_elite__lvl3_01_naked"; break;
		case GlobalniID.Postava_Mox_Female_Lvl_3_3: vzhled = n"gang__mox_wa_elite__lvl3_03"; vzhledBez = n"gang__mox_wa_elite__lvl3_03_naked"; break;
		case GlobalniID.Postava_Mox_Bouncer_02: vzhled = n"gang__mox_wa__beyond_bouncer_05"; vzhledBez = n"gang__mox_wa__beyond_bouncer_05_naked"; break;
		case GlobalniID.Postava_Martha_Frakes:
			if vybranyVzhled == 1 { vzhled = n"gang__valentinos_wa__sq018__funeral_02"; vzhledBez = n"gang__valentinos_wa__sq018__funeral_02_naked"; }
			else { vzhled = n"service__medical_wa__sts_hey_rey_01_martha_frakes"; vzhledBez = n"service__medical_wa__sts_hey_rey_01_martha_frakes_naked"; }
			break;
		case GlobalniID.Postava_Ofelia_Patricia_Sirawian: vzhled = n"gang__maelstrom_wa__sq011__patricia"; vzhledBez = n"gang__maelstrom_wa__sq011__patricia_naked"; break;
		case GlobalniID.Postava_Maman_Mama_Brigitte: vzhled = n"maman_brigitte_brigitte__default"; vzhledBez = n"maman_brigitte_brigitte__default_naked"; break;
		case GlobalniID.Postava_Helen_Wandoo: vzhled = n"service__default_wa__sts_ep1_06__barman"; vzhledBez = n"service__default_wa__sts_ep1_06__barman_naked"; break;
		case GlobalniID.Postava_Imogen: vzhled = n"citizen__nightlife_wa_default_09"; vzhledBez = n"citizen__nightlife_wa_default_09_naked"; break;
		case GlobalniID.Postava_Yoko_Tsuru: vzhled = n"service__vendor_wa_vendor_asian_02"; vzhledBez = n"service__vendor_wa_vendor_asian_02_naked"; break;
		case GlobalniID.Postava_Fiona_Vargas: vzhled = n"woman_average__sts_ep1_13__fiona"; vzhledBez = n"woman_average__sts_ep1_13__fiona_naked"; break;
		case GlobalniID.Postava_Wakakos_Desk_Girl: vzhled = n"crowd__districts_wa_rich_01"; vzhledBez = n"crowd__districts_wa_rich_01_naked"; break;
		case GlobalniID.Postava_6th_Street_Female_06: vzhled = n"gang__6thstreet_wa_menace__lvl1_03"; vzhledBez = n"gang__6thstreet_wa_menace__lvl1_03_naked"; break;
		case GlobalniID.Postava_Aldecaldos_Female_01: vzhled = n"gang__aldecaldos_wa_grunt__lvl2_02"; vzhledBez = n"gang__aldecaldos_wa_grunt__lvl2_02_naked"; break;
		case GlobalniID.Postava_Aldecaldos_Female_02: vzhled = n"citizen__aldecaldos_wa_teenager_02"; vzhledBez = n"citizen__aldecaldos_wa_teenager_02_naked"; break;
		case GlobalniID.Postava_Aldecaldos_Female_03: vzhled = n"citizen__aldecaldos_wa_teenager_04"; vzhledBez = n"citizen__aldecaldos_wa_teenager_04_naked"; break;
		case GlobalniID.Postava_Michiko_Arasaka: vzhled = n"michiko_default"; vzhledBez = n"michiko_naked"; break;
		case GlobalniID.Postava_Cynthia_Najarro: vzhled = n"citizen__rich_wa__mq040__cynthia"; vzhledBez = n"citizen__rich_wa__mq040__cynthia_naked"; break;
		case GlobalniID.Postava_Rebeca_Price: vzhled = n"service__specialist_wa__sts_hey_spr_06_rebeca_price"; vzhledBez = n"service__specialist_wa__sts_hey_spr_06_rebeca_price_naked"; break;
		case GlobalniID.Postava_Olga_Elisabeth_Longmead: vzhled = n"olga_elisabeth_longmead_olga_elisabeth_longmead"; vzhledBez = n"olga_elisabeth_longmead_olga_elisabeth_longmead_naked"; break;
		case GlobalniID.Postava_Sophia_Dupont: vzhled = n"woman_average__cz_stadium_gunsmith_01"; vzhledBez = n"woman_average__cz_stadium_gunsmith_01_naked"; break;
		case GlobalniID.Postava_Tenant_Morning_Crowd_07: vzhled = n"citizen__tenant_wa_morning_crowd_wa_07"; vzhledBez = n"citizen__tenant_wa_morning_crowd_wa_07_naked"; break;
		case GlobalniID.Postava_Wakako_Okada: vzhled = n"wakako_okada_default"; vzhledBez = n"wakako_okada_naked"; break;
		case GlobalniID.Postava_Bree_Whitney: vzhled = n"woman_average__mq305__bree"; vzhledBez = n"woman_average__mq305__bree_naked"; break;
		case GlobalniID.Postava_Sachiko_Kusama: vzhled = n"citizen__arasaka_corpo_wa__q201__space_scientist"; vzhledBez = n"citizen__arasaka_corpo_wa__q201__space_scientist_naked"; break;
		case GlobalniID.Postava_Dietlinde: vzhled = n"service__vendor_wa__wat_nid_foodshop_02"; vzhledBez = n"service__vendor_wa__wat_nid_foodshop_02_naked"; break;
		case GlobalniID.Postava_Shelma: vzhled = n"wa_generic_netrunner_02"; vzhledBez = n"wa_generic_netrunner_02_naked"; break;
		case GlobalniID.Postava_Linh_Hyunh: vzhled = n"wa_ma_hey_spr_04_sister"; vzhledBez = n"wa_ma_hey_spr_04_sister_naked"; break;
		case GlobalniID.Postava_Lowlife_Latino_01: vzhled = n"citizen__lowlife_wa_latino_01"; vzhledBez = n"citizen__lowlife_wa_latino_01_naked"; break;
		case GlobalniID.Postava_Rich_Female_12: vzhled = n"citizen__rich_wa_rich_12"; vzhledBez = n"citizen__rich_wa_rich_12_naked"; break;
		case GlobalniID.Postava_Sexworker_Doll_02: vzhled = n"service__sexworker_wa_doll_02"; vzhledBez = n"service__sexworker_wa_doll_02_naked"; break;
		case GlobalniID.Postava_Carol_Emeka: vzhled = n"carol_default"; vzhledBez = n"carol_naked"; break;
		case GlobalniID.Postava_Vendor_03: vzhled = n"vendors_wa_vendor_wa_03"; vzhledBez = n"vendors_wa_vendor_wa_03_naked"; break;
		case GlobalniID.Postava_Caliente_Waitress_01: vzhled = n"service__dining_wa_capitan_caliente_waitress_wa_01"; vzhledBez = n"service__dining_wa_capitan_caliente_waitress_wa_01_naked"; break;
		case GlobalniID.Postava_Konpeki_Waitress_01: vzhled = n"citizen__arasaka_corpo_wa__q004__konpeki_waitress_01"; vzhledBez = n"citizen__arasaka_corpo_wa__q004__konpeki_waitress_01_naked"; break;
		case GlobalniID.Postava_Miranda_Lawson: vzhled = n"default"; vzhledBez = n"naked_ebbrb"; break;
		case GlobalniID.Postava_Clothing_Seller_Wat_Nid: vzhled = n"service__vendor_wa__wat_nid_clothingshop_01"; vzhledBez = n"service__vendor_wa__wat_nid_clothingshop_01_naked"; break;
		case GlobalniID.Postava_Queen_Of_The_Stoop_03: vzhled = n"queen_of_the_stoop_wa_queen_of_the_stoop_wa_03"; vzhledBez = n"queen_of_the_stoop_wa_queen_of_the_stoop_wa_03_naked"; break;
		case GlobalniID.Postava_Tourist_01: vzhled = n"citizen__youngster_wa__mq026__tourist_01"; vzhledBez = n"citizen__youngster_wa__mq026__tourist_01_naked"; break;
		case GlobalniID.Postava_Tourist_02: vzhled = n"citizen__youngster_wa__mq026__tourist_02"; vzhledBez = n"citizen__youngster_wa__mq026__tourist_02_naked"; break;
		case GlobalniID.Postava_Arasaka_Corpo_01: vzhled = n"citizen__arasaka_corpo_wa_corporate_01"; vzhledBez = n"citizen__arasaka_corpo_wa_corporate_01_naked"; break;
		case GlobalniID.Postava_Aldecaldos_Female_Driver_Lvl_3_3: vzhled = n"gang__aldecaldos_wa_driver__lvl3_03"; vzhledBez = n"gang__aldecaldos_wa_driver__lvl3_03_naked"; break;
		case GlobalniID.Postava_Arasaka_Netrunner_Lvl_2_3: vzhled = n"corpo__arasaka_wa_netrunner__lvl2_03"; vzhledBez = n"corpo__arasaka_wa_netrunner__lvl2_03_naked"; break;
		case GlobalniID.Postava_Veteran_Guard_01: vzhled = n"corpo__generic_wa_generic_01"; vzhledBez = n"corpo__generic_wa_generic_01_naked"; break;
		case GlobalniID.Postava_Tube_Dancer_08: vzhled = n"service__tubedancer_wa_tube_dancer_08_ground"; vzhledBez = n"service__tubedancer_wa_tube_dancer_08_ground_naked"; break;
		case GlobalniID.Postava_Song_So_Ri:
			if vybranyVzhled == 1 { vzhled = n"songbird_casual"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 2 { vzhled = n"songbird_casual_alt"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 3 { vzhled = n"songbird_home"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 4 { vzhled = n"songbird_date"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 5 { vzhled = n"songbird_night_out"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 6 { vzhled = n"songbird_sport"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 7 { vzhled = n"songbird_netrunner"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 8 { vzhled = n"songbird_kimono"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 9 { vzhled = n"songbird_bdsm"; vzhledBez = n"songbird_bdsm"; }
			else if vybranyVzhled == 10 { vzhled = n"songbird_bikini"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 11 { vzhled = n"songbird_halloween"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 12 { vzhled = n"songbird_panties"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 13 { vzhled = n"songbird_lingerie"; vzhledBez = n"songbird_nude"; }
			else if vybranyVzhled == 14 { vzhled = n"songbird_towel"; vzhledBez = n"songbird_nude"; }
			else { vzhled = n"songbird_default"; vzhledBez = n"songbird_nude"; }
			break;
		case GlobalniID.Postava_Youngster_Slacker_14: vzhled = n"citizen__youngster_wa_slacker_wa_014"; vzhledBez = n"citizen__youngster_wa_slacker_wa_014_naked"; break;
		case GlobalniID.Postava_Rhino: vzhled = n"gang__animals_wba__mq025__rhino"; vzhledBez = n"gang__animals_wba__mq025__rhino_naked"; break;
		case GlobalniID.Postava_Julia_Young:
			if vybranyVzhled == 1 { vzhled = n"outcast__wa_junkie_02_clean"; vzhledBez = n"outcast__wa_junkie_02_clean_naked"; }
			else { vzhled = n"outcast__wa_junkie_02"; vzhledBez = n"outcast__wa_junkie_02_naked"; }
			break;
		case GlobalniID.Postava_Grace_Karina_Voronova: vzhled = n"service__media_wa_actress_bushido__grace"; vzhledBez = n"service__media_wa_actress_bushido__grace_naked"; break;
		case GlobalniID.Postava_Tyler_Zan: vzhled = n"woman_average__q307__cybermerc"; vzhledBez = n"woman_average__q307__cybermerc_naked"; break;
		case GlobalniID.Postava_Yishen_Rhee: vzhled = n"gang__cyberpunk_wa__q108_crowd_f_02_vending_machine"; vzhledBez = n"gang__cyberpunk_wa__q108_crowd_f_02_vending_machine_naked"; break;
		case GlobalniID.Postava_Dogtown_Joytoy_01: vzhled = n"service__sexworker_wa_prostitute_01"; vzhledBez = n"service__sexworker_wa_prostitute_01_naked"; break;
		case GlobalniID.Postava_Dogtown_Nightlife_02: vzhled = n"citizen__nightlife_wa_default_02"; vzhledBez = n"citizen__nightlife_wa_default_02_naked"; break;
		case GlobalniID.Postava_Dogtown_Nightlife_05: vzhled = n"citizen__nightlife_wa_default_05"; vzhledBez = n"citizen__nightlife_wa_default_05_naked"; break;
		case GlobalniID.Postava_Dogtown_Nightlife_10: vzhled = n"citizen__nightlife_wa_default_10"; vzhledBez = n"citizen__nightlife_wa_default_10_naked"; break;
		case GlobalniID.Postava_Heavy_Hearts_Waitress_02: vzhled = n"service__default_wa_waitress_pyramid_02"; vzhledBez = n"service__default_wa_waitress_pyramid_02_naked"; break;
		case GlobalniID.Postava_Nina_Kraviz: vzhled = n"service__ripperdoc_wa__nina_kraviz"; break;
		case GlobalniID.Postava_Lana_Prince: vzhled = n"citizen__aldecaldos_wa__mq042__nomad_girl"; break;
		case GlobalniID.Postava_Animals_Female_01: vzhled = n"gang__animals_wba_grunt__lvl2_02"; vzhledBez = n"gang__animals_wba_grunt__lvl2_02_naked"; break;
		case GlobalniID.Postava_Animals_Female_02: vzhled = n"gang__animals_wba_elite__lvl2_01"; vzhledBez = n"gang__animals_wba_elite__lvl2_01_naked"; break;
		case GlobalniID.Postava_Animals_Female_03: vzhled = n"gang__animals_wba_elite__lvl2_02"; vzhledBez = n"gang__animals_wba_elite__lvl2_02_naked"; break;
		case GlobalniID.Postava_Dogtown_Joytoy_06: vzhled = n"service__sexworker_wa_prostitute_06"; vzhledBez = n"service__sexworker_wa_prostitute_06_naked"; break;
		case GlobalniID.Postava_Heavy_Hearts_Waitress_04: vzhled = n"service__default_wa_waitress_pyramid_04"; vzhledBez = n"service__default_wa_waitress_pyramid_04_naked"; break;
		case GlobalniID.Postava_Barghest_Female_01: vzhled = n"gang__kurtz_army_wa__ow__soldier_off_duty_01"; vzhledBez = n"gang__kurtz_army_wa__ow__soldier_off_duty_01_naked"; break;
		case GlobalniID.Postava_Barghest_Female_02: vzhled = n"gang__kurtz_army_wa__ow__soldier_off_duty_02"; vzhledBez = n"gang__kurtz_army_wa__ow__soldier_off_duty_02_naked"; break;
		case GlobalniID.Postava_Barghest_Female_03: vzhled = n"gang__kurtz_army_wa__ow__soldier_off_duty_07"; vzhledBez = n"gang__kurtz_army_wa__ow__soldier_off_duty_07_naked"; break;
		case GlobalniID.Postava_Barghest_Female_04: vzhled = n"gang__kurtz_army_wa__ow__soldier_off_duty_09"; vzhledBez = n"gang__kurtz_army_wa__ow__soldier_off_duty_09_naked"; break;
		case GlobalniID.Postava_Barghest_Female_05: vzhled = n"citizen_barghest_wa_default_01"; vzhledBez = n"citizen_barghest_wa_default_01_naked"; break;
		case GlobalniID.Postava_Scavengers_Female_01: vzhled = n"gang__scavenger_wa_fast__lvl3_01"; vzhledBez = n"gang__scavenger_wa_fast__lvl3_01_naked"; break;
		case GlobalniID.Postava_Scavengers_Female_02: vzhled = n"gang__scavenger_wa_grunt__lvl2_01"; vzhledBez = n"gang__scavenger_wa_grunt__lvl2_01_naked"; break;
		case GlobalniID.Postava_Scavengers_Female_03: vzhled = n"gang__scavenger_wa_grunt__lvl2_03"; vzhledBez = n"gang__scavenger_wa_grunt__lvl2_03_naked"; break;
		case GlobalniID.Postava_Scavengers_Female_04: vzhled = n"gang__scavenger_wa_grunt__lvl2_05"; vzhledBez = n"gang__scavenger_wa_grunt__lvl2_05_naked"; break;
		case GlobalniID.Postava_Wraiths_Female_01: vzhled = n"gang__wraith_wa_grunt__lvl1_01"; vzhledBez = n"gang__wraith_wa_grunt__lvl1_01_naked"; break;
		case GlobalniID.Postava_Wraiths_Female_02: vzhled = n"gang__wraith_wa_grunt__lvl1_02"; vzhledBez = n"gang__wraith_wa_grunt__lvl1_02_naked"; break;
		case GlobalniID.Postava_Wraiths_Female_03: vzhled = n"gang__wraith_wa_grunt__lvl1_03"; vzhledBez = n"gang__wraith_wa_grunt__lvl1_03_naked"; break;
		case GlobalniID.Postava_Wraiths_Female_04: vzhled = n"gang__wraith_wa_grunt__lvl1_04"; vzhledBez = n"gang__wraith_wa_grunt__lvl1_04_naked"; break;
		case GlobalniID.Postava_Sofia_Rossi: vzhled = n"service__sexworker_wa_prostitute_poor_01"; vzhledBez = n"service__sexworker_wa_prostitute_poor_01_naked"; break;
		case GlobalniID.Postava_E3_Female_V:
			if vybranyVzhled == 1 { vzhled = n"e3_v_female_casual"; vzhledBez = n"e3_v_female_nude"; }
			else if vybranyVzhled == 2 { vzhled = n"e3_v_female_panties"; vzhledBez = n"e3_v_female_nude"; }
			else if vybranyVzhled == 3 { vzhled = n"e3_v_female_date"; vzhledBez = n"e3_v_female_nude"; }
			else if vybranyVzhled == 4 { vzhled = n"e3_v_female_combat"; vzhledBez = n"e3_v_female_nude"; }
			else { vzhled = n"e3_v_female_default"; vzhledBez = n"e3_v_female_nude"; }
			break;
		case GlobalniID.Postava_Barbara_Babs_Okoye: vzhled = n"mq301__babs"; vzhledBez = n"mq301__babs_naked"; break;
		case GlobalniID.Postava_Trigger: vzhled = n"gang__cyberpunk_wa__q108_crowd_f_02_drugs"; vzhledBez = n"gang__cyberpunk_wa__q108_crowd_f_02_drugs_naked"; break;
		case GlobalniID.Postava_Godiva: vzhled = n"gang__cyberpunk_wa__q108_barman_f_01"; vzhledBez = n"gang__cyberpunk_wa__q108_barman_f_01_naked"; break;
		case GlobalniID.Postava_Kissy: vzhled = n"gang__cyberpunk_wa__q108_mercenary_f_02_deal_chat"; vzhledBez = n"gang__cyberpunk_wa__q108_mercenary_f_02_deal_chat_naked"; break;
		case GlobalniID.Postava_Roxxi: vzhled = n"gang__cyberpunk_wa__q108_mercenary_f_01_deal_chat"; vzhledBez = n"gang__cyberpunk_wa__q108_mercenary_f_01_deal_chat_naked"; break;
		case GlobalniID.Postava_Paradise_Waitress_03: vzhled = n"paradise_wa_waiter_03"; vzhledBez = n"paradise_wa_waiter_03_naked"; break;
		case GlobalniID.Postava_Clothing_Seller_Bls_Ina: vzhled = n"service__vendor_wa__bls_ina_se1_clothingshop_01"; vzhledBez = n"service__vendor_wa__bls_ina_se1_clothingshop_01_naked"; break;
		case GlobalniID.Postava_Barghest_Female_Guard_01: vzhled = n"gang__kurtz_army_wa__ow__guard_pyramid_01"; vzhledBez = n"gang__kurtz_army_wa__ow__guard_pyramid_01_naked"; break;
		case GlobalniID.Postava_Pacific_Female_06: vzhled = n"citizen__pacific_wa_default_06"; vzhledBez = n"citizen__pacific_wa_default_06_naked"; break;
		case GlobalniID.Postava_Susan_Abernathy: vzhled = n"citizen__arasaka_corpo_wa__q000__abernathy"; vzhledBez = n"citizen__arasaka_corpo_wa__q000__abernathy_naked"; break;
		case GlobalniID.Postava_Heavy_Hearts_Waitress_01: vzhled = n"service__default_wa_waitress_pyramid_01"; vzhledBez = n"service__default_wa_waitress_pyramid_01_naked"; break;
		case GlobalniID.Postava_Heavy_Hearts_Waitress_03: vzhled = n"service__default_wa_waitress_pyramid_03"; vzhledBez = n"service__default_wa_waitress_pyramid_03_naked"; break;
		case GlobalniID.Postava_Heavy_Hearts_Waitress_05: vzhled = n"service__default_wa_waitress_pyramid_05"; vzhledBez = n"service__default_wa_waitress_pyramid_05_naked"; break;
		case GlobalniID.Postava_NCPD_Female_02: vzhled = n"corpo__ncpd_wa__q001__policewoman"; vzhledBez = n"corpo__ncpd_wa__q001__policewoman_naked"; break;
		case GlobalniID.Postava_Nightlife_Hottie_21: vzhled = n"citizen__nightlife_wa_hood_hottie_wa_21"; vzhledBez = n"citizen__nightlife_wa_hood_hottie_wa_21_naked"; break;
		case GlobalniID.Postava_Lizzies_Stripper_04: vzhled = n"service__sexworker_wa__q004__lizzies_stripper_04"; vzhledBez = n"service__sexworker_wa__q004__lizzies_stripper_04_naked"; break;
		case GlobalniID.Postava_Arasaka_Corpo_06: vzhled = n"citizen__arasaka_corpo_wa_corporate_06"; vzhledBez = n"citizen__arasaka_corpo_wa_corporate_06_naked"; break;
		case GlobalniID.Postava_Arabella_Spider_Murphy: vzhled = n"service__specialist_wa__q101__spider_murphy"; vzhledBez = n"service__specialist_wa__q101__spider_murphy_naked"; break;
		case GlobalniID.Postava_Zoe_Alonzo: vzhled = n"zoe_alonzo_default"; vzhledBez = n"zoe_alonzo_naked"; break;
		case GlobalniID.Postava_Yelena_Sidorova: vzhled = n"yelena_sidorova_yelena_sidorova"; vzhledBez = n"yelena_sidorova_yelena_sidorova_naked"; break;
		case GlobalniID.Postava_Taki_Kenmochi: vzhled = n"gang__tyger_wa__sts_wat_kab_107_taki_furaido_chikin_kenmochi"; vzhledBez = n"gang__tyger_wa__sts_wat_kab_107_taki_furaido_chikin_kenmochi_naked"; break;
		case GlobalniID.Postava_Lt_Mower: vzhled = n"special__cyberpsycho_wa_ma_wat_kab_08_major"; vzhledBez = n"special__cyberpsycho_wa_ma_wat_kab_08_major_naked"; break;
		case GlobalniID.Postava_Tamara_Cosby: vzhled = n"special__cyberpsycho_wa_ma_std_arr_06"; vzhledBez = n"special__cyberpsycho_wa_ma_std_arr_06_naked"; break;
		case GlobalniID.Postava_Rose_Horrigan: vzhled = n"citizen__lowlife_wa__sts_std_rcr_05_rose_horrigan"; vzhledBez = n"citizen__lowlife_wa__sts_std_rcr_05_rose_horrigan_naked"; break;
		case GlobalniID.Postava_Aguilar_Nubiola_Female: vzhled = n"nicola_wa__mq304__nicola_tpp"; vzhledBez = n"nicola_wa__mq304__nicola_tpp_naked"; break;
		case GlobalniID.Postava_Biker_Female_04: vzhled = n"citizen__biker_wa_biker_04"; vzhledBez = n"citizen__biker_wa_biker_04_naked"; break;
		case GlobalniID.Postava_Arasaka_Scientist: vzhled = n"citizen__arasaka_corpo_wa__q101__soulkiller_operator"; vzhledBez = n"citizen__arasaka_corpo_wa__q101__soulkiller_operator_naked"; break;
		case GlobalniID.Postava_Nightlife_Hottie_15: vzhled = n"citizen__nightlife_wa_hood_hottie_wa_15"; vzhledBez = n"citizen__nightlife_wa_hood_hottie_wa_15_naked"; break;
		case GlobalniID.Postava_Pacific_Female_13: vzhled = n"citizen__pacific_wa_default_13"; vzhledBez = n"citizen__pacific_wa_default_13_naked"; break;
		case GlobalniID.Postava_Laura_May: vzhled = n"woman_average__cz_con_junkshop_01"; vzhledBez = n"woman_average__cz_con_junkshop_01_naked"; break;
		case GlobalniID.Postava_Sofia_Ramirez: vzhled = n"service__sexworker_wa__ma_pac_cvi_08__tortured"; vzhledBez = n"service__sexworker_wa__ma_pac_cvi_08__tortured_naked"; break;
		case GlobalniID.Postava_Food_Seller_Wbr_Jpn: vzhled = n"service__vendor_wa__wbr_jpn_foodshop_01"; vzhledBez = n"service__vendor_wa__wbr_jpn_foodshop_01_naked"; break;
		case GlobalniID.Postava_Maggie_Isley: vzhled = n"outcast__wa__cbj_ep1_02_cyberjunkie"; vzhledBez = n"outcast__wa__cbj_ep1_02_cyberjunkie_naked"; break;
		case GlobalniID.Postava_Ayo_Zarin: vzhled = n"gang__voodoo_wa__we_ep1_05_high_rank"; vzhledBez = n"gang__voodoo_wa__we_ep1_05_high_rank_naked"; break;
		case GlobalniID.Postava_Journey_Ruiz: vzhled = n"service__vendor_wa__q204__music_store_owner"; vzhledBez = n"service__vendor_wa__q204__music_store_owner_naked"; break;
		case GlobalniID.Postava_Sexworker_Prostitute_05: vzhled = n"service__sexworker_wa_prostitute_poor_05"; vzhledBez = n"service__sexworker_wa_prostitute_poor_05_naked"; break;
		case GlobalniID.Postava_Sexworker_Prostitute_07: vzhled = n"service__sexworker_wa_prostitute_poor_07"; vzhledBez = n"service__sexworker_wa_prostitute_poor_07_naked"; break;
		case GlobalniID.Postava_Sexworker_Doll_04: vzhled = n"service__sexworker_wa_doll_04"; vzhledBez = n"service__sexworker_wa_doll_04_naked"; break;
		case GlobalniID.Postava_Sexworker_Doll_08: vzhled = n"service__sexworker_wa_doll_08"; vzhledBez = n"service__sexworker_wa_doll_08_naked"; break;
		case GlobalniID.Postava_Sexworker_10: vzhled = n"prostitute_wa_prostitute_wa_10"; vzhledBez = n"prostitute_wa_prostitute_wa_10_naked"; break;
		case GlobalniID.Postava_Sexworker_02: vzhled = n"prostitute_wa_prostitute_wa_02"; vzhledBez = n"prostitute_wa_prostitute_wa_02_naked"; break;
		case GlobalniID.Postava_Nancy_Hartley:
			if vybranyVzhled == 1 { vzhled = n"nancy_nancy_2020"; vzhledBez = n"nancy_nancy_2020_naked"; }
			else { vzhled = n"nancy_default"; vzhledBez = n"nancy_naked"; }
			break;
		case GlobalniID.Postava_Griselda_Green_Cloud_Martinez: vzhled = n"citizen__nightlife_wa__mq028__green_cloud"; vzhledBez = n"citizen__nightlife_wa__mq028__green_cloud_naked"; break;
		case GlobalniID.Postava_Lucy_Thackery: vzhled = n"service__ripperdoc_wa__sts_wat_kab_02_lucy_thackery"; vzhledBez = n"service__ripperdoc_wa__sts_wat_kab_02_lucy_thackery_naked"; break;
		case GlobalniID.Postava_Voodoo_Boys_Female_01: vzhled = n"gang__voodoo_wa_grunt__lvl1_02"; vzhledBez = n"gang__voodoo_wa_grunt__lvl1_02_naked"; break;
		case GlobalniID.Postava_Voodoo_Boys_Female_02: vzhled = n"gang__voodoo_wa_grunt__lvl2_03"; vzhledBez = n"gang__voodoo_wa_grunt__lvl2_03_naked"; break;
		case GlobalniID.Postava_Voodoo_Boys_Female_03: vzhled = n"gang__voodoo_wa_netrunner__lvl2_02"; vzhledBez = n"gang__voodoo_wa_netrunner__lvl2_02_naked"; break;
		case GlobalniID.Postava_Voodoo_Boys_Female_04: vzhled = n"gang__voodoo_wa_grunt__lvl1_01"; vzhledBez = n"gang__voodoo_wa_grunt__lvl1_01_naked"; break;
		case GlobalniID.Postava_Voodoo_Boys_Female_05: vzhled = n"gang__voodoo_wa_grunt__lvl2_03"; vzhledBez = n"gang__voodoo_wa_grunt__lvl2_03_naked"; break;
		case GlobalniID.Postava_Voodoo_Boys_Female_06: vzhled = n"gang__voodoo_wa_netrunner__lvl3_02"; vzhledBez = n"gang__voodoo_wa_netrunner__lvl3_02_naked"; break;
		case GlobalniID.Postava_Voodoo_Boys_Female_07: vzhled = n"gang__voodoo_wa_netrunner__lvl2_01"; vzhledBez = n"gang__voodoo_wa_netrunner__lvl2_01_naked"; break;
		case GlobalniID.Postava_Scavengers_Female_05: vzhled = n"gang__scavenger_wa_grunt__lvl1_03"; vzhledBez = n"gang__scavenger_wa_grunt__lvl1_03_naked"; break;
		case GlobalniID.Postava_Scavengers_Female_06: vzhled = n"gang__scavenger_wa_grunt__lvl2_02"; vzhledBez = n"gang__scavenger_wa_grunt__lvl2_02_naked"; break;
		case GlobalniID.Postava_Scavengers_Female_07: vzhled = n"gang__scavenger_wa_grunt__lvl3_01"; vzhledBez = n"gang__scavenger_wa_grunt__lvl3_01_naked"; break;
		case GlobalniID.Postava_Scavengers_Female_08: vzhled = n"gang__scavenger_wa_netrunner__lvl2_03"; vzhledBez = n"gang__scavenger_wa_netrunner__lvl2_03_naked"; break;
		case GlobalniID.Postava_Mallrat_05: vzhled = n"mallrat_wa_mallrat_wa_05"; vzhledBez = n"mallrat_wa_mallrat_wa_05_naked"; break;
		case GlobalniID.Postava_Queen_Of_The_Stoop_16: vzhled = n"queen_of_the_stoop_wa_queen_of_the_stoop_wa_16"; vzhledBez = n"queen_of_the_stoop_wa_queen_of_the_stoop_wa_16_naked"; break;
		case GlobalniID.Postava_R3n0: vzhled = n"citizen__arasaka_corpo_wa__mq015__seller"; vzhledBez = n"citizen__arasaka_corpo_wa__mq015__seller_naked"; break;
		case GlobalniID.Postava_Rich_Female_25: vzhled = n"citizen__rich_wa_rich_25_casual"; vzhledBez = n"citizen__rich_wa_rich_25_casual_naked"; break;
		case GlobalniID.Postava_Mallrat_10: vzhled = n"mallrat_wa_mallrat_wa_10"; vzhledBez = n"mallrat_wa_mallrat_wa_10_naked"; break;
		case GlobalniID.Postava_District_Teen_01: vzhled = n"crowd__districts_wa_teen_01"; vzhledBez = n"crowd__districts_wa_teen_01_naked"; break;
		case GlobalniID.Postava_Sexworker_Doll_07: vzhled = n"service__sexworker_wa_doll_07"; vzhledBez = n"service__sexworker_wa_doll_07_naked"; break;
		case GlobalniID.Postava_Queen_Of_The_Stoop_07: vzhled = n"queen_of_the_stoop_wa_queen_of_the_stoop_wa_07"; vzhledBez = n"queen_of_the_stoop_wa_queen_of_the_stoop_wa_07_naked"; break;
		case GlobalniID.Postava_Linda_Spencer:
			if vybranyVzhled == 1 { vzhled = n"service__dining_wa__mq019__fa_club_staff_club_closed"; vzhledBez = n"service__dining_wa__mq019__fa_club_staff_club_naked"; }
			else { vzhled = n"service__dining_wa__mq019__fa_club_staff_club_opened"; vzhledBez = n"service__dining_wa__mq019__fa_club_staff_club_naked"; }
			break;
		case GlobalniID.Postava_Citizen_Corporat_01: vzhled = n"corporat_wa_corporat_wa_01"; vzhledBez = n"corporat_wa_corporat_wa_01_naked"; break;
		case GlobalniID.Postava_Citizen_Corporat_12: vzhled = n"citizen__corporat_wa_corporat_wa_12"; vzhledBez = n"citizen__corporat_wa_corporat_wa_12_naked"; break;
		case GlobalniID.Postava_Youngster_Slacker_05: vzhled = n"slacker_wa_slacker_wa_05"; vzhledBez = n"slacker_wa_slacker_wa_05_naked"; break;
		case GlobalniID.Postava_Youngster_Slacker_06: vzhled = n"slacker_wa_slacker_wa_06"; vzhledBez = n"slacker_wa_slacker_wa_06_naked"; break;
		case GlobalniID.Postava_Youngster_Slacker_08: vzhled = n"slacker_wa_slacker_wa_08"; vzhledBez = n"slacker_wa_slacker_wa_08_naked"; break;
		case GlobalniID.Postava_Micaela_Ruiz: vzhled = n"citizen__lowlife_wa__mq025__cesars_girl"; vzhledBez = n"citizen__lowlife_wa__mq025__cesars_girl_naked"; break;
		case GlobalniID.Postava_Paradise_Client_02:
			if vybranyVzhled == 1 { vzhled = n"paradise_wa_default_02_2"; vzhledBez = n"paradise_wa_default_02_2_naked"; }
			else { vzhled = n"paradise_wa_default_02"; vzhledBez = n"paradise_wa_default_02_naked"; }
			break;
		case GlobalniID.Postava_Pacific_Female_07: vzhled = n"citizen__pacific_wa_default_07_3"; vzhledBez = n"citizen__pacific_wa_default_07_3_naked"; break;
		case GlobalniID.Postava_Rich_Female_14: vzhled = n"citizen__rich_wa_rich_14"; vzhledBez = n"citizen__rich_wa_rich_14_naked"; break;
		case GlobalniID.Postava_Clothing_Seller_Std_Rcr: vzhled = n"service__vendor_wa__std_rcr_clothingshop_01"; vzhledBez = n"service__vendor_wa__std_rcr_clothingshop_01_naked"; break;
		case GlobalniID.Postava_Hologram_Prostitute:
			if vybranyVzhled == 1 { vzhled = n"special__hologram_wa__q105__jigjig_prostitute_no_holo"; vzhledBez = n"special__hologram_wa__q105__jigjig_prostitute_no_holo_naked"; }
			else { vzhled = n"special__hologram_wa__q105__jigjig_prostitute"; vzhledBez = n"special__hologram_wa__q105__jigjig_prostitute_naked"; }
			break;
		case GlobalniID.Postava_Hologram_Pachinko_Girl:
			if vybranyVzhled == 1 { vzhled = n"special__hologram_wa__q001_pachinko_girl_no_holo"; vzhledBez = n"special__hologram_wa__q001_pachinko_girl_no_holo_naked"; }
			else { vzhled = n"special__hologram_wa__q001_pachinko_girl"; vzhledBez = n"special__hologram_wa__q001_pachinko_girl_naked"; }
			break;
		case GlobalniID.Postava_Hologram_VIP:
			if vybranyVzhled == 1 { vzhled = n"special__hologram_wa__q004_vip_room_hologram_no_holo"; vzhledBez = n"special__hologram_wa__q004_vip_room_hologram_no_holo_naked"; }
			else { vzhled = n"special__hologram_wa__q004_vip_room_hologram"; vzhledBez = n"special__hologram_wa__q004_vip_room_hologram_naked"; }
			break;
		case GlobalniID.Postava_Nova_MacCaster: vzhled = n"gang__maelstrom_wa_grunt__lvl2_06"; vzhledBez = n"gang__maelstrom_wa_grunt__lvl2_06_naked"; break;
		case GlobalniID.Postava_Canon_FemV:
			if vybranyVzhled == 1 { vzhled = n"Corpo"; vzhledBez = n"DIY_Nude"; }
			else if vybranyVzhled == 2 { vzhled = n"Nomad"; vzhledBez = n"DIY_Nude"; }
			else if vybranyVzhled == 3 { vzhled = n"Street_Kid"; vzhledBez = n"DIY_Nude"; }
			else if vybranyVzhled == 4 { vzhled = n"Fortnite"; vzhledBez = n"DIY_Nude"; }
			else if vybranyVzhled == 5 { vzhled = n"Fortnite_v2"; vzhledBez = n"DIY_Nude"; }
			else if vybranyVzhled == 6 { vzhled = n"Phantom_Liberty"; vzhledBez = n"DIY_Nude"; }
			else if vybranyVzhled == 7 { vzhled = n"Phantom_Liberty_v2"; vzhledBez = n"DIY_Nude"; }
			else { vzhled = n"Main"; vzhledBez = n"DIY_Nude"; }
			break;
		case GlobalniID.Postava_Lowlife_Latino_07: vzhled = n"citizen__lowlife_wa_latino_07"; vzhledBez = n"citizen__lowlife_wa_latino_07_naked"; break;
		case GlobalniID.Postava_Clothing_Seller_Wbr_Jpn: vzhled = n"service__vendor_wa__wbr_jpn_cloth_01"; vzhledBez = n"service__vendor_wa__wbr_jpn_cloth_01_naked"; break;
		case GlobalniID.Postava_Christine_Markov: vzhled = n"service__vendor_wa__sq012__christine_markov"; vzhledBez = n"service__vendor_wa__sq012__christine_markov_naked"; break;

		case GlobalniID.Postava_Kerry_Eurodyne:
			if vybranyVzhled == 1 { vzhled = n"kerry_eurodyne_kerry_eurodyne_young_2013"; vzhledBez = n"kerry_eurodyne_kerry_eurodyne_young_2013_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"kerry_eurodyne_kerry_eurodyne_young"; vzhledBez = n"kerry_eurodyne_kerry_eurodyne_young_naked"; }
			else if vybranyVzhled == 3 { vzhled = n"kerry_ep__q307__two_years_later_lizzies_bds"; vzhledBez = n"kerry_ep__q307__two_years_later_lizzies_bds_naked"; }
			else { vzhled = n"kerry_eurodyne_kerry_eurodyne_old"; vzhledBez = n"kerry_eurodyne_nude"; }
			break;
		case GlobalniID.Postava_River_Ward: vzhled = n"river_ward_default"; vzhledBez = n"river_ward_naked"; break;
		case GlobalniID.Postava_Angel: vzhled = n"service__sexworker_ma__q105__angel"; vzhledBez = n"service__sexworker_ma__q105__angel_naked"; break;
		case GlobalniID.Postava_Mike_Tiny_Mike_Kowalski: vzhled = n"gang__cyberpunk_ma_STS_wat_kab_01_tiny_mike"; vzhledBez = n"gang__cyberpunk_ma_STS_wat_kab_01_tiny_mike_naked"; break;
		case GlobalniID.Postava_Saul_Bright: vzhled = n"saul_default"; vzhledBez = n"saul_naked"; break;
		case GlobalniID.Postava_Jackie_Welles: vzhled = n"jackie_welles_default"; vzhledBez = n"jackie_welles_naked"; break;
		case GlobalniID.Postava_Victor_Vektor: vzhled = n"victor_vektor_default"; vzhledBez = n"victor_vektor_naked"; break;
		case GlobalniID.Postava_Jefferson_Peralez: vzhled = n"jefferson_peralez_default"; vzhledBez = n"jefferson_peralez_naked"; break;
		case GlobalniID.Postava_Tom_Caldera: vzhled = n"service__sexworker_ma__q105__tom"; vzhledBez = n"service__sexworker_ma__q105__tom_naked"; break;
		case GlobalniID.Postava_Benjamin_Stone: vzhled = n"citizen__workout_mb__q000__backetball_thug"; vzhledBez = n"citizen__workout_mb__q000__backetball_thug_naked"; break;
		case GlobalniID.Postava_Mitch_Anderson: vzhled = n"mitch_default"; vzhledBez = n"mitch_naked"; break;
		case GlobalniID.Postava_Aymeric_Cassel: vzhled = n"theo_default"; vzhledBez = n"theo_naked"; break;
		case GlobalniID.Postava_Paco_Torres: vzhled = n"mq301__paco"; vzhledBez = n"mq301__paco_naked"; break;
		case GlobalniID.Postava_Placide: vzhled = n"placide_placide__default"; vzhledBez = n"placide_placide__naked"; break;
		case GlobalniID.Postava_Goro_Takemura:
			if vybranyVzhled == 1 { vzhled = n"takemura_ep__q307__two_years_later"; vzhledBez = n"takemura_ep__q307__two_years_later_naked"; }
			else { vzhled = n"goro_takemura_ronin_shirt"; vzhledBez = n"goro_takemura_naked"; }
			break;
		case GlobalniID.Postava_Sandayu_Oda: vzhled = n"oda_oda_no_gear"; vzhledBez = n"oda_oda_no_gear_naked"; break;
		case GlobalniID.Postava_Ozob_Bozo: vzhled = n"ozob_no_jacket"; vzhledBez = n"ozob_naked"; break;
		case GlobalniID.Postava_Muamar_El_Capitan_Reyes: vzhled = n"capitan_reyes_default"; vzhledBez = n"capitan_reyes_naked"; break;
		case GlobalniID.Postava_Jotaro_Shobo: vzhled = n"gang__tyger_ma__sts_wat_kab_07_jotaro"; vzhledBez = n"gang__tyger_ma__sts_wat_kab_07_jotaro_naked"; break;
		case GlobalniID.Postava_Kurt_Hansen: vzhled = n"kurt_default"; vzhledBez = n"kurt_naked"; break;
		case GlobalniID.Postava_Ayden_Daniels: vzhled = n"man_average__sa_ep1_courier__police_02"; vzhledBez = n"man_average__sa_ep1_courier__police_02_naked"; break;
		case GlobalniID.Postava_NCPD_Male_01: vzhled = n"corpo__ncpd_ma_ncpd_01"; vzhledBez = n"corpo__ncpd_ma_ncpd_01_naked"; break;
		case GlobalniID.Postava_Dusty_Lowe: vzhled = n"service__sexworker_ma__ow__poor_01"; vzhledBez = n"service__sexworker_ma__ow__poor_01_naked"; break;
		case GlobalniID.Postava_Logan_Scott: vzhled = n"service__sexworker_ma__ow__luxury_01"; vzhledBez = n"service__sexworker_ma__ow__luxury_01_naked"; break;
		case GlobalniID.Postava_Valentinos_Male_01: vzhled = n"gang__valentinos_ma_grunt__lvl2_02"; vzhledBez = n"gang__valentinos_ma_grunt__lvl2_02_naked"; break;
		case GlobalniID.Postava_Valentinos_Male_02: vzhled = n"gang__valentinos_ma_grunt__lvl2_09"; vzhledBez = n"gang__valentinos_ma_grunt__lvl2_09_naked"; break;
		case GlobalniID.Postava_Valentinos_Male_03: vzhled = n"gang__valentinos_ma_elite__lvl2_09"; vzhledBez = n"gang__valentinos_ma_elite__lvl2_09_naked"; break;
		case GlobalniID.Postava_6th_Street_Male_01: vzhled = n"gang__6thstreet_ma_hooligan__lvl1_01"; vzhledBez = n"gang__6thstreet_ma_hooligan__lvl1_01_naked"; break;
		case GlobalniID.Postava_6th_Street_Male_02: vzhled = n"gang__6thstreet_ma_party_07"; vzhledBez = n"gang__6thstreet_ma_party_07_naked"; break;
		case GlobalniID.Postava_6th_Street_Male_03: vzhled = n"gang__6thstreet_ma_party_08"; vzhledBez = n"gang__6thstreet_ma_party_08_naked"; break;
		case GlobalniID.Postava_6th_Street_Male_04: vzhled = n"gang__6thstreet_ma_party_01"; vzhledBez = n"gang__6thstreet_ma_party_01_naked"; break;
		case GlobalniID.Postava_Mateo_Thiago: vzhled = n"gang__mox_ma__q004__mateo_thiago"; vzhledBez = n"gang__mox_ma__q004__mateo_thiago_naked"; break;
		case GlobalniID.Postava_Mox_Male_01: vzhled = n"gang__mox_ma_mox1"; vzhledBez = n"gang__mox_ma_mox1_naked"; break;
		case GlobalniID.Postava_Mox_Male_02: vzhled = n"gang__mox_ma_mox2"; vzhledBez = n"gang__mox_ma_mox2_naked"; break;
		case GlobalniID.Postava_Mox_Male_03: vzhled = n"gang__mox_ma_mox3"; vzhledBez = n"gang__mox_ma_mox3_naked"; break;
		case GlobalniID.Postava_Maelstrom_Male_01: vzhled = n"gang__maelstrom_ma_grunt__lvl1_01"; vzhledBez = n"gang__maelstrom_ma_grunt__lvl1_01_naked"; break;
		case GlobalniID.Postava_Maelstrom_Male_02: vzhled = n"gang__maelstrom_ma_grunt__lvl2_03"; vzhledBez = n"gang__maelstrom_ma_grunt__lvl2_03_naked"; break;
		case GlobalniID.Postava_Tyger_Claws_Male_01: vzhled = n"gang__tyger_ma_biker__lvl1_01"; vzhledBez = n"gang__tyger_ma_biker__lvl1_01_naked"; break;
		case GlobalniID.Postava_Tyger_Claws_Male_02: vzhled = n"gang__tyger_ma_gangster__lvl1_03"; vzhledBez = n"gang__tyger_ma_gangster__lvl1_03_naked"; break;
		case GlobalniID.Postava_Tyger_Claws_Male_03: vzhled = n"gang__tyger_ma_gangster__lvl2_03"; vzhledBez = n"gang__tyger_ma_gangster__lvl2_03_naked"; break;
		case GlobalniID.Postava_Mox_Male_04: vzhled = n"gang__mox_ma_mox4"; vzhledBez = n"gang__mox_ma_mox4_naked"; break;
		case GlobalniID.Postava_Mox_Male_05: vzhled = n"gang__mox_ma_mox5"; vzhledBez = n"gang__mox_ma_mox5_naked"; break;
		case GlobalniID.Postava_Mox_Male_06: vzhled = n"gang__mox_ma_mox6"; vzhledBez = n"gang__mox_ma_mox6_naked"; break;
		case GlobalniID.Postava_Mox_Male_07: vzhled = n"gang__mox_ma_mox7"; vzhledBez = n"gang__mox_ma_mox7_naked"; break;
		case GlobalniID.Postava_Mox_Male_08: vzhled = n"gang__mox_ma_mox8"; vzhledBez = n"gang__mox_ma_mox8_naked"; break;
		case GlobalniID.Postava_Mox_Male_09: vzhled = n"gang__mox_ma_mox9"; vzhledBez = n"gang__mox_ma_mox9_naked"; break;
		case GlobalniID.Postava_Arthur_Jenkins: vzhled = n"citizen__arasaka_corpo_ma__q000__jenkins"; vzhledBez = n"citizen__arasaka_corpo_ma__q000__jenkins_naked"; break;
		case GlobalniID.Postava_Finn_Fingers_Gerstatt: vzhled = n"fingers_default"; vzhledBez = n"fingers_naked"; break;
		case GlobalniID.Postava_Bryce_Mosley: vzhled = n"corpo__netwatch_ma__q110__bryce_mosley"; vzhledBez = n"corpo__netwatch_ma__q110__bryce_mosley_naked"; break;
		case GlobalniID.Postava_Frank_Nostra: vzhled = n"citizen__arasaka_corpo_ma__q000__corpo_friend"; vzhledBez = n"citizen__arasaka_corpo_ma__q000__corpo_friend_naked"; break;
		case GlobalniID.Postava_Wade_Mr_Hands_Bleecker: vzhled = n"service__fixer_ma__mr_hands"; vzhledBez = n"service__fixer_ma__mr_hands_naked"; break;
		case GlobalniID.Postava_Sebastian_Padre_Ibarra: vzhled = n"sebastian_perez_default"; vzhledBez = n"sebastian_perez_naked"; break;
		case GlobalniID.Postava_Declan_Brick_Griffin: vzhled = n"q003__brick_default"; vzhledBez = n"q003__brick_naked"; break;
		case GlobalniID.Postava_Simon_Royce_Randall: vzhled = n"royce_default"; vzhledBez = n"royce_naked"; break;
		case GlobalniID.Postava_Dum_Dum: vzhled = n"maelstrom_gang_ma__q003_maelstrom_speaker_main"; vzhledBez = n"maelstrom_gang_ma__q003_maelstrom_speaker_main_naked"; break;
		case GlobalniID.Postava_Dexter_Dex_DeShawn: vzhled = n"dex_default"; vzhledBez = n"dex_naked"; break;
		case GlobalniID.Postava_Jake_Tim_Kelly: vzhled = n"service__media_ma_actor_bushidox__jake_casual"; vzhledBez = n"service__media_ma_actor_bushidox__jake_casual_naked"; break;
		case GlobalniID.Postava_Ziggy_Q: vzhled = n"service__media_ma__tvhost_n54__ziggy_q"; vzhledBez = n"service__media_ma__tvhost_n54__ziggy_q_naked"; break;
		case GlobalniID.Postava_Johnny_Silverhand: vzhled = n"silverhand_default"; break;
		case GlobalniID.Postava_Solomon_Reed: vzhled = n"reed_default"; break;
		case GlobalniID.Postava_Animals_Male_01: vzhled = n"gang__animals_mba_elite__lvl2_03"; vzhledBez = n"gang__animals_mba_elite__lvl2_03_naked"; break;
		case GlobalniID.Postava_Animals_Male_02: vzhled = n"gang__animals_mba_bouncer__lvl2_03"; vzhledBez = n"gang__animals_mba_bouncer__lvl2_03_naked"; break;
		case GlobalniID.Postava_Animals_Male_03: vzhled = n"gang__animals_mba_elite__lvl3_05"; vzhledBez = n"gang__animals_mba_elite__lvl3_05_naked"; break;
		case GlobalniID.Postava_Barghest_Male_01: vzhled = n"gang__kurtz_army_ma__ow__soldier_off_duty_01"; vzhledBez = n"gang__kurtz_army_ma__ow__soldier_off_duty_01_naked"; break;
		case GlobalniID.Postava_Barghest_Male_02: vzhled = n"gang__kurtz_army_ma__ow__soldier_off_duty_05"; vzhledBez = n"gang__kurtz_army_ma__ow__soldier_off_duty_05_naked"; break;
		case GlobalniID.Postava_Barghest_Male_03: vzhled = n"gang__kurtz_army_ma__ow__soldier_off_duty_10"; vzhledBez = n"gang__kurtz_army_ma__ow__soldier_off_duty_10_naked"; break;
		case GlobalniID.Postava_Scavengers_Male_01: vzhled = n"gang__scavenger_ma_fast__lvl2_01"; vzhledBez = n"gang__scavenger_ma_fast__lvl2_01_naked"; break;
		case GlobalniID.Postava_Scavengers_Male_02: vzhled = n"gang__scavenger_ma_grunt__lvl2_01"; vzhledBez = n"gang__scavenger_ma_grunt__lvl2_01_naked"; break;
		case GlobalniID.Postava_Scavengers_Male_03: vzhled = n"gang__scavenger_ma_grunt__lvl2_03"; vzhledBez = n"gang__scavenger_ma_grunt__lvl2_03_naked"; break;
		case GlobalniID.Postava_Scavengers_Male_04: vzhled = n"gang__scavenger_ma_grunt__lvl2_06"; vzhledBez = n"gang__scavenger_ma_grunt__lvl2_06_naked"; break;
		case GlobalniID.Postava_Wraiths_Male_01: vzhled = n"gang__wraith_ma_grunt__lvl1_01"; vzhledBez = n"gang__wraith_ma_grunt__lvl1_01_naked"; break;
		case GlobalniID.Postava_Wraiths_Male_02: vzhled = n"gang__wraith_ma_grunt__lvl1_02"; vzhledBez = n"gang__wraith_ma_grunt__lvl1_02_naked"; break;
		case GlobalniID.Postava_Wraiths_Male_03: vzhled = n"gang__wraith_ma_grunt__lvl1_03"; vzhledBez = n"gang__wraith_ma_grunt__lvl1_03_naked"; break;
		case GlobalniID.Postava_E3_Male_V:
			if vybranyVzhled == 1 { vzhled = n"e3_v_male_casual"; vzhledBez = n"e3_v_male_nude"; }
			else if vybranyVzhled == 2 { vzhled = n"e3_v_male_panties"; vzhledBez = n"e3_v_male_nude"; }
			else if vybranyVzhled == 3 { vzhled = n"e3_v_male_date"; vzhledBez = n"e3_v_male_nude"; }
			else if vybranyVzhled == 4 { vzhled = n"e3_v_male_combat"; vzhledBez = n"e3_v_male_nude"; }
			else { vzhled = n"e3_v_male_default"; vzhledBez = n"e3_v_male_nude"; }
			break;
		case GlobalniID.Postava_Pepe_Najarro: vzhled = n"elcoyote_barman_default"; vzhledBez = n"elcoyote_barman_naked"; break;
		case GlobalniID.Postava_Dante_Caruso: vzhled = n"man_average__mq305__dante"; vzhledBez = n"man_average__mq305__dante_naked"; break;
		case GlobalniID.Postava_Chester_Bennett: vzhled = n"gang__kurtz_army_mb__mq304__bennett"; vzhledBez = n"gang__kurtz_army_mb__mq304__bennett_naked"; break;
		case GlobalniID.Postava_Yuri_Bychkov: vzhled = n"q304__jurij"; vzhledBez = n"q304__jurij_naked"; break;
		case GlobalniID.Postava_Hideyoshi_Oshima: vzhled = n"citizen__rich_ma__q104__hideo"; break;
		case GlobalniID.Postava_Aguilar_Nubiola_Male: vzhled = n"nicola_ma__mq304__nicola_tpp"; vzhledBez = n"nicola_ma__mq304__nicola_tpp_naked"; break;
		case GlobalniID.Postava_Hasan_Demir:
			if vybranyVzhled == 1 { vzhled = n"man_average__sts_ep1_04__hasan_stac"; vzhledBez = n"man_average__sts_ep1_04__hasan_stac_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"man_average__sts_ep1_04__hasan_squat"; vzhledBez = n"man_average__sts_ep1_04__hasan_squat_naked"; }
			else { vzhled = n"man_average__sts_ep1_04__hasan"; vzhledBez = n"man_average__sts_ep1_04__hasan_naked"; }
			break;
		case GlobalniID.Postava_Edgar_TooLina_Tool:
			if vybranyVzhled == 1 { vzhled = n"man_big__mq303__tool"; vzhledBez = n"man_big__mq303__tool_naked"; }
			else { vzhled = n"man_big__mq303__tool_epilogue"; vzhledBez = n"man_big__mq303__tool_epilogue_naked"; }
			break;
		case GlobalniID.Postava_Adam_Smasher: vzhled = n"boss__adam_smasher_mb_2077_quest_appearance"; vzhledBez = n"boss__adam_smasher_mb_2077_quest_appearance"; break;
		case GlobalniID.Postava_Wilky_Slider_LaGuerre: vzhled = n"baron_default"; vzhledBez = n"baron_naked"; break;
		case GlobalniID.Postava_Milko_Alexis: vzhled = n"man_average__sts_ep1_12__milko"; vzhledBez = n"man_average__sts_ep1_12__milko_naked"; break;
		case GlobalniID.Postava_Yorinobu_Arasaka: vzhled = n"yorinobu_arasaka_yorinobu_default"; vzhledBez = n"yorinobu_arasaka_yorinobu_naked"; break;
		case GlobalniID.Postava_Jago_Szabo: vzhled = n"gang__kurtz_army_ma__mq304__jago"; vzhledBez = n"gang__kurtz_army_ma__mq304__jago_naked"; break;
		case GlobalniID.Postava_Robert_Wilson: vzhled = n"wilson_default"; vzhledBez = n"wilson_naked"; break;
		case GlobalniID.Postava_Obese_Caribbean_01: vzhled = n"citizen__obese_mf_caribbean_01"; vzhledBez = n"citizen__obese_mf_caribbean_01_naked"; break;
		case GlobalniID.Postava_Mr_Blue_Eyes: vzhled = n"corporat_ma__q003_gman"; vzhledBez = n"corporat_ma__q003_gman_naked"; break;
		case GlobalniID.Postava_Driss_Scorpion_Meriana: vzhled = n"scorpion_default"; vzhledBez = n"scorpion_naked"; break;
		case GlobalniID.Postava_Henry:
			if vybranyVzhled == 1 { vzhled = n"henry_2070_rockerboy"; vzhledBez = n"henry_2070_rockerboy_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"henry_2020_rockerboy"; vzhledBez = n"henry_2020_rockerboy_naked"; }
			else if vybranyVzhled == 3 { vzhled = n"henry_2020_rockerboy_2"; vzhledBez = n"henry_2020_rockerboy_2_naked"; }
			else { vzhled = n"henry_2070_drug_addict"; vzhledBez = n"henry_2070_drug_addict_naked"; }
			break;
		case GlobalniID.Postava_Theodore_Teddy_Simos: vzhled = n"teddy_default"; vzhledBez = n"teddy_naked"; break;
		case GlobalniID.Postava_Nix: vzhled = n"gang__cyberpunk_ma__q103__nix"; vzhledBez = n"gang__cyberpunk_ma__q103__nix_naked"; break;
		case GlobalniID.Postava_Lyle_Thompson: vzhled = n"thompson_no_coat"; vzhledBez = n"thompson_no_coat_naked"; break;
		case GlobalniID.Postava_Cesar_Diego_Ruiz: vzhled = n"gang__valentinos_ma__mq025__el_cesar"; vzhledBez = n"gang__valentinos_ma__mq025__el_cesar_naked"; break;
		case GlobalniID.Postava_Roy_Batty: vzhled = n"gang__cyberpunk_ma__mq025__roy_no_blood"; vzhledBez = n"gang__cyberpunk_ma__mq025__roy_no_blood_naked"; break;
		case GlobalniID.Postava_Max_Jones: vzhled = n"service__media_ma__sts_wat_nid_12_max_jones"; vzhledBez = n"service__media_ma__sts_wat_nid_12_max_jones_naked"; break;
		case GlobalniID.Postava_Odell_Blanco: vzhled = n"man_average__sts_ep1_01__priest"; vzhledBez = n"man_average__sts_ep1_01__priest_naked"; break;
		case GlobalniID.Postava_Denzel_The_Brain_Cryer: vzhled = n"denzel_cryer_default"; vzhledBez = n"denzel_cryer_naked"; break;
		case GlobalniID.Postava_Emmerick_Bronson: vzhled = n"gang__generic_mb__q005__emmerick"; vzhledBez = n"gang__generic_mb__q005__emmerick_naked"; break;
		case GlobalniID.Postava_Peter_Sampson:
			if vybranyVzhled == 1 { vzhled = n"peter_sampson_racing"; vzhledBez = n"peter_sampson_naked"; }
			else if vybranyVzhled == 2 { vzhled = n"peter_sampson_racing_no_helmet"; vzhledBez = n"peter_sampson_naked"; }
			else { vzhled = n"peter_sampson_default"; vzhledBez = n"peter_sampson_naked"; }
			break;
		case GlobalniID.Postava_Juan_Mendez: vzhled = n"corpo__ncpd_mb__mq010__mendez"; vzhledBez = n"corpo__ncpd_mb__mq010__mendez_naked"; break;
		case GlobalniID.Postava_Leon_Rinder: vzhled = n"q303__rinder"; vzhledBez = n"q303__rinder_naked"; break;
		case GlobalniID.Postava_Dino_Dinovic: vzhled = n"dino_default"; vzhledBez = n"dino_naked"; break;
		case GlobalniID.Postava_Santiago_Aldecaldo: vzhled = n"santiago_santiago"; vzhledBez = n"santiago_santiago_naked"; break;
		case GlobalniID.Postava_Albert_Murphy: vzhled = n"gang__kurtz_army_ma__q304__murphy"; vzhledBez = n"gang__kurtz_army_ma__q304__murphy_naked"; break;
		case GlobalniID.Postava_Rafael_Perez: vzhled = n"service__ripperdoc_ma__std_arr_ripperdoc_01"; vzhledBez = n"service__ripperdoc_ma__std_arr_ripperdoc_01_naked"; break;
		case GlobalniID.Postava_Nonbinary_Youngster_01: vzhled = n"citizen__nonbinary_ma_youngster_01"; vzhledBez = n"citizen__nonbinary_ma_youngster_01_naked"; break;
		case GlobalniID.Postava_Cassidy_Righter: vzhled = n"cassidy_default"; vzhledBez = n"cassidy_naked"; break;
		case GlobalniID.Postava_Jax_Forgrave: vzhled = n"gang__maelstrom_mb_strong__lvl3_03"; vzhledBez = n"gang__maelstrom_mb_strong__lvl3_03_naked"; break;
		case GlobalniID.Postava_Boris_Ribakov: vzhled = n"man_average__sts_ep1_08__fiodor"; vzhledBez = n"man_average__sts_ep1_08__fiodor_naked"; break;
		case GlobalniID.Postava_Hwangbo_Dong_Gun: vzhled = n"gang__tyger_ma__sts_wat_nid_03_hwangbo_dong_gun"; vzhledBez = n"gang__tyger_ma__sts_wat_nid_03_hwangbo_dong_gun_naked"; break;
		case GlobalniID.Postava_Barry_Lewis: vzhled = n"citizen__lowlife_mb__mq010__barry"; vzhledBez = n"citizen__lowlife_mb__mq010__barry_naked"; break;
		case GlobalniID.Postava_Gustavo_Orta: vzhled = n"gang__valentinos_ma__sts_hey_rey_01_gustavo_orta"; vzhledBez = n"gang__valentinos_ma__sts_hey_rey_01_gustavo_orta_naked"; break;
		case GlobalniID.Postava_Bob_Sagan: vzhled = n"bob_default"; vzhledBez = n"bob_naked"; break;
		case GlobalniID.Postava_Satoshi_Ueno: vzhled = n"man_average__cz_con_clothingshop_01"; vzhledBez = n"man_average__cz_con_clothingshop_01_naked"; break;

		case GlobalniID.Postava_Robot_Corpo:
			if vybranyVzhled == 1 { vzhled = n"corpo__android_ma_ncpd_droid__lvl1_01"; vzhledBez = vzhled; }
			else if vybranyVzhled == 2 { vzhled = n"corpo__android_ma_militech_droid__lvl2_01"; vzhledBez = vzhled; }
			else if vybranyVzhled == 3 { vzhled = n"corpo__android_ma_maxtac_droid__lvl2_01"; vzhledBez = vzhled; }
			else if vybranyVzhled == 4 { vzhled = n"corpo__android_ma_kang_tao_droid__lvl2_01"; vzhledBez = vzhled; }
			else if vybranyVzhled == 5 { vzhled = n"corpo__android_ma__mq060__nitro_youth_droid"; vzhledBez = vzhled; }
			else if vybranyVzhled == 6 { vzhled = n"corpo__android_ma__mq060__nitro_youth_communication_droid"; vzhledBez = vzhled; }
			else { vzhled = n"corpo__android_ma_arasaka_droid__lvl2_01"; vzhledBez = vzhled; }
			break;
		case GlobalniID.Postava_Robot_Gang_Maelstrom:
			if vybranyVzhled == 1 { vzhled = n"gang__android_ma_maelstrom_droid__lvl2_02"; vzhledBez = vzhled; }
			else if vybranyVzhled == 2 { vzhled = n"gang__android_ma_maelstrom_droid__lvl2_03"; vzhledBez = vzhled; }
			else if vybranyVzhled == 3 { vzhled = n"gang__android_ma_maelstrom_droid__lvl2_04"; vzhledBez = vzhled; }
			else { vzhled = n"gang__android_ma_maelstrom_droid__lvl2_01"; vzhledBez = vzhled; }
			break;
		case GlobalniID.Postava_Robot_Gang_Wraith:
			if vybranyVzhled == 1 { vzhled = n"gang__android_ma_wraith_droid__lvl1_02"; vzhledBez = vzhled; }
			else if vybranyVzhled == 2 { vzhled = n"gang__android_ma_wraith_droid__lvl1_03"; vzhledBez = vzhled; }
			else if vybranyVzhled == 3 { vzhled = n"gang__android_ma_wraith_droid__lvl1_04"; vzhledBez = vzhled; }
			else if vybranyVzhled == 4 { vzhled = n"gang__android_ma_wraith_droid__lvl1_05"; vzhledBez = vzhled; }
			else { vzhled = n"gang__android_ma_wraith_droid__lvl1_01"; vzhledBez = vzhled; }
			break;
		case GlobalniID.Postava_Robot_Gang_Scavenger:
			if vybranyVzhled == 1 { vzhled = n"gang__android_ma_scavenger_droid__lvl2_02"; vzhledBez = vzhled; }
			else if vybranyVzhled == 2 { vzhled = n"gang__android_ma_scavenger_droid__lvl2_03"; vzhledBez = vzhled; }
			else if vybranyVzhled == 3 { vzhled = n"gang__android_ma_scavenger_droid__lvl2_04"; vzhledBez = vzhled; }
			else if vybranyVzhled == 4 { vzhled = n"gang__android_ma_scavenger_droid__lvl2_05"; vzhledBez = vzhled; }
			else if vybranyVzhled == 5 { vzhled = n"gang__android_ma_scavenger_droid__lvl2_06"; vzhledBez = vzhled; }
			else { vzhled = n"gang__android_ma_scavenger_droid__lvl2_01"; vzhledBez = vzhled; }
			break;
		case GlobalniID.Postava_Robot_Gang_6th_Street:
			if vybranyVzhled == 1 { vzhled = n"gang__android_ma_6th_street_droid_lvl1_02"; vzhledBez = vzhled; }
			else if vybranyVzhled == 2 { vzhled = n"gang__android_ma_6th_street_droid_lvl1_03"; vzhledBez = vzhled; }
			else if vybranyVzhled == 3 { vzhled = n"gang__android_ma_6th_street_droid_lvl1_04"; vzhledBez = vzhled; }
			else if vybranyVzhled == 4 { vzhled = n"gang__android_ma_6th_street_droid_lvl1_05"; vzhledBez = vzhled; }
			else if vybranyVzhled == 5 { vzhled = n"gang__android_ma_6th_street_droid_lvl1_06"; vzhledBez = vzhled; }
			else { vzhled = n"gang__android_ma_6th_street_droid_lvl1_01"; vzhledBez = vzhled; }
			break;
		case GlobalniID.Postava_Robot_Training:
			if vybranyVzhled == 1 { vzhled = n"special__vr_tutorial_ma_dummy_light"; vzhledBez = vzhled; }
			else { vzhled = n"special__vr_tutorial_ma_dummy_melee"; vzhledBez = vzhled; }
			break;
		case GlobalniID.Postava_Robot_Remote: vzhled = n"corpo__android_ma__sts_ep1_13__communication_droid"; vzhledBez = vzhled; break;
		case GlobalniID.Postava_Robot_Nusa: vzhled = n"corpo__android_ma_nusa_droid__lvl2_01"; vzhledBez = vzhled; break;
		case GlobalniID.Postava_Robot_Moth_Barman: vzhled = n"corpo__android_ma__q303__barmaid_droid"; vzhledBez = vzhled; break;
	};

	return [vzhled, vzhledBez];
}

public enum InkAtlasSoubor {
	Prazdne = 0,
	LizziesBDs_Postavy_01 = 1,
	LizziesBDs_Postavy_02 = 2,
	LizziesBDs_Postavy_03 = 3,
	LizziesBDs_Postavy_04 = 4,
	LizziesBDs_Postavy_05 = 5,
	LizziesBDs_Postavy_06 = 6,
	LizziesBDs_Postavy_07 = 7,
	LizziesBDs_Postavy_08 = 8,
	LizziesBDs_Postavy_09 = 40,
	LizziesBDs_Postavy_10 = 41,
	LizziesBDs_Postavy_11 = 43,
	LizziesBDs_Postavy_12 = 44,
	LizziesBDs_Postavy_13 = 46,
	LizziesBDs_Postavy_14 = 52,
	LizziesBDs_Postavy_15 = 54,
	LizziesBDs_Postavy_16 = 56,
	LizziesBDs_Postavy_17 = 58,
	LizziesBDs_Postavy_18 = 60,
	LizziesBDs_Postavy_19 = 64,
	LizziesBDs_Postavy_20 = 66,
	LizziesBDs_Postavy_21 = 15,
	LizziesBDs_Postavy_CanonFemV = 68,
	LizziesBDs_Postavy_E3V = 45,
	LizziesBDs_Postavy_Staff_01 = 9,
	LizziesBDs_Postavy_Staff_02 = 10,
	LizziesBDs_Postavy_SongSoRi = 11,
	LizziesBDs_Postavy_Robots_01 = 61,
	LizziesBDs_Postavy_Robots_02 = 62,
	LizziesBDs_Postavy_Robots_03 = 63,
	LizziesBDs_Lokace_Zen = 12,
	LizziesBDs_Lokace_01 = 13,
	LizziesBDs_Lokace_02 = 14,
	LizziesBDs_Lokace_03 = 42,
	LizziesBDs_Lokace_04 = 68,
	LizziesBDs_Lokace_Psycho_01 = 67,
	LizziesBDs_Lokace_Bar = 16,
	LizziesBDs_Lokace_Bar_2 = 57,
	LizziesBDs_Lokace_K_01 = 47,
	LizziesBDs_Lokace_K_02 = 48,
	LizziesBDs_Lokace_K_03 = 49,
	LizziesBDs_Lokace_K_04 = 50,
	LizziesBDs_Lokace_K_05 = 51,
	LizziesBDs_Lokace_K_06 = 53,
	LizziesBDs_Lokace_K_07 = 65,
	Assets_00 = 17,
	Assets_01 = 18,
	Assets_02 = 19,
	Assets_03 = 20,
	Assets_04 = 21,
	Assets_05 = 22,
	Assets_06 = 23,
	Assets_07 = 24,
	Assets_08 = 25,
	Assets_09 = 26,
	Assets_10 = 27,
	Assets_27 = 59,
	Assets_34 = 28,
	Assets_35 = 29,
	Assets_EP1_06 = 30,
	Assets_EP1_07 = 31,
	Assets_EP1_09 = 32,
	Assets_EP1_10 = 33,
	Assets_EP1_11 = 34,
	Assets_EP1_12 = 35,
	Assets_EP1_13 = 36,
	Assets_EP1_14 = 37,
	Assets_EP1_08 = 38,
	GangLogos = 39,
	DynamickyNahled = 55
}

public func DataInkAtlas(inkAtlas: InkAtlasSoubor) -> ResRef {
	let cesta: ResRef = r"";

	switch inkAtlas {
		case InkAtlasSoubor.LizziesBDs_Postavy_01: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_01.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_02: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_02.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_03: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_03.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_04: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_04.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_05: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_05.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_06: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_06.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_07: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_07.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_08: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_08.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_09: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_09.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_10: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_10.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_11: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_11.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_12: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_12.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_13: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_13.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_14: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_14.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_15: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_15.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_16: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_16.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_17: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_17.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_18: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_18.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_19: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_19.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_20: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_20.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_21: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_21.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_E3V: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_e3v.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_Staff_01: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_stf_01.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_Staff_02: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_stf_02.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_songsori.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_Robots_01: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_robots_01.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_Robots_02: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_robots_02.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_Robots_03: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_robots_03.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Postavy_CanonFemV: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_postavy_canonfemv.inkatlas"; break;
		case InkAtlasSoubor.GangLogos: cesta = r"base\\gameplay\\gui\\common\\icons\\gang_logos.inkatlas"; break;
		case InkAtlasSoubor.Assets_00: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen0.inkatlas"; break;
		case InkAtlasSoubor.Assets_01: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen1.inkatlas"; break;
		case InkAtlasSoubor.Assets_02: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen2.inkatlas"; break;
		case InkAtlasSoubor.Assets_03: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen3.inkatlas"; break;
		case InkAtlasSoubor.Assets_04: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen4.inkatlas"; break;
		case InkAtlasSoubor.Assets_05: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen5.inkatlas"; break;
		case InkAtlasSoubor.Assets_06: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen6.inkatlas"; break;
		case InkAtlasSoubor.Assets_07: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen7.inkatlas"; break;
		case InkAtlasSoubor.Assets_08: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen8.inkatlas"; break;
		case InkAtlasSoubor.Assets_09: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen9.inkatlas"; break;
		case InkAtlasSoubor.Assets_10: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen10.inkatlas"; break;
		case InkAtlasSoubor.Assets_27: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen27.inkatlas"; break;
		case InkAtlasSoubor.Assets_34: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen34.inkatlas"; break;
		case InkAtlasSoubor.Assets_35: cesta = r"base\\gameplay\\gui\\common\\icons\\codex\\assets_fullscreen35.inkatlas"; break;
		case InkAtlasSoubor.Assets_EP1_06: cesta = r"ep1\\gameplay\\gui\\common\\icons\\codex\\assets_ep1_fullscreen6.inkatlas"; break;
		case InkAtlasSoubor.Assets_EP1_07: cesta = r"ep1\\gameplay\\gui\\common\\icons\\codex\\assets_ep1_fullscreen7.inkatlas"; break;
		case InkAtlasSoubor.Assets_EP1_09: cesta = r"ep1\\gameplay\\gui\\common\\icons\\codex\\assets_ep1_fullscreen9.inkatlas"; break;
		case InkAtlasSoubor.Assets_EP1_10: cesta = r"ep1\\gameplay\\gui\\common\\icons\\codex\\assets_ep1_fullscreen10.inkatlas"; break;
		case InkAtlasSoubor.Assets_EP1_11: cesta = r"ep1\\gameplay\\gui\\common\\icons\\codex\\assets_ep1_fullscreen11.inkatlas"; break;
		case InkAtlasSoubor.Assets_EP1_12: cesta = r"ep1\\gameplay\\gui\\common\\icons\\codex\\assets_ep1_fullscreen12.inkatlas"; break;
		case InkAtlasSoubor.Assets_EP1_14: cesta = r"ep1\\gameplay\\gui\\common\\icons\\codex\\assets_ep1_fullscreen14.inkatlas"; break;
		case InkAtlasSoubor.Assets_EP1_13: cesta = r"ep1\\gameplay\\gui\\common\\icons\\codex\\assets_ep1_fullscreen13.inkatlas"; break;
		case InkAtlasSoubor.Assets_EP1_08: cesta = r"ep1\\gameplay\\gui\\common\\icons\\codex\\assets_ep1_fullscreen8.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_01: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_01.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_02: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_02.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_03: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_03.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_04: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_04.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_Psycho_01: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_psycho_01.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_Bar: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_bar.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_Bar_2: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_bar_2.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_Zen: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_zen.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_K_01: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_k_01.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_K_02: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_k_02.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_K_03: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_k_03.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_K_04: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_k_04.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_K_05: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_k_05.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_K_06: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_k_06.inkatlas"; break;
		case InkAtlasSoubor.LizziesBDs_Lokace_K_07: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_lokace_k_07.inkatlas"; break;
		case InkAtlasSoubor.DynamickyNahled: cesta = r"mod\\arman3_lizzies_bds\\gameplay\\gui\\preview\\preview.inkatlas"; break;
	};

	return cesta;
}

//SortByName
public func PostavySerazeniJmenoAbc() -> array<GlobalniID> = [
GlobalniID.Postava_LokaceBezPostavy,GlobalniID.Kategorie05,GlobalniID.Postava_6th_Street_Female_01,GlobalniID.Postava_6th_Street_Female_02,GlobalniID.Postava_6th_Street_Female_03,GlobalniID.Postava_6th_Street_Female_04,GlobalniID.Postava_6th_Street_Female_05,GlobalniID.Postava_6th_Street_Female_06,GlobalniID.Postava_6th_Street_Male_01,GlobalniID.Postava_6th_Street_Male_02,GlobalniID.Postava_6th_Street_Male_03,GlobalniID.Postava_6th_Street_Male_04,GlobalniID.Postava_Robot_Gang_6th_Street,GlobalniID.Postava_Adam_Smasher,GlobalniID.Postava_Aguilar_Nubiola_Female,GlobalniID.Postava_Aguilar_Nubiola_Male,GlobalniID.Postava_Tourist_02,GlobalniID.Postava_Akai_Red_Menace_Kyoi,GlobalniID.Postava_Albert_Murphy,GlobalniID.Kategorie08,GlobalniID.Postava_Aldecaldos_Female_01,GlobalniID.Postava_Aldecaldos_Female_02,GlobalniID.Postava_Aldecaldos_Female_03,GlobalniID.Postava_Aldecaldos_Female_Driver_Lvl_3_3,GlobalniID.Postava_Alena_Alex_Xenakis,GlobalniID.Postava_Altiera_Alt_Cunningham,GlobalniID.Postava_Angel,GlobalniID.Postava_Angelica_Angie_Whelan,GlobalniID.Kategorie10,GlobalniID.Postava_Animals_Female_01,GlobalniID.Postava_Animals_Female_02,GlobalniID.Postava_Animals_Female_03,GlobalniID.Postava_Animals_Male_01,GlobalniID.Postava_Animals_Male_02,GlobalniID.Postava_Animals_Male_03,GlobalniID.Postava_Anna_Hamill,GlobalniID.Postava_Mox_Female_Lvl_3_2,GlobalniID.Postava_Aoi_Blue_Moon_Tsuki,GlobalniID.Postava_Arabella_Spider_Murphy,GlobalniID.Postava_Arasaka_Corpo_01,GlobalniID.Postava_Arasaka_Corpo_06,GlobalniID.Postava_Arasaka_Netrunner_Lvl_2_3,GlobalniID.Postava_Arasaka_Scientist,GlobalniID.Postava_Clothing_Seller_Std_Arr,GlobalniID.Postava_Arthur_Jenkins,GlobalniID.Postava_Aurore_Cassel,GlobalniID.Postava_Ayden_Daniels,GlobalniID.Postava_Aymeric_Cassel,GlobalniID.Postava_Ayo_Zarin,GlobalniID.Postava_Barbara_Babs_Okoye,GlobalniID.Kategorie11,GlobalniID.Postava_Barghest_Female_01,GlobalniID.Postava_Barghest_Female_02,GlobalniID.Postava_Barghest_Female_03,GlobalniID.Postava_Barghest_Female_04,GlobalniID.Postava_Barghest_Female_05,GlobalniID.Postava_Barghest_Female_Guard_01,GlobalniID.Postava_Barghest_Male_01,GlobalniID.Postava_Barghest_Male_02,GlobalniID.Postava_Barghest_Male_03,GlobalniID.Postava_Barry_Lewis,GlobalniID.Postava_Beatrice_Ellen_8ug8ear_Trieste,GlobalniID.Postava_Benjamin_Stone,GlobalniID.Postava_Paradise_Waitress_03,GlobalniID.Postava_Bob_Sagan,GlobalniID.Postava_Boris_Ribakov,GlobalniID.Postava_Bree_Whitney,GlobalniID.Postava_Brittany_Hayes,GlobalniID.Postava_Bryce_Mosley,GlobalniID.Postava_Canon_FemV,GlobalniID.Postava_Caliente_Waitress_01,GlobalniID.Postava_Carol_Emeka,GlobalniID.Postava_Cassidy_Righter,GlobalniID.Postava_Cesar_Diego_Ruiz,GlobalniID.Postava_Charlene_Fox,GlobalniID.Postava_Cheri_Nowlin,GlobalniID.Postava_Chester_Bennett,GlobalniID.Postava_Christine_Markov,GlobalniID.Postava_Claire_Russell,GlobalniID.Postava_Robot_Corpo,GlobalniID.Postava_Citizen_Corporat_01,GlobalniID.Postava_Citizen_Corporat_12,GlobalniID.Kategorie15,GlobalniID.Postava_Cynthia_Najarro,GlobalniID.Postava_Dakota_Smith,GlobalniID.Postava_Dao_Hyunh,GlobalniID.Postava_Declan_Brick_Griffin,GlobalniID.Postava_Denny,GlobalniID.Postava_Denzel_The_Brain_Cryer,GlobalniID.Postava_Dexter_Dex_DeShawn,GlobalniID.Postava_Dietlinde,GlobalniID.Postava_Dino_Dinovic,GlobalniID.Postava_District_Teen_01,GlobalniID.Postava_Dogtown_Joytoy_01,GlobalniID.Postava_Dogtown_Joytoy_06,GlobalniID.Postava_Dogtown_Nightlife_02,GlobalniID.Postava_Dogtown_Nightlife_05,GlobalniID.Postava_Dogtown_Nightlife_10,GlobalniID.Postava_Driss_Scorpion_Meriana,GlobalniID.Postava_Dum_Dum,GlobalniID.Postava_Dusty_Lowe,GlobalniID.Postava_E3_Female_V,GlobalniID.Postava_E3_Male_V,GlobalniID.Postava_Edgar_TooLina_Tool,GlobalniID.Postava_Elisabeth_Lizzy_Wizzy_Wissenfurth,GlobalniID.Postava_Elizabeth_Peralez,GlobalniID.Postava_Emilie_Massenat,GlobalniID.Postava_Emmerick_Bronson,GlobalniID.Postava_Evelyn_Parker,GlobalniID.Postava_Female_V,GlobalniID.Postava_Male_V,GlobalniID.Postava_Farida_Nazeri,GlobalniID.Postava_Biker_Female_04,GlobalniID.Postava_Tube_Dancer_08,GlobalniID.Postava_Finn_Fingers_Gerstatt,GlobalniID.Postava_Fiona_Vargas,GlobalniID.Postava_Vendor_03,GlobalniID.Postava_Frank_Nostra,GlobalniID.Postava_Georgina_Zembinsky,GlobalniID.Postava_Gillean_Jordan,GlobalniID.Postava_Godiva,GlobalniID.Postava_Goro_Takemura,GlobalniID.Postava_Grace_Karina_Voronova,GlobalniID.Postava_Griselda_Green_Cloud_Martinez,GlobalniID.Postava_Guadalupe_Alejandra_Welles,GlobalniID.Postava_Gustavo_Orta,GlobalniID.Postava_Hanako_Arasaka,GlobalniID.Postava_Hasan_Demir,GlobalniID.Postava_Heavy_Hearts_Waitress_01,GlobalniID.Postava_Heavy_Hearts_Waitress_02,GlobalniID.Postava_Heavy_Hearts_Waitress_03,GlobalniID.Postava_Heavy_Hearts_Waitress_04,GlobalniID.Postava_Heavy_Hearts_Waitress_05,GlobalniID.Postava_Helen_Wandoo,GlobalniID.Postava_Henry,GlobalniID.Postava_Hideyoshi_Oshima,GlobalniID.Postava_Hologram_Pachinko_Girl,GlobalniID.Postava_Hologram_Prostitute,GlobalniID.Postava_Hologram_VIP,GlobalniID.Postava_Hwangbo_Dong_Gun,GlobalniID.Postava_Imogen,GlobalniID.Postava_Iris_Tanner,GlobalniID.Postava_Jackie_Welles,GlobalniID.Postava_Jago_Szabo,GlobalniID.Postava_Jake_Tim_Kelly,GlobalniID.Postava_Clothing_Seller_Wbr_Jpn,GlobalniID.Postava_Jasmine_Dixon,GlobalniID.Postava_Jax_Forgrave,GlobalniID.Postava_Jefferson_Peralez,GlobalniID.Postava_JigJig_Dancer_05,GlobalniID.Postava_Joanne_Koch,GlobalniID.Postava_Joss_Kutcher,GlobalniID.Postava_Jotaro_Shobo,GlobalniID.Postava_Journey_Ruiz,GlobalniID.Kategorie01,GlobalniID.Postava_Juan_Mendez,GlobalniID.Postava_Judy_Alvarez,GlobalniID.Postava_Julia_Young,GlobalniID.Postava_Karina_Lee,GlobalniID.Postava_Kerry_Eurodyne,GlobalniID.Postava_Kissy,GlobalniID.Postava_Konpeki_Receptionist_01,GlobalniID.Postava_Konpeki_Waitress_01,GlobalniID.Postava_Kurt_Hansen,GlobalniID.Postava_Lana_Prince,GlobalniID.Postava_Laura_May,GlobalniID.Postava_Lauren_Costigan,GlobalniID.Postava_Leon_Rinder,GlobalniID.Postava_Lina_Malina,GlobalniID.Postava_Linda_Spencer,GlobalniID.Postava_Linh_Hyunh,GlobalniID.Postava_Logan_Scott,GlobalniID.Postava_Lowlife_Latino_01,GlobalniID.Postava_Lowlife_Latino_07,GlobalniID.Postava_Queen_Of_The_Stoop_03,GlobalniID.Postava_Queen_Of_The_Stoop_07,GlobalniID.Postava_Queen_Of_The_Stoop_12,GlobalniID.Postava_Queen_Of_The_Stoop_16,GlobalniID.Postava_Lt_Mower,GlobalniID.Postava_Lucy_Thackery,GlobalniID.Postava_Lucyna_Lucy_Kushinada,GlobalniID.Postava_Lyle_Thompson,GlobalniID.Kategorie06,GlobalniID.Postava_Maelstrom_Female_01,GlobalniID.Postava_Maelstrom_Female_02,GlobalniID.Postava_Maelstrom_Female_03,GlobalniID.Postava_Maelstrom_Male_01,GlobalniID.Postava_Maelstrom_Male_02,GlobalniID.Postava_Robot_Gang_Maelstrom,GlobalniID.Postava_Maggie_Isley,GlobalniID.Postava_Maiko_Maeda,GlobalniID.Postava_Mallrat_05,GlobalniID.Postava_Mallrat_10,GlobalniID.Postava_Maman_Mama_Brigitte,GlobalniID.Postava_Martha_Frakes,GlobalniID.Postava_Mateo_Thiago,GlobalniID.Postava_Max_Jones,GlobalniID.Postava_Tourist_01,GlobalniID.Postava_Melisa_Rory,GlobalniID.Postava_Meredith_Stout,GlobalniID.Postava_Micaela_Ruiz,GlobalniID.Postava_Michiko_Arasaka,GlobalniID.Postava_Mike_Tiny_Mike_Kowalski,GlobalniID.Postava_Milko_Alexis,GlobalniID.Postava_Miranda_Lawson,GlobalniID.Postava_Misty_Olszewski,GlobalniID.Postava_Mitch_Anderson,GlobalniID.Postava_Mox_Female_Lvl_2_1,GlobalniID.Postava_Mox_Female_Lvl_2_2,GlobalniID.Postava_Mox_Female_Lvl_2_3,GlobalniID.Postava_Mox_Female_Lvl_3_1,GlobalniID.Postava_Mox_Female_Lvl_3_3,GlobalniID.Postava_Mox_Female_01,GlobalniID.Postava_Mox_Female_02,GlobalniID.Postava_Mox_Female_03,GlobalniID.Postava_Mox_Female_04,GlobalniID.Postava_Mox_Female_05,GlobalniID.Postava_Mox_Female_06,GlobalniID.Postava_Mox_Male_01,GlobalniID.Postava_Mox_Male_02,GlobalniID.Postava_Mox_Male_03,GlobalniID.Postava_Mox_Male_04,GlobalniID.Postava_Mox_Male_05,GlobalniID.Postava_Mox_Male_06,GlobalniID.Postava_Mox_Male_07,GlobalniID.Postava_Mox_Male_08,GlobalniID.Postava_Mox_Male_09,GlobalniID.Postava_Mr_Blue_Eyes,GlobalniID.Postava_Muamar_El_Capitan_Reyes,GlobalniID.Postava_Nadezhda_Tiurina,GlobalniID.Postava_Nadia_Petrova,GlobalniID.Postava_Nancy_Hartley,GlobalniID.Postava_NCPD_Female_01,GlobalniID.Postava_NCPD_Female_02,GlobalniID.Postava_NCPD_Male_01,GlobalniID.Postava_Nele_Springer,GlobalniID.Postava_Nightlife_Hottie_15,GlobalniID.Postava_Nightlife_Hottie_21,GlobalniID.Postava_Nika_Yankovich,GlobalniID.Postava_Nina_Kraviz,GlobalniID.Postava_Nix,GlobalniID.Postava_Nonbinary_Youngster_01,GlobalniID.Postava_Clothing_Seller_Wat_Nid,GlobalniID.Postava_Nova_MacCaster,GlobalniID.Postava_Robot_Nusa,GlobalniID.Postava_Obese_Caribbean_01,GlobalniID.Postava_Odell_Blanco,GlobalniID.Postava_Ofelia_Patricia_Sirawian,GlobalniID.Postava_Olga_Elisabeth_Longmead,GlobalniID.Postava_Ozob_Bozo,GlobalniID.Postava_Pacific_Female_06,GlobalniID.Postava_Pacific_Female_07,GlobalniID.Postava_Pacific_Female_13,GlobalniID.Postava_Paco_Torres,GlobalniID.Postava_Panam_Palmer,GlobalniID.Postava_Paradise_Client_02,GlobalniID.Postava_Pepe_Najarro,GlobalniID.Postava_Peter_Sampson,GlobalniID.Postava_Placide,GlobalniID.Postava_Purple_Force,GlobalniID.Postava_R3n0,GlobalniID.Postava_Rachel_Casich,GlobalniID.Postava_Rafael_Perez,GlobalniID.Postava_Food_Seller_Wbr_Jpn,GlobalniID.Postava_Clothing_Seller_Std_Rcr,GlobalniID.Postava_Rebeca_Price,GlobalniID.Postava_Regina_Jones,GlobalniID.Postava_Robot_Remote,GlobalniID.Kategorie09,GlobalniID.Postava_Rhino,GlobalniID.Postava_Rich_Female_12,GlobalniID.Postava_Rich_Female_14,GlobalniID.Postava_Rich_Female_25,GlobalniID.Postava_Rita_Wheeler,GlobalniID.Postava_River_Ward,GlobalniID.Postava_Johnny_Silverhand,GlobalniID.Postava_Robert_Wilson,GlobalniID.Kategorie17,GlobalniID.Postava_Rogue_Amendiares,GlobalniID.Postava_Rosalind_Myers,GlobalniID.Postava_Rose_Horrigan,GlobalniID.Postava_Roxanne_Sumner,GlobalniID.Postava_Roxxi,GlobalniID.Postava_Roy_Batty,GlobalniID.Postava_Ruby_Collins,GlobalniID.Postava_Ruth_Dzeng,GlobalniID.Postava_Sachiko_Kusama,GlobalniID.Postava_Sandayu_Oda,GlobalniID.Postava_Sandra_Dorsett,GlobalniID.Postava_Santiago_Aldecaldo,GlobalniID.Postava_Satoshi_Ueno,GlobalniID.Postava_Saul_Bright,GlobalniID.Postava_Robot_Gang_Scavenger,GlobalniID.Kategorie12,GlobalniID.Postava_Scavengers_Female_01,GlobalniID.Postava_Scavengers_Female_02,GlobalniID.Postava_Scavengers_Female_03,GlobalniID.Postava_Scavengers_Female_04,GlobalniID.Postava_Scavengers_Female_05,GlobalniID.Postava_Scavengers_Female_06,GlobalniID.Postava_Scavengers_Female_07,GlobalniID.Postava_Scavengers_Female_08,GlobalniID.Postava_Scavengers_Male_01,GlobalniID.Postava_Scavengers_Male_02,GlobalniID.Postava_Scavengers_Male_03,GlobalniID.Postava_Scavengers_Male_04,GlobalniID.Postava_Sebastian_Padre_Ibarra,GlobalniID.Postava_Sexworker_02,GlobalniID.Postava_Sexworker_10,GlobalniID.Postava_Sexworker_Doll_02,GlobalniID.Postava_Sexworker_Doll_04,GlobalniID.Postava_Sexworker_Doll_07,GlobalniID.Postava_Sexworker_Doll_08,GlobalniID.Postava_Sexworker_Prostitute_05,GlobalniID.Postava_Sexworker_Prostitute_07,GlobalniID.Postava_Shelma,GlobalniID.Postava_Simon_Royce_Randall,GlobalniID.Postava_Skye,GlobalniID.Postava_Sofia_Ramirez,GlobalniID.Postava_Sofia_Rossi,GlobalniID.Postava_Solomon_Reed,GlobalniID.Postava_Song_Songbird_So_Mi,GlobalniID.Postava_Song_So_Ri,GlobalniID.Postava_Sophia_Dupont,GlobalniID.Kategorie14,GlobalniID.Postava_Stella_Ramos,GlobalniID.Postava_Lizzies_Stripper_04,GlobalniID.Postava_Susan_Abernathy,GlobalniID.Postava_Susanna_Susie_Q_Quinn,GlobalniID.Postava_T_Bug,GlobalniID.Postava_Taki_Kenmochi,GlobalniID.Postava_Tamara_Cosby,GlobalniID.Postava_Tasha_Rodriquez,GlobalniID.Postava_Tenant_Morning_Crowd_07,GlobalniID.Postava_Robot_Moth_Barman,GlobalniID.Kategorie03,GlobalniID.Postava_Mox_Bouncer_02,GlobalniID.Postava_Theo_Price,GlobalniID.Postava_Theodore_Teddy_Simos,GlobalniID.Postava_Tom_Caldera,GlobalniID.Postava_Clothing_Seller_Bls_Ina,GlobalniID.Postava_Robot_Training,GlobalniID.Postava_Trigger,GlobalniID.Kategorie07,GlobalniID.Postava_Tyger_Claws_Female_01,GlobalniID.Postava_Tyger_Claws_Female_02,GlobalniID.Postava_Tyger_Claws_Female_03,GlobalniID.Postava_Tyger_Claws_Male_01,GlobalniID.Postava_Tyger_Claws_Male_02,GlobalniID.Postava_Tyger_Claws_Male_03,GlobalniID.Postava_Tyler_Zan,GlobalniID.Kategorie02,GlobalniID.Postava_Valentinos_Female_01,GlobalniID.Postava_Valentinos_Female_02,GlobalniID.Postava_Valentinos_Female_03,GlobalniID.Postava_Valentinos_Female_04,GlobalniID.Postava_Valentinos_Male_01,GlobalniID.Postava_Valentinos_Male_02,GlobalniID.Postava_Valentinos_Male_03,GlobalniID.Kategorie04,GlobalniID.Postava_Veteran_Guard_01,GlobalniID.Postava_Victor_Vektor,GlobalniID.Kategorie16,GlobalniID.Postava_Voodoo_Boys_Female_01,GlobalniID.Postava_Voodoo_Boys_Female_02,GlobalniID.Postava_Voodoo_Boys_Female_03,GlobalniID.Postava_Voodoo_Boys_Female_04,GlobalniID.Postava_Voodoo_Boys_Female_05,GlobalniID.Postava_Voodoo_Boys_Female_06,GlobalniID.Postava_Voodoo_Boys_Female_07,GlobalniID.Postava_Wade_Mr_Hands_Bleecker,GlobalniID.Postava_Wakako_Okada,GlobalniID.Postava_Wakakos_Desk_Girl,GlobalniID.Postava_Wilky_Slider_LaGuerre,GlobalniID.Postava_Robot_Gang_Wraith,GlobalniID.Kategorie13,GlobalniID.Postava_Wraiths_Female_01,GlobalniID.Postava_Wraiths_Female_02,GlobalniID.Postava_Wraiths_Female_03,GlobalniID.Postava_Wraiths_Female_04,GlobalniID.Postava_Wraiths_Male_01,GlobalniID.Postava_Wraiths_Male_02,GlobalniID.Postava_Wraiths_Male_03,GlobalniID.Postava_Yawen_Packard,GlobalniID.Postava_Yelena_Sidorova,GlobalniID.Postava_Yishen_Rhee,GlobalniID.Postava_Yoko_Tsuru,GlobalniID.Postava_Yorinobu_Arasaka,GlobalniID.Postava_Youngster_Slacker_05,GlobalniID.Postava_Youngster_Slacker_06,GlobalniID.Postava_Youngster_Slacker_08,GlobalniID.Postava_Youngster_Slacker_14,GlobalniID.Postava_Yuri_Bychkov,GlobalniID.Postava_Zaria_Hughes,GlobalniID.Postava_Ziggy_Q,GlobalniID.Postava_Zoe_Alonzo,GlobalniID.Postava_Zuleikha_El_Ahmar
];

//SortBySurname
public func PostavySerazeniPrijmeniAbc() -> array<GlobalniID> = [
GlobalniID.Postava_LokaceBezPostavy,GlobalniID.Postava_6th_Street_Female_01,GlobalniID.Postava_6th_Street_Female_02,GlobalniID.Postava_6th_Street_Female_03,GlobalniID.Postava_6th_Street_Female_04,GlobalniID.Postava_6th_Street_Female_05,GlobalniID.Postava_6th_Street_Female_06,GlobalniID.Postava_6th_Street_Male_01,GlobalniID.Postava_6th_Street_Male_02,GlobalniID.Postava_6th_Street_Male_03,GlobalniID.Postava_6th_Street_Male_04,GlobalniID.Postava_Susan_Abernathy,GlobalniID.Postava_Santiago_Aldecaldo,GlobalniID.Kategorie08,GlobalniID.Postava_Aldecaldos_Female_01,GlobalniID.Postava_Aldecaldos_Female_02,GlobalniID.Postava_Aldecaldos_Female_03,GlobalniID.Postava_Milko_Alexis,GlobalniID.Postava_Zoe_Alonzo,GlobalniID.Postava_Judy_Alvarez,GlobalniID.Postava_Rogue_Amendiares,GlobalniID.Postava_Mitch_Anderson,GlobalniID.Postava_Angel,GlobalniID.Kategorie10,GlobalniID.Postava_Animals_Female_01,GlobalniID.Postava_Animals_Female_02,GlobalniID.Postava_Animals_Female_03,GlobalniID.Postava_Animals_Male_01,GlobalniID.Postava_Animals_Male_02,GlobalniID.Postava_Animals_Male_03,GlobalniID.Postava_Hanako_Arasaka,GlobalniID.Postava_Michiko_Arasaka,GlobalniID.Postava_Arasaka_Corpo_06,GlobalniID.Postava_Yorinobu_Arasaka,GlobalniID.Kategorie11,GlobalniID.Postava_Barghest_Female_01,GlobalniID.Postava_Barghest_Female_02,GlobalniID.Postava_Barghest_Female_03,GlobalniID.Postava_Barghest_Female_04,GlobalniID.Postava_Barghest_Female_05,GlobalniID.Postava_Barghest_Female_Guard_01,GlobalniID.Postava_Barghest_Male_01,GlobalniID.Postava_Barghest_Male_02,GlobalniID.Postava_Barghest_Male_03,GlobalniID.Postava_Roy_Batty,GlobalniID.Postava_Chester_Bennett,GlobalniID.Postava_Paradise_Waitress_03,GlobalniID.Postava_Odell_Blanco,GlobalniID.Postava_Wade_Mr_Hands_Bleecker,GlobalniID.Postava_Mox_Bouncer_02,GlobalniID.Kategorie16,GlobalniID.Postava_Ozob_Bozo,GlobalniID.Postava_Saul_Bright,GlobalniID.Postava_Maman_Mama_Brigitte,GlobalniID.Postava_Emmerick_Bronson,GlobalniID.Postava_Yuri_Bychkov,GlobalniID.Postava_Tom_Caldera,GlobalniID.Postava_Rachel_Casich,GlobalniID.Postava_Aurore_Cassel,GlobalniID.Postava_Aymeric_Cassel,GlobalniID.Kategorie15,GlobalniID.Kategorie07,GlobalniID.Postava_Ruby_Collins,GlobalniID.Postava_Citizen_Corporat_01,GlobalniID.Postava_Citizen_Corporat_12,GlobalniID.Postava_Tamara_Cosby,GlobalniID.Postava_Lauren_Costigan,GlobalniID.Kategorie02,GlobalniID.Postava_Denzel_The_Brain_Cryer,GlobalniID.Postava_Altiera_Alt_Cunningham,GlobalniID.Postava_JigJig_Dancer_05,GlobalniID.Postava_Tube_Dancer_08,GlobalniID.Postava_Ayden_Daniels,GlobalniID.Postava_Hasan_Demir,GlobalniID.Postava_Denny,GlobalniID.Postava_Dexter_Dex_DeShawn,GlobalniID.Postava_Dietlinde,GlobalniID.Postava_Dino_Dinovic,GlobalniID.Postava_District_Teen_01,GlobalniID.Postava_Jasmine_Dixon,GlobalniID.Kategorie09,GlobalniID.Postava_Dogtown_Joytoy_01,GlobalniID.Postava_Dogtown_Joytoy_06,GlobalniID.Postava_Dogtown_Nightlife_02,GlobalniID.Postava_Dogtown_Nightlife_05,GlobalniID.Postava_Dogtown_Nightlife_10,GlobalniID.Postava_Hwangbo_Dong_Gun,GlobalniID.Postava_Sandra_Dorsett,GlobalniID.Postava_Aldecaldos_Female_Driver_Lvl_3_3,GlobalniID.Postava_Dum_Dum,GlobalniID.Postava_Sophia_Dupont,GlobalniID.Postava_Ruth_Dzeng,GlobalniID.Postava_Zuleikha_El_Ahmar,GlobalniID.Postava_Carol_Emeka,GlobalniID.Postava_Kerry_Eurodyne,GlobalniID.Postava_Mr_Blue_Eyes,GlobalniID.Postava_Arasaka_Corpo_01,GlobalniID.Postava_Veteran_Guard_01,GlobalniID.Postava_Biker_Female_04,GlobalniID.Postava_Purple_Force,GlobalniID.Postava_Jax_Forgrave,GlobalniID.Postava_Charlene_Fox,GlobalniID.Postava_Martha_Frakes,GlobalniID.Postava_Finn_Fingers_Gerstatt,GlobalniID.Postava_Hologram_Pachinko_Girl,GlobalniID.Postava_Wakakos_Desk_Girl,GlobalniID.Postava_Godiva,GlobalniID.Postava_Declan_Brick_Griffin,GlobalniID.Postava_Anna_Hamill,GlobalniID.Postava_Kurt_Hansen,GlobalniID.Postava_Tourist_01,GlobalniID.Postava_Brittany_Hayes,GlobalniID.Postava_Heavy_Hearts_Waitress_01,GlobalniID.Postava_Heavy_Hearts_Waitress_02,GlobalniID.Postava_Heavy_Hearts_Waitress_03,GlobalniID.Postava_Heavy_Hearts_Waitress_04,GlobalniID.Postava_Heavy_Hearts_Waitress_05,GlobalniID.Postava_Henry,GlobalniID.Postava_Rose_Horrigan,GlobalniID.Postava_Zaria_Hughes,GlobalniID.Postava_Dao_Hyunh,GlobalniID.Postava_Linh_Hyunh,GlobalniID.Postava_Sebastian_Padre_Ibarra,GlobalniID.Postava_Imogen,GlobalniID.Postava_Nancy_Hartley,GlobalniID.Postava_Maggie_Isley,GlobalniID.Postava_Arthur_Jenkins,GlobalniID.Postava_Regina_Jones,GlobalniID.Postava_Max_Jones,GlobalniID.Postava_Gillean_Jordan,GlobalniID.Kategorie01,GlobalniID.Postava_Jake_Tim_Kelly,GlobalniID.Postava_Taki_Kenmochi,GlobalniID.Postava_Kissy,GlobalniID.Postava_Joanne_Koch,GlobalniID.Postava_Mike_Tiny_Mike_Kowalski,GlobalniID.Postava_Nina_Kraviz,GlobalniID.Postava_Sachiko_Kusama,GlobalniID.Postava_Lucyna_Lucy_Kushinada,GlobalniID.Postava_Joss_Kutcher,GlobalniID.Postava_Akai_Red_Menace_Kyoi,GlobalniID.Postava_Wilky_Slider_LaGuerre,GlobalniID.Postava_Miranda_Lawson,GlobalniID.Postava_Karina_Lee,GlobalniID.Postava_Barry_Lewis,GlobalniID.Postava_Johnny_Silverhand,GlobalniID.Postava_Olga_Elisabeth_Longmead,GlobalniID.Postava_Dusty_Lowe,GlobalniID.Postava_Queen_Of_The_Stoop_12,GlobalniID.Postava_Lowlife_Latino_01,GlobalniID.Postava_Queen_Of_The_Stoop_03,GlobalniID.Postava_Queen_Of_The_Stoop_16,GlobalniID.Postava_Queen_Of_The_Stoop_07,GlobalniID.Postava_Lowlife_Latino_07,GlobalniID.Postava_Nova_MacCaster,GlobalniID.Postava_Maiko_Maeda,GlobalniID.Kategorie06,GlobalniID.Postava_Maelstrom_Female_01,GlobalniID.Postava_Maelstrom_Female_02,GlobalniID.Postava_Maelstrom_Female_03,GlobalniID.Postava_Maelstrom_Male_01,GlobalniID.Postava_Maelstrom_Male_02,GlobalniID.Postava_NCPD_Male_01,GlobalniID.Postava_Lina_Malina,GlobalniID.Postava_Mallrat_05,GlobalniID.Postava_Mallrat_10,GlobalniID.Postava_Christine_Markov,GlobalniID.Postava_Griselda_Green_Cloud_Martinez,GlobalniID.Postava_Emilie_Massenat,GlobalniID.Postava_Laura_May,GlobalniID.Postava_Juan_Mendez,GlobalniID.Postava_Driss_Scorpion_Meriana,GlobalniID.Postava_Song_Songbird_So_Mi,GlobalniID.Postava_Bryce_Mosley,GlobalniID.Postava_Lt_Mower,GlobalniID.Kategorie03,GlobalniID.Postava_Mox_Female_01,GlobalniID.Postava_Mox_Female_02,GlobalniID.Postava_Mox_Female_03,GlobalniID.Postava_Mox_Female_04,GlobalniID.Postava_Mox_Female_05,GlobalniID.Postava_Mox_Female_06,GlobalniID.Postava_Mox_Female_Lvl_2_1,GlobalniID.Postava_Mox_Female_Lvl_2_2,GlobalniID.Postava_Mox_Female_Lvl_2_3,GlobalniID.Postava_Mox_Female_Lvl_3_1,GlobalniID.Postava_Mox_Female_Lvl_3_3,GlobalniID.Postava_Mox_Male_01,GlobalniID.Postava_Mox_Male_02,GlobalniID.Postava_Mox_Male_03,GlobalniID.Postava_Mox_Male_04,GlobalniID.Postava_Mox_Male_05,GlobalniID.Postava_Mox_Male_06,GlobalniID.Postava_Mox_Male_07,GlobalniID.Postava_Mox_Male_08,GlobalniID.Postava_Mox_Male_09,GlobalniID.Postava_Albert_Murphy,GlobalniID.Postava_Arabella_Spider_Murphy,GlobalniID.Postava_Rosalind_Myers,GlobalniID.Postava_Cynthia_Najarro,GlobalniID.Postava_Pepe_Najarro,GlobalniID.Postava_Farida_Nazeri,GlobalniID.Postava_NCPD_Female_01,GlobalniID.Postava_NCPD_Female_02,GlobalniID.Postava_Arasaka_Netrunner_Lvl_2_3,GlobalniID.Postava_Nightlife_Hottie_21,GlobalniID.Postava_Nightlife_Hottie_15,GlobalniID.Postava_Nix,GlobalniID.Postava_Nonbinary_Youngster_01,GlobalniID.Postava_Frank_Nostra,GlobalniID.Postava_Cheri_Nowlin,GlobalniID.Postava_Mox_Female_Lvl_3_2,GlobalniID.Postava_Aguilar_Nubiola_Female,GlobalniID.Postava_Aguilar_Nubiola_Male,GlobalniID.Postava_Obese_Caribbean_01,GlobalniID.Postava_Sandayu_Oda,GlobalniID.Postava_Wakako_Okada,GlobalniID.Postava_Tourist_02,GlobalniID.Postava_Barbara_Babs_Okoye,GlobalniID.Postava_Misty_Olszewski,GlobalniID.Postava_Gustavo_Orta,GlobalniID.Postava_Hideyoshi_Oshima,GlobalniID.Postava_Pacific_Female_06,GlobalniID.Postava_Pacific_Female_13,GlobalniID.Postava_Pacific_Female_07,GlobalniID.Postava_Yawen_Packard,GlobalniID.Postava_Panam_Palmer,GlobalniID.Postava_Paradise_Client_02,GlobalniID.Postava_Evelyn_Parker,GlobalniID.Postava_Elizabeth_Peralez,GlobalniID.Postava_Jefferson_Peralez,GlobalniID.Postava_Rafael_Perez,GlobalniID.Postava_Nadia_Petrova,GlobalniID.Postava_Placide,GlobalniID.Postava_Theo_Price,GlobalniID.Postava_Rebeca_Price,GlobalniID.Postava_Lana_Prince,GlobalniID.Postava_Hologram_Prostitute,GlobalniID.Postava_Ziggy_Q,GlobalniID.Postava_Susanna_Susie_Q_Quinn,GlobalniID.Postava_R3n0,GlobalniID.Postava_Sofia_Ramirez,GlobalniID.Postava_Stella_Ramos,GlobalniID.Postava_Simon_Royce_Randall,GlobalniID.Postava_Konpeki_Receptionist_01,GlobalniID.Postava_Solomon_Reed,GlobalniID.Postava_Muamar_El_Capitan_Reyes,GlobalniID.Postava_Yishen_Rhee,GlobalniID.Postava_Rhino,GlobalniID.Postava_Song_So_Ri,GlobalniID.Postava_Boris_Ribakov,GlobalniID.Postava_Rich_Female_12,GlobalniID.Postava_Rich_Female_25,GlobalniID.Postava_Rich_Female_14,GlobalniID.Postava_Cassidy_Righter,GlobalniID.Postava_Leon_Rinder,GlobalniID.Postava_Robot_Corpo,GlobalniID.Postava_Robot_Gang_Maelstrom,GlobalniID.Postava_Robot_Gang_Wraith,GlobalniID.Postava_Robot_Gang_Scavenger,GlobalniID.Postava_Robot_Gang_6th_Street,GlobalniID.Postava_Robot_Training,GlobalniID.Postava_Robot_Remote,GlobalniID.Postava_Robot_Nusa,GlobalniID.Postava_Robot_Moth_Barman,GlobalniID.Kategorie17,GlobalniID.Postava_Tasha_Rodriquez,GlobalniID.Postava_Melisa_Rory,GlobalniID.Postava_Sofia_Rossi,GlobalniID.Postava_Roxxi,GlobalniID.Postava_Journey_Ruiz,GlobalniID.Postava_Micaela_Ruiz,GlobalniID.Postava_Cesar_Diego_Ruiz,GlobalniID.Postava_Claire_Russell,GlobalniID.Postava_Bob_Sagan,GlobalniID.Postava_Peter_Sampson,GlobalniID.Kategorie12,GlobalniID.Postava_Scavengers_Female_01,GlobalniID.Postava_Scavengers_Female_02,GlobalniID.Postava_Scavengers_Female_03,GlobalniID.Postava_Scavengers_Female_04,GlobalniID.Postava_Scavengers_Female_05,GlobalniID.Postava_Scavengers_Female_06,GlobalniID.Postava_Scavengers_Female_07,GlobalniID.Postava_Scavengers_Female_08,GlobalniID.Postava_Scavengers_Male_01,GlobalniID.Postava_Scavengers_Male_02,GlobalniID.Postava_Scavengers_Male_03,GlobalniID.Postava_Scavengers_Male_04,GlobalniID.Postava_Arasaka_Scientist,GlobalniID.Postava_Logan_Scott,GlobalniID.Postava_Clothing_Seller_Std_Arr,GlobalniID.Postava_Clothing_Seller_Std_Rcr,GlobalniID.Postava_Sexworker_Doll_02,GlobalniID.Postava_Sexworker_Prostitute_05,GlobalniID.Postava_Sexworker_Prostitute_07,GlobalniID.Postava_Sexworker_Doll_04,GlobalniID.Postava_Sexworker_Doll_08,GlobalniID.Postava_Sexworker_10,GlobalniID.Postava_Sexworker_02,GlobalniID.Postava_Sexworker_Doll_07,GlobalniID.Postava_Shelma,GlobalniID.Postava_Jotaro_Shobo,GlobalniID.Postava_Yelena_Sidorova,GlobalniID.Postava_Theodore_Teddy_Simos,GlobalniID.Postava_Ofelia_Patricia_Sirawian,GlobalniID.Postava_Skye,GlobalniID.Postava_Adam_Smasher,GlobalniID.Postava_Dakota_Smith,GlobalniID.Kategorie14,GlobalniID.Postava_Linda_Spencer,GlobalniID.Postava_Nele_Springer,GlobalniID.Postava_Benjamin_Stone,GlobalniID.Postava_Meredith_Stout,GlobalniID.Kategorie05,GlobalniID.Postava_Lizzies_Stripper_04,GlobalniID.Postava_Roxanne_Sumner,GlobalniID.Postava_Jago_Szabo,GlobalniID.Postava_T_Bug,GlobalniID.Postava_Goro_Takemura,GlobalniID.Postava_Iris_Tanner,GlobalniID.Postava_Lucy_Thackery,GlobalniID.Postava_Mateo_Thiago,GlobalniID.Postava_Lyle_Thompson,GlobalniID.Postava_Nadezhda_Tiurina,GlobalniID.Postava_Edgar_TooLina_Tool,GlobalniID.Postava_Paco_Torres,GlobalniID.Postava_Beatrice_Ellen_8ug8ear_Trieste,GlobalniID.Postava_Trigger,GlobalniID.Postava_Aoi_Blue_Moon_Tsuki,GlobalniID.Postava_Yoko_Tsuru,GlobalniID.Postava_Tyger_Claws_Female_01,GlobalniID.Postava_Tyger_Claws_Female_02,GlobalniID.Postava_Tyger_Claws_Female_03,GlobalniID.Postava_Tyger_Claws_Male_01,GlobalniID.Postava_Tyger_Claws_Male_02,GlobalniID.Postava_Tyger_Claws_Male_03,GlobalniID.Postava_Satoshi_Ueno,GlobalniID.Postava_E3_Female_V,GlobalniID.Postava_Canon_FemV,GlobalniID.Postava_E3_Male_V,GlobalniID.Postava_Valentinos_Female_01,GlobalniID.Postava_Valentinos_Female_02,GlobalniID.Postava_Valentinos_Female_03,GlobalniID.Postava_Valentinos_Female_04,GlobalniID.Postava_Tenant_Morning_Crowd_07,GlobalniID.Postava_Valentinos_Male_01,GlobalniID.Postava_Valentinos_Male_02,GlobalniID.Postava_Valentinos_Male_03,GlobalniID.Kategorie04,GlobalniID.Postava_Fiona_Vargas,GlobalniID.Postava_Victor_Vektor,GlobalniID.Postava_Vendor_03,GlobalniID.Postava_Clothing_Seller_Wat_Nid,GlobalniID.Postava_Clothing_Seller_Bls_Ina,GlobalniID.Postava_Food_Seller_Wbr_Jpn,GlobalniID.Postava_Clothing_Seller_Wbr_Jpn,GlobalniID.Postava_Hologram_VIP,GlobalniID.Postava_Voodoo_Boys_Female_01,GlobalniID.Postava_Voodoo_Boys_Female_02,GlobalniID.Postava_Voodoo_Boys_Female_03,GlobalniID.Postava_Voodoo_Boys_Female_04,GlobalniID.Postava_Voodoo_Boys_Female_05,GlobalniID.Postava_Voodoo_Boys_Female_06,GlobalniID.Postava_Voodoo_Boys_Female_07,GlobalniID.Postava_Grace_Karina_Voronova,GlobalniID.Postava_Caliente_Waitress_01,GlobalniID.Postava_Konpeki_Waitress_01,GlobalniID.Postava_Helen_Wandoo,GlobalniID.Postava_River_Ward,GlobalniID.Postava_Guadalupe_Alejandra_Welles,GlobalniID.Postava_Jackie_Welles,GlobalniID.Postava_Rita_Wheeler,GlobalniID.Postava_Angelica_Angie_Whelan,GlobalniID.Postava_Bree_Whitney,GlobalniID.Postava_Robert_Wilson,GlobalniID.Postava_Elisabeth_Lizzy_Wizzy_Wissenfurth,GlobalniID.Kategorie13,GlobalniID.Postava_Wraiths_Female_01,GlobalniID.Postava_Wraiths_Female_02,GlobalniID.Postava_Wraiths_Female_03,GlobalniID.Postava_Wraiths_Female_04,GlobalniID.Postava_Wraiths_Male_01,GlobalniID.Postava_Wraiths_Male_02,GlobalniID.Postava_Wraiths_Male_03,GlobalniID.Postava_Alena_Alex_Xenakis,GlobalniID.Postava_Nika_Yankovich,GlobalniID.Postava_Julia_Young,GlobalniID.Postava_Youngster_Slacker_14,GlobalniID.Postava_Youngster_Slacker_05,GlobalniID.Postava_Youngster_Slacker_06,GlobalniID.Postava_Youngster_Slacker_08,GlobalniID.Postava_Female_V,GlobalniID.Postava_Male_V,GlobalniID.Postava_Tyler_Zan,GlobalniID.Postava_Ayo_Zarin,GlobalniID.Postava_Georgina_Zembinsky
];

public func NarozeninyData(datum: String) -> array<GlobalniID> {
	let data: array<GlobalniID> = [];

	switch datum {
		case "19-01": data = [GlobalniID.Postava_River_Ward]; break;
		case "02-03": data = [GlobalniID.Postava_Hanako_Arasaka]; break;
		case "28-03": data = [GlobalniID.Postava_Rosalind_Myers]; break;
		case "05-04": data = [GlobalniID.Postava_Victor_Vektor]; break;
		case "07-04": data = [GlobalniID.Postava_Kerry_Eurodyne]; break;
		case "30-04": data = [GlobalniID.Postava_Misty_Olszewski]; break;
		case "21-05": data = [GlobalniID.Postava_Aurore_Cassel, GlobalniID.Postava_Aymeric_Cassel]; break;
		case "26-05": data = [GlobalniID.Postava_Jackie_Welles]; break;
		case "21-06": data = [GlobalniID.Postava_Adam_Smasher]; break;
		case "02-07": data = [GlobalniID.Postava_Wade_Mr_Hands_Bleecker]; break;
		case "07-07": data = [GlobalniID.Postava_Rita_Wheeler]; break;
		case "23-08": data = [GlobalniID.Postava_Panam_Palmer]; break;
		case "27-08": data = [GlobalniID.Postava_Altiera_Alt_Cunningham]; break;
		case "22-09": data = [GlobalniID.Postava_Kurt_Hansen]; break;
		case "12-10": data = [GlobalniID.Postava_Female_V, GlobalniID.Postava_Male_V, GlobalniID.Postava_E3_Female_V, GlobalniID.Postava_E3_Male_V, GlobalniID.Postava_Canon_FemV]; break;
		case "23-10": data = [GlobalniID.Postava_Goro_Takemura]; break;
		case "14-11": data = [GlobalniID.Postava_Rogue_Amendiares]; break;
		case "16-11": data = [GlobalniID.Postava_Johnny_Silverhand]; break;
		case "27-11": data = [GlobalniID.Postava_Judy_Alvarez]; break;
		case "12-12": data = [GlobalniID.Postava_Solomon_Reed]; break;
		case "29-12": data = [GlobalniID.Postava_Song_Songbird_So_Mi]; break;
		case "26-09": data = [GlobalniID.Prazdne]; break;
		case "10-12": data = [GlobalniID.Prazdne]; break;
		case "13-09": data = [GlobalniID.Prazdne]; break;
	};

	return data;
}

public func Prekladatele() -> String {
	let str: String = "";

	str += "<Rich style=\"Bold\">N0vemberM1ke</> (Japanese)";
	str += ", ";
	str += "<Rich style=\"Bold\">Meridian4761</> (Persian)";
	str += ", ";
	str += "<Rich style=\"Bold\">downsource</> (German)";
	str += ", ";
	str += "<Rich style=\"Bold\">hor0303 / ApoKrytia</> (Traditional Chinese)";
	str += ", ";
	str += "<Rich style=\"Bold\">Arrows0201 / catandlemonade / MusTangGD</> (Simplified Chinese)";
	str += ", ";
	str += "<Rich style=\"Bold\">Kruatz / areces97</> (Spanish)";
	str += ", ";
	str += "<Rich style=\"Bold\">yRaven / PabloLorenzo / BlazingBlack12</> (Brazilian Portuguese)";
	str += ", ";
	str += "<Rich style=\"Bold\">Laryakan / Angie7938</> (French)";
	str += ", ";
	str += "<Rich style=\"Bold\">Shadoky</> (Polish)";
	str += ", ";
	str += "<Rich style=\"Bold\">OzelHarekaTR</> (Turkish)";
	str += ", ";
	str += "<Rich style=\"Bold\">MoookGwak / haljit00 / nolimit14448 / laststock2077</> (Korean)";
	str += ", ";
	str += "<Rich style=\"Bold\">orazio / EastwardSage / micuzzo87</> (Italian)";
	str += ", ";
	str += "<Rich style=\"Bold\">Locked15 / Mrstarman59 / Masuryan</> (Russian)";
	str += ", ";
	str += "<Rich style=\"Bold\">LiquidBronze / ArmanIII</> (English)";
	str += ", ";
	str += "<Rich style=\"Bold\">ArmanIII</> (Czech)";

	return str;
}
