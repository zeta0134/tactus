<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.10" tiledversion="1.11.0" name="TechnicalTiles" tilewidth="16" tileheight="16" tilecount="32" columns="16">
 <image source="tilesets/technical_tiles_tiled.png" width="256" height="32"/>
 <tile id="1" type="detail">
  <properties>
   <property name="behavior" value="TILE_REGULAR_FLOOR"/>
   <property name="detail" value="DETAIL_SPARSE_GRASS"/>
  </properties>
 </tile>
 <tile id="2" type="detail">
  <properties>
   <property name="behavior" value="TILE_REGULAR_FLOOR"/>
   <property name="detail" value="DETAIL_SPARSE_SHROOMS"/>
  </properties>
 </tile>
 <tile id="3" type="detail">
  <properties>
   <property name="behavior" value="TILE_REGULAR_FLOOR"/>
   <property name="detail" value="DETAIL_SPARSE_GRASS_SHROOMS"/>
  </properties>
 </tile>
 <tile id="4" type="detail">
  <properties>
   <property name="behavior" value="TILE_REGULAR_FLOOR"/>
   <property name="detail" value="DETAIL_CAVE"/>
  </properties>
 </tile>
 <tile id="5" type="detail">
  <properties>
   <property name="behavior" value="TILE_REGULAR_FLOOR"/>
   <property name="detail" value="DETAIL_CAVE_SHROOMS"/>
  </properties>
 </tile>
 <tile id="6" type="detail">
  <properties>
   <property name="behavior" value="TILE_REGULAR_FLOOR"/>
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
</tileset>
