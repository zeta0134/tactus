no_item_name_localized:
  .addr no_item_name_english
  .addr no_item_name_toki_pona_sitelen_lasina
  .addr no_item_name_toki_pona_sitelen_pona
no_item_name_english: .byte D_FONT, FONT_ASCII, "NO ITEM", D_RETURN
no_item_name_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "ILO ALA", D_RETURN
no_item_name_toki_pona_sitelen_pona: .byte D_FONT, FONT_SITELEN_PONA, _ILO, _ALA, D_RETURN

no_item_description_localized:
  .addr no_item_description_english
  .addr no_item_description_toki_pona_sitelen_lasina
  .addr no_item_description_toki_pona_sitelen_pona
no_item_description_english: .byte D_FONT, FONT_ASCII, "Huh? You shouldn't be", D_NEWLINE, "reading this!", D_RETURN
no_item_description_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "seme? o lukin ala", D_NEWLINE, "e lipu ni, a!", D_RETURN
no_item_description_toki_pona_sitelen_pona: .byte D_FONT, FONT_SITELEN_PONA, _SEME, D_FONT, FONT_ASCII, " ", D_FONT, FONT_SITELEN_PONA, _O, _LUKIN, _ALA, _E, _LIPU, _NI, _A, D_RETURN

dagger_name_localized:
  .addr dagger_name_english
  .addr dagger_name_toki_pona_sitelen_lasina
  .addr dagger_name_toki_pona_sitelen_pona
dagger_name_english: .byte D_FONT, FONT_ASCII, "DAGGER", D_RETURN
dagger_name_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "ILO UTALA LILI", D_RETURN
dagger_name_toki_pona_sitelen_pona: .byte D_FONT, FONT_SITELEN_PONA, _ILO, _UTALA, _LILI, D_RETURN

dagger_description_localized:
  .addr dagger_description_english
  .addr dagger_description_toki_pona_sitelen_lasina
  .addr dagger_description_toki_pona_sitelen_pona
dagger_description_english: .byte D_FONT, FONT_ASCII, "...kinda crummy!", D_RETURN
dagger_description_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "... ni li ike lili.", D_RETURN
dagger_description_toki_pona_sitelen_pona: .byte D_FONT, FONT_ASCII, "...", D_FONT, FONT_SITELEN_PONA, _NI, _LI, _IKE, _LILI, D_RETURN

broadsword_name_localized:
  .addr broadsword_name_english
  .addr broadsword_name_toki_pona_sitelen_lasina
  .addr broadsword_name_toki_pona_sitelen_pona
broadsword_name_english: .byte D_FONT, FONT_ASCII, "BROADSWORD", D_RETURN
broadsword_name_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "ILO UTALA SULI POKA", D_RETURN
broadsword_name_toki_pona_sitelen_pona: .byte D_FONT, FONT_SITELEN_PONA, _ILO, _UTALA, _SULI, _POKA, D_RETURN

broadsword_description_localized:
  .addr broadsword_description_english
  .addr broadsword_description_toki_pona_sitelen_lasina
  .addr broadsword_description_toki_pona_sitelen_pona
broadsword_description_english: .byte D_FONT, FONT_ASCII, "Hits 3 squares in front.", D_RETURN
broadsword_description_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "pakala e leko poka 3.", D_RETURN
broadsword_description_toki_pona_sitelen_pona: .byte D_FONT, FONT_SITELEN_PONA, _PAKALA, _E, D_EXT_CHAR, _LEKO, _POKA, D_FONT, FONT_ASCII, "3", D_RETURN

longsword_name_localized:
  .addr longsword_name_english
  .addr longsword_name_toki_pona_sitelen_lasina
  .addr longsword_name_toki_pona_sitelen_pona
longsword_name_english: .byte D_FONT, FONT_ASCII, "LONGSWORD", D_RETURN
longsword_name_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "ILO UTALA SULI LINJA", D_RETURN
longsword_name_toki_pona_sitelen_pona: .byte D_FONT, FONT_SITELEN_PONA, _ILO, _UTALA, _SULI, _LINJA, D_RETURN

longsword_description_localized:
  .addr longsword_description_english
  .addr longsword_description_toki_pona_sitelen_lasina
  .addr longsword_description_toki_pona_sitelen_pona
longsword_description_english: .byte D_FONT, FONT_ASCII, "Hits 2 squares ahead.", D_RETURN
longsword_description_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "pakala e leko sinpin 2.", D_RETURN
longsword_description_toki_pona_sitelen_pona: .byte D_FONT, FONT_SITELEN_PONA, _PAKALA, _E, D_EXT_CHAR, _LEKO, _SINPIN, D_FONT, FONT_ASCII, "2", D_RETURN

flail_name_localized:
  .addr flail_name_english
  .addr flail_name_toki_pona_sitelen_lasina
  .addr flail_name_toki_pona_sitelen_pona
flail_name_english: .byte D_FONT, FONT_ASCII, "flail_name", D_RETURN
flail_name_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "flail_name", D_RETURN
flail_name_toki_pona_sitelen_pona: .byte D_FONT, FONT_ASCII, "flail_name", D_RETURN

flail_description_localized:
  .addr flail_description_english
  .addr flail_description_toki_pona_sitelen_lasina
  .addr flail_description_toki_pona_sitelen_pona
flail_description_english: .byte D_FONT, FONT_ASCII, "flail_description", D_RETURN
flail_description_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "flail_description", D_RETURN
flail_description_toki_pona_sitelen_pona: .byte D_FONT, FONT_ASCII, "flail_description", D_RETURN

spear_name_localized:
  .addr spear_name_english
  .addr spear_name_toki_pona_sitelen_lasina
  .addr spear_name_toki_pona_sitelen_pona
spear_name_english: .byte D_FONT, FONT_ASCII, "SPEAR", D_RETURN
spear_name_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "PALISA KIPISI", D_RETURN
spear_name_toki_pona_sitelen_pona: .byte D_FONT, FONT_SITELEN_PONA, _PALISA, D_EXT_CHAR, _KIPISI, D_RETURN

spear_description_localized:
  .addr spear_description_english
  .addr spear_description_toki_pona_sitelen_lasina
  .addr spear_description_toki_pona_sitelen_pona
spear_description_english: .byte D_FONT, FONT_ASCII, "Strike one foe up to", D_NEWLINE, "2 squares ahead.", D_RETURN
spear_description_toki_pona_sitelen_lasina: .byte D_FONT, FONT_ASCII, "pakala e leko weka 2.", D_RETURN
spear_description_toki_pona_sitelen_pona: .byte D_FONT, FONT_SITELEN_PONA, _PAKALA, _E, D_EXT_CHAR, _LEKO, _WEKA, D_FONT, FONT_ASCII, "2", D_RETURN

