<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.10" tiledversion="1.11.0" name="LayoutTiles" tilewidth="16" tileheight="16" tilecount="64" columns="16">
 <image source="tilesets/layout_tiles.png" width="256" height="64"/>
 <tile id="0">
  <properties>
   <property name="exit_east" type="bool" value="false"/>
   <property name="exit_north" type="bool" value="false"/>
   <property name="exit_south" type="bool" value="false"/>
   <property name="exit_west" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="1">
  <properties>
   <property name="exit_east" type="bool" value="false"/>
   <property name="exit_north" type="bool" value="false"/>
   <property name="exit_south" type="bool" value="true"/>
   <property name="exit_west" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="2">
  <properties>
   <property name="exit_east" type="bool" value="true"/>
   <property name="exit_north" type="bool" value="true"/>
   <property name="exit_south" type="bool" value="true"/>
   <property name="exit_west" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="3">
  <properties>
   <property name="exit_east" type="bool" value="false"/>
   <property name="exit_north" type="bool" value="true"/>
   <property name="exit_south" type="bool" value="true"/>
   <property name="exit_west" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="4">
  <properties>
   <property name="room_pool" value="ROOM_POOL_OUT_OF_BOUNDS"/>
  </properties>
 </tile>
 <tile id="5">
  <properties>
   <property name="room_pool" value="ROOM_POOL_BLOCKING_EXTERIOR"/>
  </properties>
 </tile>
 <tile id="6">
  <properties>
   <property name="room_pool" value="ROOM_POOL_BLOCKING_INTERIOR"/>
  </properties>
 </tile>
 <tile id="15">
  <properties>
   <property name="forbid_spawning" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="16">
  <properties>
   <property name="exit_east" type="bool" value="true"/>
   <property name="exit_north" type="bool" value="false"/>
   <property name="exit_south" type="bool" value="false"/>
   <property name="exit_west" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="17">
  <properties>
   <property name="exit_east" type="bool" value="true"/>
   <property name="exit_north" type="bool" value="true"/>
   <property name="exit_south" type="bool" value="true"/>
   <property name="exit_west" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="18">
  <properties>
   <property name="exit_east" type="bool" value="true"/>
   <property name="exit_north" type="bool" value="false"/>
   <property name="exit_south" type="bool" value="false"/>
   <property name="exit_west" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="19">
  <properties>
   <property name="exit_east" type="bool" value="false"/>
   <property name="exit_north" type="bool" value="false"/>
   <property name="exit_south" type="bool" value="false"/>
   <property name="exit_west" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="20">
  <properties>
   <property name="room_pool" value="ROOM_POOL_GRASSY_EXTERIOR"/>
  </properties>
 </tile>
 <tile id="32">
  <properties>
   <property name="exit_east" type="bool" value="true"/>
   <property name="exit_north" type="bool" value="false"/>
   <property name="exit_south" type="bool" value="true"/>
   <property name="exit_west" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="33">
  <properties>
   <property name="exit_east" type="bool" value="false"/>
   <property name="exit_north" type="bool" value="true"/>
   <property name="exit_south" type="bool" value="true"/>
   <property name="exit_west" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="34">
  <properties>
   <property name="exit_east" type="bool" value="true"/>
   <property name="exit_north" type="bool" value="false"/>
   <property name="exit_south" type="bool" value="true"/>
   <property name="exit_west" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="35">
  <properties>
   <property name="exit_east" type="bool" value="false"/>
   <property name="exit_north" type="bool" value="false"/>
   <property name="exit_south" type="bool" value="true"/>
   <property name="exit_west" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="36">
  <properties>
   <property name="room_pool" value="ROOM_POOL_CAVE_INTERIOR"/>
  </properties>
 </tile>
 <tile id="48">
  <properties>
   <property name="exit_east" type="bool" value="true"/>
   <property name="exit_north" type="bool" value="true"/>
   <property name="exit_south" type="bool" value="false"/>
   <property name="exit_west" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="49">
  <properties>
   <property name="exit_east" type="bool" value="false"/>
   <property name="exit_north" type="bool" value="true"/>
   <property name="exit_south" type="bool" value="false"/>
   <property name="exit_west" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="50">
  <properties>
   <property name="exit_east" type="bool" value="true"/>
   <property name="exit_north" type="bool" value="true"/>
   <property name="exit_south" type="bool" value="false"/>
   <property name="exit_west" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="51">
  <properties>
   <property name="exit_east" type="bool" value="false"/>
   <property name="exit_north" type="bool" value="true"/>
   <property name="exit_south" type="bool" value="false"/>
   <property name="exit_west" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="52">
  <properties>
   <property name="room_pool" value="ROOM_POOL_DEBUG_ACTION_53"/>
  </properties>
 </tile>
 <tile id="63">
  <properties>
   <property name="room_pool" value="ROOM_POOL_HUB_WORLD_SET_A"/>
  </properties>
 </tile>
</tileset>
