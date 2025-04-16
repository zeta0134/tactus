# Sortof an experiment for gettext

import gettext, sys

sitelen_pona_pu = {}
sitelen_pona_pu["󱤀"] = "_A"
sitelen_pona_pu["󱤁"] = "_AKESI"
sitelen_pona_pu["󱤂"] = "_ALA"
sitelen_pona_pu["󱤃"] = "_ALASA"
sitelen_pona_pu["󱤄"] = "_ALE"
sitelen_pona_pu["󱤅"] = "_ANPA"
sitelen_pona_pu["󱤆"] = "_ANTE"
sitelen_pona_pu["󱤇"] = "_ANU"
sitelen_pona_pu["󱤈"] = "_AWEN"
sitelen_pona_pu["󱤉"] = "_E"
sitelen_pona_pu["󱤊"] = "_EN"
sitelen_pona_pu["󱤋"] = "_ESUN"
sitelen_pona_pu["󱤌"] = "_ILO"
sitelen_pona_pu["󱤍"] = "_IKE"
sitelen_pona_pu["󱤎"] = "_ILO"
sitelen_pona_pu["󱤏"] = "_INSA"
sitelen_pona_pu["󱤐"] = "_JAKI"
sitelen_pona_pu["󱤑"] = "_JAN"
sitelen_pona_pu["󱤒"] = "_JELO"
sitelen_pona_pu["󱤓"] = "_JO"
sitelen_pona_pu["󱤔"] = "_KALA"
sitelen_pona_pu["󱤕"] = "_KALAMA"
sitelen_pona_pu["󱤖"] = "_KAMA"
sitelen_pona_pu["󱤗"] = "_KASI"
sitelen_pona_pu["󱤘"] = "_KEN"
sitelen_pona_pu["󱤙"] = "_KEPEKEN"
sitelen_pona_pu["󱤚"] = "_KILI"
sitelen_pona_pu["󱤛"] = "_KIWEN"
sitelen_pona_pu["󱤜"] = "_KO"
sitelen_pona_pu["󱤝"] = "_KON"
sitelen_pona_pu["󱤞"] = "_KULE"
sitelen_pona_pu["󱤟"] = "_KULUPU"
sitelen_pona_pu["󱤠"] = "_KUTE"
sitelen_pona_pu["󱤡"] = "_LA"
sitelen_pona_pu["󱤢"] = "_LAPE"
sitelen_pona_pu["󱤣"] = "_LASO"
sitelen_pona_pu["󱤤"] = "_LAWA"
sitelen_pona_pu["󱤥"] = "_LEN"
sitelen_pona_pu["󱤦"] = "_LETE"
sitelen_pona_pu["󱤧"] = "_LI"
sitelen_pona_pu["󱤨"] = "_LILI"
sitelen_pona_pu["󱤩"] = "_LINJA"
sitelen_pona_pu["󱤪"] = "_LIPU"
sitelen_pona_pu["󱤫"] = "_LOJE"
sitelen_pona_pu["󱤬"] = "_LON"
sitelen_pona_pu["󱤭"] = "_LUKA"
sitelen_pona_pu["󱤮"] = "_LUKIN"
sitelen_pona_pu["󱤯"] = "_LUPA"
sitelen_pona_pu["󱤰"] = "_MA"
sitelen_pona_pu["󱤱"] = "_MAMA"
sitelen_pona_pu["󱤲"] = "_MANI"
sitelen_pona_pu["󱤳"] = "_MELI"
sitelen_pona_pu["󱤴"] = "_MI"
sitelen_pona_pu["󱤵"] = "_MIJE"
sitelen_pona_pu["󱤶"] = "_MOKU"
sitelen_pona_pu["󱤷"] = "_MOLI"
sitelen_pona_pu["󱤸"] = "_MONSI"
sitelen_pona_pu["󱤹"] = "_MU"
sitelen_pona_pu["󱤺"] = "_MUN"
sitelen_pona_pu["󱤻"] = "_MUSI"
sitelen_pona_pu["󱤼"] = "_MUTE"
sitelen_pona_pu["󱤽"] = "_NANPA"
sitelen_pona_pu["󱤾"] = "_NASA"
sitelen_pona_pu["󱤿"] = "_NASIN"
sitelen_pona_pu["󱥀"] = "_NENA"
sitelen_pona_pu["󱥁"] = "_NI"
sitelen_pona_pu["󱥂"] = "_NIMI"
sitelen_pona_pu["󱥃"] = "_NOKA"
sitelen_pona_pu["󱥄"] = "_O"
sitelen_pona_pu["󱥅"] = "_OLIN"
sitelen_pona_pu["󱥆"] = "_ONA"
sitelen_pona_pu["󱥇"] = "_OPEN"
sitelen_pona_pu["󱥈"] = "_PAKALA"
sitelen_pona_pu["󱥉"] = "_PALI"
sitelen_pona_pu["󱥊"] = "_PALISA"
sitelen_pona_pu["󱥋"] = "_PAN"
sitelen_pona_pu["󱥌"] = "_PANA"
sitelen_pona_pu["󱥍"] = "_PI"
sitelen_pona_pu["󱥎"] = "_PILIN"
sitelen_pona_pu["󱥏"] = "_PIMEJA"
sitelen_pona_pu["󱥐"] = "_PINI"
sitelen_pona_pu["󱥑"] = "_PIPI"
sitelen_pona_pu["󱥒"] = "_POKA"
sitelen_pona_pu["󱥓"] = "_POKI"
sitelen_pona_pu["󱥔"] = "_PONA"
sitelen_pona_pu["󱥕"] = "_PU"
sitelen_pona_pu["󱥖"] = "_SAMA"
sitelen_pona_pu["󱥗"] = "_SELI"
sitelen_pona_pu["󱥘"] = "_SELO"
sitelen_pona_pu["󱥙"] = "_SEME"
sitelen_pona_pu["󱥚"] = "_SEWI"
sitelen_pona_pu["󱥛"] = "_SIJELO"
sitelen_pona_pu["󱥜"] = "_SIKE"
sitelen_pona_pu["󱥝"] = "_SIN"
sitelen_pona_pu["󱥞"] = "_SINA"
sitelen_pona_pu["󱥟"] = "_SINPIN"
sitelen_pona_pu["󱥠"] = "_SITELEN"
sitelen_pona_pu["󱥡"] = "_SONA"
sitelen_pona_pu["󱥢"] = "_SOWELI"
sitelen_pona_pu["󱥣"] = "_SULI"
sitelen_pona_pu["󱥤"] = "_SUNO"
sitelen_pona_pu["󱥥"] = "_SUPA"
sitelen_pona_pu["󱥦"] = "_SUWI"
sitelen_pona_pu["󱥧"] = "_TAN"
sitelen_pona_pu["󱥨"] = "_TASO"
sitelen_pona_pu["󱥩"] = "_TAWA"
sitelen_pona_pu["󱥪"] = "_TELO"
sitelen_pona_pu["󱥫"] = "_TENPO"
sitelen_pona_pu["󱥬"] = "_TOKI"
sitelen_pona_pu["󱥭"] = "_TOMO"
sitelen_pona_pu["󱥮"] = "_TU"
sitelen_pona_pu["󱥯"] = "_UNPA"
sitelen_pona_pu["󱥰"] = "_UTA"
sitelen_pona_pu["󱥱"] = "_UTALA"
sitelen_pona_pu["󱥲"] = "_WALO"
sitelen_pona_pu["󱥳"] = "_WAN"
sitelen_pona_pu["󱥴"] = "_WASO"
sitelen_pona_pu["󱥵"] = "_WAWA"
sitelen_pona_pu["󱥶"] = "_WEKA"
sitelen_pona_pu["󱥷"] = "_WILE"

