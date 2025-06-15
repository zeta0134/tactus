#!/usr/bin/env python3

# Sortof an experiment for gettext

import gettext, sys
from sitelen_pona import sitelen_pona_pu, sitelen_pona_ku, sitelen_pona_kijete_santakalu

# returns the byte sequence corresponding to this glyph. 
def special_glyphs(raw_char):
    if raw_char in sitelen_pona_pu:
        return ([sitelen_pona_pu[raw_char]], "FONT_SITELEN_PONA")
    if raw_char in sitelen_pona_ku:
        return (sitelen_pona_ku[raw_char], "FONT_SITELEN_PONA")
    if raw_char in sitelen_pona_kijete_santakalu:
        return (sitelen_pona_kijete_santakalu[raw_char], "FONT_SITELEN_PONA")
    if raw_char == "\n":
        return (["D_NEWLINE"], "FONT_ASCII")
    return None

# Don't go nuts with these, many commands aren't that useful
# and the more we have, the more expensive this routine gets.
embedded_command_strings = {}
embedded_command_strings["[PLAYER_NAME]"] = ["D_PLAYER_NAME"]
embedded_command_strings["[WAIT]"] = ["D_WAIT"]
embedded_command_strings["[CLEAR]"] = ["D_CLEAR"]

def contains_command_string(test_str):
    for candidate_command in embedded_command_strings:
        if test_str.startswith(candidate_command):
            remaining_str = test_str[len(candidate_command):]
            return (embedded_command_strings[candidate_command], remaining_str)
    return None

def massage_string(unicode_str):
    output_string = []
    byte_count = 0
    current_font = ""
    current_ascii_string = ""
    while len(unicode_str) > 0:
        maybe_cmd = contains_command_string(unicode_str)
        if maybe_cmd != None:
            if len(current_ascii_string) > 0:
                if current_font != "FONT_ASCII":
                    output_string.append("D_FONT")
                    output_string.append("FONT_ASCII")
                    current_font = "FONT_ASCII"
                    byte_count += 2
                output_string.append(f'"{current_ascii_string}"')
                byte_count += len(current_ascii_string)
                current_ascii_string = ""
            (cmd_bytes, unicode_str) = maybe_cmd
            output_string.extend(cmd_bytes)
            byte_count += len(cmd_bytes)
        else:
            raw_char = unicode_str[0:1]
            unicode_str = unicode_str[1:]
            glyph_properties = special_glyphs(raw_char)
            if glyph_properties != None:
                if len(current_ascii_string) > 0:
                    if current_font != "FONT_ASCII":
                        output_string.append("D_FONT")
                        output_string.append("FONT_ASCII")
                        current_font = "FONT_ASCII"
                        byte_count += 2
                    output_string.append(f'"{current_ascii_string}"')
                    byte_count += len(current_ascii_string)
                    current_ascii_string = ""
                (byte_sequence, font) = glyph_properties
                if current_font != font:
                    output_string.append("D_FONT")
                    output_string.append(font)
                    current_font = font
                    byte_count += 2
                output_string.extend(byte_sequence)
                byte_count += len(byte_sequence)
            elif raw_char.isascii():
                current_ascii_string += raw_char
            else:
                print(f"Warning: unprintable char: {raw_char}, ignoring")
    if len(current_ascii_string) > 0:
        if current_font != "FONT_ASCII":
            output_string.append("D_FONT")
            output_string.append("FONT_ASCII")
            current_font = "FONT_ASCII"
            byte_count += 2
        output_string.append(f'"{current_ascii_string}"')
        byte_count += len(current_ascii_string)
    
    # TODO: check for instances of double-newline and replace with D_WAIT, D_CLEAR?
    # other fun exceptions? unclear!

    # All strings end with D_RETURN, without exception.
    output_string.append("D_RETURN")
    byte_count += 1

    return (".byte " + ", ".join(output_string), byte_count)

