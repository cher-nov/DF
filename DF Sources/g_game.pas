unit g_game;

interface

uses
  Windows, g_basic, g_player, Messages, e_graphics, Classes, g_res_downloader,
  SysUtils, g_sound, MAPSTRUCT, WADEDITOR, md5asm;

type
  TGameSettings = record
    GameType: Byte;
    GameMode: Byte;
    TimeLimit: Word;
    GoalLimit: Word;
    WarmupTime: Word;
    MaxLives: Byte;
    Options: LongWord;
    WAD: String;
  end;

  TGameEvent = record
    Name: String;
    Command: String;
  end;

  TDelayedEvent = record
    Pending: Boolean;
    Time: LongWord;
    DEType: Byte;
    DENum: Integer;
    DEStr: String;
  end;

  TPlayerSettings = record
    Name: String;
    Model: String;
    Color: TRGB;
    Team: Byte;
  end;

  TMegaWADInfo = record
    Name: String;
    Description: String;
    Author: String;
    Pic: String;
  end;

  THearPoint = record
    Active: Boolean;
    Coords: TPoint;
  end;

function  g_Game_IsNet(): Boolean;
function  g_Game_IsServer(): Boolean;
function  g_Game_IsClient(): Boolean;
procedure g_Game_Init();
procedure g_Game_Free();
procedure g_Game_LoadData();
procedure g_Game_FreeData();
procedure g_Game_Update();
procedure g_Game_Draw();
procedure g_Game_Quit();
procedure g_Game_SetupScreenSize();
procedure g_Game_ChangeResolution(newWidth, newHeight: Word; nowFull, nowMax: Boolean);
function  g_Game_ModeToText(Mode: Byte): string;
function  g_Game_TextToMode(Mode: string): Byte;
procedure g_Game_ExecuteEvent(Name: String);
function  g_Game_DelayEvent(DEType: Byte; Time: LongWord; Num: Integer = 0; Str: String = ''): Integer;
procedure g_Game_AddPlayer(Team: Byte = TEAM_NONE);
procedure g_Game_RemovePlayer();
procedure g_Game_Spectate();
procedure g_Game_SpectateCenterView();
procedure g_Game_StartSingle(Map: String; TwoPlayers: Boolean; nPlayers: Byte);
procedure g_Game_StartCustom(Map: String; GameMode: Byte; TimeLimit, GoalLimit: Word; MaxLives: Byte; Options: LongWord; nPlayers: Byte);
procedure g_Game_StartServer(Map: String; GameMode: Byte; TimeLimit, GoalLimit: Word; MaxLives: Byte; Options: LongWord; nPlayers: Byte; IPAddr: LongWord; Port: Word);
procedure g_Game_StartClient(Addr: String; Port: Word; PW: String);
procedure g_Game_Restart();
procedure g_Game_RestartLevel();
procedure g_Game_RestartRound(NoMapRestart: Boolean = False);
procedure g_Game_ClientWAD(NewWAD: String; WHash: TMD5Digest);
procedure g_Game_SaveOptions();
function  g_Game_StartMap(Map: String; Force: Boolean = False): Boolean;
procedure g_Game_ChangeMap(MapPath: String);
procedure g_Game_ExitLevel(Map: Char16);
function  g_Game_GetFirstMap(WAD: String): String;
function  g_Game_GetNextMap(): String;
procedure g_Game_NextLevel();
procedure g_Game_Pause(Enable: Boolean);
procedure g_Game_InGameMenu(Show: Boolean);
function  g_Game_IsWatchedPlayer(UID: Word): Boolean;
function  g_Game_IsWatchedTeam(Team: Byte): Boolean;
procedure g_Game_Message(Msg: String; Time: Word);
procedure g_Game_LoadMapList(FileName: String);
procedure g_Game_PauseAllSounds(Enable: Boolean);
procedure g_Game_StopAllSounds(all: Boolean);
procedure g_Game_UpdateTriggerSounds();
function  g_Game_GetMegaWADInfo(WAD: String): TMegaWADInfo;
procedure g_Game_Announce_GoodShot(SpawnerUID: Word);
procedure g_Game_Announce_KillCombo(Param: Integer);
procedure g_Game_StartVote(Command, Initiator: string);
procedure g_Game_CheckVote;
procedure g_TakeScreenShot();
procedure g_FatalError(Text: String);
procedure g_SimpleError(Text: String);
function  g_Game_IsTestMap(): Boolean;
procedure g_Game_DeleteTestMap();
procedure GameCVars(P: SArray);
procedure GameCommands(P: SArray);
procedure DebugCommands(P: SArray);
procedure g_Game_Process_Params;
procedure g_Game_SetLoadingText(Text: String; Max: Integer; reWrite: Boolean);
procedure g_Game_StepLoading();
procedure g_Game_ClearLoading();
procedure g_Game_SetDebugMode();
procedure DrawLoadingStat();

{ procedure SetWinPause(Enable: Boolean); }

const
  GAME_TICK = 28;

  LOADING_SHOW_STEP = 100;
  LOADING_INTERLINE = 20;

  GT_NONE   = 0;
  GT_SINGLE = 1;
  GT_CUSTOM = 2;
  GT_SERVER = 3;
  GT_CLIENT = 4;

  GM_NONE = 0;
  GM_DM   = 1;
  GM_TDM  = 2;
  GM_CTF  = 3;
  GM_COOP = 4;
  GM_SINGLE = 5;

  MESSAGE_DIKEY = WM_USER + 1;

  EXIT_QUIT            = 1;
  EXIT_SIMPLE          = 2;
  EXIT_RESTART         = 3;
  EXIT_ENDLEVELSINGLE  = 4;
  EXIT_ENDLEVELCUSTOM  = 5;

  GAME_OPTION_RESERVED     = 1;
  GAME_OPTION_TEAMDAMAGE   = 2;
  GAME_OPTION_ALLOWEXIT    = 4;
  GAME_OPTION_WEAPONSTAY   = 8;
  GAME_OPTION_MONSTERS     = 16;
  GAME_OPTION_BOTVSPLAYER  = 32;
  GAME_OPTION_BOTVSMONSTER = 64;

  STATE_NONE        = 0;
  STATE_MENU        = 1;
  STATE_FOLD        = 2;
  STATE_INTERCUSTOM = 3;
  STATE_INTERSINGLE = 4;
  STATE_INTERTEXT   = 5;
  STATE_INTERPIC    = 6;
  STATE_ENDPIC      = 7;
  STATE_SLIST       = 8;

  LMS_RESPAWN_NONE   = 0;
  LMS_RESPAWN_WARMUP = 1;
  LMS_RESPAWN_FINAL  = 2;

  SPECT_NONE    = 0;
  SPECT_STATS   = 1;
  SPECT_MAPVIEW = 2;
  SPECT_PLAYERS = 3;

  DE_GLOBEVENT = 0;
  DE_BFGHIT    = 1;
  DE_KILLCOMBO = 2;

  ANNOUNCE_NONE   = 0;
  ANNOUNCE_ME     = 1;
  ANNOUNCE_MEPLUS = 2;
  ANNOUNCE_ALL    = 3;

  CONFIG_FILENAME = 'Doom2DF.cfg';
  LOG_FILENAME = 'Doom2DF.log';

  TEST_MAP_NAME = '$$$_TEST_$$$';

  STD_PLAYER_MODEL = 'Doomer';

var
  gStdFont: DWORD;
  gGameSettings: TGameSettings;
  gPlayer1Settings: TPlayerSettings;
  gPlayer2Settings: TPlayerSettings;
  gGameOn: Boolean;
  gPlayerScreenSize: TPoint;
  gPlayer1ScreenCoord: TPoint;
  gPlayer2ScreenCoord: TPoint;
  gPlayer1: TPlayer = nil;
  gPlayer2: TPlayer = nil;
  gPlayerDrawn: TPlayer = nil;
  gTime: LongWord;
  gSwitchGameMode: Byte = GM_DM;
  gHearPoint1, gHearPoint2: THearPoint;
  gSoundEffectsDF: Boolean = False;
  gSoundTriggerTime: Word = 0;
  gAnnouncer: Byte = ANNOUNCE_NONE;
  goodsnd: array[0..3] of TPlayableSound;
  killsnd: array[0..3] of TPlayableSound;
  gDefInterTime: ShortInt = -1;
  gInterEndTime: LongWord = 0;
  gInterTime: LongWord = 0;
  gServInterTime: Byte = 0;
  gGameStartTime: LongWord = 0;
  gTotalMonsters: Integer = 0;
  gPause: Boolean;
  gShowTime: Boolean = True;
  gShowFPS: Boolean = False;
  gShowGoals: Boolean = True;
  gShowStat: Boolean = True;
  gShowKillMsg: Boolean = True;
  gShowLives: Boolean = True;
  gShowPing: Boolean = False;
  gShowMap: Boolean = False;
  gExit: Byte = 0;
  gState: Byte = STATE_NONE;
  sX, sY: Integer;
  sWidth, sHeight: Word;
  gSpectMode: Byte = SPECT_NONE;
  gSpectHUD: Boolean = True;
  gSpectKeyPress: Boolean = False;
  gSpectX: Integer = 0;
  gSpectY: Integer = 0;
  gSpectStep: Byte = 8;
  gSpectViewTwo: Boolean = False;
  gSpectPID1: Integer = -1;
  gSpectPID2: Integer = -1;
  gMusic: TMusic = nil;
  gLoadGameMode: Boolean;
  gCheats: Boolean = False;
  gMapOnce: Boolean = False;
  gMapToDelete: String;
  gTempDelete: Boolean = False;
  gLastMap: Boolean = False;
  gWinPosX, gWinPosY: Integer;
  gWinSizeX, gWinSizeY: Integer;
  gWinFrameX, gWinFrameY, gWinCaption: Integer;
  gWinActive: Boolean = False;
  gResolutionChange: Boolean = False;
  gRC_Width, gRC_Height: Word;
  gRC_FullScreen, gRC_Maximized: Boolean;
  gLanguageChange: Boolean = False;
  gDebugMode: Boolean = False;
  g_debug_Sounds: Boolean = False;
  g_debug_Frames: Boolean = False;
  g_debug_WinMsgs: Boolean = False;
  g_debug_MonsterOff: Boolean = False;
  g_debug_BotAIOff: Byte = 0;
  g_debug_HealthBar: Boolean = False;
  g_Debug_Player: Boolean = False;
  gCoopMonstersKilled: Word = 0;
  gCoopSecretsFound: Word = 0;
  gCoopTotalMonstersKilled: Word = 0;
  gCoopTotalSecretsFound: Word = 0;
  gCoopTotalMonsters: Word = 0;
  gCoopTotalSecrets: Word = 0;
  gStatsOff: Boolean = False;
  gStatsPressed: Boolean = False;
  gExitByTrigger: Boolean = False;
  gNextMap: String = '';
  gLMSRespawn: Byte = LMS_RESPAWN_NONE;
  gLMSRespawnTime: Cardinal = 0;
  gLMSSoftSpawn: Boolean = False;
  gMissionFailed: Boolean = False;
  gVoteInProgress: Boolean = False;
  gVotePassed: Boolean = False;
  gVoteCommand: string = '';
  gVoteTimer: Cardinal = 0;
  gVoteCmdTimer: Cardinal = 0;
  gVoteCount: Integer = 0;
  gVoteTimeout: Cardinal = 30;
  gVoted: Boolean = False;
  gVotesEnabled: Boolean = True;
  gEvents: Array of TGameEvent;
  gDelayedEvents: Array of TDelayedEvent;

  P1MoveButton: Byte = 0;
  P2MoveButton: Byte = 0;

implementation

uses
  g_textures, g_main, g_window, dglOpenGL, g_menu,
  g_gui, e_input, e_log, g_console, g_items, g_map,
  g_playermodel, g_gfx, g_options, g_weapons, Math,
  g_triggers, MAPDEF, g_monsters, e_sound, CONFIG,
  DirectInput, BinEditor, g_language, g_net,
  ENet, e_fixedbuffer, g_netmsg, g_netmaster;

type
  TEndCustomGameStat = record
    PlayerStat: TPlayerStatArray;
    TeamStat: TTeamStat;
    GameTime: LongWord;
    GameMode: Byte;
    Map, MapName: String;
  end;

  TEndSingleGameStat = record
    PlayerStat: Array [0..1] of record
      Kills: Integer;
      Secrets: Integer;
    end;
    GameTime: LongWord;
    TwoPlayers: Boolean;
    TotalSecrets: Integer;
  end;

  TLoadingStat = record
    CurValue: Integer;
    MaxValue: Integer;
    ShowCount: Integer;
    Msgs: Array of String;
    NextMsg: Word;
  end;

  TParamStrValue = record
    Name: String;
    Value: String;
  end;

  TParamStrValues = Array of TParamStrValue;

const
  INTER_ACTION_TEXT = 1;
  INTER_ACTION_PIC = 2;
  INTER_ACTION_MUSIC = 3;

var
  FPS, UPS: Word;
  FPSCounter, UPSCounter: Word;
  FPSTime, UPSTime: LongWord;
  DataLoaded: Boolean = False;
  LastScreenShot: Int64;
  IsDrawStat: Boolean = False;
  CustomStat: TEndCustomGameStat;
  SingleStat: TEndSingleGameStat;
  LoadingStat: TLoadingStat;
  EndingGameCounter: Byte = 0;
  MessageText: String;
  MessageTime: Word;
  MapList: SArray = nil;
  MapIndex: Integer = -1;
  MegaWAD: record
    info: TMegaWADInfo;
    endpic: String;
    endmus: String;
    res: record
      text: Array of ShortString;
      anim: Array of ShortString;
      pic: Array of ShortString;
      mus: Array of ShortString;
    end;
    triggers: Array of record
      event: ShortString;
      actions: Array of record
        action, p1, p2: Integer;
      end;
    end;
    cur_trigger: Integer;
    cur_action: Integer;
  end;
  InterPic: String;
  InterText: record
    lines: SArray;
    img: String;
    cur_line: Integer;
    cur_char: Integer;
    counter: Integer;
    endtext: Boolean;
  end;

function Compare(a, b: TPlayerStat): Integer;
begin
  if a.Spectator then Result := 1
    else if b.Spectator then Result := -1
      else if a.Frags < b.Frags then Result := 1
        else if a.Frags > b.Frags then Result := -1
          else if a.Deaths < b.Deaths then Result := -1
            else if a.Deaths > b.Deaths then Result := 1
              else if a.Kills < b.Kills then Result := -1
                else Result := 1;
end;

procedure SortGameStat(var stat: TPlayerStatArray);
var
  I, J: Integer;
  T: TPlayerStat;
begin
  if stat = nil then Exit;

  for I := High(stat) downto Low(stat) do
    for J := Low(stat) to High(stat) - 1 do
      if Compare(stat[J], stat[J + 1]) = 1  then
      begin
        T := stat[J];
        stat[J] := stat[J + 1];
        stat[J + 1] := T;
      end;
end;

function g_Game_ModeToText(Mode: Byte): string;
begin
  Result := '';
  case Mode of
    GM_DM:   Result := _lc[I_MENU_GAME_TYPE_DM];
    GM_TDM:  Result := _lc[I_MENU_GAME_TYPE_TDM];
    GM_CTF:  Result := _lc[I_MENU_GAME_TYPE_CTF];
    GM_COOP: Result := _lc[I_MENU_GAME_TYPE_COOP];
    GM_SINGLE: Result := _lc[I_MENU_GAME_TYPE_SINGLE];
  end;
end;

function g_Game_TextToMode(Mode: string): Byte;
begin
  Result := GM_NONE;
  Mode := UpperCase(Mode);
  if Mode = _lc[I_MENU_GAME_TYPE_DM] then
  begin
    Result := GM_DM;
    Exit;
  end;
  if Mode = _lc[I_MENU_GAME_TYPE_TDM] then
  begin
    Result := GM_TDM;
    Exit;
  end;
  if Mode = _lc[I_MENU_GAME_TYPE_CTF] then
  begin
    Result := GM_CTF;
    Exit;
  end;
  if Mode = _lc[I_MENU_GAME_TYPE_COOP] then
  begin
    Result := GM_COOP;
    Exit;
  end;
  if Mode = _lc[I_MENU_GAME_TYPE_SINGLE] then
  begin
    Result := GM_SINGLE;
    Exit;
  end;
end;

function g_Game_IsNet(): Boolean;
begin
  Result := (gGameSettings.GameType in [GT_SERVER, GT_CLIENT]);
end;

function g_Game_IsServer(): Boolean;
begin
  Result := (gGameSettings.GameType in [GT_SINGLE, GT_CUSTOM, GT_SERVER]);
end;

function g_Game_IsClient(): Boolean;
begin
  Result := (gGameSettings.GameType = GT_CLIENT);
end;

function g_Game_GetMegaWADInfo(WAD: String): TMegaWADInfo;
var
  w: TWADEditor_1;
  cfg: TConfig;
  p: Pointer;
  len: Integer;
begin
  Result.name := ExtractFileName(WAD);
  Result.description := '';
  Result.author := '';

  w := TWADEditor_1.Create();
  w.ReadFile(WAD);

  if not w.GetResource('', 'INTERSCRIPT', p, len) then
  begin
    w.Free();
    Exit;
  end;

  cfg := TConfig.CreateMem(p, len);
  Result.name := cfg.ReadStr('megawad', 'name', ExtractFileName(WAD));
  Result.description := cfg.ReadStr('megawad', 'description', '');
  Result.author := cfg.ReadStr('megawad', 'author', '');
  Result.pic := cfg.ReadStr('megawad', 'pic', '');
  cfg.Free();

  FreeMem(p);
end;

procedure g_Game_FreeWAD();
var
  a: Integer;
begin
  for a := 0 to High(MegaWAD.res.pic) do
    if MegaWAD.res.pic[a] <> '' then
      g_Texture_Delete(MegaWAD.res.pic[a]);

  for a := 0 to High(MegaWAD.res.mus) do
    if MegaWAD.res.mus[a] <> '' then
      g_Sound_Delete(MegaWAD.res.mus[a]);

  MegaWAD.res.pic := nil;
  MegaWAD.res.text := nil;
  MegaWAD.res.anim := nil;
  MegaWAD.res.mus := nil;
  MegaWAD.triggers := nil;

  g_Texture_Delete('TEXTURE_endpic');
  g_Sound_Delete('MUSIC_endmus');

  ZeroMemory(@MegaWAD, SizeOf(MegaWAD));
  gGameSettings.WAD := '';
end;

procedure g_Game_LoadWAD(WAD: string);
var
  w: TWADEditor_1;
  cfg: TConfig;
  p: Pointer;
  {b, }len: Integer;
  s: string;
begin
  g_Game_FreeWAD();
  gGameSettings.WAD := WAD;
  if not (gGameSettings.GameMode in [GM_COOP, GM_SINGLE]) then
    Exit;

  MegaWAD.info := g_Game_GetMegaWADInfo(MapsDir + WAD);

  w := TWADEditor_1.Create();
  w.ReadFile(MapsDir + WAD);

  if not w.GetResource('', 'INTERSCRIPT', p, len) then
  begin
    w.Free();
    Exit;
  end;

  cfg := TConfig.CreateMem(p, len);

 {b := 1;
 while True do
 begin
  s := cfg.ReadStr('pic', 'pic'+IntToStr(b), '');
  if s = '' then Break;
  b := b+1;

  SetLength(MegaWAD.res.pic, Length(MegaWAD.res.pic)+1);
  MegaWAD.res.pic[High(MegaWAD.res.pic)] := s;

  g_Texture_CreateWADEx(s, s);
 end;

 b := 1;
 while True do
 begin
  s := cfg.ReadStr('mus', 'mus'+IntToStr(b), '');
  if s = '' then Break;
  b := b+1;

  SetLength(MegaWAD.res.mus, Length(MegaWAD.res.mus)+1);
  MegaWAD.res.mus[High(MegaWAD.res.mus)] := s;

  g_Music_CreateWADEx(s, s);
 end;}

  MegaWAD.endpic := cfg.ReadStr('megawad', 'endpic', '');
  if MegaWAD.endpic <> '' then
  begin
    g_ProcessResourceStr(MegaWAD.endpic, @s, nil, nil);
    if s = '' then s := MapsDir+WAD else s := GameDir+'\wads\';
    g_Texture_CreateWADEx('TEXTURE_endpic', s+MegaWAD.endpic);
  end;
  MegaWAD.endmus := cfg.ReadStr('megawad', 'endmus', 'Standart.wad:D2DMUS\�����');
  if MegaWAD.endmus <> '' then
  begin
    g_ProcessResourceStr(MegaWAD.endmus, @s, nil, nil);
    if s = '' then s := MapsDir+WAD else s := GameDir+'\wads\';
    g_Sound_CreateWADEx('MUSIC_endmus', s+MegaWAD.endmus, True);
  end;

  cfg.Free();
  FreeMem(p);
  w.Free();
end;

{procedure start_trigger(t: string);
begin
end;

function next_trigger(): Boolean;
begin
end;}

procedure DisableCheats();
begin
  MAX_RUNVEL := 8;
  VEL_JUMP := 10;
  gFly := False;

  if gPlayer1 <> nil then gPlayer1.GodMode := False;
  if gPlayer2 <> nil then gPlayer2.GodMode := False;
  if gPlayer1 <> nil then gPlayer1.NoTarget := False;
  if gPlayer2 <> nil then gPlayer2.NoTarget := False;
end;

procedure g_Game_ExecuteEvent(Name: String);
var
  a: Integer;
begin
  if Name = '' then
    Exit;
  if gEvents = nil then
    Exit;
  for a := 0 to High(gEvents) do
    if gEvents[a].Name = Name then
    begin
      if gEvents[a].Command <> '' then
        g_Console_Process(gEvents[a].Command, True);
      break;
    end;
end;

function g_Game_DelayEvent(DEType: Byte; Time: LongWord; Num: Integer = 0; Str: String = ''): Integer;
var
  a, n: Integer;
begin
  n := -1;
  if gDelayedEvents <> nil then
    for a := 0 to High(gDelayedEvents) do
      if not gDelayedEvents[a].Pending then
      begin
        n := a;
        break;
      end;
  if n = -1 then
  begin
    SetLength(gDelayedEvents, Length(gDelayedEvents) + 1);
    n := High(gDelayedEvents);
  end;
  gDelayedEvents[n].Pending := True;
  gDelayedEvents[n].DEType := DEType;
  gDelayedEvents[n].DENum := Num;
  gDelayedEvents[n].DEStr := Str;
  if DEType = DE_GLOBEVENT then
    gDelayedEvents[n].Time := (GetTimer() div 1000) + Time
  else
    gDelayedEvents[n].Time := gTime + Time;
  Result := n;
end;

procedure EndGame();
var
  a: Integer;
  FileName, SectionName, ResName: string;
begin
  if g_Game_IsNet and g_Game_IsServer then
    MH_SEND_GameEvent(NET_EV_MAPEND, Byte(gMissionFailed));

// ���� ����:
  gPause := False;
  gGameOn := False;

  g_Game_StopAllSounds(False);

  MessageTime := 0;
  MessageText := '';

  EndingGameCounter := 0;
  g_ActiveWindow := nil;

  gLMSRespawn := LMS_RESPAWN_NONE;
  gLMSRespawnTime := 0;

  case gExit of
    EXIT_SIMPLE: // ����� ����� ���� ��� ����� �����
      begin
        g_Game_Free();

        if gMapOnce  then
          begin // ��� ��� ����
            g_Game_Quit();
          end
        else
          begin // ����� � ������� ����
            gMusic.SetByName('MUSIC_MENU');
            gMusic.Play();
            if gState <> STATE_SLIST then
            begin
              g_GUI_ShowWindow('MainMenu');
              gState := STATE_MENU;
            end else
            begin
              // ��������� ������ ��������
              slReturnPressed := True;
              if g_Net_Slist_Fetch(slCurrent) then
              begin
                if slCurrent = nil then
                  slWaitStr := _lc[I_NET_SLIST_NOSERVERS];
              end
              else
                slWaitStr := _lc[I_NET_SLIST_ERROR];
            end;

            g_Game_ExecuteEvent('ongameend');
          end;
      end;

    EXIT_RESTART: // ������ ������� �������
      begin
        if not g_Game_IsClient then g_Game_Restart();
      end;

    EXIT_ENDLEVELCUSTOM: // ���������� ������� � ����� ����
      begin
      // ���������� ����� ����:
        g_ProcessResourceStr(gMapInfo.Map, FileName, SectionName, ResName);

        CustomStat.GameTime := gTime;
        CustomStat.Map := ExtractFileName(FileName)+':'+ResName;
        CustomStat.MapName := gMapInfo.Name;
        CustomStat.GameMode := gGameSettings.GameMode;
        if gGameSettings.GameMode in [GM_TDM, GM_CTF] then
          CustomStat.TeamStat := gTeamStat;

        CustomStat.PlayerStat := nil;

      // ���������� �������:
        if gPlayers <> nil then
        begin
          for a := 0 to High(gPlayers) do
            if gPlayers[a] <> nil then
            begin
              SetLength(CustomStat.PlayerStat, Length(CustomStat.PlayerStat)+1);
              with CustomStat.PlayerStat[High(CustomStat.PlayerStat)] do
              begin
                Name := gPlayers[a].Name;
                Frags := gPlayers[a].Frags;
                Deaths := gPlayers[a].Death;
                Kills := gPlayers[a].Kills;
                Team := gPlayers[a].Team;
                Color := gPlayers[a].Model.Color;
                Spectator := gPlayers[a].FSpectator;
              end;
            end;

          SortGameStat(CustomStat.PlayerStat);
        end;

        g_Game_ExecuteEvent('onmapend');

      // ���������� �����:
        EndingGameCounter := 255;
        gState := STATE_FOLD;
        gInterTime := 0;
        if gDefInterTime < 0 then
          gInterEndTime := IfThen((gGameSettings.GameType = GT_SERVER) and (gPlayer1 = nil), 15000, 25000)
        else
          gInterEndTime := gDefInterTime * 1000;
      end;

    EXIT_ENDLEVELSINGLE: // ���������� ������� � ��������� ����
      begin
      // ���������� ��������� ����:
        SingleStat.GameTime := gTime;
        SingleStat.TwoPlayers := gPlayer2 <> nil;
        SingleStat.TotalSecrets := gSecretsCount;
      // ���������� ������� ������:
        SingleStat.PlayerStat[0].Kills := gPlayer1.MonsterKills;
        SingleStat.PlayerStat[0].Secrets := gPlayer1.Secrets;
      // ���������� ������� ������ (���� ����):
        if SingleStat.TwoPlayers then
        begin
          SingleStat.PlayerStat[1].Kills := gPlayer2.MonsterKills;
          SingleStat.PlayerStat[1].Secrets := gPlayer2.Secrets;
        end;

        g_Game_ExecuteEvent('onmapend');

      // ���� ��� �����:
        if gNextMap <> '' then
          begin
            gMusic.SetByName('MUSIC_INTERMUS');
            gMusic.Play();
            gState := STATE_INTERSINGLE;

            g_Game_ExecuteEvent('oninter');
          end
        else // ������ ��� ����
          begin
          // ���������� �����:
            EndingGameCounter := 255;
            gState := STATE_FOLD;
          end;
      end;
  end;

// ��������� ����������:
  if gExit <> EXIT_QUIT then
    gExit := 0;
end;

procedure DrawStat();
var
  pc, x, y, w, h: Integer;
  w1, w2, w3, w4: Integer;
  a, aa: Integer;
  cw, ch, r, g, b, rr, gg, bb: Byte;
  s1, s2, s3: String;
  _y: Integer;
  stat: TPlayerStatArray;
  wad, map: string;
  mapstr: string;
