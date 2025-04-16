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

def massage_string(unicode_str):
    output_string = []
    byte_count = 0
    current_font = ""
    current_ascii_string = ""
    for raw_char in unicode_str:
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
    return language_strings

def print_localized_strings(language_strings, languages, output_file):
    # TODO: Compute the size of each string table and, if necessary, emit a segment switch.
    # (We have most of the necessary data already.)
    for k in language_strings:
        output_file.write(f"{k}_localized:\n")
        # first write the localization table, which will always include all languages
        # in a fixed order
        for l in languages:
            output_file.write(f"  .addr {k}_{l}\n")
        # Now for every translated string, output its correspond string encoding. If we
        # don't have a translation, use English or the key name as a fallback.
        for l in languages:
            byte_string = f"[{k}]"
            if l in language_strings[k]:
                byte_string = language_strings[k][l]["message"]
            elif "english" in language_strings[k]:
                byte_string = language_strings[k]["english"]["message"]
            output_file.write(f"{k}_{l}: {byte_string}\n")
        output_file.write("\n")

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