def gather_translated_strings(languages):
    language_strings = {}
    for l in languages:
        languages[l].install()

        # Items somewhat uniquely have a name/description formatting thing going on,
        # so we break them up accordingly.

        items = {}
        items["no_item"] = {
            "name":        _("no_item_name"),
            "description": _("no_item_description")}
        items["dagger"] = {
            "name":        _("dagger_name"),
            "description": _("dagger_description")}
        items["broadsword"] = {
            "name":        _("broadsword_name"),
            "description": _("broadsword_description")}
        items["longsword"] = {
            "name":        _("longsword_name"),
            "description": _("longsword_description")}
        items["flail"] = {
            "name":        _("flail_name"),
            "description": _("flail_description")}
        items["spear"] = {
            "name":        _("spear_name"),
            "description": _("spear_description")}

        items["basic_torch"] = {
            "name":        _("basic_torch_name"),
            "description": _("basic_torch_description")}
        items["large_torch"] = {
            "name":        _("large_torch_name"),
            "description": _("large_torch_description")}
        items["compass"] = {
            "name":        _("compass_name"),
            "description": _("compass_description")}
        items["map"] = {
            "name":        _("map_name"),
            "description": _("map_description")}
        items["small_fries"] = {
            "name":        _("small_fries_name"),
            "description": _("small_fries_description")}
        items["medium_fries"] = {
            "name":        _("medium_fries_name"),
            "description": _("medium_fries_description")}
        items["large_fries"] = {
            "name":        _("large_fries_name"),
            "description": _("large_fries_description")}
        items["go_go_boots"] = {
            "name":        _("go_go_boots_name"),
            "description": _("go_go_boots_description")}
        items["gold_sack"] = {
            "name":        _("gold_sack_name"),
            "description": _("gold_sack_description")}
        items["heart_container"] = {
            "name":        _("heart_container_name"),
            "description": _("heart_container_description")}
        items["temporary_heart"] = {
            "name":        _("temporary_heart_name"),
            "description": _("temporary_heart_description")}
        items["heart_armor"] = {
            "name":        _("heart_armor_name"),
            "description": _("heart_armor_description")}
        items["defensive_shield"] = {
            "name":        _("defensive_shield_name"),
            "description": _("defensive_shield_description")}
        items["chain_link"] = {
            "name":        _("chain_link_name"),
            "description": _("chain_link_description")}
        items["aloha_tshirt"] = {
            "name":        _("aloha_tshirt_name"),
            "description": _("aloha_tshirt_description")}
        items["bombs"] = {
            "name":        _("bombs_name"),
            "description": _("bombs_description")}
        items["spell_fire"] = {
            "name":        _("spell_fire_name"),
            "description": _("spell_fire_description")}
        items["spell_air"] = {
            "name":        _("spell_air_name"),
            "description": _("spell_air_description")}
        items["spell_ice"] = {
            "name":        _("spell_ice_name"),
            "description": _("spell_ice_description")}
        items["spell_earth"] = {
            "name":        _("spell_earth_name"),
            "description": _("spell_earth_description")}
        items["spell_bomb_fiesta"] = {
            "name":        _("spell_bomb_fiesta_name"),
            "description": _("spell_bomb_fiesta_description")}
        items["spell_life"] = {
            "name":        _("spell_life_name"),
            "description": _("spell_life_description")}
        items["obsidian_ring"] = {
            "name":        _("obsidian_ring_name"),
            "description": _("obsidian_ring_description")}
        items["ruby_necklace"] = {
            "name":        _("ruby_necklace_name"),
            "description": _("ruby_necklace_description")}
        items["topaz_earrings"] = {
            "name":        _("topaz_earrings_name"),
            "description": _("topaz_earrings_description")}
        items["sapphire_bracelet"] = {
            "name":        _("sapphire_bracelet_name"),
            "description": _("sapphire_bracelet_description")}
        items["ninja_footwraps"] = {
            "name":        _("ninja_footwraps_name"),
            "description": _("ninja_footwraps_description")}
        items["amulet_of_yendor"] = {
            "name":        _("amulet_of_yendor_name"),
            "description": _("amulet_of_yendor_description")}
        items["lucky_penny"] = {
            "name":        _("lucky_penny_name"),
            "description": _("lucky_penny_description")}
        items["cheap_plastic_imitation_of_the_amulet_of_yendor"] = {
            "name":        _("cheap_plastic_imitation_of_the_amulet_of_yendor_name"),
            "description": _("cheap_plastic_imitation_of_the_amulet_of_yendor_description")}

        # massage the translated strings into a data structure keyed on the individual message,
        # as this is our output unit for the game. (We're looping over entire languages at once,
        # so this is slightly awkward to do.)
        for k in items:
            (item_name_message, item_name_length)               = massage_string(items[k]["name"])
            (item_description_message, item_description_length) = massage_string(items[k]["description"])
            if k + "_name" not in language_strings:
                language_strings[k + "_name"] = {}
            language_strings[k + "_name"][l] = {
                "message": item_name_message,
                "length": item_name_length}
            if k + "_description" not in language_strings:
                language_strings[k + "_description"] = {}
            language_strings[k + "_description"][l] = {
                "message": item_description_message,
                "length": item_description_length}

        # now for UI strings, oh boy oh boy!

        ui_strings = {}
        # various debug strings that we initially used to test localization. these shouldn't go
        # anywhere particularly visible in the final game, but we might as well keep them around
        # and translate them properly while we test.
        ui_strings["hello_world"] = _("hello_world")

        # Somewhat common strings reused by several components
        ui_strings["ui_option_enabled"]   = _("ui_option_enabled")
        ui_strings["ui_option_disabled"]  = _("ui_option_disabled")
        ui_strings["ui_option_on"]   = _("ui_option_on")
        ui_strings["ui_option_off"]  = _("ui_option_off")

        # options strings, sorted by tab
        # tab: palette 1
        ui_strings["options_player_palette_header"]              = _("options_player_palette_header")
        ui_strings["options_player_palette_preset_label"]        = _("options_player_palette_preset_label")
        ui_strings["options_player_palette_preset_personalized"] = _("options_player_palette_preset_personalized")
        ui_strings["options_player_palette_preset_peony"]        = _("options_player_palette_preset_peony")
        ui_strings["options_player_palette_preset_periwinkle"]   = _("options_player_palette_preset_periwinkle")
        ui_strings["options_player_palette_preset_petunia"]      = _("options_player_palette_preset_petunia")
        ui_strings["options_player_palette_preset_protea"]       = _("options_player_palette_preset_protea")
        ui_strings["options_player_palette_preset_passion"]      = _("options_player_palette_preset_passion")

        ui_strings["options_player_palette_outfit"] = _("options_player_palette_outfit")
        ui_strings["options_player_palette_shoes"]  = _("options_player_palette_shoes")
        ui_strings["options_player_palette_face"]   = _("options_player_palette_face")

        # note: this option may be going away, in favor of challenge totems
        ui_strings["options_game_mode_label"]       = _("options_game_mode_label")
        ui_strings["options_game_mode_standard"]    = _("options_game_mode_standard")
        ui_strings["options_game_mode_patient"]     = _("options_game_mode_patient")
        ui_strings["options_game_mode_doubletime"]  = _("options_game_mode_doubletime")

        ui_strings["options_disco_floor_label"]            = _("options_disco_floor_label")
        ui_strings["options_disco_floor_instant_squares"]  = _("options_disco_floor_instant_squares")
        ui_strings["options_disco_floor_frozen_squares"]   = _("options_disco_floor_frozen_squares")
        ui_strings["options_disco_floor_instant_outlines"] = _("options_disco_floor_instant_outlines")
        ui_strings["options_disco_floor_frozen_outlines"]  = _("options_disco_floor_frozen_outlines")
        ui_strings["options_disco_floor_just_groovement"]  = _("options_disco_floor_just_groovement")
        ui_strings["options_disco_floor_no_motion"]        = _("options_disco_floor_no_motion")

        ui_strings["options_minimap_theme_label"]        = _("options_minimap_theme_label")
        ui_strings["options_minimap_theme_dark_grey"]    = _("options_minimap_theme_dark_grey")
        ui_strings["options_minimap_theme_dark_yellow"]  = _("options_minimap_theme_dark_yellow")
        ui_strings["options_minimap_theme_dark_blue"]    = _("options_minimap_theme_dark_blue")
        ui_strings["options_minimap_theme_dark_red"]     = _("options_minimap_theme_dark_red")
        ui_strings["options_minimap_theme_light_grey"]   = _("options_minimap_theme_light_grey")
        ui_strings["options_minimap_theme_light_yellow"] = _("options_minimap_theme_light_yellow")
        ui_strings["options_minimap_theme_light_blue"]   = _("options_minimap_theme_light_blue")
        ui_strings["options_minimap_theme_light_red"]    = _("options_minimap_theme_light_red")

        ui_strings["options_colorspace_label"]            = _("options_colorspace_label")
        ui_strings["options_colorspace_default"]          = _("options_colorspace_default")
        ui_strings["options_colorspace_protan_deuteran"]  = _("options_colorspace_protan_deuteran")
        ui_strings["options_colorspace_tritan"]           = _("options_colorspace_tritan")
        ui_strings["options_colorspace_monochrome_green"] = _("options_colorspace_monochrome_green")
        ui_strings["options_colorspace_monochrome_grey"]  = _("options_colorspace_monochrome_grey")

        ui_strings["options_ppu_type_label"]           = _("options_ppu_type_label")
        ui_strings["options_ppu_type_automatic"]       = _("options_ppu_type_automatic")
        ui_strings["options_ppu_type_composite"]       = _("options_ppu_type_composite")
        ui_strings["options_ppu_type_rgb"]             = _("options_ppu_type_rgb")

        ui_strings["options_color_emphasis_label"]     = _("options_color_emphasis_label")

        ui_strings["options_rhythm_assistance_header"] = _("options_rhythm_assistance_header")
        ui_strings["options_flash_player_label"]       = _("options_flash_player_label")
        ui_strings["options_flash_separator_label"]    = _("options_flash_separator_label")

        ui_strings["options_soundfx_mode_label"]       = _("options_soundfx_mode_label")
        ui_strings["options_music_mode_label"]         = _("options_music_mode_label")
        ui_strings["options_music_mode_metronome"]     = _("options_music_mode_metronome")

        ui_strings["options_tab_header_world_palette"] = _("options_tab_header_world_palette")
        ui_strings["options_tab_header_gameplay"]      = _("options_tab_header_gameplay")
        ui_strings["options_tab_header_input"]         = _("options_tab_header_input")
        ui_strings["options_tab_header_audio"]         = _("options_tab_header_audio")
        ui_strings["options_tab_header_compatibility"] = _("options_tab_header_compatibility")
        ui_strings["options_tab_header_debug"]         = _("options_tab_header_debug")

        ui_strings["options_coming_soon_placeholder"]  = _("options_coming_soon_placeholder")
        ui_strings["options_silly_tcrf_shoutout"]      = _("options_silly_tcrf_shoutout")

        ui_strings["file_select_header"]                      = _("file_select_header")
        ui_strings["file_select_msg_erase_which"]             = _("file_select_msg_erase_which")
        ui_strings["file_select_msg_erase_confirm"]           = _("file_select_msg_erase_confirm")
        ui_strings["file_select_msg_copy_source_select"]      = _("file_select_msg_copy_source_select")
        ui_strings["file_select_msg_copy_destination_select"] = _("file_select_msg_copy_destination_select")
        ui_strings["file_select_msg_copy_confirm"]            = _("file_select_msg_copy_confirm")
        ui_strings["file_select_erase_file_button"]           = _("file_select_erase_file_button")
        ui_strings["file_select_copy_file_button"]            = _("file_select_copy_file_button")

        ui_strings["name_entry_header"]            = _("name_entry_header")

        ui_strings["file_details_welcome_string"]            = _("file_details_welcome_string")

        ui_strings["file_details_start_game_button"] = _("file_details_start_game_button")
        ui_strings["file_details_options_button"]    = _("file_details_options_button")

        ui_strings["file_select_new_file"]        = _("file_select_new_file")
        ui_strings["file_select_run_in_progress"] = _("file_select_run_in_progress")

        ui_strings["string_entry_delete_button"] = _("string_entry_delete_button")
        ui_strings["string_entry_accept_button"] = _("string_entry_accept_button")

        ui_strings["string_entry_english_uppercase"]         = _("string_entry_english_uppercase")
        ui_strings["string_entry_english_lowercase"]         = _("string_entry_english_lowercase")
        ui_strings["string_entry_sitelen_pona_pu_1"]         = _("string_entry_sitelen_pona_pu_1")
        ui_strings["string_entry_sitelen_pona_pu_2"]         = _("string_entry_sitelen_pona_pu_2")
        ui_strings["string_entry_sitelen_pona_pu_3_ku_misc"] = _("string_entry_sitelen_pona_pu_3_ku_misc")

        for k in ui_strings:
            (message, length) = massage_string(ui_strings[k])
            if k not in language_strings:
                language_strings[k] = {}
            language_strings[k][l] = {
                "message": message,
                "length": length}

    return language_strings