begin
  pc := g_Player_GetCount;
  e_TextureFontGetSize(gStdFont, cw, ch);

  w := gScreenWidth-(gScreenWidth div 5);
  if gGameSettings.GameMode in [GM_TDM, GM_CTF] then
    h := 32+ch*(11+pc)
  else
    h := 40+ch*5+(ch+8)*pc;
  x := (gScreenWidth div 2)-(w div 2);
  y := (gScreenHeight div 2)-(h div 2);

  e_DrawFillQuad(x, y, x+w-1, y+h-1, 64, 64, 64, 32);
  e_DrawQuad(x, y, x+w-1, y+h-1, 255, 127, 0);

  g_ProcessResourceStr(gMapInfo.Map, @wad, nil, @map);
  wad := ExtractFileName(wad);
  mapstr := wad + ':\' + map + ' - ' + gMapInfo.Name;

  case gGameSettings.GameMode of
    GM_DM:
    begin
      if gGameSettings.MaxLives = 0 then
        s1 := _lc[I_GAME_DM]
      else
        s1 := _lc[I_GAME_LMS];
      s2 := Format(_lc[I_GAME_FRAG_LIMIT], [gGameSettings.GoalLimit]);
      s3 := Format(_lc[I_GAME_TIME_LIMIT], [gGameSettings.TimeLimit div 3600, (gGameSettings.TimeLimit div 60) mod 60, gGameSettings.TimeLimit mod 60]);
    end;

    GM_TDM:
    begin
      if gGameSettings.MaxLives = 0 then
        s1 := _lc[I_GAME_TDM]
      else
        s1 := _lc[I_GAME_TLMS];
      s2 := Format(_lc[I_GAME_FRAG_LIMIT], [gGameSettings.GoalLimit]);
      s3 := Format(_lc[I_GAME_TIME_LIMIT], [gGameSettings.TimeLimit div 3600, (gGameSettings.TimeLimit div 60) mod 60, gGameSettings.TimeLimit mod 60]);
    end;

    GM_CTF:
    begin
      s1 := _lc[I_GAME_CTF];
      s2 := Format(_lc[I_GAME_SCORE_LIMIT], [gGameSettings.GoalLimit]);
      s3 := Format(_lc[I_GAME_TIME_LIMIT], [gGameSettings.TimeLimit div 3600, (gGameSettings.TimeLimit div 60) mod 60, gGameSettings.TimeLimit mod 60]);
    end;

    GM_COOP:
    begin
      if gGameSettings.MaxLives = 0 then
        s1 := _lc[I_GAME_COOP]
      else
        s1 := _lc[I_GAME_SURV];
      s2 := _lc[I_GAME_MONSTERS] + ' ' + IntToStr(gCoopMonstersKilled) + '/' + IntToStr(gTotalMonsters);
      s3 := _lc[I_GAME_SECRETS] + ' ' + IntToStr(gCoopSecretsFound) + '/' + IntToStr(gSecretsCount);
    end;

    else
    begin
      s1 := '';
      s2 := '';
    end;
  end;

  _y := y+8;
  e_TextureFontPrintEx(x+(w div 2)-(Length(s1)*cw div 2), _y, s1, gStdFont, 255, 255, 255, 1);
  _y := _y+ch+8;
  e_TextureFontPrintEx(x+(w div 2)-(Length(mapstr)*cw div 2), _y, mapstr, gStdFont, 200, 200, 200, 1);
  _y := _y+ch+8;
  e_TextureFontPrintEx(x+16, _y, s2, gStdFont, 200, 200, 200, 1);

  e_TextureFontPrintEx(x+w-16-(Length(s3))*cw, _y, s3,
                       gStdFont, 200, 200, 200, 1);

  if NetMode = NET_SERVER then
    e_TextureFontPrintEx(x+8, y + 8, _lc[I_NET_SERVER], gStdFont, 255, 255, 255, 1)
  else
    if NetMode = NET_CLIENT then
      e_TextureFontPrintEx(x+8, y + 8,
        NetClientIP + ':' + IntToStr(NetClientPort), gStdFont, 255, 255, 255, 1);

  if pc = 0 then
    Exit;
  stat := g_Player_GetStats();
  SortGameStat(stat);

  w2 := (w-16) div 6 + 48; // ������ 2 �������
  w3 := (w-16) div 6; // ������ 3 � 4 ��������
  w4 := w3;
  w1 := w-16-w2-w3-w4; // ���������� ������������ - ��� ����� � ����� ������

  if gGameSettings.GameMode in [GM_TDM, GM_CTF] then
  begin
    _y := _y+ch+ch;

    for a := TEAM_RED to TEAM_BLUE do
    begin
      if a = TEAM_RED then
      begin
        s1 := _lc[I_GAME_TEAM_RED];
        r := 255;
        g := 0;
        b := 0;
      end
      else
      begin
        s1 := _lc[I_GAME_TEAM_BLUE];
        r := 0;
        g := 0;
        b := 255;
      end;

      e_TextureFontPrintEx(x+16, _y, s1, gStdFont, r, g, b, 1);
      e_TextureFontPrintEx(x+w1+16, _y, IntToStr(gTeamStat[a].Goals),
                           gStdFont, r, g, b, 1);

      _y := _y+ch+(ch div 4);
      e_DrawLine(1, x+16, _y, x+w-16, _y, r, g, b);
      _y := _y+(ch div 4);

      for aa := 0 to High(stat) do
        if stat[aa].Team = a then
          with stat[aa] do
          begin
            if Spectator then
            begin
              rr := r div 2;
              gg := g div 2;
              bb := b div 2;
            end
            else
            begin
              rr := r;
              gg := g;
              bb := b;
            end;
            // ���
            e_TextureFontPrintEx(x+16, _y, Name, gStdFont, rr, gg, bb, 1);
            // ����/������
            e_TextureFontPrintEx(x+w1+16, _y, Format(_lc[I_GAME_PING_MS], [Ping, Loss]), gStdFont, rr, gg, bb, 1);
            // �����
            e_TextureFontPrintEx(x+w1+w2+16, _y, IntToStr(Frags), gStdFont, rr, gg, bb, 1);
            // ������
            e_TextureFontPrintEx(x+w1+w2+w3+16, _y, IntToStr(Deaths), gStdFont, rr, gg, bb, 1);
            _y := _y+ch;
          end;

          _y := _y+ch;
    end;
  end
  else if gGameSettings.GameMode in [GM_DM, GM_COOP] then
  begin
    _y := _y+ch+ch;
    e_TextureFontPrintEx(x+16, _y, _lc[I_GAME_PLAYER_NAME], gStdFont, 255, 127, 0, 1);
    e_TextureFontPrintEx(x+16+w1, _y, _lc[I_GAME_PING], gStdFont, 255, 127, 0, 1);
    e_TextureFontPrintEx(x+16+w1+w2, _y, _lc[I_GAME_FRAGS], gStdFont, 255, 127, 0, 1);
    e_TextureFontPrintEx(x+16+w1+w2+w3, _y, _lc[I_GAME_DEATHS], gStdFont, 255, 127, 0, 1);

    _y := _y+ch+8;
    for aa := 0 to High(stat) do
      with stat[aa] do
      begin
        if Spectator then
        begin
          r := 127;
          g := 64;
        end
        else
        begin
          r := 255;
          g := 127;
        end;
        // ���� ������
        e_DrawFillQuad(x+16, _y+4, x+32-1, _y+16+4-1, Color.R, Color.G, Color.B, 0);
        e_DrawQuad(x+16, _y+4, x+32-1, _y+16+4-1, 192, 192, 192);
        // ���
        e_TextureFontPrintEx(x+16+16+8, _y+4, Name, gStdFont, r, g, 0, 1);
        // ����/������
        e_TextureFontPrintEx(x+w1+16, _y+4, Format(_lc[I_GAME_PING_MS], [Ping, Loss]), gStdFont, r, g, 0, 1);
        // �����
        e_TextureFontPrintEx(x+w1+w2+16, _y+4, IntToStr(Frags), gStdFont, r, g, 0, 1);
        // ������
        e_TextureFontPrintEx(x+w1+w2+w3+16, _y+4, IntToStr(Deaths), gStdFont, r, g, 0, 1);
        _y := _y+ch+8;
      end;
  end
end;

procedure g_Game_Init();
var
  SR: TSearchRec;
begin
  gExit := 0;
  gMapToDelete := '';
  gTempDelete := False;

  g_Texture_CreateWADEx('MENU_BACKGROUND', GameWAD+':TEXTURES\TITLE');
  g_Texture_CreateWADEx('INTER', GameWAD+':TEXTURES\INTER');
  g_Texture_CreateWADEx('ENDGAME_EN', GameWAD+':TEXTURES\ENDGAME_EN');
  g_Texture_CreateWADEx('ENDGAME_RU', GameWAD+':TEXTURES\ENDGAME_RU');

  LoadStdFont('STDTXT', 'STDFONT', gStdFont);
  LoadFont('MENUTXT', 'MENUFONT', gMenuFont);
  LoadFont('SMALLTXT', 'SMALLFONT', gMenuSmallFont);

  g_Game_ClearLoading();
  g_Game_SetLoadingText(Format('Doom 2D: Forever %s', [GAME_VERSION]), 0, False);
  g_Game_SetLoadingText('', 0, False);

  g_Game_SetLoadingText(_lc[I_LOAD_CONSOLE], 0, False);
  g_Console_Init();

  g_Game_SetLoadingText(_lc[I_LOAD_MODELS], 0, False);
  g_PlayerModel_LoadData();

  if FindFirst(ModelsDir+'*.wad', faAnyFile, SR) = 0 then
    repeat
      if not g_PlayerModel_Load(ModelsDir+SR.Name) then
        e_WriteLog(Format('Error loading model %s', [SR.Name]), MSG_WARNING);
    until FindNext(SR) <> 0;
  FindClose(SR);

  gGameOn := False;
  gPause := False;
  gTime := 0;
  LastScreenShot := 0;

  {e_MouseInfo.Accel := 1.0;}

  g_Game_SetLoadingText(_lc[I_LOAD_GAME_DATA], 0, False);
  g_Game_LoadData();

  g_Game_SetLoadingText(_lc[I_LOAD_MUSIC], 0, False);
  g_Sound_CreateWADEx('MUSIC_INTERMUS', GameWAD+':MUSIC\INTERMUS', True);
  g_Sound_CreateWADEx('MUSIC_MENU', GameWAD+':MUSIC\MENU', True);
  g_Sound_CreateWADEx('MUSIC_ROUNDMUS', GameWAD+':MUSIC\ROUNDMUS');
  g_Sound_CreateWADEx('MUSIC_STDENDMUS', GameWAD+':MUSIC\ENDMUS', True);

  g_Game_SetLoadingText(_lc[I_LOAD_MENUS], 0, False);
  g_Menu_Init();

  gMusic := TMusic.Create();
  gMusic.SetByName('MUSIC_MENU');
  gMusic.Play();

  gGameSettings.WarmupTime := 30;

  gState := STATE_MENU;

  SetLength(gEvents, 6);
  gEvents[0].Name := 'ongamestart';
  gEvents[1].Name := 'ongameend';
  gEvents[2].Name := 'onmapstart';
  gEvents[3].Name := 'onmapend';
  gEvents[4].Name := 'oninter';
  gEvents[5].Name := 'onwadend';
end;

procedure g_Game_Free();
begin
  if NetMode = NET_CLIENT then g_Net_Disconnect();
  if NetMode = NET_SERVER then g_Net_Host_Die();

  g_Map_Free();
  g_Player_Free();
  g_Player_RemoveAllCorpses();

  gGameSettings.GameType := GT_NONE;
  if gGameSettings.GameMode = GM_SINGLE then
    gGameSettings.GameMode := GM_DM;
  gSwitchGameMode := gGameSettings.GameMode;

  gChatShow := False;
  gExitByTrigger := False;
end;

function IsActivePlayer(p: TPlayer): Boolean;
begin
  Result := False;
  if p = nil then
    Exit;
  Result := (not p.FDummy) and (not p.FSpectator);
end;

function GetActivePlayer_ByID(ID: Integer): TPlayer;
var
  a: Integer;
begin
  Result := nil;
  if ID < 0 then
    Exit;
  if gPlayers = nil then
    Exit;
  for a := Low(gPlayers) to High(gPlayers) do
    if IsActivePlayer(gPlayers[a]) then
    begin
      if gPlayers[a].UID <> ID then
        continue;
      Result := gPlayers[a];
      break;
    end;
end;

function GetActivePlayerID_Next(Skip: Integer = -1): Integer;
var
  a, idx: Integer;
  ids: Array of Word;
begin
  Result := -1;
  if gPlayers = nil then
    Exit;
  SetLength(ids, 0);
  idx := -1;
  for a := Low(gPlayers) to High(gPlayers) do
    if IsActivePlayer(gPlayers[a]) then
    begin
      SetLength(ids, Length(ids) + 1);
      ids[High(ids)] := gPlayers[a].UID;
      if gPlayers[a].UID = Skip then
        idx := High(ids);
    end;
  if Length(ids) = 0 then
    Exit;
  if idx = -1 then
    Result := ids[0]
  else
    Result := ids[(idx + 1) mod Length(ids)];
end;

function GetActivePlayerID_Prev(Skip: Integer = -1): Integer;
var
  a, idx: Integer;
  ids: Array of Word;
begin
  Result := -1;
  if gPlayers = nil then
    Exit;
  SetLength(ids, 0);
  idx := -1;
  for a := Low(gPlayers) to High(gPlayers) do
    if IsActivePlayer(gPlayers[a]) then
    begin
      SetLength(ids, Length(ids) + 1);
      ids[High(ids)] := gPlayers[a].UID;
      if gPlayers[a].UID = Skip then
        idx := High(ids);
    end;
  if Length(ids) = 0 then
    Exit;
  if idx = -1 then
    Result := ids[Length(ids) - 1]
  else
    Result := ids[(Length(ids) - 1 + idx) mod Length(ids)];
end;

procedure g_Game_Update();
var
  Msg: g_gui.TMessage;
  Time: Int64;
  a: Byte;
  w: Word;
  i, b: Integer;
begin
// ���� ��������� ����:
  if gExit = EXIT_QUIT then
    Exit;
// ���� ����������� - ������������:
  if gExit <> 0 then
  begin
    EndGame();
    if gExit = EXIT_QUIT then
      Exit;
  end;

// ������ ���������� � ��������, ���� ���� �������:
  e_PollInput();

// ��������� ������� (�������� � ���������):
  g_Console_Update();

  if (NetMode = NET_NONE) and (g_Game_IsNet) and (gGameOn or (gState in [STATE_FOLD, STATE_INTERCUSTOM])) then
  begin
    gExit := EXIT_SIMPLE;
    EndGame();
    Exit;
  end;

  case gState of
    STATE_INTERSINGLE, // ��������� ����� ����������� ������ � ��������� ����
    STATE_INTERCUSTOM, // ��������� ����� ����������� ������ � ����� ����
    STATE_INTERTEXT, // ����� ����� ��������
    STATE_INTERPIC: // �������� ����� ��������
      begin
        if g_Game_IsNet and g_Game_IsServer then
        begin
          gInterTime := gInterTime + GAME_TICK;
          a := Min((gInterEndTime - gInterTime) div 1000 + 1, 255);
          if a <> gServInterTime then
          begin
            gServInterTime := a;
            MH_SEND_TimeSync(gServInterTime);
          end;
        end;

        if (not g_Game_IsClient) and
        (
          (
            (e_KeyPressed(e_IKey_Enter) or e_KeyPressed(e_IKey_Space))
            and (not gJustChatted) and (not gConsoleShow) and (not gChatShow)
            and (g_ActiveWindow = nil)
          )
          or (g_Game_IsNet and (gInterTime > gInterEndTime))
        )
        then
        begin // ������ <Enter>/<������> ��� ������ ���������� �������:
          g_Game_StopAllSounds(True);

          if gMapOnce then // ��� ��� ����
            gExit := EXIT_SIMPLE
          else
            if gNextMap <> '' then // ��������� �� ��������� �����
              g_Game_ChangeMap(gNextMap)
            else // ��������� ����� ���
            begin
              if gGameSettings.GameType in [GT_CUSTOM, GT_SERVER] then
              begin
              // ����� � ������� ����:
                g_Game_Free;
                g_GUI_ShowWindow('MainMenu');
                gMusic.SetByName('MUSIC_MENU');
                gMusic.Play();
                gState := STATE_MENU;
              end else
              begin
              // ��������� ��������:
                g_Game_ExecuteEvent('onwadend');
                g_Game_Free();
                if not gMusic.SetByName('MUSIC_endmus') then
                  gMusic.SetByName('MUSIC_STDENDMUS');
                gMusic.Play();
                gState := STATE_ENDPIC;
              end;
              g_Game_ExecuteEvent('ongameend');
            end;

          Exit;
        end;

        if gState = STATE_INTERTEXT then
          if InterText.counter > 0 then
            InterText.counter := InterText.counter - 1;
      end;

    STATE_FOLD: // ��������� ������
      begin
        if EndingGameCounter = 0 then
          begin
          // ���������� ������� � ����� ����:
            if gGameSettings.GameType in [GT_CUSTOM, GT_SERVER, GT_CLIENT] then
              begin
                if gLastMap and (gGameSettings.GameMode = GM_COOP) then
                begin
                  g_Game_ExecuteEvent('onwadend');
                  if not gMusic.SetByName('MUSIC_endmus') then
                    gMusic.SetByName('MUSIC_STDENDMUS');
                end
                else
                  gMusic.SetByName('MUSIC_ROUNDMUS');

                gMusic.Play();
                gState := STATE_INTERCUSTOM;
              end
            else // ����������� ��������� ����� � ��������� ����
              begin
                gMusic.SetByName('MUSIC_INTERMUS');
                gMusic.Play();
                gState := STATE_INTERSINGLE;
              end;
            g_Game_ExecuteEvent('oninter');
          end
        else
          DecMin(EndingGameCounter, 6, 0);
      end;

    STATE_ENDPIC: // �������� ��������� ��������
      begin
        if gMapOnce then // ��� ��� ����
        begin
          gExit := EXIT_SIMPLE;
          Exit;
        end;
      end;

    STATE_SLIST:
        g_Serverlist_Control(slCurrent);
  end;

  if g_Game_IsNet then
    if not gConsoleShow then
      if not gChatShow then
      begin
        if g_ActiveWindow = nil then
        begin
          if e_KeyPressed(gGameControls.GameControls.Chat) then
            g_Console_Chat_Switch(False)
          else if (e_KeyPressed(gGameControls.GameControls.TeamChat)) and
                  (gGameSettings.GameMode in [GM_TDM, GM_CTF]) then
            g_Console_Chat_Switch(True);
        end;
      end else
        if not gChatEnter then
          if (not e_KeyPressed(gGameControls.GameControls.Chat))
             and (not e_KeyPressed(gGameControls.GameControls.TeamChat)) then
            gChatEnter := True;

// ���������� �� Tab:
  if gGameOn then
    IsDrawStat := (not gConsoleShow) and (not gChatShow) and
                  (gGameSettings.GameType <> GT_SINGLE) and
                  e_KeyPressed(gGameControls.GameControls.Stat);

// ���� ����:
  if gGameOn and not gPause and (gState <> STATE_FOLD) then
  begin
  // ����� += 28 �����������:
    gTime := gTime + GAME_TICK;

  // ��������� ���������� ������:
    if MessageTime = 0 then
      MessageText := '';
    if MessageTime > 0 then
      MessageTime := MessageTime - 1;

    if (g_Game_IsServer) then
    begin
    // ��� ����� ����� �������:
      if (gGameSettings.TimeLimit > 0) then
        if (gTime - gGameStartTime) div 1000 >= gGameSettings.TimeLimit then
        begin // �� ������ => ����� ������
          g_Game_NextLevel();
          Exit;
        end;

    // ���� ���������� ������� � LMS:
      if (gLMSRespawn > LMS_RESPAWN_NONE) and (gLMSRespawnTime < gTime) then
        g_Game_RestartRound(gLMSSoftSpawn);

    // �������� ��������� �����������, ���� ����� ������
      if gVoteInProgress and (gVoteTimer < gTime) then
        g_Game_CheckVote
      else if gVotePassed and (gVoteCmdTimer < gTime) then
      begin
        g_Console_Process(gVoteCommand);
        gVoteCommand := '';
        gVotePassed := False;
      end;

    // �������� ����� ������� ������
      if gFlags[FLAG_RED].State = FLAG_STATE_CAPTURED then
        gFlags[FLAG_RED].CaptureTime := gFlags[FLAG_RED].CaptureTime + GAME_TICK;
      if gFlags[FLAG_BLUE].State = FLAG_STATE_CAPTURED then
        gFlags[FLAG_BLUE].CaptureTime := gFlags[FLAG_BLUE].CaptureTime + GAME_TICK;

    // ��� ����� ����� �����:
      if (gGameSettings.GoalLimit > 0) then
      begin
        b := 0;

        if gGameSettings.GameMode = GM_DM then
          begin // � DM ���� ������ � max �������
            for i := 0 to High(gPlayers) do
              if gPlayers[i] <> nil then
                if gPlayers[i].Frags > b then
                  b := gPlayers[i].Frags;
          end
        else
          if gGameSettings.GameMode in [GM_TDM, GM_CTF] then
          begin // � CTF/TDM �������� ������� � ���������� ������
            b := Max(gTeamStat[TEAM_RED].Goals, gTeamStat[TEAM_BLUE].Goals);
          end;

      // ����� ����� ������ => ����� ������:
        if b >= gGameSettings.GoalLimit then
        begin
          g_Game_NextLevel();
          Exit;
        end;
      end;

    // ������������ ������� �������:
      if gPlayer1 <> nil then gPlayer1.ReleaseKeys();
      if gPlayer2 <> nil then gPlayer2.ReleaseKeys();
      if (not gConsoleShow) and (not gChatShow) and (g_ActiveWindow = nil) then
      begin
      // ������ �����:
        if gPlayer1 <> nil then
          with gGameControls.P1Control do
          begin
            if e_KeyPressed(KeyLeft) and (not e_KeyPressed(KeyRight)) then
              P1MoveButton := 1 // ������ ������ "�����"
            else
              if (not e_KeyPressed(KeyLeft)) and e_KeyPressed(KeyRight) then
                P1MoveButton := 2 // ������ ������ "������"
              else
                if (not e_KeyPressed(KeyLeft)) and (not e_KeyPressed(KeyRight)) then
                  P1MoveButton := 0; // �� ������ �� "�����", �� "������"

          // ������ ��� ������ ���� ������ "�����"/"������" => �������� ������:
            if P1MoveButton = 1 then
              gPlayer1.PressKey(KEY_LEFT)
            else
            if P1MoveButton = 2 then
              gPlayer1.PressKey(KEY_RIGHT);

          // ������ ���� ������ "������", � ������ "�����" => ����� ������, ������� �����:
            if (P1MoveButton = 2) and e_KeyPressed(KeyLeft) then
              gPlayer1.SetDirection(D_LEFT)
            else
            // ������ ���� ������ "�����", � ������ "������" => ����� �����, ������� ������:
              if (P1MoveButton = 1) and e_KeyPressed(KeyRight) then
                gPlayer1.SetDirection(D_RIGHT)
              else
              // ���-�� ���� ������ � �� ���������� => ���� �����, ���� � �������:
                if P1MoveButton <> 0 then
                  gPlayer1.SetDirection(TDirection(P1MoveButton-1));

          // ��������� �������:
            if e_KeyPressed(KeyJump) then gPlayer1.PressKey(KEY_JUMP);
            if e_KeyPressed(KeyUp) then gPlayer1.PressKey(KEY_UP);
            if e_KeyPressed(KeyDown) then gPlayer1.PressKey(KEY_DOWN);
            if e_KeyPressed(KeyFire) then gPlayer1.PressKey(KEY_FIRE);
            if e_KeyPressed(KeyNextWeapon) then gPlayer1.PressKey(KEY_NEXTWEAPON);
            if e_KeyPressed(KeyPrevWeapon) then gPlayer1.PressKey(KEY_PREVWEAPON);
            if e_KeyPressed(KeyOpen) then gPlayer1.PressKey(KEY_OPEN);
          end;
      // ������ �����:
        if gPlayer2 <> nil then
          with gGameControls.P2Control do
          begin
            if e_KeyPressed(KeyLeft) and (not e_KeyPressed(KeyRight)) then
              P2MoveButton := 1 // ������ ������ "�����"
            else
              if (not e_KeyPressed(KeyLeft)) and e_KeyPressed(KeyRight) then
                P2MoveButton := 2 // ������ ������ "������"
              else
                if (not e_KeyPressed(KeyLeft)) and (not e_KeyPressed(KeyRight)) then
                  P2MoveButton := 0; // �� ������ �� "�����", �� "������"

          // ������ ��� ������ ���� ������ "�����"/"������" => �������� ������:
            if P2MoveButton = 1 then
              gPlayer2.PressKey(KEY_LEFT, 1000)
            else
              if P2MoveButton = 2 then
                gPlayer2.PressKey(KEY_RIGHT, 1000);

          // ������ ���� ������ "������", � ������ "�����" => ����� ������, ������� �����:
            if (P2MoveButton = 2) and e_KeyPressed(KeyLeft) then
              gPlayer2.SetDirection(D_LEFT)
            else
            // ������ ���� ������ "�����", � ������ "������" => ����� �����, ������� ������:
              if (P2MoveButton = 1) and e_KeyPressed(KeyRight) then
                gPlayer2.SetDirection(D_RIGHT)
              else
              // ���-�� ���� ������ � �� ���������� => ���� �����, ���� � �������:
                if P2MoveButton <> 0 then
                  gPlayer2.SetDirection(TDirection(P2MoveButton-1));

          // ��������� �������:
            if e_KeyPressed(KeyJump) then gPlayer2.PressKey(KEY_JUMP, 1000);
            if e_KeyPressed(KeyUp) then gPlayer2.PressKey(KEY_UP, 1000);
            if e_KeyPressed(KeyDown) then gPlayer2.PressKey(KEY_DOWN, 1000);
            if e_KeyPressed(KeyFire) then gPlayer2.PressKey(KEY_FIRE);
            if e_KeyPressed(KeyNextWeapon) then gPlayer2.PressKey(KEY_NEXTWEAPON);
            if e_KeyPressed(KeyPrevWeapon) then gPlayer2.PressKey(KEY_PREVWEAPON);
            if e_KeyPressed(KeyOpen) then gPlayer2.PressKey(KEY_OPEN);
          end;
      end  // if not console
      else
        if g_Game_IsNet and (gPlayer1 <> nil) then
          gPlayer1.PressKey(KEY_CHAT, 10000);

    end; // if server

  // �����������
    if (gPlayer1 = nil) and (gPlayer2 = nil) and
       (not gConsoleShow) and (not gChatShow) and (g_ActiveWindow = nil) then
    begin
      if not gSpectKeyPress then
      begin
        if e_KeyPressed(gGameControls.P1Control.KeyJump) then
        begin
          // switch spect mode
          case gSpectMode of
            SPECT_NONE: ; // not spectator
            SPECT_STATS,
            SPECT_MAPVIEW: Inc(gSpectMode);
            SPECT_PLAYERS: gSpectMode := SPECT_STATS; // reset to 1
          end;
          gSpectKeyPress := True;
        end;
        if gSpectMode = SPECT_MAPVIEW then
        begin
          if e_KeyPressed(gGameControls.P1Control.KeyLeft) then
            gSpectX := Max(gSpectX - gSpectStep, 0);
          if e_KeyPressed(gGameControls.P1Control.KeyRight) then
            gSpectX := Min(gSpectX + gSpectStep, gMapInfo.Width - gScreenWidth);
          if e_KeyPressed(gGameControls.P1Control.KeyUp) then
            gSpectY := Max(gSpectY - gSpectStep, 0);
          if e_KeyPressed(gGameControls.P1Control.KeyDown) then
            gSpectY := Min(gSpectY + gSpectStep, gMapInfo.Height - gScreenHeight);
          if e_KeyPressed(gGameControls.P1Control.KeyPrevWeapon) then
          begin
            // decrease step
            if gSpectStep > 4 then gSpectStep := gSpectStep shr 1;
            gSpectKeyPress := True;
          end;
          if e_KeyPressed(gGameControls.P1Control.KeyNextWeapon) then
          begin
            // increase step
            if gSpectStep < 64 then gSpectStep := gSpectStep shl 1;
            gSpectKeyPress := True;
          end;
        end;
        if gSpectMode = SPECT_PLAYERS then
        begin
          if e_KeyPressed(gGameControls.P1Control.KeyUp) then
          begin
            // add second view
            gSpectViewTwo := True;
            gSpectKeyPress := True;
          end;
          if e_KeyPressed(gGameControls.P1Control.KeyDown) then
          begin
            // remove second view
            gSpectViewTwo := False;
            gSpectKeyPress := True;
          end;
          if e_KeyPressed(gGameControls.P1Control.KeyLeft) then
          begin
            // prev player (view 1)
            gSpectPID1 := GetActivePlayerID_Prev(gSpectPID1);
            gSpectKeyPress := True;
          end;
          if e_KeyPressed(gGameControls.P1Control.KeyRight) then
          begin
            // next player (view 1)
            gSpectPID1 := GetActivePlayerID_Next(gSpectPID1);
            gSpectKeyPress := True;
          end;
          if e_KeyPressed(gGameControls.P1Control.KeyPrevWeapon) then
          begin
            // prev player (view 2)
            gSpectPID2 := GetActivePlayerID_Prev(gSpectPID2);
            gSpectKeyPress := True;
          end;
          if e_KeyPressed(gGameControls.P1Control.KeyNextWeapon) then
          begin
            // next player (view 2)
            gSpectPID2 := GetActivePlayerID_Next(gSpectPID2);
            gSpectKeyPress := True;
          end;
        end;
      end
      else
        if (not e_KeyPressed(gGameControls.P1Control.KeyJump)) and
           (not e_KeyPressed(gGameControls.P1Control.KeyLeft)) and
           (not e_KeyPressed(gGameControls.P1Control.KeyRight)) and
           (not e_KeyPressed(gGameControls.P1Control.KeyUp)) and
           (not e_KeyPressed(gGameControls.P1Control.KeyDown)) and
           (not e_KeyPressed(gGameControls.P1Control.KeyPrevWeapon)) and
           (not e_KeyPressed(gGameControls.P1Control.KeyNextWeapon)) then
          gSpectKeyPress := False;
    end;

  // ��������� ��� ���������:
    g_Map_Update();
    g_Items_Update();
    g_Triggers_Update();
    g_Weapon_Update();
    g_Monsters_Update();
    g_GFX_Update();
    g_Player_UpdateAll();
    g_Player_UpdatePhysicalObjects();
    if gGameSettings.GameType = GT_SERVER then
      if Length(gMonstersSpawned) > 0 then
      begin
        for I := 0 to High(gMonstersSpawned) do
          MH_SEND_MonsterSpawn(gMonstersSpawned[I]);
        SetLength(gMonstersSpawned, 0);
      end;

    if (gSoundTriggerTime > 8) then
    begin
      g_Game_UpdateTriggerSounds();
      gSoundTriggerTime := 0;
    end
    else
      Inc(gSoundTriggerTime);

    if (NetMode = NET_SERVER) then
    begin
      Inc(NetTimeToUpdate);
      Inc(NetTimeToReliable);
      if NetTimeToReliable >= NetRelupdRate then
      begin
        for I := 0 to High(gPlayers) do
          if gPlayers[I] <> nil then
            MH_SEND_PlayerPos(True, gPlayers[I].UID);

        if gMonsters <> nil then
          for I := 0 to High(gMonsters) do
            if gMonsters[I] <> nil then
            begin
              if (gMonsters[I].MonsterType = MONSTER_BARREL) then
              begin
                if (gMonsters[I].GameVelX <> 0) or (gMonsters[I].GameVelY <> 0) then
                  MH_SEND_MonsterPos(gMonsters[I].UID);
              end
              else
                if (gMonsters[I].MonsterState <> MONSTATE_SLEEP) then
                  if (gMonsters[I].MonsterState <> MONSTATE_DEAD) or
                     (gMonsters[I].GameVelX <> 0) or
                     (gMonsters[I].GameVelY <> 0) then
                  MH_SEND_MonsterPos(gMonsters[I].UID);
            end;

        NetTimeToReliable := 0;
        NetTimeToUpdate := NetUpdateRate;
      end
      else if NetTimeToUpdate >= NetUpdateRate then
      begin
        if gPlayers <> nil then
          for I := 0 to High(gPlayers) do
            if gPlayers[I] <> nil then
              MH_SEND_PlayerPos(False, gPlayers[I].UID);

        if gMonsters <> nil then
          for I := 0 to High(gMonsters) do
            if gMonsters[I] <> nil then
            begin
              if (gMonsters[I].MonsterType = MONSTER_BARREL) then
              begin
                if (gMonsters[I].GameVelX <> 0) or (gMonsters[I].GameVelY <> 0) then
                  MH_SEND_MonsterPos(gMonsters[I].UID);
              end
              else
                if (gMonsters[I].MonsterState <> MONSTATE_SLEEP) then
                  if (gMonsters[I].MonsterState <> MONSTATE_DEAD) or
                     (gMonsters[I].GameVelX <> 0) or
                     (gMonsters[I].GameVelY <> 0) then
                  MH_SEND_MonsterPos(gMonsters[I].UID);
            end;

        NetTimeToUpdate := 0;
      end;

      if NetUseMaster then
        if gTime >= NetTimeToMaster then
        begin
          if (NetMHost = nil) or (NetMPeer = nil) then
            if not g_Net_Slist_Connect then
              g_Console_Add(_lc[I_NET_MSG_ERROR] + _lc[I_NET_SLIST_ERROR]);

          g_Net_Slist_Update;
          NetTimeToMaster := gTime + NetMasterRate;
        end;
    end
    else
      if NetMode = NET_CLIENT then
        MC_SEND_PlayerPos();
  end; // if gameOn ...