sitelen_pona_ku = {}
sitelen_pona_ku["󱥸"] = ["D_EXT_CHAR", "_NAMAKO"]
sitelen_pona_ku["󱥹"] = ["D_EXT_CHAR", "_KIN"]
sitelen_pona_ku["󱥺"] = ["D_EXT_CHAR", "_OKO"]
sitelen_pona_ku["󱥻"] = ["D_EXT_CHAR", "_KIPISI"]
sitelen_pona_ku["󱥼"] = ["D_EXT_CHAR", "_LEKO"]
sitelen_pona_ku["󱥽"] = ["D_EXT_CHAR", "_MONSUTA"]
sitelen_pona_ku["󱥾"] = ["D_EXT_CHAR", "_TONSI"]
sitelen_pona_ku["󱥿"] = ["D_EXT_CHAR", "_JASIMA"]
sitelen_pona_ku["󱦁"] = ["D_EXT_CHAR", "_SOKO"]
sitelen_pona_ku["󱦂"] = ["D_EXT_CHAR", "_MESO"]
sitelen_pona_ku["󱦃"] = ["D_EXT_CHAR", "_EPIKU"]
sitelen_pona_ku["󱦄"] = ["D_EXT_CHAR", "_KOKOSILA"]
sitelen_pona_ku["󱦅"] = ["D_EXT_CHAR", "_LANPAN"]
sitelen_pona_ku["󱦆"] = ["D_EXT_CHAR", "_N"]
sitelen_pona_ku["󱦇"] = ["D_EXT_CHAR", "_MISIKEKE"]
sitelen_pona_ku["󱦢"] = ["D_EXT_CHAR", "_MAJUNA"]

sitelen_pona_kijete_santakalu = {}
sitelen_pona_kijete_santakalu["󱦀"] = ["D_EXT_CHAR", "_KIJETE", "D_EXT_CHAR", "_SANTAKALU"]

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

    lang_en     = gettext.translation('base',    path_to_catalogue, languages=["en_US"])
    lang_tok    = gettext.translation('base',    path_to_catalogue, languages=["tok_US"])
    lang_tok_sp = gettext.translation('sitelen', path_to_catalogue, languages=["tok_US"])

    languages = {}
    languages["english"]                  = gettext.translation('base',    './tactus', languages=["en_US"])
    languages["toki_pona_sitelen_lasina"] = gettext.translation('base',    './tactus', languages=["tok_US"])
    languages["toki_pona_sitelen_pona"]   = gettext.translation('sitelen', './tactus', languages=["tok_US"])

    language_strings = gather_translated_strings(languages)

    with open(output_filename, "w") as output_file:
        print_localized_strings(language_strings, languages, output_file)
    with open(header_filename, "w") as header_file:
        print_header(language_strings, header_file)