def print_localized_strings(language_strings, languages, output_file):
    current_segment = 0
    bytes_written_to_this_segment = 0
    output_file.write(f'    .segment "LOCALIZED_STRINGS_{current_segment}"\n')
    # TODO: Compute the size of each string table and, if necessary, emit a segment switch.
    # (We have most of the necessary data already.)
    for k in language_strings:
        localization_table = ""
        table_size_in_bytes = 0

        localization_table += f"{k}_localized:\n"
        # first write the localization table, which will always include all languages
        # in a fixed order
        for l in languages:
            localization_table += f"  .addr {k}_{l}\n"
            table_size_in_bytes += 2
        # Now for every translated string, output its correspond string encoding. If we
        # don't have a translation, use English or the key name as a fallback.
        for l in languages:
            byte_string = f"[{k}]"
            message_length = len(byte_string)
            if l in language_strings[k]:
                byte_string = language_strings[k][l]["message"]
                message_length = language_strings[k][l]["length"]
            elif "english" in language_strings[k]:
                byte_string = language_strings[k]["english"]["message"]
                message_length = language_strings[k]["english"]["length"]
            localization_table += f"{k}_{l}: {byte_string}\n"
            table_size_in_bytes += message_length
        localization_table += "\n"

        # if necessary, emit a segment swap
        if bytes_written_to_this_segment + table_size_in_bytes > 8192:
            current_segment += 1
            bytes_written_to_this_segment = 0
            output_file.write(f'    .segment "LOCALIZED_STRINGS_{current_segment}"\n')

        # write to output file, and track our bytes written
        output_file.write(localization_table)
        bytes_written_to_this_segment += table_size_in_bytes


def print_header(language_strings, output_file):
    for k in language_strings:
        output_file.write(f".global {k}_localized\n")

# For now we'll hardcode the locales and domains, etc. Don't overthink this.
if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: localize.py path/to/catalogue output.asm output.inc")
        sys.exit(-1)
    path_to_catalogue = sys.argv[1]
    output_filename = sys.argv[2]
    header_filename = sys.argv[3]

    languages = {}
    languages["english"]                  = gettext.translation('base',    path_to_catalogue, languages=["en_US"])
    languages["toki_pona_sitelen_lasina"] = gettext.translation('base',    path_to_catalogue, languages=["tok_US"])
    languages["toki_pona_sitelen_pona"]   = gettext.translation('sitelen', path_to_catalogue, languages=["tok_US"])

    language_strings = gather_translated_strings(languages)

    with open(output_filename, "w") as output_file:
        print_localized_strings(language_strings, languages, output_file)
    with open(header_filename, "w") as header_file:
        print_header(language_strings, header_file)