// ������� ���� ���������� - �������� ������� ���:
  if g_ActiveWindow <> nil then
  begin
    w := e_GetFirstKeyPressed();

    if (w <> e_WrongKey) then
      begin
        Msg.Msg := MESSAGE_DIKEY;
        Msg.wParam := w;
        g_ActiveWindow.OnMessage(Msg);
      end;

  // ���� ��� �� ����� �� ���������, �� ���������:
    if g_ActiveWindow <> nil then
      g_ActiveWindow.Update();

  // ����� ������� ����������:
    if gResolutionChange then
    begin
      e_WriteLog('Changing resolution', MSG_NOTIFY);
      g_Game_ChangeResolution(gRC_Width, gRC_Height, gRC_FullScreen, gRC_Maximized);
      gResolutionChange := False;
    end;

  // ����� ������� ����:
    if gLanguageChange then
    begin
      //e_WriteLog('Read language file', MSG_NOTIFY);
      //g_Language_Load(DataDir + gLanguage + '.txt');
      g_Language_Set(gLanguage);
      g_Menu_Reset();
      gLanguageChange := False;
    end;
  end;

// ������ �������� (�� ���� 200 �����������):
  if e_KeyPressed(gGameControls.GameControls.TakeScreenshot) then
    if (GetTimer()-LastScreenShot) > 200000 then
    begin
      g_TakeScreenShot();
      LastScreenShot := GetTimer();
    end;

// ������� ������� ��� ������ ���� ������ �� ���� (F10):
  if e_KeyPressed(DIK_F10) and
     gGameOn and
     (not gConsoleShow) and
     (g_ActiveWindow = nil) then
  begin
    KeyPress(VK_F10);
  end;

  Time := GetTimer() div 1000;

// ��������� ���������� �������:
  if gDelayedEvents <> nil then
    for a := 0 to High(gDelayedEvents) do
      if gDelayedEvents[a].Pending and
      (
        ((gDelayedEvents[a].DEType = DE_GLOBEVENT) and (gDelayedEvents[a].Time <= Time)) or
        ((gDelayedEvents[a].DEType > DE_GLOBEVENT) and (gDelayedEvents[a].Time <= gTime))
      ) then
      begin
        case gDelayedEvents[a].DEType of
          DE_GLOBEVENT:
            g_Game_ExecuteEvent(gDelayedEvents[a].DEStr);
          DE_BFGHIT:
            if gGameOn then
              g_Game_Announce_GoodShot(gDelayedEvents[a].DENum);
          DE_KILLCOMBO:
            if gGameOn then
            begin
              g_Game_Announce_KillCombo(gDelayedEvents[a].DENum);
              if g_Game_IsNet and g_Game_IsServer then
                MH_SEND_GameEvent(NET_EV_KILLCOMBO, gDelayedEvents[a].DENum);
            end;
        end;
        gDelayedEvents[a].Pending := False;
      end;

// ������ ������� ��������� ������� ����������:
  UPSCounter := UPSCounter + 1;
  if Time - UPSTime >= 1000 then
  begin
    UPS := UPSCounter;
    UPSCounter := 0;
    UPSTime := Time;
  end;
end;

procedure g_Game_LoadData();
begin
  if DataLoaded then Exit;

  e_WriteLog('Loading game data...', MSG_NOTIFY);

  g_Texture_CreateWADEx('NOTEXTURE', GameWAD+':TEXTURES\NOTEXTURE');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_HUD', GameWAD+':TEXTURES\HUD');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_HUDAIR', GameWAD+':TEXTURES\AIRBAR');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_HUDJET', GameWAD+':TEXTURES\JETBAR');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_HUDBG', GameWAD+':TEXTURES\HUDBG');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_ARMORHUD', GameWAD+':TEXTURES\ARMORHUD');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_REDFLAG', GameWAD+':TEXTURES\FLAGHUD_RB');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_REDFLAG_S', GameWAD+':TEXTURES\FLAGHUD_RS');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_REDFLAG_D', GameWAD+':TEXTURES\FLAGHUD_RD');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_BLUEFLAG', GameWAD+':TEXTURES\FLAGHUD_BB');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_BLUEFLAG_S', GameWAD+':TEXTURES\FLAGHUD_BS');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_BLUEFLAG_D', GameWAD+':TEXTURES\FLAGHUD_BD');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_TALKBUBBLE', GameWAD+':TEXTURES\TALKBUBBLE');
  g_Texture_CreateWADEx('TEXTURE_PLAYER_INVULPENTA', GameWAD+':TEXTURES\PENTA');
  g_Frames_CreateWAD(nil, 'FRAMES_TELEPORT', GameWAD+':TEXTURES\TELEPORT', 64, 64, 10, False);
  g_Sound_CreateWADEx('SOUND_GAME_TELEPORT', GameWAD+':SOUNDS\TELEPORT');
  g_Sound_CreateWADEx('SOUND_GAME_NOTELEPORT', GameWAD+':SOUNDS\NOTELEPORT');
  g_Sound_CreateWADEx('SOUND_GAME_DOOROPEN', GameWAD+':SOUNDS\DOOROPEN');
  g_Sound_CreateWADEx('SOUND_GAME_DOORCLOSE', GameWAD+':SOUNDS\DOORCLOSE');
  g_Sound_CreateWADEx('SOUND_GAME_BULK1', GameWAD+':SOUNDS\BULK1');
  g_Sound_CreateWADEx('SOUND_GAME_BULK2', GameWAD+':SOUNDS\BULK2');
  g_Sound_CreateWADEx('SOUND_GAME_BUBBLE1', GameWAD+':SOUNDS\BUBBLE1');
  g_Sound_CreateWADEx('SOUND_GAME_BUBBLE2', GameWAD+':SOUNDS\BUBBLE2');
  g_Sound_CreateWADEx('SOUND_GAME_SWITCH1', GameWAD+':SOUNDS\SWITCH1');
  g_Sound_CreateWADEx('SOUND_GAME_SWITCH0', GameWAD+':SOUNDS\SWITCH0');
  g_Sound_CreateWADEx('SOUND_GAME_RADIO', GameWAD+':SOUNDS\RADIO');
  g_Sound_CreateWADEx('SOUND_ANNOUNCER_GOOD1', GameWAD+':SOUNDS\GOOD1');
  g_Sound_CreateWADEx('SOUND_ANNOUNCER_GOOD2', GameWAD+':SOUNDS\GOOD2');
  g_Sound_CreateWADEx('SOUND_ANNOUNCER_GOOD3', GameWAD+':SOUNDS\GOOD3');
  g_Sound_CreateWADEx('SOUND_ANNOUNCER_GOOD4', GameWAD+':SOUNDS\GOOD4');
  g_Sound_CreateWADEx('SOUND_ANNOUNCER_KILL2X', GameWAD+':SOUNDS\KILL2X');
  g_Sound_CreateWADEx('SOUND_ANNOUNCER_KILL3X', GameWAD+':SOUNDS\KILL3X');
  g_Sound_CreateWADEx('SOUND_ANNOUNCER_KILL4X', GameWAD+':SOUNDS\KILL4X');
  g_Sound_CreateWADEx('SOUND_ANNOUNCER_KILLMX', GameWAD+':SOUNDS\KILLMX');

  goodsnd[0] := TPlayableSound.Create();
  goodsnd[1] := TPlayableSound.Create();
  goodsnd[2] := TPlayableSound.Create();
  goodsnd[3] := TPlayableSound.Create();

  goodsnd[0].SetByName('SOUND_ANNOUNCER_GOOD1');
  goodsnd[1].SetByName('SOUND_ANNOUNCER_GOOD2');
  goodsnd[2].SetByName('SOUND_ANNOUNCER_GOOD3');
  goodsnd[3].SetByName('SOUND_ANNOUNCER_GOOD4');

  killsnd[0] := TPlayableSound.Create();
  killsnd[1] := TPlayableSound.Create();
  killsnd[2] := TPlayableSound.Create();
  killsnd[3] := TPlayableSound.Create();

  killsnd[0].SetByName('SOUND_ANNOUNCER_KILL2X');
  killsnd[1].SetByName('SOUND_ANNOUNCER_KILL3X');
  killsnd[2].SetByName('SOUND_ANNOUNCER_KILL4X');
  killsnd[3].SetByName('SOUND_ANNOUNCER_KILLMX');

  g_Game_SetLoadingText(_lc[I_LOAD_ITEMS_DATA], 0, False);
  g_Items_LoadData();

  g_Game_SetLoadingText(_lc[I_LOAD_WEAPONS_DATA], 0, False);
  g_Weapon_LoadData();

  g_Monsters_LoadData();

  DataLoaded := True;
end;

procedure g_Game_FreeData();
begin
  if not DataLoaded then Exit;

  g_Items_FreeData();
  g_Weapon_FreeData();
  g_Monsters_FreeData();

  e_WriteLog('Releasing game data...', MSG_NOTIFY);

  g_Texture_Delete('NOTEXTURE');
  g_Texture_Delete('TEXTURE_PLAYER_HUD');
  g_Texture_Delete('TEXTURE_PLAYER_HUDBG');
  g_Texture_Delete('TEXTURE_PLAYER_ARMORHUD');
  g_Texture_Delete('TEXTURE_PLAYER_REDFLAG');
  g_Texture_Delete('TEXTURE_PLAYER_REDFLAG_S');
  g_Texture_Delete('TEXTURE_PLAYER_REDFLAG_D');
  g_Texture_Delete('TEXTURE_PLAYER_BLUEFLAG');
  g_Texture_Delete('TEXTURE_PLAYER_BLUEFLAG_S');
  g_Texture_Delete('TEXTURE_PLAYER_BLUEFLAG_D');
  g_Texture_Delete('TEXTURE_PLAYER_TALKBUBBLE');
  g_Texture_Delete('TEXTURE_PLAYER_INVULPENTA');
  g_Frames_DeleteByName('FRAMES_TELEPORT');
  g_Sound_Delete('SOUND_GAME_TELEPORT');
  g_Sound_Delete('SOUND_GAME_NOTELEPORT');
  g_Sound_Delete('SOUND_GAME_DOOROPEN');
  g_Sound_Delete('SOUND_GAME_DOORCLOSE');
  g_Sound_Delete('SOUND_GAME_BULK1');
  g_Sound_Delete('SOUND_GAME_BULK2');
  g_Sound_Delete('SOUND_GAME_BUBBLE1');
  g_Sound_Delete('SOUND_GAME_BUBBLE2');
  g_Sound_Delete('SOUND_GAME_SWITCH1');
  g_Sound_Delete('SOUND_GAME_SWITCH0');

  goodsnd[0].Free();
  goodsnd[1].Free();
  goodsnd[2].Free();
  goodsnd[3].Free();

  g_Sound_Delete('SOUND_ANNOUNCER_GOOD1');
  g_Sound_Delete('SOUND_ANNOUNCER_GOOD2');
  g_Sound_Delete('SOUND_ANNOUNCER_GOOD3');
  g_Sound_Delete('SOUND_ANNOUNCER_GOOD4');

  killsnd[0].Free();
  killsnd[1].Free();
  killsnd[2].Free();
  killsnd[3].Free();

  g_Sound_Delete('SOUND_ANNOUNCER_KILL2X');
  g_Sound_Delete('SOUND_ANNOUNCER_KILL3X');
  g_Sound_Delete('SOUND_ANNOUNCER_KILL4X');
  g_Sound_Delete('SOUND_ANNOUNCER_KILLMX');

  DataLoaded := False;
end;

procedure DrawCustomStat();
var
  pc, x, y, w, _y,
  w1, w2, w3,
  t, p, m: Integer;
  ww1, hh1: Word;
  ww2, hh2, r, g, b, rr, gg, bb: Byte;
  s1, s2, topstr: String;
begin
  e_TextureFontGetSize(gStdFont, ww2, hh2);

  e_PollInput();
  if e_KeyPressed(e_IKey_Tab) then
  begin
    if not gStatsPressed then
    begin
      gStatsOff := not gStatsOff;
      gStatsPressed := True;
    end;
  end
  else
    gStatsPressed := False;

  if gStatsOff then
  begin
    s1 := _lc[I_MENU_INTER_NOTICE_TAB];
    w := (Length(s1) * ww2) div 2;
    x := gScreenWidth div 2 - w;
    y := 8;
    e_TextureFontPrint(x, y, s1, gStdFont);
    Exit;
  end;

  if (gGameSettings.GameMode = GM_COOP) then
  begin
    if gMissionFailed then
      topstr := _lc[I_MENU_INTER_MISSION_FAIL]
    else
      topstr := _lc[I_MENU_INTER_LEVEL_COMPLETE];
  end
  else
    topstr := _lc[I_MENU_INTER_ROUND_OVER];

  e_CharFont_GetSize(gMenuFont, topstr, ww1, hh1);
  e_CharFont_Print(gMenuFont, (gScreenWidth div 2)-(ww1 div 2), 16, topstr);

  if g_Game_IsNet then
  begin
    topstr := Format(_lc[I_MENU_INTER_NOTICE_TIME], [gServInterTime]);
    if not gChatShow then
      e_TextureFontPrintEx((gScreenWidth div 2)-(Length(topstr)*ww2 div 2),
                           gScreenHeight-(hh2+4)*2, topstr, gStdFont, 255, 255, 255, 1);
  end;

  if g_Game_IsClient then
    topstr := _lc[I_MENU_INTER_NOTICE_MAP]
  else
    topstr := _lc[I_MENU_INTER_NOTICE_SPACE];
  if not gChatShow then
    e_TextureFontPrintEx((gScreenWidth div 2)-(Length(topstr)*ww2 div 2),
                         gScreenHeight-(hh2+4), topstr, gStdFont, 255, 255, 255, 1);

  x := 32;
  y := 16+hh1+16;

  w := gScreenWidth-x*2;

  w2 := (w-16) div 6;
  w3 := w2;
  w1 := w-16-w2-w3;

  e_DrawFillQuad(x, y, gScreenWidth-x-1, gScreenHeight-y-1, 64, 64, 64, 32);
  e_DrawQuad(x, y, gScreenWidth-x-1, gScreenHeight-y-1, 255, 127, 0);

  m := Max(Length(_lc[I_MENU_MAP])+1, Length(_lc[I_GAME_GAME_TIME])+1)*ww2;

  case CustomStat.GameMode of
    GM_DM:
    begin
      if gGameSettings.MaxLives = 0 then
        s1 := _lc[I_GAME_DM]
      else
        s1 := _lc[I_GAME_LMS];
    end;
    GM_TDM:
    begin
      if gGameSettings.MaxLives = 0 then
        s1 := _lc[I_GAME_TDM]
      else
        s1 := _lc[I_GAME_TLMS];
    end;
    GM_CTF: s1 := _lc[I_GAME_CTF];
    GM_COOP:
    begin
      if gGameSettings.MaxLives = 0 then
        s1 := _lc[I_GAME_COOP]
      else
        s1 := _lc[I_GAME_SURV];
    end;
    else s1 := '';
  end;

  _y := y+16;
  e_TextureFontPrintEx(x+(w div 2)-(Length(s1)*ww2 div 2), _y, s1, gStdFont, 255, 255, 255, 1);
  _y := _y+8;

  _y := _y+16;
  e_TextureFontPrintEx(x+8, _y, _lc[I_MENU_MAP], gStdFont, 255, 127, 0, 1);
  e_TextureFontPrint(x+8+m, _y, Format('%s - %s', [CustomStat.Map, CustomStat.MapName]), gStdFont);

  _y := _y+16;
  e_TextureFontPrintEx(x+8, _y, _lc[I_GAME_GAME_TIME], gStdFont, 255, 127, 0, 1);
  e_TextureFontPrint(x+8+m, _y, Format('%d:%.2d:%.2d', [CustomStat.GameTime div 1000 div 3600,
                                                       (CustomStat.GameTime div 1000 div 60) mod 60,
                                                        CustomStat.GameTime div 1000 mod 60]), gStdFont);

  pc := Length(CustomStat.PlayerStat);
  if pc = 0 then Exit;

  if CustomStat.GameMode = GM_COOP then
  begin
    m := Max(Length(_lc[I_GAME_MONSTERS])+1, Length(_lc[I_GAME_SECRETS])+1)*ww2;
    _y := _y+32;
    s2 := _lc[I_GAME_MONSTERS];
    e_TextureFontPrintEx(x+8, _y, s2, gStdFont, 255, 127, 0, 1);
    e_TextureFontPrintEx(x+8+m, _y, IntToStr(gCoopMonstersKilled) + '/' + IntToStr(gTotalMonsters), gStdFont, 255, 255, 255, 1);
    _y := _y+16;
    s2 := _lc[I_GAME_SECRETS];
    e_TextureFontPrintEx(x+8, _y, s2, gStdFont, 255, 127, 0, 1);
    e_TextureFontPrintEx(x+8+m, _y, IntToStr(gCoopSecretsFound) + '/' + IntToStr(gSecretsCount), gStdFont, 255, 255, 255, 1);
    if gLastMap then
    begin
      m := Max(Length(_lc[I_GAME_MONSTERS_TOTAL])+1, Length(_lc[I_GAME_SECRETS_TOTAL])+1)*ww2;
      _y := _y-16;
      s2 := _lc[I_GAME_MONSTERS_TOTAL];
      e_TextureFontPrintEx(x+250, _y, s2, gStdFont, 255, 127, 0, 1);
      e_TextureFontPrintEx(x+250+m, _y, IntToStr(gCoopTotalMonstersKilled) + '/' + IntToStr(gCoopTotalMonsters), gStdFont, 255, 255, 255, 1);
      _y := _y+16;
      s2 := _lc[I_GAME_SECRETS_TOTAL];
      e_TextureFontPrintEx(x+250, _y, s2, gStdFont, 255, 127, 0, 1);
      e_TextureFontPrintEx(x+250+m, _y, IntToStr(gCoopTotalSecretsFound) + '/' + IntToStr(gCoopTotalSecrets), gStdFont, 255, 255,  255, 1);
    end;
  end;

  if CustomStat.GameMode in [GM_TDM, GM_CTF] then
  begin
    _y := _y+16+16;

    with CustomStat do
      if TeamStat[TEAM_RED].Goals > TeamStat[TEAM_BLUE].Goals then s1 := _lc[I_GAME_WIN_RED]
        else if TeamStat[TEAM_BLUE].Goals > TeamStat[TEAM_RED].Goals then s1 := _lc[I_GAME_WIN_BLUE]
          else s1 := _lc[I_GAME_WIN_DRAW];

    e_TextureFontPrintEx(x+8+(w div 2)-(Length(s1)*ww2 div 2), _y, s1, gStdFont, 255, 255, 255, 1);
    _y := _y+40;

    for t := TEAM_RED to TEAM_BLUE do
    begin
      if t = TEAM_RED then
      begin
        e_TextureFontPrintEx(x+8, _y, _lc[I_GAME_TEAM_RED],
                             gStdFont, 255, 0, 0, 1);
        e_TextureFontPrintEx(x+w1+8, _y, IntToStr(CustomStat.TeamStat[TEAM_RED].Goals),
                             gStdFont, 255, 0, 0, 1);
        r := 255;
        g := 0;
        b := 0;
      end
      else
      begin
        e_TextureFontPrintEx(x+8, _y, _lc[I_GAME_TEAM_BLUE],
                             gStdFont, 0, 0, 255, 1);
        e_TextureFontPrintEx(x+w1+8, _y, IntToStr(CustomStat.TeamStat[TEAM_BLUE].Goals),
                             gStdFont, 0, 0, 255, 1);
        r := 0;
        g := 0;
        b := 255;
      end;

      e_DrawLine(1, x+8, _y+20, x-8+w, _y+20, r, g, b);
      _y := _y+24;

      for p := 0 to High(CustomStat.PlayerStat) do
        if CustomStat.PlayerStat[p].Team = t then
          with CustomStat.PlayerStat[p] do
          begin
            if Spectator then
            begin
              rr := r div 2;
              gg := g div 2;
              bb := b div 2;
            end
            else
            begin
              rr := r;
              gg := g;
              bb := b;
            end;
            e_TextureFontPrintEx(x+8, _y, Name, gStdFont, rr, gg, bb, 1);
            e_TextureFontPrintEx(x+w1+8, _y, IntToStr(Frags), gStdFont, rr, gg, bb, 1);
            e_TextureFontPrintEx(x+w1+w2+8, _y, IntToStr(Deaths), gStdFont, rr, gg, bb, 1);
            _y := _y+24;
          end;

      _y := _y+16+16;
    end;
  end
  else if CustomStat.GameMode in [GM_DM, GM_COOP] then
  begin
    _y := _y+40;
    e_TextureFontPrintEx(x+8, _y, _lc[I_GAME_PLAYER_NAME], gStdFont, 255, 127, 0, 1);
    e_TextureFontPrintEx(x+8+w1, _y, _lc[I_GAME_FRAGS], gStdFont, 255, 127, 0, 1);
    e_TextureFontPrintEx(x+8+w1+w2, _y, _lc[I_GAME_DEATHS], gStdFont, 255, 127, 0, 1);

    _y := _y+24;
    for p := 0 to High(CustomStat.PlayerStat) do
      with CustomStat.PlayerStat[p] do
      begin
        e_DrawFillQuad(x+8, _y+4, x+24-1, _y+16+4-1, Color.R, Color.G, Color.B, 0);

        if Spectator then
          r := 127
        else
          r := 255;

        e_TextureFontPrintEx(x+8+16+8, _y+4, Name, gStdFont, r, r, r, 1, True);
        e_TextureFontPrintEx(x+w1+8+16+8, _y+4, IntToStr(Frags), gStdFont, r, r, r, 1, True);
        e_TextureFontPrintEx(x+w1+w2+8+16+8, _y+4, IntToStr(Deaths), gStdFont, r, r, r, 1, True);
        _y := _y+24;
      end;
  end;
end;

procedure DrawSingleStat();
var
  tm, key_x, val_x, y: Integer;
  w1, w2, h: Word;
  s1, s2: String;

  procedure player_stat(n: Integer);
  var
    kpm: Real;

  begin
  // "Kills: # / #":
    s1 := Format(' %d ', [SingleStat.PlayerStat[n].Kills]);
    s2 := Format(' %d', [gTotalMonsters]);

    e_CharFont_Print(gMenuFont, key_x, y, _lc[I_MENU_INTER_KILLS]);
    e_CharFont_PrintEx(gMenuFont, val_x, y, s1, _RGB(255, 0, 0));
    e_CharFont_GetSize(gMenuFont, s1, w1, h);
    e_CharFont_Print(gMenuFont, val_x+w1, y, '/');
    s1 := s1 + '/';
    e_CharFont_GetSize(gMenuFont, s1, w1, h);
    e_CharFont_PrintEx(gMenuFont, val_x+w1, y, s2, _RGB(255, 0, 0));

  // "Kills-per-minute: ##.#":
    s1 := _lc[I_MENU_INTER_KPM];
    if tm > 0 then
      kpm := (SingleStat.PlayerStat[n].Kills / tm) * 60
    else
      kpm := SingleStat.PlayerStat[n].Kills;
    s2 := Format(' %.1f', [kpm]);

    e_CharFont_Print(gMenuFont, key_x, y+32, s1);
    e_CharFont_PrintEx(gMenuFont, val_x, y+32, s2, _RGB(255, 0, 0));

  // "Secrets found: # / #":
    s1 := Format(' %d ', [SingleStat.PlayerStat[n].Secrets]);
    s2 := Format(' %d', [SingleStat.TotalSecrets]);

    e_CharFont_Print(gMenuFont, key_x, y+64, _lc[I_MENU_INTER_SECRETS]);
    e_CharFont_PrintEx(gMenuFont, val_x, y+64, s1, _RGB(255, 0, 0));
    e_CharFont_GetSize(gMenuFont, s1, w1, h);
    e_CharFont_Print(gMenuFont, val_x+w1, y+64, '/');
    s1 := s1 + '/';
    e_CharFont_GetSize(gMenuFont, s1, w1, h);
    e_CharFont_PrintEx(gMenuFont, val_x+w1, y+64, s2, _RGB(255, 0, 0));
  end;

