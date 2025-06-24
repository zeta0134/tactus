<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.10" tiledversion="1.11.2" name="TechnicalTiles" tilewidth="16" tileheight="16" tilecount="128" columns="16">
 <image source="tilesets/technical_tiles_tiled.png" width="256" height="128"/>
 <tile id="1" type="detail">
  <properties>
   <property name="behavior" value="TILE_DISCO_FLOOR"/>
   <property name="detail" value="DETAIL_SPARSE_GRASS"/>
  </properties>
 </tile>
 <tile id="2" type="detail">
  <properties>
   <property name="behavior" value="TILE_DISCO_FLOOR"/>
   <property name="detail" value="DETAIL_SPARSE_SHROOMS"/>
  </properties>
 </tile>
 <tile id="3" type="detail">
  <properties>
   <property name="behavior" value="TILE_DISCO_FLOOR"/>
   <property name="detail" value="DETAIL_SPARSE_GRASS_SHROOMS"/>
  </properties>
 </tile>
 <tile id="4" type="detail">
  <properties>
   <property name="behavior" value="TILE_DISCO_FLOOR"/>
   <property name="detail" value="DETAIL_CAVE"/>
  </properties>
 </tile>
 <tile id="5" type="detail">
  <properties>
   <property name="behavior" value="TILE_DISCO_FLOOR"/>
   <property name="detail" value="DETAIL_CAVE_SHROOMS"/>
  </properties>
 </tile>
 <tile id="6" type="detail">
  <properties>
   <property name="behavior" value="TILE_DISCO_FLOOR"/>
   <property name="detail" value="DETAIL_SAND"/>
  </properties>
 </tile>
 <tile id="14">
  <properties>
   <property name="behavior" value="TILE_ITEM_SHADOW"/>
   <property name="tile_id" value="BG_TILE_WEAPON_SHADOW"/>
  </properties>
 </tile>
 <tile id="15">
  <properties>
   <property name="behavior" value="TILE_CHALLENGE_SPIKES"/>
   <property name="tile_id" value="BG_TILE_SPIKES_LOWERED"/>
  </properties>
 </tile>
 <tile id="16">
  <properties>
   <property name="behavior" value="TILE_SEMISAFE_FLOOR"/>
  </properties>
 </tile>
 <tile id="17" type="detail">
  <properties>
   <property name="behavior" value="TILE_WALL"/>
   <property name="detail" value="DETAIL_GRASS_WALL_LOWER_BORDER"/>
  </properties>
 </tile>
 <tile id="18" type="detail">
  <properties>
   <property name="behavior" value="TILE_WALL"/>
   <property name="detail" value="DETAIL_GRASS_WALL"/>
  </properties>
 </tile>
 <tile id="19" type="detail">
  <properties>
   <property name="behavior" value="TILE_WALL"/>
   <property name="detail" value="DETAIL_GRASS_WALL_UPPER_BORDER"/>
  </properties>
 </tile>
 <tile id="20" type="detail">
  <properties>
   <property name="behavior" value="TILE_WALL"/>
   <property name="detail" value="DETAIL_GRASS_WALL_HORIZ_STRIP"/>
  </properties>
 </tile>
 <tile id="32" type="item">
  <properties>
   <property name="behavior" value="ITEM_DAGGER"/>
  </properties>
 </tile>
 <tile id="33" type="item">
  <properties>
   <property name="behavior" value="ITEM_BROADSWORD"/>
  </properties>
 </tile>
 <tile id="34" type="item">
  <properties>
   <property name="behavior" value="ITEM_LONGSWORD"/>
  </properties>
 </tile>
 <tile id="35" type="item">
  <properties>
   <property name="behavior" value="ITEM_SPEAR"/>
  </properties>
 </tile>
 <tile id="36" type="item">
  <properties>
   <property name="behavior" value="ITEM_FLAIL"/>
  </properties>
 </tile>
 <tile id="37" type="item">
  <properties>
   <property name="behavior" value="ITEM_BOMB_STANDARD_X3"/>
  </properties>
 </tile>
 <tile id="38" type="item">
  <properties>
   <property name="behavior" value="ITEM_BASIC_TORCH"/>
  </properties>
 </tile>
 <tile id="39" type="item">
  <properties>
   <property name="behavior" value="ITEM_LARGE_TORCH"/>
  </properties>
 </tile>
 <tile id="40" type="item">
  <properties>
   <property name="behavior" value="ITEM_COMBAT_ANCHOR"/>
  </properties>
 </tile>
 <tile id="41" type="item">
  <properties>
   <property name="behavior" value="ITEM_UPGRADE_ICE"/>
  </properties>
 </tile>
 <tile id="42" type="item">
  <properties>
   <property name="behavior" value="ITEM_UPGRADE_EARTH"/>
  </properties>
 </tile>
 <tile id="43" type="item">
  <properties>
   <property name="behavior" value="ITEM_UPGRADE_AIR"/>
  </properties>
 </tile>
 <tile id="44" type="item">
  <properties>
   <property name="behavior" value="ITEM_UPGRADE_FIRE"/>
  </properties>
 </tile>
 <tile id="48" type="item">
  <properties>
   <property name="behavior" value="ITEM_SPELL_FIRE"/>
  </properties>
 </tile>
 <tile id="49" type="item">
  <properties>
   <property name="behavior" value="ITEM_SPELL_AIR"/>
  </properties>
 </tile>
 <tile id="50" type="item">
  <properties>
   <property name="behavior" value="ITEM_SPELL_ICE"/>
  </properties>
 </tile>
 <tile id="51" type="item">
  <properties>
   <property name="behavior" value="ITEM_SPELL_EARTH"/>
  </properties>
 </tile>
 <tile id="52" type="item">
  <properties>
   <property name="behavior" value="ITEM_SPELL_BOMB"/>
  </properties>
 </tile>
 <tile id="53" type="item">
  <properties>
   <property name="behavior" value="ITEM_SPELL_LIFE"/>
  </properties>
 </tile>
 <tile id="54" type="map">
  <properties>
   <property name="behavior" value="TILE_HAZARD_HEAL"/>
   <property name="tile_id" value="BG_TILE_HAZARD_TILE_HEART"/>
  </properties>
 </tile>
 <tile id="55" type="map">
  <properties>
   <property name="behavior" value="TILE_HAZARD_POISON"/>
   <property name="tile_id" value="BG_TILE_HAZARD_TILE_POISON"/>
  </properties>
 </tile>
 <tile id="56" type="map">
  <properties>
   <property name="behavior" value="TILE_HAZARD_FREEZE"/>
   <property name="tile_id" value="BG_TILE_HAZARD_TILE_FREEZE"/>
  </properties>
 </tile>
 <tile id="57" type="map">
  <properties>
   <property name="behavior" value="TILE_HAZARD_SHOCK"/>
   <property name="tile_id" value="BG_TILE_HAZARD_TILE_SHOCK"/>
  </properties>
 </tile>
 <tile id="58" type="map">
  <properties>
   <property name="behavior" value="TILE_HAZARD_BURN"/>
   <property name="tile_id" value="BG_TILE_HAZARD_TILE_BURN"/>
  </properties>
 </tile>
 <tile id="63" type="map">
  <properties>
   <property name="behavior" value="TILE_HIDDEN_WARP_FLOOR"/>
  </properties>
 </tile>
 <tile id="64" type="chest">
  <properties>
   <property name="behavior" value="TILE_HELPFUL_CHEST"/>
   <property name="palette_index" type="int" value="2"/>
   <property name="tile_id" value="BG_TILE_SMALL_CHEST"/>
  </properties>
 </tile>
 <tile id="67" type="chest">
  <properties>
   <property name="behavior" value="TILE_MIMIC"/>
   <property name="palette_index" type="int" value="2"/>
   <property name="tile_id" value="BG_TILE_MIMIC_FIDGET"/>
  </properties>
 </tile>
 <tile id="68" type="chest">
  <properties>
   <property name="behavior" value="TILE_HIDDEN_CHEST"/>
   <property name="palette_index" type="int" value="2"/>
   <property name="tile_id" value="BG_TILE_MIMIC_IDLE"/>
  </properties>
 </tile>
 <tile id="69" type="chest">
  <properties>
   <property name="behavior" value="TILE_HELPFUL_CHEST"/>
   <property name="palette_index" type="int" value="2"/>
   <property name="tile_id" value="BG_TILE_SMALL_CHEST_LIGHT"/>
  </properties>
 </tile>
 <tile id="80" type="chest">
  <properties>
   <property name="behavior" value="TILE_LARGE_CHEST"/>
   <property name="palette_index" type="int" value="3"/>
   <property name="tile_id" value="BG_TILE_LARGE_CHEST"/>
  </properties>
 </tile>
 <tile id="81" type="chest">
  <properties>
   <property name="behavior" value="TILE_CHALLENGE_CHEST"/>
   <property name="palette_index" type="int" value="3"/>
   <property name="tile_id" value="BG_TILE_CHALLENGE_CHEST"/>
  </properties>
 </tile>
 <tile id="82" type="chest">
  <properties>
   <property name="behavior" value="TILE_TIMED_CHEST"/>
   <property name="palette_index" type="int" value="3"/>
   <property name="tile_id" value="BG_TILE_TIMED_CHEST"/>
  </properties>
 </tile>
 <tile id="83" type="chest">
  <properties>
   <property name="behavior" value="TILE_MIMIC"/>
   <property name="palette_index" type="int" value="3"/>
   <property name="tile_id" value="BG_TILE_MIMIC_FIDGET"/>
  </properties>
 </tile>
 <tile id="84" type="chest">
  <properties>
   <property name="behavior" value="TILE_HIDDEN_RARE_CHEST"/>
   <property name="palette_index" type="int" value="3"/>
   <property name="tile_id" value="BG_TILE_MIMIC_IDLE"/>
  </properties>
 </tile>
 <tile id="85" type="chest">
  <properties>
   <property name="behavior" value="TILE_LARGE_CHEST"/>
   <property name="palette_index" type="int" value="3"/>
   <property name="tile_id" value="BG_TILE_LARGE_CHEST_LIGHT"/>
  </properties>
 </tile>
 <tile id="86" type="chest">
  <properties>
   <property name="behavior" value="TILE_CHALLENGE_CHEST"/>
   <property name="palette_index" type="int" value="3"/>
   <property name="tile_id" value="BG_TILE_CHALLENGE_CHEST_LIGHT"/>
  </properties>
 </tile>
 <tile id="87" type="chest">
  <properties>
   <property name="behavior" value="TILE_TIMED_CHEST"/>
   <property name="palette_index" type="int" value="3"/>
   <property name="tile_id" value="BG_TILE_TIMED_CHEST_LIGHT"/>
  </properties>
 </tile>
 <tile id="96" type="chest">
  <properties>
   <property name="behavior" value="TILE_LARGE_CHEST"/>
   <property name="palette_index" type="int" value="1"/>
   <property name="tile_id" value="BG_TILE_LARGE_CHEST"/>
  </properties>
 </tile>
 <tile id="97" type="chest">
  <properties>
   <property name="behavior" value="TILE_CHALLENGE_CHEST"/>
   <property name="palette_index" type="int" value="1"/>
   <property name="tile_id" value="BG_TILE_CHALLENGE_CHEST"/>
  </properties>
 </tile>
 <tile id="98" type="chest">
  <properties>
   <property name="behavior" value="TILE_TIMED_CHEST"/>
   <property name="palette_index" type="int" value="1"/>
   <property name="tile_id" value="BG_TILE_TIMED_CHEST"/>
  </properties>
 </tile>
 <tile id="99" type="chest">
  <properties>
   <property name="behavior" value="TILE_MIMIC"/>
   <property name="palette_index" type="int" value="1"/>
   <property name="tile_id" value="BG_TILE_MIMIC_FIDGET"/>
  </properties>
 </tile>
 <tile id="100" type="chest">
  <properties>
   <property name="behavior" value="TILE_HIDDEN_LEGENDARY_CHEST"/>
   <property name="palette_index" type="int" value="1"/>
   <property name="tile_id" value="BG_TILE_MIMIC_IDLE"/>
  </properties>
 </tile>
 <tile id="101" type="chest">
  <properties>
   <property name="behavior" value="TILE_LARGE_CHEST"/>
   <property name="palette_index" type="int" value="1"/>
   <property name="tile_id" value="BG_TILE_LARGE_CHEST_LIGHT"/>
  </properties>
 </tile>
 <tile id="102" type="chest">
  <properties>
   <property name="behavior" value="TILE_CHALLENGE_CHEST"/>
   <property name="palette_index" type="int" value="1"/>
   <property name="tile_id" value="BG_TILE_CHALLENGE_CHEST_LIGHT"/>
  </properties>
 </tile>
 <tile id="103" type="chest">
  <properties>
   <property name="behavior" value="TILE_TIMED_CHEST"/>
   <property name="palette_index" type="int" value="1"/>
   <property name="tile_id" value="BG_TILE_TIMED_CHEST_LIGHT"/>
  </properties>
 </tile>
</tileset>
