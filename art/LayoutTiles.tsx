<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.10" tiledversion="1.11.0" name="LayoutTiles" tilewidth="16" tileheight="16" tilecount="128" columns="16">
 <image source="tilesets/layout_tiles.png" width="256" height="128"/>
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
   <property name="forbid_player_spawning" type="bool" value="true"/>
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
 <tile id="57">
  <properties>
   <property name="room_pool" value="ROOM_POOL_HUB_WORLD_SET_DEBUG_5"/>
  </properties>
 </tile>
 <tile id="58">
  <properties>
   <property name="room_pool" value="ROOM_POOL_HUB_WORLD_SET_DEBUG_4"/>
  </properties>
 </tile>
 <tile id="59">
  <properties>
   <property name="room_pool" value="ROOM_POOL_HUB_WORLD_SET_DEBUG_3"/>
  </properties>
 </tile>
 <tile id="60">
  <properties>
   <property name="room_pool" value="ROOM_POOL_HUB_WORLD_SET_DEBUG_2"/>
  </properties>
 </tile>
 <tile id="61">
  <properties>
   <property name="room_pool" value="ROOM_POOL_HUB_WORLD_SET_DEBUG_1"/>
  </properties>
 </tile>
 <tile id="62">
  <properties>
   <property name="room_pool" value="ROOM_POOL_HUB_WORLD_SET_BIG_ROOM"/>
  </properties>
 </tile>
 <tile id="63">
  <properties>
   <property name="room_pool" value="ROOM_POOL_HUB_WORLD_SET_SPAWN"/>
  </properties>
 </tile>
 <tile id="74">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_2_NORMAL_EXIT"/>
  </properties>
 </tile>
 <tile id="75">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_2_WARP_EXIT"/>
  </properties>
 </tile>
 <tile id="76">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_2A_BOSS"/>
  </properties>
 </tile>
 <tile id="77">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_2B_BOSS"/>
  </properties>
 </tile>
 <tile id="78">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_2C_BOSS"/>
  </properties>
 </tile>
 <tile id="79">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_2W_BOSS"/>
  </properties>
 </tile>
 <tile id="90">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_3_NORMAL_EXIT"/>
  </properties>
 </tile>
 <tile id="91">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_3_WARP_EXIT"/>
  </properties>
 </tile>
 <tile id="92">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_3A_BOSS"/>
  </properties>
 </tile>
 <tile id="93">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_3B_BOSS"/>
  </properties>
 </tile>
 <tile id="94">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_3C_BOSS"/>
  </properties>
 </tile>
 <tile id="95">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_3W_BOSS"/>
  </properties>
 </tile>
 <tile id="106">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_4_NORMAL_EXIT"/>
  </properties>
 </tile>
 <tile id="107">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_4_WARP_EXIT"/>
  </properties>
 </tile>
 <tile id="108">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_4A_BOSS"/>
  </properties>
 </tile>
 <tile id="109">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_4B_BOSS"/>
  </properties>
 </tile>
 <tile id="110">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_4C_BOSS"/>
  </properties>
 </tile>
 <tile id="111">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_4W_BOSS"/>
  </properties>
 </tile>
 <tile id="122">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_5_NORMAL_EXIT"/>
  </properties>
 </tile>
 <tile id="123">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_5_WARP_EXIT"/>
  </properties>
 </tile>
 <tile id="124">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_1_BOSS"/>
  </properties>
 </tile>
 <tile id="125">
  <properties>
   <property name="room_pool" value=""/>
  </properties>
 </tile>
 <tile id="126">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_5S_BOSS"/>
  </properties>
 </tile>
 <tile id="127">
  <properties>
   <property name="room_pool" value="ROOM_POOL_ZONE_5W_BOSS"/>
  </properties>
 </tile>
</tileset>