begin
// "Level Complete":
  e_CharFont_GetSize(gMenuFont, _lc[I_MENU_INTER_LEVEL_COMPLETE], w1, h);
  e_CharFont_Print(gMenuFont, (gScreenWidth-w1) div 2, 32, _lc[I_MENU_INTER_LEVEL_COMPLETE]);

// ���������� ���������� ������������ �� ����� ������� ������:
  s1 := _lc[I_MENU_INTER_KPM];
  e_CharFont_GetSize(gMenuFont, s1, w1, h);
  Inc(w1, 16);
  s1 := ' 9999.9';
  e_CharFont_GetSize(gMenuFont, s1, w2, h);

  key_x := (gScreenWidth-w1-w2) div 2;
  val_x := key_x + w1;

// "Time: #:##:##":
  tm := SingleStat.GameTime div 1000;
  s1 := _lc[I_MENU_INTER_TIME];
  s2 := Format(' %d:%.2d:%.2d', [tm div (60*60), (tm mod (60*60)) div 60, tm mod 60]);

  e_CharFont_Print(gMenuFont, key_x, 80, s1);
  e_CharFont_PrintEx(gMenuFont, val_x, 80, s2, _RGB(255, 0, 0));

  if SingleStat.TwoPlayers then
    begin
    // "Player 1":
      s1 := _lc[I_MENU_PLAYER_1];
      e_CharFont_GetSize(gMenuFont, s1, w1, h);
      e_CharFont_Print(gMenuFont, (gScreenWidth-w1) div 2, 128, s1);

    // ���������� ������� ������:
      y := 176;
      player_stat(0);

    // "Player 2":
      s1 := _lc[I_MENU_PLAYER_2];
      e_CharFont_GetSize(gMenuFont, s1, w1, h);
      e_CharFont_Print(gMenuFont, (gScreenWidth-w1) div 2, 288, s1);

    // ���������� ������� ������:
      y := 336;
      player_stat(1);
    end
  else
    begin
    // ���������� ������� ������:
      y := 128;
      player_stat(0);
    end;
end;

procedure DrawLoadingStat();
var
  ww, hh: Word;
  xx, yy, i: Integer;
  s: String;
begin
  if Length(LoadingStat.Msgs) = 0 then
    Exit;

  e_CharFont_GetSize(gMenuFont, _lc[I_MENU_LOADING], ww, hh);
  yy := (gScreenHeight div 3);
  e_CharFont_Print(gMenuFont, (gScreenWidth div 2)-(ww div 2), yy-2*hh, _lc[I_MENU_LOADING]);
  xx := (gScreenWidth div 3);

  with LoadingStat do
    for i := 0 to NextMsg-1 do
      begin
        if (i = (NextMsg-1)) and (MaxValue > 0) then
          s := Format('%s:  %d/%d', [Msgs[i], CurValue, MaxValue])
        else
          s := Msgs[i];

        e_CharFont_PrintEx(gMenuSmallFont, xx, yy, s, _RGB(255, 0, 0));
        yy := yy + LOADING_INTERLINE;
      end;
end;

procedure DrawMinimap(p: TPlayer; RenderRect: TRect);
var
  a, aX, aY, aX2, aY2, Scale, ScaleSz: Integer;
begin
  if (gMapInfo.Width > RenderRect.Right - RenderRect.Left) or
     (gMapInfo.Height > RenderRect.Bottom - RenderRect.Top) then
  begin
    Scale := 1;
  // ������� �������� ����� � 1 ������� ����-�����:
    ScaleSz := 16 div Scale;
  // ������� ����-�����:
    aX := max(gMapInfo.Width div ScaleSz, 1);
    aY := max(gMapInfo.Height div ScaleSz, 1);
  // ����� �����:
    e_DrawFillQuad(0, 0, aX-1, aY-1, 0, 0, 0, 0);

    if gWalls <> nil then
    begin
    // ������ �����:
      for a := 0 to High(gWalls) do
        with gWalls[a] do
          if PanelType <> 0 then
          begin
          // ����� ������� ����:
            aX := X div ScaleSz;
            aY := Y div ScaleSz;
          // �������:
            aX2 := max(Width div ScaleSz, 1);
            aY2 := max(Height div ScaleSz, 1);
          // ������ ������ ����:
            aX2 := aX + aX2 - 1;
            aY2 := aY + aY2 - 1;

            case PanelType of
              PANEL_WALL:      e_DrawFillQuad(aX, aY, aX2, aY2, 208, 208, 208, 0);
              PANEL_OPENDOOR, PANEL_CLOSEDOOR:
                if Enabled then e_DrawFillQuad(aX, aY, aX2, aY2, 160, 160, 160, 0);
            end;
          end;
    end;
    if gSteps <> nil then
    begin
    // ������ �������:
      for a := 0 to High(gSteps) do
        with gSteps[a] do
          if PanelType <> 0 then
          begin
          // ����� ������� ����:
            aX := X div ScaleSz;
            aY := Y div ScaleSz;
          // �������:
            aX2 := max(Width div ScaleSz, 1);
            aY2 := max(Height div ScaleSz, 1);
          // ������ ������ ����:
            aX2 := aX + aX2 - 1;
            aY2 := aY + aY2 - 1;

            e_DrawFillQuad(aX, aY, aX2, aY2, 128, 128, 128, 0);
          end;
    end;
    if gLifts <> nil then
    begin
    // ������ �����:
      for a := 0 to High(gLifts) do
        with gLifts[a] do
          if PanelType <> 0 then
          begin
          // ����� ������� ����:
            aX := X div ScaleSz;
            aY := Y div ScaleSz;
          // �������:
            aX2 := max(Width div ScaleSz, 1);
            aY2 := max(Height div ScaleSz, 1);
          // ������ ������ ����:
            aX2 := aX + aX2 - 1;
            aY2 := aY + aY2 - 1;

            case LiftType of
              0: e_DrawFillQuad(aX, aY, aX2, aY2, 116,  72,  36, 0);
              1: e_DrawFillQuad(aX, aY, aX2, aY2, 116, 124,  96, 0);
              2: e_DrawFillQuad(aX, aY, aX2, aY2, 200,  80,   4, 0);
              3: e_DrawFillQuad(aX, aY, aX2, aY2, 252, 140,  56, 0);
            end;
          end;
    end;
    if gWater <> nil then
    begin
    // ������ ����:
      for a := 0 to High(gWater) do
        with gWater[a] do
          if PanelType <> 0 then
          begin
          // ����� ������� ����:
            aX := X div ScaleSz;
            aY := Y div ScaleSz;
          // �������:
            aX2 := max(Width div ScaleSz, 1);
            aY2 := max(Height div ScaleSz, 1);
          // ������ ������ ����:
            aX2 := aX + aX2 - 1;
            aY2 := aY + aY2 - 1;

            e_DrawFillQuad(aX, aY, aX2, aY2, 0, 0, 192, 0);
          end;
    end;
    if gAcid1 <> nil then
    begin
    // ������ ������� 1:
      for a := 0 to High(gAcid1) do
        with gAcid1[a] do
          if PanelType <> 0 then
          begin
          // ����� ������� ����:
            aX := X div ScaleSz;
            aY := Y div ScaleSz;
          // �������:
            aX2 := max(Width div ScaleSz, 1);
            aY2 := max(Height div ScaleSz, 1);
          // ������ ������ ����:
            aX2 := aX + aX2 - 1;
            aY2 := aY + aY2 - 1;

            e_DrawFillQuad(aX, aY, aX2, aY2, 0, 176, 0, 0);
          end;
    end;
    if gAcid2 <> nil then
    begin
    // ������ ������� 2:
      for a := 0 to High(gAcid2) do
        with gAcid2[a] do
          if PanelType <> 0 then
          begin
          // ����� ������� ����:
            aX := X div ScaleSz;
            aY := Y div ScaleSz;
          // �������:
            aX2 := max(Width div ScaleSz, 1);
            aY2 := max(Height div ScaleSz, 1);
          // ������ ������ ����:
            aX2 := aX + aX2 - 1;
            aY2 := aY + aY2 - 1;

            e_DrawFillQuad(aX, aY, aX2, aY2, 176, 0, 0, 0);
          end;
    end;
    if gPlayers <> nil then
    begin
    // ������ �������:
      for a := 0 to High(gPlayers) do
        if gPlayers[a] <> nil then with gPlayers[a] do
          if Live then begin
          // ����� ������� ����:
            aX := Obj.X div ScaleSz + 1;
            aY := Obj.Y div ScaleSz + 1;
          // �������:
            aX2 := max(Obj.Rect.Width div ScaleSz, 1);
            aY2 := max(Obj.Rect.Height div ScaleSz, 1);
          // ������ ������ ����:
            aX2 := aX + aX2 - 1;
            aY2 := aY + aY2 - 1;

            if gPlayers[a] = p then
              e_DrawFillQuad(aX, aY, aX2, aY2, 0, 255, 0, 0)
            else
              case Team of
                TEAM_RED:  e_DrawFillQuad(aX, aY, aX2, aY2, 255,   0,   0, 0);
                TEAM_BLUE: e_DrawFillQuad(aX, aY, aX2, aY2, 0,     0, 255, 0);
                else       e_DrawFillQuad(aX, aY, aX2, aY2, 255, 128,   0, 0);
              end;
          end;
    end;
    if gMonsters <> nil then
    begin
    // ������ ��������:
      for a := 0 to High(gMonsters) do
        if gMonsters[a] <> nil then with gMonsters[a] do
          if Live then begin
          // ����� ������� ����:
            aX := Obj.X div ScaleSz + 1;
            aY := Obj.Y div ScaleSz + 1;
          // �������:
            aX2 := max(Obj.Rect.Width div ScaleSz, 1);
            aY2 := max(Obj.Rect.Height div ScaleSz, 1);
          // ������ ������ ����:
            aX2 := aX + aX2 - 1;
            aY2 := aY + aY2 - 1;

            e_DrawFillQuad(aX, aY, aX2, aY2, 255, 255, 0, 0);
          end;
    end;
  end;
end;

procedure DrawMapView(x, y, w, h: Integer);
var
  bx, by: Integer;
begin
  glPushMatrix();

  bx := Round(x/(gMapInfo.Width - w)*(gBackSize.X - w));
  by := Round(y/(gMapInfo.Height - h)*(gBackSize.Y - h));
  g_Map_DrawBack(-bx, -by);

  sX := x;
  sY := y;
  sWidth := w;
  sHeight := h;

  glTranslatef(-x, -y, 0);

  g_Map_DrawPanels(PANEL_BACK);
  g_Map_DrawPanels(PANEL_STEP);
  g_Items_Draw();
  g_Weapon_Draw();
  g_Player_DrawShells();
  g_Player_DrawAll();
  g_Player_DrawCorpses();
  g_Map_DrawPanels(PANEL_WALL);
  g_Monsters_Draw();
  g_Map_DrawPanels(PANEL_CLOSEDOOR);
  g_GFX_Draw();
  g_Map_DrawFlags();
  g_Map_DrawPanels(PANEL_ACID1);
  g_Map_DrawPanels(PANEL_ACID2);
  g_Map_DrawPanels(PANEL_WATER);
  g_Map_DrawPanels(PANEL_FORE);
  if g_debug_HealthBar then
  begin
    g_Monsters_DrawHealth();
    g_Player_DrawHealth();
  end;

  glPopMatrix();
end;

procedure DrawPlayer(p: TPlayer);
var
  px, py, a, b, c, d: Integer;
begin
  if (p = nil) or (p.FDummy) then
  begin
    glPushMatrix();
    g_Map_DrawBack(0, 0);
    glPopMatrix();
    Exit;
  end;

  gPlayerDrawn := p;

  glPushMatrix();

  px := p.GameX + PLAYER_RECT_CX;
  py := p.GameY + PLAYER_RECT_CY;

  if px > (gPlayerScreenSize.X div 2) then
    a := -px + (gPlayerScreenSize.X div 2)
  else
    a := 0;
  if py > (gPlayerScreenSize.Y div 2) then
    b := -py + (gPlayerScreenSize.Y div 2)
  else
    b := 0;
  if px > (gMapInfo.Width - (gPlayerScreenSize.X div 2)) then
    a := -gMapInfo.Width + gPlayerScreenSize.X;
  if py > (gMapInfo.Height - (gPlayerScreenSize.Y div 2)) then
    b := -gMapInfo.Height + gPlayerScreenSize.Y;
  if gMapInfo.Width <= gPlayerScreenSize.X then
    a := 0;
  if gMapInfo.Height <= gPlayerScreenSize.Y then
    b := 0;

  if p.IncCam <> 0 then
  begin
    if py > (gMapInfo.Height - (gPlayerScreenSize.Y div 2)) then
    begin
      if p.IncCam > 120-(py-(gMapInfo.Height-(gPlayerScreenSize.Y div 2))) then
        p.IncCam := 120-(py-(gMapInfo.Height-(gPlayerScreenSize.Y div 2)));
    end;

    if py < (gPlayerScreenSize.Y div 2) then
    begin
      if p.IncCam < -120+((gPlayerScreenSize.Y div 2)-py) then
        p.IncCam := -120+((gPlayerScreenSize.Y div 2)-py);
    end;

    if p.IncCam < 0 then
      while (py+(gPlayerScreenSize.Y div 2)-p.IncCam > gMapInfo.Height) and
            (p.IncCam < 0) do
        p.IncCam := p.IncCam + 1;

    if p.IncCam > 0 then
      while (py-(gPlayerScreenSize.Y div 2)-p.IncCam < 0) and
            (p.IncCam > 0) do
        p.IncCam := p.IncCam - 1;
  end;

  if (px< gPlayerScreenSize.X div 2) or
     (gMapInfo.Width-gPlayerScreenSize.X <= 256) then
    c := 0
  else
    if (px > gMapInfo.Width-(gPlayerScreenSize.X div 2)) then
      c := gBackSize.X - gPlayerScreenSize.X
    else
      c := Round((px-(gPlayerScreenSize.X div 2))/(gMapInfo.Width-gPlayerScreenSize.X)*(gBackSize.X-gPlayerScreenSize.X));

  if (py-p.IncCam <= gPlayerScreenSize.Y div 2) or
     (gMapInfo.Height-gPlayerScreenSize.Y <= 256) then
    d := 0
  else
    if (py-p.IncCam >= gMapInfo.Height-(gPlayerScreenSize.Y div 2)) then
      d := gBackSize.Y - gPlayerScreenSize.Y
    else
      d := Round((py-p.IncCam-(gPlayerScreenSize.Y div 2))/(gMapInfo.Height-gPlayerScreenSize.Y)*(gBackSize.Y-gPlayerScreenSize.Y));

  g_Map_DrawBack(-c, -d);

  sX := -a;
  sY := -(b+p.IncCam);
  sWidth := gPlayerScreenSize.X;
  sHeight := gPlayerScreenSize.Y;

  glTranslatef(a, b+p.IncCam, 0);

  g_Map_DrawPanels(PANEL_BACK);
  g_Map_DrawPanels(PANEL_STEP);
  g_Items_Draw();
  g_Weapon_Draw();
  g_Player_DrawShells();
  g_Player_DrawAll();
  g_Player_DrawCorpses();
  g_Map_DrawPanels(PANEL_WALL);
  g_Monsters_Draw();
  g_Map_DrawPanels(PANEL_CLOSEDOOR);
  g_GFX_Draw();
  g_Map_DrawFlags();
  g_Map_DrawPanels(PANEL_ACID1);
  g_Map_DrawPanels(PANEL_ACID2);
  g_Map_DrawPanels(PANEL_WATER);
  g_Map_DrawPanels(PANEL_FORE);
  if g_debug_HealthBar then
  begin
    g_Monsters_DrawHealth();
    g_Player_DrawHealth();
  end;

  if p.FSpectator then
    e_TextureFontPrintEx(p.GameX + PLAYER_RECT_CX - 4,
                         p.GameY + PLAYER_RECT_CY - 4,
                         'X', gStdFont, 255, 255, 255, 1, True);
  {
  for a := 0 to High(gCollideMap) do
    for b := 0 to High(gCollideMap[a]) do
    begin
      d := 0;
      if ByteBool(gCollideMap[a, b] and MARK_WALL) then
        d := d + 1;
      if ByteBool(gCollideMap[a, b] and MARK_DOOR) then
        d := d + 2;

      case d of
        1: e_DrawPoint(1, b, a, 200, 200, 200);
        2: e_DrawPoint(1, b, a, 64, 64, 255);
        3: e_DrawPoint(1, b, a, 255, 0, 255);
      end;
    end;
  }

  glPopMatrix();

  p.DrawPain();
  p.DrawPickup();
  p.DrawRulez();
  if gShowMap then
    DrawMinimap(p, Rect(0, 0, 128, 128));
  if g_Debug_Player then
    g_Player_DrawDebug(p);
  p.DrawGUI();
end;

procedure g_Game_Draw();
var
  ID: DWORD;
  w, h: Word;
  ww, hh: Byte;
  Time: Int64;
  back: string;
  plView1, plView2: TPlayer;
  Split: Boolean;
begin
  if gExit = EXIT_QUIT then Exit;

  Time := GetTimer() div 1000;
  FPSCounter := FPSCounter+1;
  if Time - FPSTime >= 1000 then
  begin
    FPS := FPSCounter;
    FPSCounter := 0;
    FPSTime := Time;
  end;

  if gGameOn or (gState = STATE_FOLD) then
  begin
    if (gPlayer1 <> nil) and (gPlayer2 <> nil) then
    begin
      gSpectMode := SPECT_NONE;
      if not gRevertPlayers then
      begin
        plView1 := gPlayer1;
        plView2 := gPlayer2;
      end
      else
      begin
        plView1 := gPlayer2;
        plView2 := gPlayer1;
      end;
    end
    else
      if (gPlayer1 <> nil) or (gPlayer2 <> nil) then
      begin
        gSpectMode := SPECT_NONE;
        if gPlayer2 = nil then
          plView1 := gPlayer1
        else
          plView1 := gPlayer2;
        plView2 := nil;
      end
      else
      begin
        plView1 := nil;
        plView2 := nil;
      end;

    if (plView1 = nil) and (plView2 = nil) and (gSpectMode = SPECT_NONE) then
      gSpectMode := SPECT_STATS;

    if gSpectMode = SPECT_PLAYERS then
      if gPlayers <> nil then
      begin
        plView1 := GetActivePlayer_ByID(gSpectPID1);
        if plView1 = nil then
        begin
          gSpectPID1 := GetActivePlayerID_Next();
          plView1 := GetActivePlayer_ByID(gSpectPID1);
        end;
        if gSpectViewTwo then
        begin
          plView2 := GetActivePlayer_ByID(gSpectPID2);
          if plView2 = nil then
          begin
            gSpectPID2 := GetActivePlayerID_Next();
            plView2 := GetActivePlayer_ByID(gSpectPID2);
          end;
        end;
      end;

    if gSpectMode = SPECT_MAPVIEW then
    begin
    // ����� ��������� �����
      Split := False;
      e_SetViewPort(0, 0, gScreenWidth, gScreenHeight);
      DrawMapView(gSpectX, gSpectY, gScreenWidth, gScreenHeight);
      gHearPoint1.Active := True;
      gHearPoint1.Coords.X := gScreenWidth div 2 + gSpectX;
      gHearPoint1.Coords.Y := gScreenHeight div 2 + gSpectY;
      gHearPoint2.Active := False;
    end
    else
    begin
      Split := (plView1 <> nil) and (plView2 <> nil);

    // ����� ����� �������
      if plView1 <> nil then
      begin
        gHearPoint1.Active := True;
        gHearPoint1.Coords.X := plView1.GameX;
        gHearPoint1.Coords.Y := plView1.GameY;
      end else
        gHearPoint1.Active := False;
      if plView2 <> nil then
      begin
        gHearPoint2.Active := True;
        gHearPoint2.Coords.X := plView2.GameX;
        gHearPoint2.Coords.Y := plView2.GameY;
      end else
        gHearPoint2.Active := False;

    // ������ ������� �������:
      gPlayerScreenSize.X := gScreenWidth-196;
      if Split then
      begin
        gPlayerScreenSize.Y := gScreenHeight div 2;
        if gScreenHeight mod 2 = 0 then
          Dec(gPlayerScreenSize.Y);
      end
      else
        gPlayerScreenSize.Y := gScreenHeight;

      if Split then
        if gScreenHeight mod 2 = 0 then
          e_SetViewPort(0, gPlayerScreenSize.Y+2, gPlayerScreenSize.X+196, gPlayerScreenSize.Y)
        else
          e_SetViewPort(0, gPlayerScreenSize.Y+1, gPlayerScreenSize.X+196, gPlayerScreenSize.Y);

      DrawPlayer(plView1);
      gPlayer1ScreenCoord.X := sX;
      gPlayer1ScreenCoord.Y := sY;

      if Split then
      begin
        e_SetViewPort(0, 0, gPlayerScreenSize.X+196, gPlayerScreenSize.Y);

        DrawPlayer(plView2);
        gPlayer2ScreenCoord.X := sX;
        gPlayer2ScreenCoord.Y := sY;
      end;

      e_SetViewPort(0, 0, gScreenWidth, gScreenHeight);

      if Split then
        e_DrawLine(2, 0, gScreenHeight div 2, gScreenWidth, gScreenHeight div 2, 0, 0, 0);
    end;

    if MessageText <> '' then
    begin
      w := 0;
      h := 0;
      e_CharFont_GetSizeFmt(gMenuFont, MessageText, w, h);
      if Split then
        e_CharFont_PrintFmt(gMenuFont, (gScreenWidth div 2)-(w div 2),
                        (gScreenHeight div 2)-(h div 2), MessageText)
      else
        e_CharFont_PrintFmt(gMenuFont, (gScreenWidth div 2)-(w div 2),
                  Round(gScreenHeight / 2.75)-(h div 2), MessageText);
    end;

    if IsDrawStat or (gSpectMode = 1) then DrawStat();

    if gSpectHUD and (not gChatShow) and (gSpectMode <> SPECT_NONE) then
    begin
    // Draw spectator GUI
      ww := 0;
      hh := 0;
      e_TextureFontGetSize(gStdFont, ww, hh);
      case gSpectMode of
        SPECT_STATS:
          e_TextureFontPrintEx(0, gScreenHeight - (hh+2)*2, 'MODE: Stats', gStdFont, 255, 255, 255, 1);
        SPECT_MAPVIEW:
          e_TextureFontPrintEx(0, gScreenHeight - (hh+2)*2, 'MODE: Observe Map', gStdFont, 255, 255, 255, 1);
        SPECT_PLAYERS:
          e_TextureFontPrintEx(0, gScreenHeight - (hh+2)*2, 'MODE: Watch Players', gStdFont, 255, 255, 255, 1);
      end;
      e_TextureFontPrintEx(2*ww, gScreenHeight - (hh+2), '< jump >', gStdFont, 255, 255, 255, 1);
      if gSpectMode = SPECT_MAPVIEW then
      begin
        e_TextureFontPrintEx(22*ww, gScreenHeight - (hh+2)*2, '[-]', gStdFont, 255, 255, 255, 1);
        e_TextureFontPrintEx(26*ww, gScreenHeight - (hh+2)*2, 'Step ' + IntToStr(gSpectStep), gStdFont, 255, 255, 255, 1);
        e_TextureFontPrintEx(34*ww, gScreenHeight - (hh+2)*2, '[+]', gStdFont, 255, 255, 255, 1);
        e_TextureFontPrintEx(18*ww, gScreenHeight - (hh+2), '<prev weap>', gStdFont, 255, 255, 255, 1);
        e_TextureFontPrintEx(30*ww, gScreenHeight - (hh+2), '<next weap>', gStdFont, 255, 255, 255, 1);
      end;
      if gSpectMode = SPECT_PLAYERS then
      begin
        e_TextureFontPrintEx(22*ww, gScreenHeight - (hh+2)*2, 'Player 1', gStdFont, 255, 255, 255, 1);
        e_TextureFontPrintEx(20*ww, gScreenHeight - (hh+2), '<left/right>', gStdFont, 255, 255, 255, 1);
        if gSpectViewTwo then
        begin
          e_TextureFontPrintEx(37*ww, gScreenHeight - (hh+2)*2, 'Player 2', gStdFont, 255, 255, 255, 1);
          e_TextureFontPrintEx(34*ww, gScreenHeight - (hh+2), '<prev w/next w>', gStdFont, 255, 255, 255, 1);
          e_TextureFontPrintEx(52*ww, gScreenHeight - (hh+2)*2, '2x View', gStdFont, 255, 255, 255, 1);
          e_TextureFontPrintEx(51*ww, gScreenHeight - (hh+2), '<up/down>', gStdFont, 255, 255, 255, 1);
        end
        else
        begin
          e_TextureFontPrintEx(35*ww, gScreenHeight - (hh+2)*2, '2x View', gStdFont, 255, 255, 255, 1);
          e_TextureFontPrintEx(34*ww, gScreenHeight - (hh+2), '<up/down>', gStdFont, 255, 255, 255, 1);
        end;
      end;
    end;
  end;

  if gPause and gGameOn and (g_ActiveWindow = nil) then
  begin
    e_DrawFillQuad(0, 0, gScreenWidth-1, gScreenHeight-1, 48, 48, 48, 180);

    e_CharFont_GetSize(gMenuFont, _lc[I_MENU_PAUSE], w, h);
    e_CharFont_Print(gMenuFont, (gScreenWidth div 2)-(w div 2),
                    (gScreenHeight div 2)-(h div 2), _lc[I_MENU_PAUSE]);
  end;

  if not gGameOn then
  begin
    if (gState = STATE_MENU) then
    begin
      if  ((g_ActiveWindow = nil) or (g_ActiveWindow.BackTexture = '')) then
      begin
        if g_Texture_Get('MENU_BACKGROUND', ID) then
          e_DrawSize(ID, 0, 0, 0, False, False, gScreenWidth, gScreenHeight)
        else e_Clear(GL_COLOR_BUFFER_BIT, 0, 0, 0);
      end;
      if g_ActiveWindow <> nil then
        e_DrawFillQuad(0, 0, gScreenWidth-1, gScreenHeight-1, 48, 48, 48, 180);
    end;

    if gState = STATE_FOLD then
      e_DrawFillQuad(0, 0, gScreenWidth-1, gScreenHeight-1, 0, 0, 0, EndingGameCounter);

    if gState = STATE_INTERCUSTOM then
    begin
      if gLastMap and (gGameSettings.GameMode = GM_COOP) then
      begin
        back := 'TEXTURE_endpic';
        if not g_Texture_Get(back, ID) then
          back := _lc[I_TEXTURE_ENDPIC];
      end
      else
        back := 'INTER';

      if g_Texture_Get(back, ID) then
        e_DrawSize(ID, 0, 0, 0, False, False, gScreenWidth, gScreenHeight)
      else
        e_Clear(GL_COLOR_BUFFER_BIT, 0, 0, 0);

      DrawCustomStat();

      if g_ActiveWindow <> nil then
        e_DrawFillQuad(0, 0, gScreenWidth-1, gScreenHeight-1, 48, 48, 48, 180);
    end;

    if gState = STATE_INTERSINGLE then
    begin
      if EndingGameCounter > 0 then
        e_DrawFillQuad(0, 0, gScreenWidth-1, gScreenHeight-1, 0, 0, 0, EndingGameCounter)
      else
      begin
        back := 'INTER';

        if g_Texture_Get(back, ID) then
          e_DrawSize(ID, 0, 0, 0, False, False, gScreenWidth, gScreenHeight)
        else
          e_Clear(GL_COLOR_BUFFER_BIT, 0, 0, 0);

        DrawSingleStat();

        if g_ActiveWindow <> nil then
          e_DrawFillQuad(0, 0, gScreenWidth-1, gScreenHeight-1, 48, 48, 48, 180);
      end;
    end;

    if gState = STATE_ENDPIC then
    begin
      ID := DWORD(-1);
      if not g_Texture_Get('TEXTURE_endpic', ID) then
        g_Texture_Get(_lc[I_TEXTURE_ENDPIC], ID);

      if ID <> DWORD(-1) then
        e_DrawSize(ID, 0, 0, 0, False, False, gScreenWidth, gScreenHeight)
      else
        e_Clear(GL_COLOR_BUFFER_BIT, 0, 0, 0);

      if g_ActiveWindow <> nil then
        e_DrawFillQuad(0, 0, gScreenWidth-1, gScreenHeight-1, 48, 48, 48, 180);
    end;

    if gState = STATE_SLIST then
    begin
      if g_Texture_Get('MENU_BACKGROUND', ID) then
      begin
        e_DrawSize(ID, 0, 0, 0, False, False, gScreenWidth, gScreenHeight);
        e_DrawFillQuad(0, 0, gScreenWidth-1, gScreenHeight-1, 48, 48, 48, 180);
      end;
      g_Serverlist_Draw(slCurrent);
    end;
  end;

  if g_ActiveWindow <> nil then
  begin
    if gGameOn then
      e_DrawFillQuad(0, 0, gScreenWidth-1, gScreenHeight-1, 48, 48, 48, 180);
    g_ActiveWindow.Draw();
  end;

  g_Console_Draw();

  if g_debug_Sounds and gGameOn then
  begin
    for w := 0 to High(e_SoundsArray) do
      for h := 0 to e_SoundsArray[w].nRefs do
        e_DrawPoint(1, w+100, h+100, 255, 0, 0);
  end;

  if gShowFPS then
  begin
    e_TextureFontPrint(0, 0, Format('FPS: %d', [FPS]), gStdFont);
    e_TextureFontPrint(0, 16, Format('UPS: %d', [UPS]), gStdFont);
  end;

  if gGameOn and gShowTime and (gGameSettings.GameType in [GT_CUSTOM, GT_SERVER, GT_CLIENT]) then
  e_TextureFontPrint(gScreenWidth-72, 0,
                     Format('%d:%.2d:%.2d', [gTime div 1000 div 3600, (gTime div 1000 div 60) mod 60, gTime div 1000 mod 60]),
                     gStdFont);
end;

procedure g_Game_Quit();
begin
  g_Game_StopAllSounds(True);
  gMusic.Free();
  g_Game_SaveOptions();
  g_Game_FreeData();
  g_PlayerModel_FreeData();
  g_Texture_DeleteAll();
  g_Frames_DeleteAll();
  g_Menu_Free();
  
  if NetInitDone then g_Net_Free;

// ���� ������� ����� ����� �����:
  if gMapToDelete <> '' then
    g_Game_DeleteTestMap();

  gExit := EXIT_QUIT;
  PostQuitMessage(0);
end;

procedure g_FatalError(Text: String);
begin
  g_Console_Add(Format(_lc[I_FATAL_ERROR], [Text]), True);
  e_WriteLog(Format(_lc[I_FATAL_ERROR], [Text]), MSG_WARNING);

  gExit := EXIT_SIMPLE;
end;

procedure g_SimpleError(Text: String);
begin
  g_Console_Add(Format(_lc[I_SIMPLE_ERROR], [Text]), True);
  e_WriteLog(Format(_lc[I_SIMPLE_ERROR], [Text]), MSG_WARNING);
end;

procedure g_Game_SetupScreenSize();
var
  d: Single;
begin
// ������ ������� �������:
  gPlayerScreenSize.X := gScreenWidth-196;
  if (gPlayer1 <> nil) and (gPlayer2 <> nil) then
    gPlayerScreenSize.Y := gScreenHeight div 2
  else
    gPlayerScreenSize.Y := gScreenHeight;

// ������ ������� �����:
  if BackID <> DWORD(-1) then
  begin
    d := SKY_STRETCH;

    if (gScreenWidth*d > gMapInfo.Width) or
       (gScreenHeight*d > gMapInfo.Height) then
      d := 1.0;

    gBackSize.X := Round(gScreenWidth*d);
    gBackSize.Y := Round(gScreenHeight*d);
  end;
end;

procedure g_Game_ChangeResolution(newWidth, newHeight: Word; nowFull, nowMax: Boolean);
var
  sz: TPoint;
begin
// ���� ���� ���� ���������� �� ���� �����, �� ���������������:
  if gWinMaximized then
  begin
    if not gFullscreen then
    begin // ��� ������� �����
      ShowWindow(h_Wnd, SW_RESTORE);
    end;

    gWinMaximized := False;
  end;

// ������ �����: ������� ��� �������������:
  if gFullscreen <> nowFull then
  begin
    gFullscreen := nowFull;

    if not gFullscreen then
      begin // �������� �������:
      // ��������� �������������:
        SetForegroundWindow(0);
        ChangeDisplaySettings(_devicemodeA(nil^), CDS_FULLSCREEN);
      // ����� ����:
        SetWindowLong(h_Wnd, GWL_STYLE, Integer(gWindowStyle[1][1]));
        SetWindowLong(h_Wnd, GWL_EXSTYLE, Integer(gWindowStyle[1][2]));
      end
    else
      begin // �������� �������������
      // ����� ����:
        SetWindowLong(h_Wnd, GWL_STYLE, Integer(gWindowStyle[2][1]));
        SetWindowLong(h_Wnd, GWL_EXSTYLE, Integer(gWindowStyle[2][2]));
        SetForegroundWindow(h_Wnd);
      end;
  end;

// �������� WM_SIZE � ������ ���������:
  if gFullScreen then
    begin // �������������
      g_Window_SetDisplay();

      SetWindowPos(h_Wnd, HWND_TOP,
                   0, 0, newWidth, newHeight,
                   SWP_SHOWWINDOW);
    end
  else // �������
    begin
    // ������ ����:
      sz.X := newWidth + 2*gWinFrameX;
      sz.Y := newHeight + 2*gWinFrameY + gWinCaption;

      gWinMaximized := nowMax;

      SetWindowPos(h_Wnd, HWND_TOP,
                   gWinRealPosX, gWinRealPosY, sz.X, sz.Y,
                   SWP_SHOWWINDOW);

      if gWinMaximized then
        ShowWindow(h_Wnd, SW_SHOWMAXIMIZED);
    end;
end;

procedure g_Game_AddPlayer(Team: Byte = TEAM_NONE);
begin
  if ((not gGameOn) and (gState <> STATE_INTERCUSTOM))
  or (not (gGameSettings.GameType in [GT_CUSTOM, GT_SERVER, GT_CLIENT])) then
    Exit;
  if gPlayer1 = nil then
  begin
    if g_Game_IsClient then
    begin
      if NetPlrUID1 > -1 then
      begin
        MC_SEND_CheatRequest(NET_CHEAT_SPECTATE);
        gPlayer1 := g_Player_Get(NetPlrUID1);
      end;
      Exit;
    end;

    if not (Team in [TEAM_RED, TEAM_BLUE]) then
      Team := gPlayer1Settings.Team;

    // �������� ������� ������:
    gPlayer1 := g_Player_Get(g_Player_Create(gPlayer1Settings.Model,
                                             gPlayer1Settings.Color,
                                             Team, False));
    if gPlayer1 = nil then
      g_FatalError(Format(_lc[I_GAME_ERROR_PLAYER_CREATE], [1]))
    else
    begin
      gPlayer1.Name := gPlayer1Settings.Name;
      g_Console_Add(Format(_lc[I_PLAYER_JOIN], [gPlayer1.Name]), True);
      if g_Game_IsServer and g_Game_IsNet then
        MH_SEND_PlayerCreate(gPlayer1.UID);
      gPlayer1.Respawn(False, True);

      if g_Game_IsNet and NetUseMaster then
        g_Net_Slist_Update;
    end;

    Exit;
  end;
  if gPlayer2 = nil then
  begin
    if g_Game_IsClient then
    begin
      if NetPlrUID2 > -1 then
        gPlayer2 := g_Player_Get(NetPlrUID2);
      Exit;
    end;

    if not (Team in [TEAM_RED, TEAM_BLUE]) then
      Team := gPlayer2Settings.Team;

    // �������� ������� ������:
    gPlayer2 := g_Player_Get(g_Player_Create(gPlayer2Settings.Model,
                                             gPlayer2Settings.Color,
                                             Team, False));
    if gPlayer2 = nil then
      g_FatalError(Format(_lc[I_GAME_ERROR_PLAYER_CREATE], [2]))
    else
    begin
      gPlayer2.Name := gPlayer2Settings.Name;
      g_Console_Add(Format(_lc[I_PLAYER_JOIN], [gPlayer2.Name]), True);
      if g_Game_IsServer and g_Game_IsNet then
        MH_SEND_PlayerCreate(gPlayer2.UID);
      gPlayer2.Respawn(False, True);

      if g_Game_IsNet and NetUseMaster then
        g_Net_Slist_Update;
    end;

    Exit;
  end;
end;

procedure g_Game_RemovePlayer();
var
  Pl: TPlayer;
begin
  if ((not gGameOn) and (gState <> STATE_INTERCUSTOM))
  or (not (gGameSettings.GameType in [GT_CUSTOM, GT_SERVER, GT_CLIENT])) then
    Exit;
  Pl := gPlayer2;
  if Pl <> nil then
  begin
    if g_Game_IsServer then
    begin
      Pl.Lives := 0;
      Pl.Kill(K_SIMPLEKILL, 0, HIT_DISCON);
      g_Console_Add(Format(_lc[I_PLAYER_LEAVE], [Pl.Name]), True);
      g_Player_Remove(Pl.UID);

      if g_Game_IsNet and NetUseMaster then
        g_Net_Slist_Update;
    end else
      gPlayer2 := nil;
    Exit;
  end;
  Pl := gPlayer1;
  if Pl <> nil then
  begin
    if g_Game_IsServer then
    begin
      Pl.Lives := 0;
      Pl.Kill(K_SIMPLEKILL, 0, HIT_DISCON);
      g_Console_Add(Format(_lc[I_PLAYER_LEAVE], [Pl.Name]), True);
      g_Player_Remove(Pl.UID);

      if g_Game_IsNet and NetUseMaster then
        g_Net_Slist_Update;
    end else
    begin
      gPlayer1 := nil;
      MC_SEND_CheatRequest(NET_CHEAT_SPECTATE);
    end;
    Exit;
  end;
end;

procedure g_Game_Spectate();
begin
  g_Game_RemovePlayer();
  if gPlayer1 <> nil then
    g_Game_RemovePlayer();
end;

procedure g_Game_SpectateCenterView();
begin
  gSpectX := Max(gMapInfo.Width div 2 - gScreenWidth div 2, 0);
  gSpectY := Max(gMapInfo.Height div 2 - gScreenHeight div 2, 0);
end;

procedure g_Game_StartSingle(Map: String; TwoPlayers: Boolean; nPlayers: Byte);
var
  i, nPl: Integer;
begin
  g_Game_Free();

  e_WriteLog('Starting singleplayer game...', MSG_NOTIFY);

  g_Game_ClearLoading();

// ��������� ����:
  ZeroMemory(@gGameSettings, SizeOf(TGameSettings));
  gAimLine := False;
  gShowMap := False;
  gGameSettings.GameType := GT_SINGLE;
  gGameSettings.MaxLives := 0;
  gGameSettings.Options := gGameSettings.Options + GAME_OPTION_ALLOWEXIT;
  gGameSettings.Options := gGameSettings.Options + GAME_OPTION_MONSTERS;
  gGameSettings.Options := gGameSettings.Options + GAME_OPTION_BOTVSMONSTER;
  gSwitchGameMode := GM_SINGLE;

  g_Game_ExecuteEvent('ongamestart');

// ��������� �������� ���� �������:
  g_Game_SetupScreenSize();

// �������� ������� ������:
  gPlayer1 := g_Player_Get(g_Player_Create(gPlayer1Settings.Model,
                                           gPlayer1Settings.Color,
                                           gPlayer1Settings.Team, False));
  if gPlayer1 = nil then
  begin
    g_FatalError(Format(_lc[I_GAME_ERROR_PLAYER_CREATE], [1]));
    Exit;
  end;

  gPlayer1.Name := gPlayer1Settings.Name;
  nPl := 1;

// �������� ������� ������, ���� ����:
  if TwoPlayers then
  begin
    gPlayer2 := g_Player_Get(g_Player_Create(gPlayer2Settings.Model,
                                             gPlayer2Settings.Color,
                                             gPlayer2Settings.Team, False));
    if gPlayer2 = nil then
    begin
      g_FatalError(Format(_lc[I_GAME_ERROR_PLAYER_CREATE], [2]));
      Exit;
    end;

    gPlayer2.Name := gPlayer2Settings.Name;
    Inc(nPl);
  end;

// �������� � ������ �����:
  if not g_Game_StartMap(MAP, True) then
  begin
    g_FatalError(Format(_lc[I_GAME_ERROR_MAP_LOAD], [gGameSettings.WAD + ':\' + MAP]));
    Exit;
  end;

// ��������� ������� � �����:
  g_Player_Init();

// ������� �����:
  for i := nPl+1 to nPlayers do
    g_Player_Create(STD_PLAYER_MODEL, _RGB(0, 0, 0), 0, True);
end;

procedure g_Game_StartCustom(Map: String; GameMode: Byte;
                             TimeLimit, GoalLimit: Word;
                             MaxLives: Byte;
                             Options: LongWord; nPlayers: Byte);
var
  i, nPl: Integer;
begin
  g_Game_Free();

  e_WriteLog('Starting custom game...', MSG_NOTIFY);

  g_Game_ClearLoading();

// ��������� ����:
  gGameSettings.GameType := GT_CUSTOM;
  gGameSettings.GameMode := GameMode;
  gSwitchGameMode := GameMode;
  gGameSettings.TimeLimit := TimeLimit;
  gGameSettings.GoalLimit := GoalLimit;
  gGameSettings.MaxLives := IfThen(GameMode = GM_CTF, 0, MaxLives);
  gGameSettings.Options := Options;

  gCoopTotalMonstersKilled := 0;
  gCoopTotalSecretsFound := 0;
  gCoopTotalMonsters := 0;
  gCoopTotalSecrets := 0;
  gAimLine := False;
  gShowMap := False;

  g_Game_ExecuteEvent('ongamestart');

// ��������� �������� ���� �������:
  g_Game_SetupScreenSize();

// ����� �����������:
  if nPlayers = 0 then
  begin
    gPlayer1 := nil;
    gPlayer2 := nil;
  end;

  nPl := 0;
  if nPlayers >= 1 then
  begin
  // �������� ������� ������:
    gPlayer1 := g_Player_Get(g_Player_Create(gPlayer1Settings.Model,
                                             gPlayer1Settings.Color,
                                             gPlayer1Settings.Team, False));
    if gPlayer1 = nil then
    begin
      g_FatalError(Format(_lc[I_GAME_ERROR_PLAYER_CREATE], [1]));
      Exit;
    end;

    gPlayer1.Name := gPlayer1Settings.Name;
    Inc(nPl);
  end;

  if nPlayers >= 2 then
  begin
  // �������� ������� ������:
    gPlayer2 := g_Player_Get(g_Player_Create(gPlayer2Settings.Model,
                                             gPlayer2Settings.Color,
                                             gPlayer2Settings.Team, False));
    if gPlayer2 = nil then
    begin
      g_FatalError(Format(_lc[I_GAME_ERROR_PLAYER_CREATE], [2]));
      Exit;
    end;

    gPlayer2.Name := gPlayer2Settings.Name;
    Inc(nPl);
  end;

// �������� � ������ �����:
  if not g_Game_StartMap(Map, True) then
  begin
    g_FatalError(Format(_lc[I_GAME_ERROR_MAP_LOAD], [Map]));
    Exit;
  end;

// ��� ����� ���������:
  if (g_Map_GetPointCount(RESPAWNPOINT_PLAYER1) +
      g_Map_GetPointCount(RESPAWNPOINT_PLAYER2) +
      g_Map_GetPointCount(RESPAWNPOINT_DM) +
      g_Map_GetPointCount(RESPAWNPOINT_RED)+
      g_Map_GetPointCount(RESPAWNPOINT_BLUE)) < 1 then
  begin
    g_FatalError(_lc[I_GAME_ERROR_GET_SPAWN]);
    Exit;
  end;

// ��������� ������� � �����:
  g_Player_Init();

// ������� �����:
  for i := nPl+1 to nPlayers do
    g_Player_Create(STD_PLAYER_MODEL, _RGB(0, 0, 0), 0, True);
end;

procedure g_Game_StartServer(Map: String; GameMode: Byte;
                             TimeLimit, GoalLimit: Word; MaxLives: Byte;
                             Options: LongWord; nPlayers: Byte;
                             IPAddr: LongWord; Port: Word);
begin
  g_Game_Free();

  e_WriteLog('Starting net game (server)...', MSG_NOTIFY);

  g_Game_ClearLoading();

// ��������� ����:
  gGameSettings.GameType := GT_SERVER;
  gGameSettings.GameMode := GameMode;
  gSwitchGameMode := GameMode;
  gGameSettings.TimeLimit := TimeLimit;
  gGameSettings.GoalLimit := GoalLimit;
  gGameSettings.MaxLives := IfThen(GameMode = GM_CTF, 0, MaxLives);
  gGameSettings.Options := Options;

  gCoopTotalMonstersKilled := 0;
  gCoopTotalSecretsFound := 0;
  gCoopTotalMonsters := 0;
  gCoopTotalSecrets := 0;
  gAimLine := False;
  gShowMap := False;

  g_Game_ExecuteEvent('ongamestart');

// ��������� �������� ���� ������
  g_Game_SetupScreenSize();

// ����� �����������:
  if nPlayers = 0 then
  begin
    gPlayer1 := nil;
    gPlayer2 := nil;
  end;

  if nPlayers >= 1 then
  begin
  // �������� ������� ������:
    gPlayer1 := g_Player_Get(g_Player_Create(gPlayer1Settings.Model,
                                             gPlayer1Settings.Color,
                                             gPlayer1Settings.Team, False));
    if gPlayer1 = nil then
    begin
      g_FatalError(Format(_lc[I_GAME_ERROR_PLAYER_CREATE], [1]));
      Exit;
    end;

    gPlayer1.Name := gPlayer1Settings.Name;
  end;

  if nPlayers >= 2 then
  begin
  // �������� ������� ������:
    gPlayer2 := g_Player_Get(g_Player_Create(gPlayer2Settings.Model,
                                             gPlayer2Settings.Color,
                                             gPlayer2Settings.Team, False));
    if gPlayer2 = nil then
    begin
      g_FatalError(Format(_lc[I_GAME_ERROR_PLAYER_CREATE], [2]));
      Exit;
    end;

    gPlayer2.Name := gPlayer2Settings.Name;
  end;

// �������� ������
  if not g_Net_Host(IPAddr, Port, NetMaxClients) then
  begin
    g_FatalError(_lc[I_NET_MSG] + _lc[I_NET_ERR_HOST]);
    Exit;
  end;

  g_Net_Slist_Set(NetSlistIP, NetSlistPort);

// �������� � ������ �����:
  if not g_Game_StartMap(Map, True) then
  begin
    g_FatalError(Format(_lc[I_GAME_ERROR_MAP_LOAD], [Map]));
    Exit;
  end;

// ��� ����� ���������:
  if (g_Map_GetPointCount(RESPAWNPOINT_PLAYER1) +
      g_Map_GetPointCount(RESPAWNPOINT_PLAYER2) +
      g_Map_GetPointCount(RESPAWNPOINT_DM) +
      g_Map_GetPointCount(RESPAWNPOINT_RED)+
      g_Map_GetPointCount(RESPAWNPOINT_BLUE)) < 1 then
  begin
    g_FatalError(_lc[I_GAME_ERROR_GET_SPAWN]);
    Exit;
  end;

// ��������� ������� � �����:
  g_Player_Init();

  NetState := NET_STATE_GAME;
end;

procedure g_Game_StartClient(Addr: String; Port: Word; PW: String);
var
  Map: String;
  WadName: string;
  Ptr: Pointer;
  T: Cardinal;
  MID: Byte;
  State: Byte;
  OuterLoop: Boolean;
  newResPath: string;
begin
  g_Game_Free();

  State := 0;
  e_WriteLog('Starting net game (client)...', MSG_NOTIFY);
  e_WriteLog('NET: Trying to connect to ' + Addr + ':' + IntToStr(Port) + '...', MSG_NOTIFY);

  g_Game_ClearLoading();

// ��������� ����:
  gGameSettings.GameType := GT_CLIENT;

  gCoopTotalMonstersKilled := 0;
  gCoopTotalSecretsFound := 0;
  gCoopTotalMonsters := 0;
  gCoopTotalSecrets := 0;
  gAimLine := False;
  gShowMap := False;

  g_Game_ExecuteEvent('ongamestart');

// ��������� �������� ���� �������:
  g_Game_SetupScreenSize();

  NetState := NET_STATE_AUTH;

  g_Game_SetLoadingText(_lc[I_LOAD_CONNECT], 0, False);
// �������� ������
  if not g_Net_Connect(Addr, Port) then
  begin
    g_FatalError(_lc[I_NET_MSG] + _lc[I_NET_ERR_CONN]);
    NetState := NET_STATE_NONE;
    Exit;
  end;

  g_Game_SetLoadingText(_lc[I_LOAD_SEND_INFO], 0, False);
  MC_SEND_Info(PW);
  g_Game_SetLoadingText(_lc[I_LOAD_WAIT_INFO], 0, False);

  OuterLoop := True;
  while OuterLoop do
  begin
    while (enet_host_service(NetHost, @NetEvent, 0) > 0) do
    begin
      if (NetEvent.kind = ENET_EVENT_TYPE_RECEIVE) then
      begin
        Ptr := NetEvent.packet^.data;
        e_Raw_Seek(0);

        MID := e_Raw_Read_Byte(Ptr);

        if (MID = NET_MSG_INFO) and (State = 0) then
        begin
          NetMyID := e_Raw_Read_Byte(Ptr);
          NetPlrUID1 := e_Raw_Read_Word(Ptr);

          WadName := e_Raw_Read_String(Ptr);
          Map := e_Raw_Read_String(Ptr);

          gWADHash := e_Raw_Read_MD5(Ptr);

          gGameSettings.GameMode := e_Raw_Read_Byte(Ptr);
          gSwitchGameMode := gGameSettings.GameMode;
          gGameSettings.GoalLimit := e_Raw_Read_Word(Ptr);
          gGameSettings.TimeLimit := e_Raw_Read_Word(Ptr);
          gGameSettings.MaxLives := e_Raw_Read_Byte(Ptr);
          gGameSettings.Options := e_Raw_Read_LongWord(Ptr);
          T := e_Raw_Read_LongWord(Ptr);

          newResPath := g_Res_SearchSameWAD(MapsDir, WadName, gWADHash);
          if newResPath = '' then
          begin
            g_Game_SetLoadingText(_lc[I_LOAD_DL_RES], 0, False);
            newResPath := g_Res_DownloadWAD(WadName);
            if newResPath = '' then
            begin
              g_FatalError(_lc[I_NET_ERR_HASH]);
              enet_packet_destroy(NetEvent.packet);
              NetState := NET_STATE_NONE;
              Exit;
            end;
          end;
          newResPath := ExtractRelativePath(MapsDir, newResPath);

          gPlayer1 := g_Player_Get(g_Player_Create(gPlayer1Settings.Model,
                                                   gPlayer1Settings.Color,
                                                   gPlayer1Settings.Team, False));

          if gPlayer1 = nil then
          begin
            g_FatalError(Format(_lc[I_GAME_ERROR_PLAYER_CREATE], [1]));

            enet_packet_destroy(NetEvent.packet);
            NetState := NET_STATE_NONE;
            Exit;
          end;

          gPlayer1.Name := gPlayer1Settings.Name;
          gPlayer1.UID := NetPlrUID1;
          gPlayer1.Reset(True);

          if not g_Game_StartMap(newResPath + ':\' + Map, True) then
          begin
            g_FatalError(Format(_lc[I_GAME_ERROR_MAP_LOAD], [WadName + ':\' + Map]));

            enet_packet_destroy(NetEvent.packet);
            NetState := NET_STATE_NONE;
            Exit;
          end;

          gTime := T;

          State := 1;
          OuterLoop := False;
          enet_packet_destroy(NetEvent.packet);
          break;
        end
        else
          enet_packet_destroy(NetEvent.packet);
      end
      else
        if (NetEvent.kind = ENET_EVENT_TYPE_DISCONNECT) then
        begin
          State := 0;
          if (NetEvent.data <= NET_DISC_MAX) then
            g_Console_Add(_lc[I_NET_MSG_ERROR] + _lc[I_NET_ERR_CONN] + ' ' +
            _lc[TStrings_Locale(Cardinal(I_NET_DISC_NONE) + NetEvent.data)], True);
          OuterLoop := False;
          Break;
        end;
    end;

    ProcessLoading();

    e_PollInput();
    
    if e_KeyPressed(e_IKey_Escape) or e_KeyPressed(e_IKey_Space) then
    begin
      State := 0;
      break;
    end;
  end;

  if State <> 1 then
  begin
    g_FatalError(_lc[I_NET_MSG] + _lc[I_NET_ERR_CONN]);
    NetState := NET_STATE_NONE;
    Exit;
  end;

  gLMSRespawn := LMS_RESPAWN_NONE;
  gLMSRespawnTime := 0;

  g_Player_Init();
  NetState := NET_STATE_GAME;
  MC_SEND_FullStateRequest;
  e_WriteLog('NET: Connection successful.', MSG_NOTIFY);
end;

procedure g_Game_SaveOptions();
begin
  g_Options_Write_Video(GameDir+'\'+CONFIG_FILENAME);
end;

procedure g_Game_ChangeMap(MapPath: String);
var
  Force: Boolean;
begin
  g_Game_ClearLoading();

  Force := gGameSettings.GameMode in [GM_DM, GM_TDM, GM_CTF];
  // ���� ������� ���������� �� �������� �����, �� ������� ���������
  if gExitByTrigger then
  begin
    Force := False;
    gExitByTrigger := False;
  end;
  if not g_Game_StartMap(MapPath, Force) then
    g_FatalError(Format(_lc[I_GAME_ERROR_MAP_LOAD], [MapPath]));
end;

procedure g_Game_Restart();
var
  Map: string;
begin
  if g_Game_IsClient then
    Exit;
  g_ProcessResourceStr(gMapInfo.Map, nil, nil, @Map);

  MessageTime := 0;
  gGameOn := False;
  g_Game_ClearLoading();
  g_Game_StartMap(Map, True);
end;

function g_Game_StartMap(Map: String; Force: Boolean = False): Boolean;
var
  NewWAD, ResName: String;
  I: Integer;
begin
  g_Map_Free();
  g_Player_RemoveAllCorpses();

  if (not g_Game_IsClient) and
     (gSwitchGameMode <> gGameSettings.GameMode) and
     (gGameSettings.GameMode <> GM_SINGLE) then
  begin
    if gSwitchGameMode = GM_CTF then
      gGameSettings.MaxLives := 0;
    gGameSettings.GameMode := gSwitchGameMode;
    Force := True;
  end else
    gSwitchGameMode := gGameSettings.GameMode;

  g_Player_ResetTeams();

  if Pos(':\', Map) > 0 then
  begin
    g_ProcessResourceStr(Map, @NewWAD, nil, @ResName);
    if g_Game_IsServer then
    begin
      gWADHash := MD5File(MapsDir + NewWAD);
      g_Game_LoadWAD(NewWAD);
    end else
      // hash recieved in MC_RECV_GameEvent -> NET_EV_MAPSTART 
      g_Game_ClientWAD(NewWAD, gWADHash);
  end else
    ResName := Map;

  Result := g_Map_Load(MapsDir + gGameSettings.WAD + ':\' + ResName);
  if Result then
    begin
      g_Player_ResetAll(Force or gLastMap, gGameSettings.GameType = GT_SINGLE);

      gState := STATE_NONE;
      g_ActiveWindow := nil;
      gGameOn := True;

      DisableCheats();
      ResetTimer();

      if gGameSettings.GameMode = GM_CTF then
      begin
        g_Map_ResetFlag(FLAG_RED);
        g_Map_ResetFlag(FLAG_BLUE);
        // CTF, � ������ ���:
        if not g_Map_HaveFlagPoints() then
          g_SimpleError(_lc[I_GAME_ERROR_CTF]);
      end;
    end
  else
    begin
      gState := STATE_MENU;
      gGameOn := False;
    end;

  gExit := 0;
  gPause := False;
  gTime := 0;
  NetTimeToUpdate := 1;
  NetTimeToReliable := 0;
  NetTimeToMaster := NetMasterRate;
  gLMSRespawn := LMS_RESPAWN_NONE;
  gLMSRespawnTime := 0;
  gMissionFailed := False;
  gNextMap := '';

  gCoopMonstersKilled := 0;
  gCoopSecretsFound := 0;

  gVoteInProgress := False;
  gVotePassed := False;
  gVoteCount := 0;
  gVoted := False;

  gStatsOff := False;

  if not gGameOn then Exit;

  g_Game_SpectateCenterView();

  if (gGameSettings.MaxLives > 0) and (gGameSettings.WarmupTime > 0) then
  begin
    gLMSRespawn := LMS_RESPAWN_WARMUP;
    gLMSRespawnTime := gTime + gGameSettings.WarmupTime*1000;
    gLMSSoftSpawn := True;
    if NetMode = NET_SERVER then
      MH_SEND_GameEvent(NET_EV_LMS_WARMUP, (gLMSRespawnTime - gTime) div 1000)
    else
      g_Console_Add(Format(_lc[I_MSG_WARMUP_START], [(gLMSRespawnTime - gTime) div 1000]), True);
  end;

  if NetMode = NET_SERVER then
  begin
    MH_SEND_GameEvent(NET_EV_MAPSTART, gGameSettings.GameMode, Map);

  // ������������
    if NetUseMaster then
    begin
      if (NetMHost = nil) or (NetMPeer = nil) then
        if not g_Net_Slist_Connect then
          g_Console_Add(_lc[I_NET_MSG_ERROR] + _lc[I_NET_SLIST_ERROR]);

      g_Net_Slist_Update;
    end;

    if NetClients <> nil then
      for I := 0 to High(NetClients) do
        if NetClients[I].Used then
        begin
          NetClients[I].Voted := False;
          if NetClients[I].RequestedFullUpdate then
          begin
            MH_SEND_Everything((NetClients[I].State = NET_STATE_AUTH), I);
            NetClients[I].RequestedFullUpdate := False;
          end;
        end;

    g_Net_UnbanNonPermHosts();
  end;

  if gLastMap then
  begin
    gCoopTotalMonstersKilled := 0;
    gCoopTotalSecretsFound := 0;
    gCoopTotalMonsters := 0;
    gCoopTotalSecrets := 0;
    gLastMap := False;
  end;

  g_Game_ExecuteEvent('onmapstart');
end;

procedure SetFirstLevel();
begin
  gNextMap := '';

  MapList := g_Map_GetMapsList(MapsDir + gGameSettings.WAD);
  if MapList = nil then
    Exit;

  SortSArray(MapList);
  gNextMap := MapList[Low(MapList)];

  MapList := nil;
end;

procedure g_Game_ExitLevel(Map: Char16);
begin
  gNextMap := Map;

  gCoopTotalMonstersKilled := gCoopTotalMonstersKilled + gCoopMonstersKilled;
  gCoopTotalSecretsFound := gCoopTotalSecretsFound + gCoopSecretsFound;
  gCoopTotalMonsters := gCoopTotalMonsters + gTotalMonsters;
  gCoopTotalSecrets := gCoopTotalSecrets + gSecretsCount;

// ����� � ����� � ��������� ����:
  if gGameSettings.GameType = GT_SINGLE then
    gExit := EXIT_ENDLEVELSINGLE
  else // ����� � ����� � ����� ����
  begin
    gExit := EXIT_ENDLEVELCUSTOM;
    if gGameSettings.GameMode = GM_COOP then
      g_Player_RememberAll;

    if not g_Map_Exist(MapsDir + gGameSettings.WAD + ':\' + gNextMap) then
    begin
      gLastMap := True;
      if gGameSettings.GameMode = GM_COOP then
        gStatsOff := True;

      gStatsPressed := True;
      gNextMap := 'MAP01';

      if not g_Map_Exist(MapsDir + gGameSettings.WAD + ':\' + gNextMap) then
        g_Game_NextLevel;

      if g_Game_IsNet then
      begin
        MH_SEND_GameStats();
        MH_SEND_CoopStats();
      end;
    end;
  end;
end;

procedure g_Game_RestartLevel();
var
  Map: string;
begin
  if gGameSettings.GameMode = GM_SINGLE then
  begin
    g_Game_Restart();
    Exit;
  end;
  gExit := EXIT_ENDLEVELCUSTOM;
  g_ProcessResourceStr(gMapInfo.Map, nil, nil, @Map);
  gNextMap := Map;
end;

procedure g_Game_ClientWAD(NewWAD: String; WHash: TMD5Digest);
var
  gWAD: String;
begin
  if LowerCase(NewWAD) = LowerCase(gGameSettings.WAD) then
    Exit;
  if not g_Game_IsClient then
    Exit;
  gWAD := g_Res_SearchSameWAD(MapsDir, ExtractFileName(NewWAD), WHash);
  if gWAD = '' then
  begin
    g_Game_SetLoadingText(_lc[I_LOAD_DL_RES], 0, False);
    gWAD := g_Res_DownloadWAD(ExtractFileName(NewWAD));
    if gWAD = '' then
    begin
      g_Game_Free();
      g_FatalError(Format(_lc[I_GAME_ERROR_MAP_WAD], [ExtractFileName(NewWAD)]));
      Exit;
    end;
  end;
  NewWAD := ExtractRelativePath(MapsDir, gWAD);
  g_Game_LoadWAD(NewWAD);
end;

procedure g_Game_RestartRound(NoMapRestart: Boolean = False);
var
  i, n, nb, nr: Integer;
begin
  if not g_Game_IsServer then Exit;
  if gLMSRespawn = LMS_RESPAWN_NONE then Exit;
  gLMSRespawn := LMS_RESPAWN_NONE;
  gLMSRespawnTime := 0;
  MessageTime := 0;

  if (gGameSettings.GameMode = GM_COOP) and not NoMapRestart then
  begin
    gMissionFailed := True;
    g_Game_RestartLevel;
    Exit;
  end;

  n := 0; nb := 0; nr := 0;
  for i := Low(gPlayers) to High(gPlayers) do
    if (gPlayers[i] <> nil) and
       ((not gPlayers[i].FSpectator) or gPlayers[i].FWantsInGame or
        (gPlayers[i] is TBot)) then
      begin
        Inc(n);
        if gPlayers[i].Team = TEAM_RED then Inc(nr)
        else if gPlayers[i].Team = TEAM_BLUE then Inc(nb)
      end;

  if (n < 2) or ((gGameSettings.GameMode = GM_TDM) and ((nr = 0) or (nb = 0))) then
  begin
    // wait a second until the fuckers finally decide to join
    gLMSRespawn := LMS_RESPAWN_WARMUP;
    gLMSRespawnTime := gTime + 1000;
    gLMSSoftSpawn := NoMapRestart;
    Exit;
  end;

  g_Player_RemoveAllCorpses;
  g_Game_Message(_lc[I_MESSAGE_LMS_START], 144);
  if g_Game_IsNet then
    MH_SEND_GameEvent(NET_EV_LMS_START);

  for i := Low(gPlayers) to High(gPlayers) do
  begin
    if gPlayers[i] = nil then continue;
    if gPlayers[i] is TBot then gPlayers[i].FWantsInGame := True;
    // don't touch normal spectators
    if gPlayers[i].FSpectator and not gPlayers[i].FWantsInGame then
    begin
      gPlayers[i].FNoRespawn := True;
      gPlayers[i].Lives := 0;
      if g_Game_IsNet then
        MH_SEND_PlayerStats(gPlayers[I].UID);
      continue;
    end;
    gPlayers[i].FNoRespawn := False;
    gPlayers[i].Lives := gGameSettings.MaxLives;
    gPlayers[i].Respawn(False, True);
    if gGameSettings.GameMode = GM_COOP then
    begin
      gPlayers[i].Frags := 0;
      gPlayers[i].RecallState;
    end;
    if (gPlayer1 = nil) and (gLMSPID1 > 0) then
      gPlayer1 := g_Player_Get(gLMSPID1);
    if (gPlayer2 = nil) and (gLMSPID2 > 0) then
      gPlayer2 := g_Player_Get(gLMSPID2);
  end;

  for i := Low(gItems) to High(gItems) do
  begin
    if gItems[i].Respawnable then
    begin
      gItems[i].QuietRespawn := True;
      gItems[i].RespawnTime := 0;
    end
    else
    begin
      g_Items_Remove(i);
      if g_Game_IsNet then MH_SEND_ItemDestroy(True, i);
    end;
  end;

  for i := Low(gMonsters) to High(gMonsters) do
  begin
    if (gMonsters[i] <> nil) and not gMonsters[i].FNoRespawn then
      gMonsters[i].Respawn;
  end;

  gLMSSoftSpawn := False;
end;

function g_Game_GetFirstMap(WAD: String): String;
begin
  Result := '';

  MapList := g_Map_GetMapsList(WAD);
  if MapList = nil then
    Exit;

  SortSArray(MapList);
  Result := MapList[Low(MapList)];

  if not g_Map_Exist(WAD + ':\' + Result) then
    Result := '';

  MapList := nil;
end;

function g_Game_GetNextMap(): String;
var
  I: Integer;
  Map: string;
begin
  Result := '';

  MapList := g_Map_GetMapsList(MapsDir + gGameSettings.WAD);
  if MapList = nil then
    Exit;

  g_ProcessResourceStr(gMapInfo.Map, nil, nil, @Map);

  SortSArray(MapList);
  MapIndex := -255;
  for I := Low(MapList) to High(MapList) do
    if Map = MapList[I] then
    begin
      MapIndex := I;
      Break;
    end;

  if MapIndex <> -255 then
  begin
    if MapIndex = High(MapList) then
     Result := MapList[Low(MapList)]
    else
      Result := MapList[MapIndex + 1];

    if not g_Map_Exist(MapsDir + gGameSettings.WAD + ':\' + Result) then Result := Map;
  end;

  MapList := nil;
end;

procedure g_Game_NextLevel();
begin
  if gGameSettings.GameMode in [GM_DM, GM_TDM, GM_CTF, GM_COOP] then
    gExit := EXIT_ENDLEVELCUSTOM
  else
  begin
    gExit := EXIT_ENDLEVELSINGLE;
    Exit;
  end;

  if gNextMap <> '' then Exit;
  gNextMap := g_Game_GetNextMap();
end;

function g_Game_IsTestMap(): Boolean;
var
  FName, Sect, Res: String;
begin
  g_ProcessResourceStr(gMapInfo.Map, FName, Sect, Res);
  Result := UpperCase(Res) = TEST_MAP_NAME;
end;

procedure g_Game_DeleteTestMap();
var
  WAD: TWADEditor_1;
  MapName: Char16;
  MapList: SArray;
  a, time: Integer;
  WadName: string;
begin
  a := Pos('.wad:\', gMapToDelete);
  if a = 0 then
    Exit;

// �������� ��� wad-����� � ��� �����:
  WadName := Copy(gMapToDelete, 1, a + 3);
  Delete(gMapToDelete, 1, a + 5);
  gMapToDelete := UpperCase(gMapToDelete);
  MapName := '';
  CopyMemory(@MapName[0], @gMapToDelete[1], Min(16, Length(gMapToDelete)));

// ��� ����� �� ����������� ��������:
  if MapName <> TEST_MAP_NAME then
    Exit;

  if not gTempDelete then
  begin
    time := g_GetFileTime(WadName);
    WAD := TWADEditor_1.Create();

  // ������ Wad-����:
    if not WAD.ReadFile(WadName) then
    begin // ��� ������ WAD-�����
      WAD.Free();
      Exit;
    end;

  // ���������� ������ ���� � ���� ������:
    WAD.CreateImage();
    MapList := WAD.GetResourcesList('');

    if MapList <> nil then
      for a := 0 to High(MapList) do
        if MapList[a] = MapName then
        begin
        // ������� � ���������:
          WAD.RemoveResource('', MapName);
          WAD.SaveTo(WadName);
          Break;
        end;

    WAD.Free();
    g_SetFileTime(WadName, time);
  end else
    DeleteFile(WadName);
end;

procedure GameCVars(P: SArray);
var
  a, b: Integer;
  stat: TPlayerStatArray;
  cmd, s: string;
  config: TConfig;
begin
  stat := nil;
  cmd := LowerCase(P[0]);
  if cmd = 'r_showfps' then
  begin
    if (Length(P) > 1) and
       ((P[1] = '1') or (P[1] = '0')) then
      gShowFPS := (P[1][1] = '1');

    if gShowFPS then
      g_Console_Add(_lc[I_MSG_SHOW_FPS_ON])
    else
      g_Console_Add(_lc[I_MSG_SHOW_FPS_OFF]);
  end
  else if (cmd = 'g_friendlyfire') and not g_Game_IsClient then
  begin
    with gGameSettings do
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
      begin
        if (P[1][1] = '1') then
          Options := Options or GAME_OPTION_TEAMDAMAGE
        else
          Options := Options and (not GAME_OPTION_TEAMDAMAGE);
      end;

      if (LongBool(Options and GAME_OPTION_TEAMDAMAGE)) then
        g_Console_Add(_lc[I_MSG_FRIENDLY_FIRE_ON])
      else
        g_Console_Add(_lc[I_MSG_FRIENDLY_FIRE_OFF]);

      if g_Game_IsNet then MH_SEND_GameSettings;
    end;
  end
  else if (cmd = 'g_weaponstay') and not g_Game_IsClient then
  begin
    with gGameSettings do
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
      begin
        if (P[1][1] = '1') then
          Options := Options or GAME_OPTION_WEAPONSTAY
        else
          Options := Options and (not GAME_OPTION_WEAPONSTAY);
      end;

      if (LongBool(Options and GAME_OPTION_WEAPONSTAY)) then
        g_Console_Add(_lc[I_MSG_WEAPONSTAY_ON])
      else
        g_Console_Add(_lc[I_MSG_WEAPONSTAY_OFF]);

      if g_Game_IsNet then MH_SEND_GameSettings;
    end;
  end
  else if cmd = 'g_gamemode' then
  begin
    a := g_Game_TextToMode(P[1]);
    if a = GM_SINGLE then a := GM_COOP;
    if (Length(P) > 1) and (a <> GM_NONE) and (not g_Game_IsClient) then
    begin
      gSwitchGameMode := a;
      if (gGameOn and (gGameSettings.GameMode = GM_SINGLE)) or
         (gState = STATE_INTERSINGLE) then
        gSwitchGameMode := GM_SINGLE;
      if not gGameOn then
        gGameSettings.GameMode := gSwitchGameMode;
    end;
    if gSwitchGameMode = gGameSettings.GameMode then
      g_Console_Add(Format(_lc[I_MSG_GAMEMODE_CURRENT],
                          [g_Game_ModeToText(gGameSettings.GameMode)]))
    else
      g_Console_Add(Format(_lc[I_MSG_GAMEMODE_CHANGE],
                          [g_Game_ModeToText(gGameSettings.GameMode),
                           g_Game_ModeToText(gSwitchGameMode)]));
  end
  else if (cmd = 'g_allow_exit') and not g_Game_IsClient then
  begin
    with gGameSettings do
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
      begin
        if (P[1][1] = '1') then
          Options := Options or GAME_OPTION_ALLOWEXIT
        else
          Options := Options and (not GAME_OPTION_ALLOWEXIT);
      end;
        
      if (LongBool(Options and GAME_OPTION_ALLOWEXIT)) then
        g_Console_Add(_lc[I_MSG_ALLOWEXIT_ON])
      else
        g_Console_Add(_lc[I_MSG_ALLOWEXIT_OFF]);
      g_Console_Add(_lc[I_MSG_ONMAPCHANGE]);

      if g_Game_IsNet then MH_SEND_GameSettings;
    end;
  end
  else if (cmd = 'g_allow_monsters') and not g_Game_IsClient then
  begin
    with gGameSettings do
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
      begin
        if (P[1][1] = '1') then
          Options := Options or GAME_OPTION_MONSTERS
        else
          Options := Options and (not GAME_OPTION_MONSTERS);
      end;

      if (LongBool(Options and GAME_OPTION_MONSTERS)) then
        g_Console_Add(_lc[I_MSG_ALLOWMON_ON])
      else
        g_Console_Add(_lc[I_MSG_ALLOWMON_OFF]);
      g_Console_Add(_lc[I_MSG_ONMAPCHANGE]);

      if g_Game_IsNet then MH_SEND_GameSettings;
    end;
  end
  else if (cmd = 'g_bot_vsplayers') and not g_Game_IsClient then
  begin
    with gGameSettings do
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
      begin
        if (P[1][1] = '1') then
          Options := Options or GAME_OPTION_BOTVSPLAYER
        else
          Options := Options and (not GAME_OPTION_BOTVSPLAYER);
      end;
        
      if (LongBool(Options and GAME_OPTION_BOTVSPLAYER)) then
        g_Console_Add(_lc[I_MSG_BOTSVSPLAYERS_ON])
      else
        g_Console_Add(_lc[I_MSG_BOTSVSPLAYERS_OFF]);

      if g_Game_IsNet then MH_SEND_GameSettings;
    end;
  end
  else if (cmd = 'g_bot_vsmonsters') and not g_Game_IsClient then
  begin
    with gGameSettings do
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
      begin
        if (P[1][1] = '1') then
          Options := Options or GAME_OPTION_BOTVSMONSTER
        else
          Options := Options and (not GAME_OPTION_BOTVSMONSTER);
      end;

      if (LongBool(Options and GAME_OPTION_BOTVSMONSTER)) then
        g_Console_Add(_lc[I_MSG_BOTSVSMONSTERS_ON])
      else
        g_Console_Add(_lc[I_MSG_BOTSVSMONSTERS_OFF]);

      if g_Game_IsNet then MH_SEND_GameSettings;
    end;
  end
  else if (cmd = 'g_warmuptime') and not g_Game_IsClient then
  begin
    if Length(P) > 1 then
    begin
      if StrToIntDef(P[1], gGameSettings.WarmupTime) = 0 then
        gGameSettings.WarmupTime := 30
      else
        gGameSettings.WarmupTime := StrToIntDef(P[1], gGameSettings.WarmupTime);
    end;

    g_Console_Add(Format(_lc[I_MSG_WARMUP],
                 [gGameSettings.WarmupTime]));
    g_Console_Add(_lc[I_MSG_ONMAPCHANGE]);
  end
  else if cmd = 'net_interp' then
  begin
    if (Length(P) > 1) then
      NetInterpLevel := StrToIntDef(P[1], NetInterpLevel);

    g_Console_Add('net_interp = ' + IntToStr(NetInterpLevel));
    config := TConfig.CreateFile(GameDir+'\'+CONFIG_FILENAME);
    config.WriteInt('Client', 'InterpolationSteps', NetInterpLevel);
    config.SaveFile(GameDir+'\'+CONFIG_FILENAME);
    config.Free();
  end
  else if cmd = 'net_forceplayerupdate' then
  begin
    if (Length(P) > 1) and
       ((P[1] = '1') or (P[1] = '0')) then
      NetForcePlayerUpdate := (P[1][1] = '1');

    if NetForcePlayerUpdate then
      g_Console_Add('net_forceplayerupdate = 1')
    else
      g_Console_Add('net_forceplayerupdate = 0');
    config := TConfig.CreateFile(GameDir+'\'+CONFIG_FILENAME);
    config.WriteBool('Client', 'ForcePlayerUpdate', NetForcePlayerUpdate);
    config.SaveFile(GameDir+'\'+CONFIG_FILENAME);
    config.Free();
  end
  else if cmd = 'net_predictself' then
  begin
    if (Length(P) > 1) and
       ((P[1] = '1') or (P[1] = '0')) then
      NetPredictSelf := (P[1][1] = '1');

    if NetPredictSelf then
      g_Console_Add('net_predictself = 1')
    else
      g_Console_Add('net_predictself = 0');
    config := TConfig.CreateFile(GameDir+'\'+CONFIG_FILENAME);
    config.WriteBool('Client', 'PredictSelf', NetPredictSelf);
    config.SaveFile(GameDir+'\'+CONFIG_FILENAME);
    config.Free();
  end
  else if cmd = 'sv_name' then
  begin
    if (Length(P) > 1) and (Length(P[1]) > 0) then
    begin
      NetServerName := P[1];
      if Length(NetServerName) > 64 then
        SetLength(NetServerName, 64);
      if g_Game_IsServer and g_Game_IsNet and NetUseMaster then
        g_Net_Slist_Update;
    end;

    g_Console_Add(cmd + ' = "' + NetServerName + '"');
  end
  else if cmd = 'sv_passwd' then
  begin
    if (Length(P) > 1) and (Length(P[1]) > 0) then
    begin
      NetPassword := P[1];
      if Length(NetPassword) > 24 then
        SetLength(NetPassword, 24);
      if g_Game_IsServer and g_Game_IsNet and NetUseMaster then
        g_Net_Slist_Update;
    end;

    g_Console_Add(cmd + ' = "' + AnsiLowerCase(NetPassword) + '"');
  end
  else if cmd = 'sv_maxplrs' then
  begin
    if (Length(P) > 1) then
    begin
      NetMaxClients := Min(Max(StrToIntDef(P[1], NetMaxClients), 1), NET_MAXCLIENTS);
      if g_Game_IsServer and g_Game_IsNet then
      begin
        b := 0;
        for a := 0 to High(NetClients) do
          if NetClients[a].Used then
          begin
            Inc(b);
            if b > NetMaxClients then
            begin
              s := g_Player_Get(NetClients[a].Player).Name;
              enet_peer_disconnect(NetClients[a].Peer, NET_DISC_FULL);
              g_Console_Add(Format(_lc[I_PLAYER_KICK], [s]));
              MH_SEND_GameEvent(NET_EV_PLAYER_KICK, 0, s);
            end;
          end;
        if NetUseMaster then
          g_Net_Slist_Update;
      end;
    end;

    g_Console_Add(cmd + ' = ' + IntToStr(NetMaxClients));
  end
  else if cmd = 'sv_public' then
  begin
    if (Length(P) > 1) then
    begin
      NetUseMaster := StrToIntDef(P[1], Byte(NetUseMaster)) > 0;
      if g_Game_IsServer and g_Game_IsNet then
        if NetUseMaster then
        begin
          if NetMPeer = nil then
            if not g_Net_Slist_Connect() then
              g_Console_Add(_lc[I_NET_MSG_ERROR] + _lc[I_NET_SLIST_ERROR]);
          g_Net_Slist_Update();
        end
        else
          if NetMPeer <> nil then
            g_Net_Slist_Disconnect();
    end;

    g_Console_Add(cmd + ' = ' + IntToStr(Byte(NetUseMaster)));
  end
  else if cmd = 'sv_intertime' then
  begin
    if (Length(P) > 1) then
      gDefInterTime := Min(Max(StrToIntDef(P[1], gDefInterTime), -1), 120);

    g_Console_Add(cmd + ' = ' + IntToStr(gDefInterTime));
  end
  else if cmd = 'p1_name' then
  begin
    if (Length(P) > 1) and gGameOn then
    begin
      if g_Game_IsClient then
      begin
        gPlayer1Settings.Name := b_Text_Unformat(P[1]);
        MC_SEND_PlayerSettings;
      end
      else
        if gPlayer1 <> nil then
        begin
          gPlayer1.Name := b_Text_Unformat(P[1]);
          if g_Game_IsNet then MH_SEND_PlayerSettings(gPlayer1.UID);
        end
        else
          gPlayer1Settings.Name := b_Text_Unformat(P[1]);
    end;
  end
  else if cmd = 'p2_name' then
  begin
    if (Length(P) > 1) and gGameOn then
    begin
      if g_Game_IsClient then
      begin
        gPlayer2Settings.Name := b_Text_Unformat(P[1]);
        MC_SEND_PlayerSettings;
      end
      else
        if gPlayer2 <> nil then
        begin
          gPlayer2.Name := b_Text_Unformat(P[1]);
          if g_Game_IsNet then MH_SEND_PlayerSettings(gPlayer2.UID);
        end
        else
          gPlayer2Settings.Name := b_Text_Unformat(P[1]);
    end;
  end
  else if cmd = 'p1_color' then
  begin
    if Length(P) > 3 then
      if g_Game_IsClient then
      begin
        gPlayer1Settings.Color := _RGB(EnsureRange(StrToIntDef(P[1], 0), 0, 255),
                                       EnsureRange(StrToIntDef(P[2], 0), 0, 255),
                                       EnsureRange(StrToIntDef(P[3], 0), 0, 255));
        MC_SEND_PlayerSettings;
      end
      else
        if gPlayer1 <> nil then
        begin
          gPlayer1.Model.SetColor(EnsureRange(StrToIntDef(P[1], 0), 0, 255),
                                  EnsureRange(StrToIntDef(P[2], 0), 0, 255),
                                  EnsureRange(StrToIntDef(P[3], 0), 0, 255));
          if g_Game_IsNet then MH_SEND_PlayerSettings(gPlayer1.UID);
        end
        else
          gPlayer1Settings.Color := _RGB(EnsureRange(StrToIntDef(P[1], 0), 0, 255),
                                         EnsureRange(StrToIntDef(P[2], 0), 0, 255),
                                         EnsureRange(StrToIntDef(P[3], 0), 0, 255));
  end
  else if (cmd = 'p2_color') and not g_Game_IsNet then
  begin
    if Length(P) > 3 then
      if g_Game_IsClient then
      begin
        gPlayer2Settings.Color := _RGB(EnsureRange(StrToIntDef(P[1], 0), 0, 255),
                                       EnsureRange(StrToIntDef(P[2], 0), 0, 255),
                                       EnsureRange(StrToIntDef(P[3], 0), 0, 255));
        MC_SEND_PlayerSettings;
      end
      else
        if gPlayer2 <> nil then
        begin
          gPlayer2.Model.SetColor(EnsureRange(StrToIntDef(P[1], 0), 0, 255),
                                  EnsureRange(StrToIntDef(P[2], 0), 0, 255),
                                  EnsureRange(StrToIntDef(P[3], 0), 0, 255));
          if g_Game_IsNet then MH_SEND_PlayerSettings(gPlayer2.UID);
        end
        else
          gPlayer2Settings.Color := _RGB(EnsureRange(StrToIntDef(P[1], 0), 0, 255),
                                         EnsureRange(StrToIntDef(P[2], 0), 0, 255),
                                         EnsureRange(StrToIntDef(P[3], 0), 0, 255));
  end
  else if gGameSettings.GameType in [GT_CUSTOM, GT_SERVER, GT_CLIENT] then
  begin
    if cmd = 'r_showtime' then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        gShowTime := (P[1][1] = '1');

      if gShowTime then
        g_Console_Add(_lc[I_MSG_TIME_ON])
      else
        g_Console_Add(_lc[I_MSG_TIME_OFF]);
    end
    else if cmd = 'r_showscore' then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        gShowGoals := (P[1][1] = '1');

      if gShowGoals then
        g_Console_Add(_lc[I_MSG_SCORE_ON])
      else
        g_Console_Add(_lc[I_MSG_SCORE_OFF]);
    end
    else if cmd = 'r_showstat' then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        gShowStat := (P[1][1] = '1');

      if gShowStat then
        g_Console_Add(_lc[I_MSG_STATS_ON])
      else
        g_Console_Add(_lc[I_MSG_STATS_OFF]);
    end
    else if cmd = 'r_showkillmsg' then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        gShowKillMsg := (P[1][1] = '1');

      if gShowKillMsg then
        g_Console_Add(_lc[I_MSG_KILL_MSGS_ON])
      else
        g_Console_Add(_lc[I_MSG_KILL_MSGS_OFF]);
    end
    else if cmd = 'r_showlives' then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        gShowLives := (P[1][1] = '1');

      if gShowLives then
        g_Console_Add(_lc[I_MSG_LIVES_ON])
      else
        g_Console_Add(_lc[I_MSG_LIVES_OFF]);
    end
    else if cmd = 'r_showspect' then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        gSpectHUD := (P[1][1] = '1');

      if gSpectHUD then
        g_Console_Add(_lc[I_MSG_SPECT_HUD_ON])
      else
        g_Console_Add(_lc[I_MSG_SPECT_HUD_OFF]);
    end
    else if cmd = 'r_showping' then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        gShowPing := (P[1][1] = '1');

      if gShowPing then
        g_Console_Add(_lc[I_MSG_PING_ON])
      else
        g_Console_Add(_lc[I_MSG_PING_OFF]);
    end
    else if (cmd = 'g_scorelimit') and not g_Game_IsClient then
    begin
      if Length(P) > 1 then
      begin
        if StrToIntDef(P[1], gGameSettings.GoalLimit) = 0 then
          gGameSettings.GoalLimit := 0
        else
          begin
            b := 0;

            if gGameSettings.GameMode = GM_DM then
              begin // DM
                stat := g_Player_GetStats();
                if stat <> nil then
                  for a := 0 to High(stat) do
                    if stat[a].Frags > b then
                      b := stat[a].Frags;
              end
            else // TDM/CTF
              b := Max(gTeamStat[TEAM_RED].Goals, gTeamStat[TEAM_BLUE].Goals);

            gGameSettings.GoalLimit := Max(StrToIntDef(P[1], gGameSettings.GoalLimit), b);
          end;

        if g_Game_IsNet then MH_SEND_GameSettings;
      end;

      g_Console_Add(Format(_lc[I_MSG_SCORE_LIMIT], [gGameSettings.GoalLimit]));
    end
    else if (cmd = 'g_timelimit') and not g_Game_IsClient then
    begin
      if (Length(P) > 1) and (StrToIntDef(P[1], -1) >= 0) then
        gGameSettings.TimeLimit := StrToIntDef(P[1], -1);

      g_Console_Add(Format(_lc[I_MSG_TIME_LIMIT],
                           [gGameSettings.TimeLimit div 3600,
                           (gGameSettings.TimeLimit div 60) mod 60,
                            gGameSettings.TimeLimit mod 60]));
      if g_Game_IsNet then MH_SEND_GameSettings;
    end
    else if (cmd = 'g_maxlives') and not g_Game_IsClient then
    begin
      if Length(P) > 1 then
      begin
        if StrToIntDef(P[1], gGameSettings.MaxLives) = 0 then
          gGameSettings.MaxLives := 0
        else
        begin
          b := 0;
          stat := g_Player_GetStats();
          if stat <> nil then
            for a := 0 to High(stat) do
              if stat[a].Lives > b then
                b := stat[a].Lives;
          gGameSettings.MaxLives :=
            Max(StrToIntDef(P[1], gGameSettings.MaxLives), b);
        end;
      end;

      g_Console_Add(Format(_lc[I_MSG_LIVES],
                           [gGameSettings.MaxLives]));
      if g_Game_IsNet then MH_SEND_GameSettings;
    end;
  end;
end;

procedure DebugCommands(P: SArray);
var
  a, b: Integer;
  cmd: string;
  pt: Windows.TPoint;
begin
// ������� ����������� ������:
  if gDebugMode then
  begin
    cmd := LowerCase(P[0]);
    if cmd = 'd_window' then
    begin
      GetCursorPos(pt);
      g_Console_Add(Format('Cursor at %d : %d', [pt.X-gWinPosX, pt.Y-gWinPosY]));
      g_Console_Add(Format('gWinPosX = %d, gWinPosY %d', [gWinPosX, gWinPosY]));
      g_Console_Add(Format('gWinRealPosX = %d, gWinRealPosY %d', [gWinRealPosX, gWinRealPosY]));
      g_Console_Add(Format('gScreenWidth = %d, gScreenHeight = %d', [gScreenWidth, gScreenHeight]));
      g_Console_Add(Format('gWinSizeX = %d, gWinSizeY = %d', [gWinSizeX, gWinSizeY]));
      g_Console_Add(Format('Frame X = %d, Y = %d, Caption Y = %d', [gWinFrameX, gWinFrameY, gWinCaption]));
    end
    else if cmd = 'd_sounds' then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        g_Debug_Sounds := (P[1][1] = '1');

      g_Console_Add(Format('d_sounds is %d', [Byte(g_Debug_Sounds)]));
    end
    else if cmd = 'd_frames' then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        g_Debug_Frames := (P[1][1] = '1');

      g_Console_Add(Format('d_frames is %d', [Byte(g_Debug_Frames)]));
    end
    else if cmd = 'd_winmsg' then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        g_Debug_WinMsgs := (P[1][1] = '1');

      g_Console_Add(Format('d_winmsg is %d', [Byte(g_Debug_WinMsgs)]));
    end
    else if (cmd = 'd_monoff') and not g_Game_IsNet then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        g_Debug_MonsterOff := (P[1][1] = '1');

      g_Console_Add(Format('d_monoff is %d', [Byte(g_debug_MonsterOff)]));
    end
    else if (cmd = 'd_botoff') and not g_Game_IsNet then
    begin
      if Length(P) > 1 then
        case P[1][1] of
          '0': g_debug_BotAIOff := 0;
          '1': g_debug_BotAIOff := 1;
          '2': g_debug_BotAIOff := 2;
          '3': g_debug_BotAIOff := 3;
        end;

      g_Console_Add(Format('d_botoff is %d', [g_debug_BotAIOff]));
    end
    else if cmd = 'd_monster' then
    begin
      if gGameOn and (gPlayer1 <> nil) and (gPlayer1.Live) and (not g_Game_IsNet) then
        if Length(P) < 2 then
        begin
          g_Console_Add(cmd + ' [ID | Name] [behaviour]');
          g_Console_Add('ID | Name');
          for b := MONSTER_DEMON to MONSTER_MAN do
            g_Console_Add(Format('%2d | %s', [b, g_Monsters_GetNameByID(b)]));
        end else
        begin
          a := StrToIntDef(P[1], 0);
          if (a < MONSTER_DEMON) or (a > MONSTER_MAN) then
            a := g_Monsters_GetIDByName(P[1]);

          if (a < MONSTER_DEMON) or (a > MONSTER_MAN) then
            g_Console_Add(Format(_lc[I_MSG_NO_MONSTER], [P[1]]))
          else
            begin
              with gPlayer1.Obj do
                b := g_Monsters_Create(a,
                     X + Rect.X + (Rect.Width div 2),
                     Y + Rect.Y + Rect.Height,
                     gPlayer1.Direction, True);
              if (Length(P) > 2) and (b >= 0) then
                gMonsters[b].MonsterBehaviour := Min(Max(StrToIntDef(P[2], BH_NORMAL), BH_NORMAL), BH_GOOD);
            end;
        end;
    end
    else if (cmd = 'd_health') then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        g_debug_HealthBar := (P[1][1] = '1');

      g_Console_Add(Format('d_health is %d', [Byte(g_debug_HealthBar)]));
    end
    else if (cmd = 'd_player') then
    begin
      if (Length(P) > 1) and
         ((P[1] = '1') or (P[1] = '0')) then
        g_debug_Player := (P[1][1] = '1');

      g_Console_Add(Format(cmd + ' is %d', [Byte(g_Debug_Player)]));
    end
    else if (cmd = 'd_joy') then
    begin
      for a := 1 to 8 do
        g_Console_Add(e_JoystickStateToString(a));
    end;
  end
    else
      g_Console_Add(_lc[I_MSG_NOT_DEBUG]);
end;

procedure GameCommands(P: SArray);
var
  a, b: Integer;
  s, pw: String;
  chstr: string;
  cmd: string;
  pl: pTNetClient;
  plr: TPlayer;
  prt: Word;
  nm: Boolean;
  listen: LongWord;
begin
// ����� �������:
  cmd := LowerCase(P[0]);
  chstr := '';
  if (cmd = 'quit') or
     (cmd = 'exit') then
  begin
    g_Game_Free();
    g_Game_Quit();
    Exit;
  end
  else if cmd = 'pause' then
  begin
    if (g_ActiveWindow = nil) then
      g_Game_Pause(not gPause);
  end
  else if cmd = 'endgame' then
    gExit := EXIT_SIMPLE
  else if cmd = 'restart' then
  begin
    if gGameOn or (gState in [STATE_INTERSINGLE, STATE_INTERCUSTOM]) then
    begin
      if g_Game_IsClient then
      begin
        g_Console_Add(_lc[I_MSG_SERVERONLY]);
        Exit;
      end;
      g_Game_Restart();
    end else
      g_Console_Add(_lc[I_MSG_NOT_GAME]);
  end
  else if cmd = 'kick' then
  begin
    if g_Game_IsServer then
    begin
      if Length(P) < 2 then
      begin
        g_Console_Add('kick <name>');
        Exit;
      end;
      if P[1] = '' then
      begin
        g_Console_Add('kick <name>');
        Exit;
      end;

      if g_Game_IsNet then
        pl := g_Net_Client_ByName(P[1]);
      if (pl <> nil) then
      begin
        s := g_Net_ClientName_ByID(pl^.ID);
        enet_peer_disconnect(pl^.Peer, NET_DISC_KICK);
        g_Console_Add(Format(_lc[I_PLAYER_KICK], [s]));
        MH_SEND_GameEvent(NET_EV_PLAYER_KICK, 0, s);
        if NetUseMaster then
          g_Net_Slist_Update;
      end else if gPlayers <> nil then
        for a := Low(gPlayers) to High(gPlayers) do
          if gPlayers[a] <> nil then
            if Copy(LowerCase(gPlayers[a].Name), 1, Length(P[1])) = LowerCase(P[1]) then
            begin
              // �� ��������� �������� ������� � ������
              if not(gPlayers[a] is TBot) and (gGameSettings.GameType = GT_SINGLE) then
                continue;
              gPlayers[a].Lives := 0;
              gPlayers[a].Kill(K_SIMPLEKILL, 0, HIT_DISCON);
              g_Console_Add(Format(_lc[I_PLAYER_LEAVE], [gPlayers[a].Name]), True);
              g_Player_Remove(gPlayers[a].UID);
              if NetUseMaster then
                g_Net_Slist_Update;
              // ���� �� ����������, ��� ���������� ����� ����� �������� ������
              g_Bot_MixNames();
            end;
    end else
      g_Console_Add(_lc[I_MSG_GM_UNAVAIL]);
  end
  else if cmd = 'kick_id' then
  begin
    if g_Game_IsServer and g_Game_IsNet then
    begin
      if Length(P) < 2 then
      begin
        g_Console_Add('kick_id <client ID>');
        Exit;
      end;
      if P[1] = '' then
      begin
        g_Console_Add('kick_id <client ID>');
        Exit;
      end;

      a := StrToIntDef(P[1], 0);
      if (NetClients <> nil) and (a <= High(NetClients)) then
      begin
        if NetClients[a].Used and (NetClients[a].Peer <> nil) then
        begin
          s := g_Net_ClientName_ByID(NetClients[a].ID);
          enet_peer_disconnect(NetClients[a].Peer, NET_DISC_KICK);
          g_Console_Add(Format(_lc[I_PLAYER_KICK], [s]));
          MH_SEND_GameEvent(NET_EV_PLAYER_KICK, 0, s);
          if NetUseMaster then
            g_Net_Slist_Update;
        end;
      end;
    end else
      g_Console_Add(_lc[I_MSG_SERVERONLY]);
  end
  else if cmd = 'ban' then
  begin
    if g_Game_IsServer and g_Game_IsNet then
    begin
      if Length(P) < 2 then
      begin
        g_Console_Add('ban <name>');
        Exit;
      end;
      if P[1] = '' then
      begin
        g_Console_Add('ban <name>');
        Exit;
      end;

      pl := g_Net_Client_ByName(P[1]);
      if (pl <> nil) then
      begin
        s := g_Net_ClientName_ByID(pl^.ID);
        g_Net_BanHost(pl^.Peer^.address.host, False);
        enet_peer_disconnect(pl^.Peer, NET_DISC_TEMPBAN);
        g_Console_Add(Format(_lc[I_PLAYER_BAN], [s]));
        MH_SEND_GameEvent(NET_EV_PLAYER_BAN, 0, s);
        if NetUseMaster then
          g_Net_Slist_Update;
      end else
        g_Console_Add(Format(_lc[I_NET_ERR_NAME404], [P[1]]));
    end else
      g_Console_Add(_lc[I_MSG_SERVERONLY]);
  end
  else if cmd = 'ban_id' then
  begin
    if g_Game_IsServer and g_Game_IsNet then
    begin
      if Length(P) < 2 then
      begin
        g_Console_Add('ban_id <client ID>');
        Exit;
      end;
      if P[1] = '' then
      begin
        g_Console_Add('ban_id <client ID>');
        Exit;
      end;

      a := StrToIntDef(P[1], 0);
      if (NetClients <> nil) and (a <= High(NetClients)) then
        if NetClients[a].Used and (NetClients[a].Peer <> nil) then
        begin
          s := g_Net_ClientName_ByID(NetClients[a].ID);
          g_Net_BanHost(NetClients[a].Peer^.address.host, False);
          enet_peer_disconnect(NetClients[a].Peer, NET_DISC_TEMPBAN);
          g_Console_Add(Format(_lc[I_PLAYER_BAN], [s]));
          MH_SEND_GameEvent(NET_EV_PLAYER_BAN, 0, s);
          if NetUseMaster then
            g_Net_Slist_Update;
        end;
    end else
      g_Console_Add(_lc[I_MSG_SERVERONLY]);
  end
  else if cmd = 'permban' then
  begin
    if g_Game_IsServer and g_Game_IsNet then
    begin
      if Length(P) < 2 then
      begin
        g_Console_Add('permban <name>');
        Exit;
      end;
      if P[1] = '' then
      begin
        g_Console_Add('permban <name>');
        Exit;
      end;

      pl := g_Net_Client_ByName(P[1]);
      if (pl <> nil) then
      begin
        s := g_Net_ClientName_ByID(pl^.ID);
        g_Net_BanHost(pl^.Peer^.address.host);
        enet_peer_disconnect(pl^.Peer, NET_DISC_BAN);
        g_Net_SaveBanList();
        g_Console_Add(Format(_lc[I_PLAYER_BAN], [s]));
        MH_SEND_GameEvent(NET_EV_PLAYER_BAN, 0, s);
        if NetUseMaster then
          g_Net_Slist_Update;
      end else
        g_Console_Add(Format(_lc[I_NET_ERR_NAME404], [P[1]]));
    end else
      g_Console_Add(_lc[I_MSG_SERVERONLY]);
  end
  else if cmd = 'permban_id' then
  begin
    if g_Game_IsServer and g_Game_IsNet then
    begin
      if Length(P) < 2 then
      begin
        g_Console_Add('permban_id <client ID>');
        Exit;
      end;
      if P[1] = '' then
      begin
        g_Console_Add('permban_id <client ID>');
        Exit;
      end;

      a := StrToIntDef(P[1], 0);
      if (NetClients <> nil) and (a <= High(NetClients)) then
        if NetClients[a].Used and (NetClients[a].Peer <> nil) then
        begin
          s := g_Net_ClientName_ByID(NetClients[a].ID);
          g_Net_BanHost(NetClients[a].Peer^.address.host);
          enet_peer_disconnect(NetClients[a].Peer, NET_DISC_BAN);
          g_Net_SaveBanList();
          g_Console_Add(Format(_lc[I_PLAYER_BAN], [s]));
          MH_SEND_GameEvent(NET_EV_PLAYER_BAN, 0, s);
          if NetUseMaster then
            g_Net_Slist_Update;
        end;
    end else
      g_Console_Add(_lc[I_MSG_SERVERONLY]);
  end
  else if cmd = 'unban' then
  begin
    if g_Game_IsServer and g_Game_IsNet then
    begin
      if Length(P) < 2 then
      begin
        g_Console_Add('unban <IP Address>');
        Exit;
      end;
      if P[1] = '' then
      begin
        g_Console_Add('unban <IP Address>');
        Exit;
      end;

      if g_Net_UnbanHost(P[1]) then
      begin
        g_Console_Add(Format(_lc[I_MSG_UNBAN_OK], [P[1]]));
        g_Net_SaveBanList();
      end else
        g_Console_Add(Format(_lc[I_MSG_UNBAN_FAIL], [P[1]]));
    end else
      g_Console_Add(_lc[I_MSG_SERVERONLY]);
  end
  else if cmd = 'clientlist' then
  begin
    if g_Game_IsServer and g_Game_IsNet then
    begin
      b := 0;
      if NetClients <> nil then
        for a := Low(NetClients) to High(NetClients) do
          if NetClients[a].Used and (NetClients[a].Peer <> nil) then
          begin
            plr := g_Player_Get(NetClients[a].Player);
            if plr = nil then continue;
            Inc(b);
            g_Console_Add(Format('#%2d: %-15s | %s', [a,
                          IpToStr(NetClients[a].Peer^.address.host), plr.Name]));
          end;
      if b = 0 then
        g_Console_Add(_lc[I_MSG_NOCLIENTS]);
    end else
      g_Console_Add(_lc[I_MSG_SERVERONLY]);
  end
  else if cmd = 'connect' then
  begin
    if (NetMode = NET_NONE) then
    begin
      if Length(P) < 2 then
      begin
        g_Console_Add('connect <IP> [port] [password]');
        Exit;
      end;
      if P[1] = '' then
      begin
        g_Console_Add('connect <IP> [port] [password]');
        Exit;
      end;

      if Length(P) > 2 then
        prt := StrToIntDef(P[2], 25666)
      else
        prt := 25666;

      if Length(P) > 3 then
        pw := P[3]
      else
        pw := '';

      g_Game_StartClient(P[1], prt, pw);
    end;
  end
  else if cmd = 'disconnect' then
  begin
    if (NetMode = NET_CLIENT) then
      g_Net_Disconnect();
  end
  else if cmd = 'reconnect' then
  begin
    if (NetMode = NET_SERVER) then
      Exit;

    if (NetMode = NET_CLIENT) then
    begin
      g_Net_Disconnect();
      gExit := EXIT_SIMPLE;
      EndGame;
    end;

    //TODO: Use last successful password to reconnect, instead of ''
    g_Game_StartClient(NetClientIP, NetClientPort, '');
  end
  else if (cmd = 'addbot') or
     (cmd = 'bot_add') then
  begin
    if Length(P) > 1 then
      g_Bot_Add(TEAM_NONE, StrToIntDef(P[1], 2))
    else
      g_Bot_Add(TEAM_NONE, 2);
  end
  else if cmd = 'bot_addlist' then
  begin
    if Length(P) > 1 then
      if Length(P) = 2 then
        g_Bot_AddList(TEAM_NONE, P[1], StrToIntDef(P[1], -1))
      else
        g_Bot_AddList(IfThen(P[2] = 'red', TEAM_RED, TEAM_BLUE), P[1], StrToIntDef(P[1], -1));
  end
  else if cmd = 'bot_removeall' then
    g_Bot_RemoveAll()
  else if cmd = 'chat' then
  begin
    if g_Game_IsNet then
    begin
      if Length(P) > 1 then
      begin
        for a := 1 to High(P) do
          chstr := chstr + P[a] + ' ';

        if Length(chstr) > 200 then SetLength(chstr, 200);

        if Length(chstr) < 1 then
        begin
          g_Console_Add('chat <text>');
          Exit;
        end;

        chstr := b_Text_Format(chstr);
        if g_Game_IsClient then
          MC_SEND_Chat(chstr, NET_CHAT_PLAYER)
        else
          MH_SEND_Chat(gPlayer1Settings.Name + ': ' + chstr, NET_CHAT_PLAYER);
      end
      else
        g_Console_Add('chat <text>');
    end else
      g_Console_Add(_lc[I_MSG_GM_UNAVAIL]);
  end
  else if cmd = 'teamchat' then
  begin
    if g_Game_IsNet and (gGameSettings.GameMode in [GM_TDM, GM_CTF]) then
    begin
      if Length(P) > 1 then
      begin
        for a := 1 to High(P) do
          chstr := chstr + P[a] + ' ';

        if Length(chstr) > 200 then SetLength(chstr, 200);

        if Length(chstr) < 1 then
        begin
          g_Console_Add('teamchat <text>');
          Exit;
        end;

        chstr := b_Text_Format(chstr);
        if g_Game_IsClient then
          MC_SEND_Chat(chstr, NET_CHAT_TEAM)
        else
          MH_SEND_Chat(gPlayer1Settings.Name + ': ' + chstr, NET_CHAT_TEAM,
            gPlayer1Settings.Team);
      end
      else
        g_Console_Add('teamchat <text>');
    end else
      g_Console_Add(_lc[I_MSG_GM_UNAVAIL]);
  end
  else if cmd = 'game' then
  begin
    if gGameSettings.GameType <> GT_NONE then
    begin
      g_Console_Add(_lc[I_MSG_GM_UNAVAIL]);
      Exit;
    end;
    if Length(P) = 1 then
    begin
      g_Console_Add(cmd + ' <WAD> [MAP] [# players]');
      Exit;
    end;
    // ���� ��� �� ��������, ������� ��� ���� ��������� �����-�� WAD
    if Pos('.wad', LowerCase(P[1])) = 0 then
      P[1] := P[1] + '.wad';

    if FileExists(MapsDir + P[1]) then
    begin
      // ���� ����� �� �������, ���� ������ ����� � �����
      if Length(P) < 3 then
      begin
        SetLength(P, 3);
        P[2] := g_Game_GetFirstMap(MapsDir + P[1]);
      end;

      s := P[1] + ':\' + UpperCase(P[2]);

      if g_Map_Exist(MapsDir + s) then
      begin
        // ��������� ���� ����
        g_Game_Free();
        with gGameSettings do
        begin
          GameMode := g_Game_TextToMode(gcGameMode);
          if gSwitchGameMode <> GM_NONE then
            GameMode := gSwitchGameMode;
          if GameMode = GM_NONE then GameMode := GM_DM;
          if GameMode = GM_SINGLE then GameMode := GM_COOP;
          b := 1;
          if Length(P) >= 4 then
            b := StrToIntDef(P[3], 1);
          g_Game_StartCustom(s, GameMode, TimeLimit,
                             GoalLimit, MaxLives, Options, b);
        end;
      end
      else
        if P[2] = '' then
          g_Console_Add(Format(_lc[I_MSG_NO_MAPS], [P[1]]))
        else
          g_Console_Add(Format(_lc[I_MSG_NO_MAP], [UpperCase(P[2])]));
    end else
      g_Console_Add(Format(_lc[I_MSG_NO_WAD], [P[1]]));
  end
  else if cmd = 'host' then
  begin
    if gGameSettings.GameType <> GT_NONE then
    begin
      g_Console_Add(_lc[I_MSG_GM_UNAVAIL]);
      Exit;
    end;
    if Length(P) < 4 then
    begin
      g_Console_Add(cmd + ' <listen IP> <port> <WAD> [MAP] [# players]');
      Exit;
    end;
    if not StrToIp(P[1], listen) then
      Exit;
    prt := StrToIntDef(P[2], 25666);

    if Pos('.wad', LowerCase(P[3])) = 0 then
      P[3] := P[3] + '.wad';

    if FileExists(MapsDir + P[3]) then
    begin
      // ���� ����� �� �������, ���� ������ ����� � �����
      if Length(P) < 5 then
      begin
        SetLength(P, 5);
        P[4] := g_Game_GetFirstMap(MapsDir + P[1]);
      end;

      s := P[3] + ':\' + UpperCase(P[4]);

      if g_Map_Exist(MapsDir + s) then
      begin
        // ��������� ���� ����
        g_Game_Free();
        with gGameSettings do
        begin
          GameMode := g_Game_TextToMode(gcGameMode);
          if gSwitchGameMode <> GM_NONE then
            GameMode := gSwitchGameMode;
          if GameMode = GM_NONE then GameMode := GM_DM;
          if GameMode = GM_SINGLE then GameMode := GM_COOP;
          b := 0;
          if Length(P) >= 6 then
            b := StrToIntDef(P[5], 0);
          g_Game_StartServer(s, GameMode, TimeLimit,
                             GoalLimit, MaxLives, Options, b, listen, prt);
        end;
      end
      else
        if P[4] = '' then
          g_Console_Add(Format(_lc[I_MSG_NO_MAPS], [P[3]]))
        else
          g_Console_Add(Format(_lc[I_MSG_NO_MAP], [UpperCase(P[4])]));
    end else
      g_Console_Add(Format(_lc[I_MSG_NO_WAD], [P[3]]));
  end
  else if cmd = 'map' then
  begin
    if Length(P) = 1 then
    begin
      if g_Game_IsServer and (gGameSettings.GameType <> GT_SINGLE) then
      begin
        g_Console_Add(cmd + ' <MAP>');
        g_Console_Add(cmd + ' <WAD> [MAP]');
      end else
        g_Console_Add(_lc[I_MSG_GM_UNAVAIL]);
    end else
      if g_Game_IsServer and (gGameSettings.GameType <> GT_SINGLE) then
      begin
        // ��� ���� ���� ��� ������
        if Length(P) < 3 then
        begin
          // ������ �������� - ���� �����, ���� ��� WAD �����
          s := UpperCase(P[1]);
          if g_Map_Exist(MapsDir + gGameSettings.WAD + ':\' + s) then
          begin // ����� �������
            gExitByTrigger := False;
            if gGameOn then
            begin // ��� ���� - ��������� �������
              gNextMap := s;
              gExit := EXIT_ENDLEVELCUSTOM;
            end
            else // ����������� - ����� ��������� �����
              g_Game_ChangeMap(s);
          end else
          begin
            g_Console_Add(Format(_lc[I_MSG_NO_MAP], [s]));
            // ����� ����� ���, ���� WAD ����
            if Pos('.wad', LowerCase(P[1])) = 0 then
              P[1] := P[1] + '.wad';

            if FileExists(MapsDir + P[1]) then
            begin
              // ��������� ����� ���, ������� ������ ������ �� �����
              SetLength(P, 3);
              P[2] := g_Game_GetFirstMap(MapsDir + P[1]);

              s := P[1] + ':\' + P[2];

              if g_Map_Exist(MapsDir + s) then
              begin
                gExitByTrigger := False;
                if gGameOn then
                begin // ��� ���� - ��������� �������
                  gNextMap := s;
                  gExit := EXIT_ENDLEVELCUSTOM;
                end
                else // ����������� - ����� ��������� �����
                  g_Game_ChangeMap(s);
              end else
                if P[2] = '' then
                  g_Console_Add(Format(_lc[I_MSG_NO_MAPS], [P[1]]))
                else
                  g_Console_Add(Format(_lc[I_MSG_NO_MAP], [P[2]]));
            end else
              g_Console_Add(Format(_lc[I_MSG_NO_WAD], [P[1]]));
          end;
        end else
        begin
          // ������� ��� ���������, ������ ������ - WAD ����, � ������ - �����
          if Pos('.wad', LowerCase(P[1])) = 0 then
            P[1] := P[1] + '.wad';

          if FileExists(MapsDir + P[1]) then
          begin
            // ����� WAD ����
            P[2] := UpperCase(P[2]);
            s := P[1] + ':\' + P[2];

            if g_Map_Exist(MapsDir + s) then
            begin // ����� �����
              gExitByTrigger := False;
              if gGameOn then
              begin // ��� ���� - ��������� �������
                gNextMap := s;
                gExit := EXIT_ENDLEVELCUSTOM;
              end
              else // ����������� - ����� ��������� �����
                g_Game_ChangeMap(s);
            end else
              g_Console_Add(Format(_lc[I_MSG_NO_MAP], [P[2]]));
          end else
            g_Console_Add(Format(_lc[I_MSG_NO_WAD], [P[1]]));
        end;
      end else
        g_Console_Add(_lc[I_MSG_GM_UNAVAIL]);
  end
  else if cmd = 'nextmap' then
  begin
    if not(gGameOn or (gState = STATE_INTERCUSTOM)) then
      g_Console_Add(_lc[I_MSG_NOT_GAME])
    else begin
      nm := True;
      if Length(P) = 1 then
      begin
        if g_Game_IsServer and (gGameSettings.GameType <> GT_SINGLE) then
        begin
          g_Console_Add(cmd + ' <MAP>');
          g_Console_Add(cmd + ' <WAD> [MAP]');
        end else begin
          nm := False;
          g_Console_Add(_lc[I_MSG_GM_UNAVAIL]);
        end;
      end else
      begin
        nm := False;
        if g_Game_IsServer and (gGameSettings.GameType <> GT_SINGLE) then
        begin
          if Length(P) < 3 then
          begin
            // ������ �������� - ���� �����, ���� ��� WAD �����
            s := UpperCase(P[1]);
            if g_Map_Exist(MapsDir + gGameSettings.WAD + ':\' + s) then
            begin // ����� �������
              gExitByTrigger := False;
              gNextMap := s;
              nm := True;
            end else
            begin
              g_Console_Add(Format(_lc[I_MSG_NO_MAP], [s]));
              // ����� ����� ���, ���� WAD ����
              if Pos('.wad', LowerCase(P[1])) = 0 then
                P[1] := P[1] + '.wad';

              if FileExists(MapsDir + P[1]) then
              begin
                // ��������� ����� ���, ������� ������ ������ �� �����
                SetLength(P, 3);
                P[2] := g_Game_GetFirstMap(MapsDir + P[1]);

                s := P[1] + ':\' + P[2];

                if g_Map_Exist(MapsDir + s) then
                begin // ������������� �����
                  gExitByTrigger := False;
                  gNextMap := s;
                  nm := True;
                end else
                  if P[2] = '' then
                    g_Console_Add(Format(_lc[I_MSG_NO_MAPS], [P[1]]))
                  else
                    g_Console_Add(Format(_lc[I_MSG_NO_MAP], [P[2]]));
              end else
                g_Console_Add(Format(_lc[I_MSG_NO_WAD], [P[1]]));
            end;
          end else
          begin
            // ������� ��� ���������, ������ ������ - WAD ����, � ������ - �����
            if Pos('.wad', LowerCase(P[1])) = 0 then
              P[1] := P[1] + '.wad';

            if FileExists(MapsDir + P[1]) then
            begin
              // ����� WAD ����
              P[2] := UpperCase(P[2]);
              s := P[1] + ':\' + P[2];

              if g_Map_Exist(MapsDir + s) then
              begin // ����� �����
                gExitByTrigger := False;
                gNextMap := s;
                nm := True;
              end else
                g_Console_Add(Format(_lc[I_MSG_NO_MAP], [P[2]]));
            end else
              g_Console_Add(Format(_lc[I_MSG_NO_WAD], [P[1]]));
          end;
        end else
          g_Console_Add(_lc[I_MSG_GM_UNAVAIL]);
      end;
      if nm then
        if gNextMap = '' then
          g_Console_Add(_lc[I_MSG_NEXTMAP_UNSET])
        else
          g_Console_Add(Format(_lc[I_MSG_NEXTMAP_SET], [gNextMap]));
    end;
  end
  else if (cmd = 'endmap') or (cmd = 'goodbye') then
  begin
    if not gGameOn then
      g_Console_Add(_lc[I_MSG_NOT_GAME])
    else
      if g_Game_IsServer and (gGameSettings.GameType <> GT_SINGLE) then
      begin
        gExitByTrigger := False;
        // ��������� ����� �� ������, ������� ����� ������� �����
        if (gNextMap = '') and (gTriggers <> nil) then
          for a := 0 to High(gTriggers) do
            if gTriggers[a].TriggerType = TRIGGER_EXIT then
            begin
              gExitByTrigger := True;
              gNextMap := gTriggers[a].Data.MapName;
              Break;
            end;
        // ���� ��������� ����� � WAD �����
        if gNextMap = '' then
          gNextMap := g_Game_GetNextMap();
        // ���������, �� ����� �� WAD ���� ��������� �������
        if Pos(':\', gNextMap) = 0 then
          s := gGameSettings.WAD + ':\' + gNextMap
        else
          s := gNextMap;
        // ���� ����� �������, ������� � ������
        if g_Map_Exist(MapsDir + s) then
          gExit := EXIT_ENDLEVELCUSTOM
        else
          g_Console_Add(Format(_lc[I_MSG_NO_MAP], [gNextMap]));
      end else
        g_Console_Add(_lc[I_MSG_GM_UNAVAIL]);
  end
  else if (cmd = 'event') then
  begin
    if (Length(P) <= 1) then
    begin
      for a := 0 to High(gEvents) do
        if gEvents[a].Command = '' then
          g_Console_Add(gEvents[a].Name + ' <none>')
        else
          g_Console_Add(gEvents[a].Name + ' "' + gEvents[a].Command + '"');
      Exit;
    end;
    if (Length(P) = 2) then
    begin
      for a := 0 to High(gEvents) do
        if gEvents[a].Name = P[1] then
          if gEvents[a].Command = '' then
            g_Console_Add(gEvents[a].Name + ' <none>')
          else
            g_Console_Add(gEvents[a].Name + ' "' + gEvents[a].Command + '"');
      Exit;
    end;
    for a := 0 to High(gEvents) do
      if gEvents[a].Name = P[1] then
      begin
        gEvents[a].Command := '';
        for b := 2 to High(P) do
          if Pos(' ', P[b]) = 0 then
            gEvents[a].Command := gEvents[a].Command + ' ' + P[b]
          else
            gEvents[a].Command := gEvents[a].Command + ' "' + P[b] + '"';
        gEvents[a].Command := Trim(gEvents[a].Command);
        Exit;
      end;
  end
// ������� ����� ����:
  else if gGameSettings.GameType in [GT_CUSTOM, GT_SERVER, GT_CLIENT] then
  begin
    if cmd = 'bot_addred' then
    begin
      if Length(P) > 1 then
        g_Bot_Add(TEAM_RED, StrToIntDef(P[1], 2))
      else
        g_Bot_Add(TEAM_RED, 2);
    end
    else if cmd = 'bot_addblue' then
    begin
      if Length(P) > 1 then
        g_Bot_Add(TEAM_BLUE, StrToIntDef(P[1], 2))
      else
        g_Bot_Add(TEAM_BLUE, 2);
    end
    else if cmd = 'suicide' then
    begin
      if gGameOn then
      begin
        if g_Game_IsClient then
          MC_SEND_CheatRequest(NET_CHEAT_SUICIDE)
        else
        begin
          if gPlayer1 <> nil then
            gPlayer1.Damage(SUICIDE_DAMAGE, gPlayer1.UID, 0, 0, HIT_SELF);
          if gPlayer2 <> nil then
            gPlayer2.Damage(SUICIDE_DAMAGE, gPlayer2.UID, 0, 0, HIT_SELF);
        end;
      end;
    end
    else if cmd = 'spectate' then
    begin
      if not gGameOn then
        Exit;
      g_Game_Spectate();
    end
    else if cmd = 'say' then
    begin
      if g_Game_IsServer and g_Game_IsNet then
      begin
        if Length(P) > 1 then
        begin
          chstr := '';
          for a := 1 to High(P) do
            chstr := chstr + P[a] + ' ';

          if Length(chstr) > 200 then SetLength(chstr, 200);

          if Length(chstr) < 1 then
          begin
            g_Console_Add('say <text>');
            Exit;
          end;

          chstr := b_Text_Format(chstr);
          MH_SEND_Chat(chstr, NET_CHAT_PLAYER);
        end
        else g_Console_Add('say <text>');
      end else
        g_Console_Add(_lc[I_MSG_SERVERONLY]);
    end
    else if cmd = 'tell' then
    begin
      if g_Game_IsServer and g_Game_IsNet then
      begin
        if (Length(P) > 2) and (P[1] <> '') then
        begin
          chstr := '';
          for a := 2 to High(P) do
            chstr := chstr + P[a] + ' ';

          if Length(chstr) > 200 then SetLength(chstr, 200);

          if Length(chstr) < 1 then
          begin
            g_Console_Add('tell <playername> <text>');
            Exit;
          end;

          pl := g_Net_Client_ByName(P[1]);
          if pl <> nil then
            MH_SEND_Chat(b_Text_Format(chstr), NET_CHAT_PLAYER, pl^.ID)
          else
            g_Console_Add(Format(_lc[I_NET_ERR_NAME404], [P[1]]));
        end
        else g_Console_Add('tell <playername> <text>');
      end else
        g_Console_Add(_lc[I_MSG_SERVERONLY]);
    end
    else if (cmd = 'overtime') and not g_Game_IsClient then
    begin
      if (Length(P) = 1) or (StrToIntDef(P[1], -1) <= 0) then
        Exit;
      // �������������� �����:
      gGameSettings.TimeLimit := (gTime - gGameStartTime) div 1000 + Word(StrToIntDef(P[1], 0));

      g_Console_Add(Format(_lc[I_MSG_TIME_LIMIT],
                           [gGameSettings.TimeLimit div 3600,
                           (gGameSettings.TimeLimit div 60) mod 60,
                            gGameSettings.TimeLimit mod 60]));
      if g_Game_IsNet then MH_SEND_GameSettings;
    end
    else if (cmd = 'rcon_password') and g_Game_IsClient then
    begin
      if (Length(P) <= 1) then
        g_Console_Add('rcon_password <password>')
      else
        MC_SEND_RCONPassword(P[1]);
    end
    else if cmd = 'rcon' then
    begin
      if g_Game_IsClient then
      begin
        if Length(P) > 1 then
        begin
          chstr := '';
          for a := 1 to High(P) do
            chstr := chstr + P[a] + ' ';

          if Length(chstr) > 200 then SetLength(chstr, 200);

          if Length(chstr) < 1 then
          begin
            g_Console_Add('rcon <command>');
            Exit;
          end;

          MC_SEND_RCONCommand(chstr);
        end
        else g_Console_Add('rcon <command>');
      end;
    end
    else if cmd = 'ready' then
    begin
      if g_Game_IsServer and (gLMSRespawn = LMS_RESPAWN_WARMUP) then
        gLMSRespawnTime := gTime + 100;
    end
    else if (cmd = 'callvote') and g_Game_IsNet then
    begin
      if Length(P) > 1 then
      begin
        chstr := '';
        for a := 1 to High(P) do begin
          if a > 1 then chstr := chstr + ' ';
          chstr := chstr + P[a];
        end;

        if Length(chstr) > 200 then SetLength(chstr, 200);

        if Length(chstr) < 1 then
        begin
          g_Console_Add('callvote <command>');
          Exit;
        end;

        if g_Game_IsClient then
          MC_SEND_Vote(True, chstr)
        else
          g_Game_StartVote(chstr, gPlayer1Settings.Name);
        g_Console_Process('vote', True);
      end
      else
        g_Console_Add('callvote <command>');
    end
    else if (cmd = 'vote') and g_Game_IsNet then
    begin
      if g_Game_IsClient then
        MC_SEND_Vote(False)
      else if gVoteInProgress then
      begin
        if (gPlayer1 <> nil) or (gPlayer2 <> nil) then
          a := Floor((NetClientCount+1)/2.0) + 1
        else
          a := Floor(NetClientCount/2.0) + 1;
        if gVoted then
        begin
          Dec(gVoteCount);
          gVoted := False;
          g_Console_Add(Format(_lc[I_MESSAGE_VOTE_REVOKED], [gPlayer1Settings.Name, gVoteCount, a]), True);
          MH_SEND_VoteEvent(NET_VE_REVOKE, gPlayer1Settings.Name, 'a', gVoteCount, a);
        end
        else
        begin
          Inc(gVoteCount);
          gVoted := True;
          g_Console_Add(Format(_lc[I_MESSAGE_VOTE_VOTE], [gPlayer1Settings.Name, gVoteCount, a]), True);
          MH_SEND_VoteEvent(NET_VE_VOTE, gPlayer1Settings.Name, 'a', gVoteCount, a);
          g_Game_CheckVote;
        end;
      end;
    end
  end;
end;

procedure g_TakeScreenShot();
var
  a: Word;
  FileName: String;
begin
  for a := 1 to High(Word) do
  begin
    FileName := Format(GameDir+'\Screenshots\Screenshot%.3d.bmp', [a]);
    if not FileExists(FileName) then
    begin
      e_MakeScreenshot(FileName, gScreenWidth, gScreenHeight);
      g_Console_Add(Format(_lc[I_CONSOLE_SCREENSHOT], [ExtractFileName(FileName)]));
      Break;
    end;
  end;
end;

procedure g_Game_InGameMenu(Show: Boolean);
begin
  if (g_ActiveWindow = nil) and Show then
    begin
      if gGameSettings.GameType = GT_SINGLE then
        g_GUI_ShowWindow('GameSingleMenu')
      else
      begin
        if g_Game_IsClient then
          g_GUI_ShowWindow('GameClientMenu')
        else
          if g_Game_IsNet then
            g_GUI_ShowWindow('GameServerMenu')
          else
            g_GUI_ShowWindow('GameCustomMenu');
      end;
      g_Sound_PlayEx('MENU_OPEN');

    // ����� ��� ���� ������ � ��������� ����:
      if (not g_Game_IsNet) then
        g_Game_Pause(True);
    end
  else
    if (g_ActiveWindow <> nil) and (not Show) then
    begin
    // ����� ��� ���� ������ � ��������� ����:
      if (not g_Game_IsNet) then
        g_Game_Pause(False);
    end;
end;

procedure g_Game_Pause(Enable: Boolean);
begin
  if not gGameOn then
    Exit;

  if gPause = Enable then
    Exit;

  if not (gGameSettings.GameType in [GT_SINGLE, GT_CUSTOM]) then
    Exit;

  gPause := Enable;
  g_Game_PauseAllSounds(Enable);
end;

procedure g_Game_PauseAllSounds(Enable: Boolean);
var
  i: Integer;
begin
// ��������:
  if gTriggers <> nil then
    for i := 0 to High(gTriggers) do
      with gTriggers[i] do
        if (TriggerType = TRIGGER_SOUND) and
           (Sound <> nil) and
           Sound.IsPlaying() then
        begin
          Sound.Pause(Enable);
        end;

// ����� �������:
  if gPlayers <> nil then
    for i := 0 to High(gPlayers) do
      if gPlayers[i] <> nil then
        gPlayers[i].PauseSounds(Enable);

// ������:
  if gMusic <> nil then
    gMusic.Pause(Enable);
end;

procedure g_Game_StopAllSounds(all: Boolean);
var
  i: Integer;
begin
  if gTriggers <> nil then
    for i := 0 to High(gTriggers) do
      with gTriggers[i] do
        if (TriggerType = TRIGGER_SOUND) and
           (Sound <> nil) then
          Sound.Stop();

  if gMusic <> nil then
    gMusic.Stop();

  if all then
    e_StopChannels();
end;

procedure g_Game_UpdateTriggerSounds();
var
  i: Integer;
begin
  if gTriggers <> nil then
    for i := 0 to High(gTriggers) do
      with gTriggers[i] do
        if (TriggerType = TRIGGER_SOUND) and
           (Sound <> nil) and
           (Data.Local) and
           Sound.IsPlaying() then
        begin
          if ((gPlayer1 <> nil) and g_CollidePoint(gPlayer1.GameX, gPlayer1.GameY, X, Y, Width, Height)) or
             ((gPlayer2 <> nil) and g_CollidePoint(gPlayer2.GameX, gPlayer2.GameY, X, Y, Width, Height)) then
          begin
            Sound.SetPan(0.5 - Data.Pan/255.0);
            Sound.SetVolume(Data.Volume/255.0);
          end
          else
            Sound.SetCoords(X+(Width div 2), Y+(Height div 2), Data.Volume/255.0);
        end;
end;

function g_Game_IsWatchedPlayer(UID: Word): Boolean;
begin
  Result := False;
  if (gPlayer1 <> nil) and (gPlayer1.UID = UID) then
  begin
    Result := True;
    Exit;
  end;
  if (gPlayer2 <> nil) and (gPlayer2.UID = UID) then
  begin
    Result := True;
    Exit;
  end;
  if gSpectMode <> SPECT_PLAYERS then
    Exit;
  if gSpectPID1 = UID then
  begin
    Result := True;
    Exit;
  end;
  if gSpectViewTwo and (gSpectPID2 = UID) then
  begin
    Result := True;
    Exit;
  end;
end;

function g_Game_IsWatchedTeam(Team: Byte): Boolean;
var
  Pl: TPlayer;
begin
  Result := False;
  if (gPlayer1 <> nil) and (gPlayer1.Team = Team) then
  begin
    Result := True;
    Exit;
  end;
  if (gPlayer2 <> nil) and (gPlayer2.Team = Team) then
  begin
    Result := True;
    Exit;
  end;
  if gSpectMode <> SPECT_PLAYERS then
    Exit;
  Pl := g_Player_Get(gSpectPID1);
  if (Pl <> nil) and (Pl.Team = Team) then
  begin
    Result := True;
    Exit;
  end;
  if gSpectViewTwo then
  begin
    Pl := g_Player_Get(gSpectPID2);
    if (Pl <> nil) and (Pl.Team = Team) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure g_Game_Message(Msg: string; Time: Word);
begin
  MessageText := b_Text_Format(Msg);
  MessageTime := Time;
end;

procedure g_Game_Announce_GoodShot(SpawnerUID: Word);
var
  a: Integer;
begin
  case gAnnouncer of
    ANNOUNCE_NONE:
      Exit;
    ANNOUNCE_ME,
    ANNOUNCE_MEPLUS:
      if not g_Game_IsWatchedPlayer(SpawnerUID) then
        Exit;
  end;
  for a := 0 to 3 do
    if goodsnd[a].IsPlaying() then
      Exit;

  goodsnd[Random(4)].Play();
end;

procedure g_Game_Announce_KillCombo(Param: Integer);
var
  UID: Word;
  c, n: Byte;
  Pl: TPlayer;
  Name: String;
begin
  UID := Param and $FFFF;
  c := Param shr 16;
  if c < 2 then
    Exit;

  Pl := g_Player_Get(UID);
  if Pl = nil then
    Name := '?'
  else
    Name := Pl.Name;

  case c of
    2: begin
      n := 0;
      g_Console_Add(Format(_lc[I_PLAYER_KILL_2X], [Name]), True);
    end;
    3: begin
      n := 1;
      g_Console_Add(Format(_lc[I_PLAYER_KILL_3X], [Name]), True);
    end;
    4: begin
      n := 2;
      g_Console_Add(Format(_lc[I_PLAYER_KILL_4X], [Name]), True);
    end;
    else begin
      n := 3;
      g_Console_Add(Format(_lc[I_PLAYER_KILL_MX], [Name]), True);
    end;
  end;

  case gAnnouncer of
    ANNOUNCE_NONE:
      Exit;
    ANNOUNCE_ME:
      if not g_Game_IsWatchedPlayer(UID) then
        Exit;
    ANNOUNCE_MEPLUS:
      if (not g_Game_IsWatchedPlayer(UID)) and (c < 4) then
        Exit;
  end;

  if killsnd[n].IsPlaying() then
    killsnd[n].Stop();
  killsnd[n].Play();
end;

procedure g_Game_StartVote(Command, Initiator: string);
var
  Need: Integer;
begin
  if not gVotesEnabled then Exit;
  if gGameSettings.GameType <> GT_SERVER then Exit;
  if gVoteInProgress or gVotePassed then
  begin
    g_Console_Add(Format(_lc[I_MESSAGE_VOTE_INPROGRESS], [gVoteCommand]), True);
    MH_SEND_VoteEvent(NET_VE_INPROGRESS, gVoteCommand);
    Exit;
  end;
  gVoteInProgress := True;
  gVotePassed := False;
  gVoteTimer := gTime + gVoteTimeout * 1000;
  gVoteCount := 0;
  gVoted := False;
  gVoteCommand := Command;

  if (gPlayer1 <> nil) or (gPlayer2 <> nil) then
    Need := Floor((NetClientCount+1)/2.0)+1
  else
    Need := Floor(NetClientCount/2.0)+1;
  g_Console_Add(Format(_lc[I_MESSAGE_VOTE_STARTED], [Initiator, Command, Need]), True);
  MH_SEND_VoteEvent(NET_VE_STARTED, Initiator, Command, Need);
end;

procedure g_Game_CheckVote;
var
  I, Need: Integer;
begin
  if gGameSettings.GameType <> GT_SERVER then Exit;
  if not gVoteInProgress then Exit;

  if (gTime >= gVoteTimer) then
  begin
    if (gPlayer1 <> nil) or (gPlayer2 <> nil) then
      Need := Floor((NetClientCount+1)/2.0) + 1
    else
      Need := Floor(NetClientCount/2.0) + 1;
    if gVoteCount >= Need then
    begin
      g_Console_Add(Format(_lc[I_MESSAGE_VOTE_PASSED], [gVoteCommand]), True);
      MH_SEND_VoteEvent(NET_VE_PASSED, gVoteCommand);
      gVotePassed := True;
      gVoteCmdTimer := gTime + 5000;
    end
    else
    begin
      g_Console_Add(_lc[I_MESSAGE_VOTE_FAILED], True);
      MH_SEND_VoteEvent(NET_VE_FAILED);
    end;
    if NetClients <> nil then
      for I := Low(NetClients) to High(NetClients) do
        if NetClients[i].Used then
          NetClients[i].Voted := False;
    gVoteInProgress := False;
    gVoted := False;
    gVoteCount := 0;
  end
  else
  begin
    if (gPlayer1 <> nil) or (gPlayer2 <> nil) then
      Need := Floor((NetClientCount+1)/2.0) + 1
    else
      Need := Floor(NetClientCount/2.0) + 1;
    if gVoteCount >= Need then
    begin
      g_Console_Add(Format(_lc[I_MESSAGE_VOTE_PASSED], [gVoteCommand]), True);
      MH_SEND_VoteEvent(NET_VE_PASSED, gVoteCommand);
      gVoteInProgress := False;
      gVotePassed := True;
      gVoteCmdTimer := gTime + 5000;
      gVoted := False;
      gVoteCount := 0;
      if NetClients <> nil then
        for I := Low(NetClients) to High(NetClients) do
          if NetClients[i].Used then
            NetClients[i].Voted := False;
    end;
  end;
end;

procedure g_Game_LoadMapList(FileName: string);
var
  ListFile: TextFile;
  s: string;
begin
  MapList := nil;
  MapIndex := -1;

  if not FileExists(FileName) then Exit; 

  AssignFile(ListFile, FileName);
  Reset(ListFile);
  while not EOF(ListFile) do
  begin
    ReadLn(ListFile, s);

    s := Trim(s);
    if s = '' then Continue;

    SetLength(MapList, Length(MapList)+1);
    MapList[High(MapList)] := s;
  end;
  CloseFile(ListFile);
end;

procedure g_Game_SetDebugMode();
begin
  gDebugMode := True;
// ���� (���� � ����� ����):
  gCheats := True;
end;

procedure g_Game_SetLoadingText(Text: String; Max: Integer; reWrite: Boolean);
var
  i: Word;
begin
  if Length(LoadingStat.Msgs) = 0 then
    Exit;

  with LoadingStat do
  begin
    if not reWrite then
    begin // ��������� �� ��������� ������ ��� �����������:
      if NextMsg = Length(Msgs) then
        begin // scroll
          for i := 0 to High(Msgs)-1 do
            Msgs[i] := Msgs[i+1];
        end
      else
        Inc(NextMsg);
    end else
      if NextMsg = 0 then
        Inc(NextMsg);

    Msgs[NextMsg-1] := Text;
    CurValue := 0;
    MaxValue := Max;
    ShowCount := 0;
  end;

  g_ActiveWindow := nil;

  ProcessLoading;
end;

procedure g_Game_StepLoading();
begin
  with LoadingStat do
  begin
    Inc(CurValue);
    Inc(ShowCount);
    if (ShowCount > LOADING_SHOW_STEP) then
    begin
      ShowCount := 0;
      ProcessLoading;
    end;
  end;
end;

procedure g_Game_ClearLoading();
var
  len: Word;
begin
  with LoadingStat do
  begin
    CurValue := 0;
    MaxValue := 0;
    ShowCount := 0;
    len := ((gScreenHeight div 3)*2 - 50) div LOADING_INTERLINE;
    SetLength(Msgs, len);
    for len := 0 to High(Msgs) do
      Msgs[len] := '';
    NextMsg := 0;
  end;
end;

procedure Parse_Params(var pars: TParamStrValues);
var
  i: Integer;
  s: String;
begin
  SetLength(pars, 0);
  i := 1;
  while i <= ParamCount do
  begin
    s := ParamStr(i);
    if (s[1] = '-') and (Length(s) > 1) then
    begin
      if (s[2] = '-') and (Length(s) > 2) then
        begin // ��������� ��������
          SetLength(pars, Length(pars) + 1);
          with pars[High(pars)] do
          begin
            Name := LowerCase(s);
            Value := '+';
          end;
        end
      else
        if (i < ParamCount) then
        begin // �������� �� ���������
          Inc(i);
          SetLength(pars, Length(pars) + 1);
          with pars[High(pars)] do
          begin
            Name := LowerCase(s);
            Value := LowerCase(ParamStr(i));
          end;
        end;
    end;

    Inc(i);
  end;
end;

function Find_Param_Value(var pars: TParamStrValues; aName: String): String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to High(pars) do
    if pars[i].Name = aName then
    begin
      Result := pars[i].Value;
      Break;
    end;
end;

procedure g_Game_Process_Params();
var
  pars: TParamStrValues;
  map: String;
  GMode, n: Byte;
  LimT, LimS: Integer;
  Opt: LongWord;
  Lives: Integer;
  s: String;
  Port: Integer;
  ip: String;
  F: TextFile;
begin
  Parse_Params(pars);

// Debug mode:
  s := Find_Param_Value(pars, '--debug');
  if (s <> '') then
    g_Game_SetDebugMode();

// Connect when game loads
  ip := Find_Param_Value(pars, '-connect');

  if ip <> '' then
  begin
    s := Find_Param_Value(pars, '-port');
    if (s = '') or not TryStrToInt(s, Port) then
      Port := 25666;

    s := Find_Param_Value(pars, '-pw');

    g_Game_StartClient(ip, Port, s);
    Exit;
  end;

// Start map when game loads:
  map := LowerCase(Find_Param_Value(pars, '-map'));
  if (map <> '') and (Pos('.wad:\', map) > 0) then
  begin
  // Game mode:
    s := Find_Param_Value(pars, '-gm');
    GMode := g_Game_TextToMode(s);
    if GMode = GM_NONE then GMode := GM_DM;
    if GMode = GM_SINGLE then GMode := GM_COOP;

  // Time limit:
    s := Find_Param_Value(pars, '-limt');
    if (s = '') or (not TryStrToInt(s, LimT)) then
      LimT := 0;
    if LimT < 0 then
      LimT := 0;

  // Goal limit:
    s := Find_Param_Value(pars, '-lims');
    if (s = '') or (not TryStrToInt(s, LimS)) then
      LimS := 0;
    if LimS < 0 then
      LimS := 0;

  // Lives limit:
    s := Find_Param_Value(pars, '-lives');
    if (s = '') or (not TryStrToInt(s, Lives)) then
      Lives := 0;
    if Lives < 0 then
      Lives := 0;

  // Options:
    s := Find_Param_Value(pars, '-opt');
    if (s = '') then
      Opt := GAME_OPTION_ALLOWEXIT or GAME_OPTION_BOTVSPLAYER or GAME_OPTION_BOTVSMONSTER
    else
      Opt := StrToIntDef(s, 0);
    if Opt = 0 then
      Opt := GAME_OPTION_ALLOWEXIT or GAME_OPTION_BOTVSPLAYER or GAME_OPTION_BOTVSMONSTER;

  // Close after map:
    s := Find_Param_Value(pars, '--close');
    if (s <> '') then
      gMapOnce := True;

  // Delete test map after play:
    s := Find_Param_Value(pars, '--testdelete');
    if (s <> '') then
      gMapToDelete := MapsDir + map;

  // Delete temporary WAD after play:
    s := Find_Param_Value(pars, '--tempdelete');
    if (s <> '') then
    begin
      gMapToDelete := MapsDir + map;
      gTempDelete := True;
    end;

  // Number of players:
    s := Find_Param_Value(pars, '-pl');
    if (s = '') then
      n := 1
    else
      n := StrToIntDef(s, 1);

  // Start:
    s := Find_Param_Value(pars, '-port');
    if (s = '') or not TryStrToInt(s, Port) then
      g_Game_StartCustom(map, GMode, LimT, LimS, Lives, Opt, n)
    else
      g_Game_StartServer(map, GMode, LimT, LimS, Lives, Opt, n, 0, Port);
  end;

// Execute script when game loads:
  s := Find_Param_Value(pars, '-exec');
  if s <> '' then
  begin
    if Pos(':\', s) = 0 then
      s := GameDir + '\' + s;

    {$I-}
    AssignFile(F, s);
    Reset(F);
    if IOResult <> 0 then
    begin
      e_WriteLog(Format(_lc[I_SIMPLE_ERROR], ['Failed to read file: ' + s]), MSG_WARNING);
      g_Console_Add(Format(_lc[I_CONSOLE_ERROR_READ], [s]));
      CloseFile(F);
      Exit;
    end;
    e_WriteLog('Executing script: ' + s, MSG_NOTIFY);
    g_Console_Add(Format(_lc[I_CONSOLE_EXEC], [s]));

    while not EOF(F) do
    begin
      ReadLn(F, s);
      if IOResult <> 0 then
      begin
        e_WriteLog(Format(_lc[I_SIMPLE_ERROR], ['Failed to read file: ' + s]), MSG_WARNING);
        g_Console_Add(Format(_lc[I_CONSOLE_ERROR_READ], [s]));
        CloseFile(F);
        Exit;
      end;
      if Pos('#', s) <> 1 then // script comment
        g_Console_Process(s, True);
    end;

    CloseFile(F);
    {$I+}
  end;

  SetLength(pars, 0);
end;

end.
