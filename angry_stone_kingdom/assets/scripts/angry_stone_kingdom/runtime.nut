// SPDX-License-Identifier: GPL-3.0-or-later
// Portable adaptation of AngryStone (2006 Matthias Braun) and KingAngryStone.
// Uses only the public SuperTux 0.7.0 scripting API. Single-player controller.
function ask_abs(x) { return x < 0 ? -x : x; }
function ask_max(a,b) { return a > b ? a : b; }
function ask_min(a,b) { return a < b ? a : b; }

class ASKActor {
  world=null; cfg=null; object=null; kind=""; x=0.0; y=0.0; sx=0.0; sy=0.0;
  width=0.0; height=0.0; vx=0.0; vy=0.0; dx=0; dy=0; olddx=0; olddy=0;
  phase="idle"; left=0.0; cooldown=0.0; frozen=0.0; hp=6; alive=true;
  grounded=false; attack_index=0; dir=-1; age=0.0; platform=null; platform_y=0.0;
  constructor(w,c) {
    world=w;cfg=c;object=w.env[c.name];kind=c.kind;
    x=object.get_x();y=object.get_y();sx=x;sy=y;
    object.set_action(kind=="rock"||kind=="wave" ? "variant-1" : "idle");
    width=object.get_width();height=object.get_height();
    if(kind=="guard"||kind=="rock"||kind=="wave") {alive=false;object.set_visible(false);}
    if(kind=="king") {phase="wait";world.boss=this;}
  }
  function activate(px,py,svx=0.0,svy=0.0) {
    alive=true;x=px;y=py;sx=x;sy=y;vx=svx;vy=svy;
    olddx=0;olddy=0;frozen=0;cooldown=0;platform=null;
    phase="idle";left=kind=="wave"?2.0:5.0;
    object.set_visible(true);object.set_pos(x,y);
    object.set_action(kind=="rock"||kind=="wave"?"variant-1":"idle");
  }
  function die() {
    if(!alive)return;alive=false;object.set_visible(false);object.set_pos(x,-10000);
    if(kind=="king") {
      world.boss_hud(0);world.env.ASKCrown.set_visible(false);
      foreach(a in world.actors)if(a.kind=="guard"||a.kind=="rock"||a.kind=="wave")a.die();
      world.exec(cfg.death);
    }
  }
  function recover() {
    phase="recover";left=kind=="king"?2.4:0.5;vx=0;vy=0;
    object.set_action("idle");
  }
  function stage() { return hp>4?1:hp>2?2:3; }
  function stomp(p) {
    p.set_pos(p.get_x(),y-p.get_height()-2);p.set_velocity(p.get_velocity_x(),-300);
    if(phase!="recover"||cooldown>0)return;
    hp--;cooldown=1.2;world.boss_hud(hp);play_sound("sounds/icecrash.ogg");
    if(hp<=0) {phase="dead";left=2.0;vx=0;vy=0;}
  }
  function king_attack(p) {
    local n=attack_index++%4;
    if(n==0) {phase="roll";left=1.2;vx=dir*(230+55*stage());object.set_action("attacking");}
    else if(n==1) {phase="jump";left=3.0;vx=dir*85;vy=-480-30*stage();grounded=false;object.set_action("attacking");}
    else if(n==2) {
      local target=ask_max(sx-290,ask_min(sx+290,p.get_x()));local offset=-stage();
      foreach(a in world.actors)if(a.kind=="rock"&&!a.alive&&offset<=stage()) {
        a.activate(target+offset*90,64,0,60);offset++;
      }
      play_sound("sounds/thud.ogg");recover();
    } else {
      local slot=0;
      foreach(a in world.actors)if(a.kind=="guard") {
        if(!a.alive)a.activate(sx+(slot==0?-250:250),y+height-a.height);
        slot++;
      }
      recover();
    }
  }
  function waves() {
    local side=-1;
    foreach(a in world.actors)if(a.kind=="wave") {
      a.activate(side<0?x-a.width-4:x+width+4,y+height-a.height,side*(160+35*stage()),0);
      side=1;
    }
    play_sound("sounds/thud.ogg");
  }
  function contact(p) {
    if(phase=="dead")return;
    local px=p.get_x(),py=p.get_y(),pw=p.get_width(),ph=p.get_height();
    if(px+pw<=x||px>=x+width||py+ph<y-2||py>=y+height)return;
    if(kind=="king"&&p.get_velocity_y()>0&&py+ph<=y+ask_max(16.0,p.get_velocity_y()*0.045)) {stomp(p);return;}
    if(frozen>0&&p.get_action().find("buttjump")!=null) {die();p.set_velocity(p.get_velocity_x(),-300);return;}
    if(frozen<=0)p.kill(false);
  }
  function move(dt) {
    grounded=false;
    if(platform!=null&&vy>=0) {
      local py=world.env[platform].get_y();
      if(x+width>world.env[platform].get_x()&&x<world.env[platform].get_x()+world.env[platform].get_width()) y+=py-platform_y;
      platform=null;
    }
    // Small steps prevent a fast charge from tunnelling through a 32px tile.
    local steps=(ask_max(ask_abs(vx),ask_abs(vy))*dt/4).tointeger()+1;
    for(local i=0;i<steps;i++) {
      local nx=x+vx*dt/steps;
      if(vx!=0 && (world.blocked(vx>0?nx+width:nx,y+2)||world.blocked(vx>0?nx+width:nx,y+height-2)||world.blocked(vx>0?nx+width:nx,y+height/2))) {
        if(phase=="attack") {olddx=dx;olddy=dy;recover();}
        else if(phase=="roll")recover();
        else if(kind=="wave"||kind=="rock") {die();return;}
        vx=0;
      } else x=nx;
      local ny=y+vy*dt/steps;
      local edge=vy>0?ny+height:ny;
      local hit=vy!=0&&(world.blocked(x+2,edge)||world.blocked(x+width-2,edge)||world.blocked(x+width/2,edge));
      local floor_y=0.0;
      if(vy>=0)foreach(name in world.platforms) {
        local obj=world.env[name];local top=obj.get_y();
        if(x+width>obj.get_x()&&x<obj.get_x()+obj.get_width()&&y+height<=top+3&&ny+height>=top) {
          hit=true;floor_y=top;platform=name;platform_y=top;break;
        }
      }
      if(hit) {
        local falling=vy>=0;
        if(falling) {y=(floor_y>0?floor_y:floor(edge/32)*32)-height;grounded=true;}
        else y=(floor(edge/32)+1)*32;
        vy=0;
        if(kind=="rock") {die();return;}
        if(phase=="attack") {olddx=dx;olddy=dy;recover();}
        else if(phase=="jump"&&falling) {waves();recover();}
      } else y=ny;
    }
  }
  function update(dt,p) {
    if(!alive)return;
    age+=dt;cooldown=ask_max(0.0,cooldown-dt);
    object.set_visible((cooldown<=0&&frozen<=0)||((age*16).tointeger()%2)==0);
    if(phase=="dead") {left-=dt;if(left<=0)die();return;}
    if(ask_abs(p.get_x()-x)>1400 && kind!="king")return;
    if(frozen>0) {frozen=ask_max(0.0,frozen-dt);contact(p);return;}
    if(kind=="rock"||kind=="wave") {
      left-=dt;if(left<=0) {die();return;}
    } else if(kind=="king") {
      if(phase=="wait") {if(ask_abs(p.get_x()-x)<440)recover();}
      else {
        left-=dt;
        if(phase=="roll"&&ask_abs(x-sx)>300)recover();
        if(left<=0) {
          if(phase=="recover") {phase="windup";left=1.2-0.15*stage();dir=p.get_x()<x?-1:1;object.set_action("charging");}
          else if(phase=="windup")king_attack(p);
          else recover();
        }
      }
    } else {
      left-=dt;
      if(phase=="idle") {
        local ndx=0,ndy=0;
        if(p.get_x()-x>-p.get_width()&&p.get_x()-x<width)ndy=p.get_y()>y?1:-1;
        else if(p.get_y()-y>-p.get_height()&&p.get_y()-y<height)ndx=p.get_x()>x?1:-1;
        if((ndx!=0||ndy!=0)&&(ndx!=olddx||ndy!=olddy)) {
          dx=ndx;dy=ndy;phase="charge";left=0.5;object.set_action("charging");
        }
      } else if(left<=0) {
        if(phase=="charge") {phase="attack";left=1.0;vx=dx*240;vy=dy*240;olddx=0;olddy=0;object.set_action("attacking");}
        else if(phase=="attack")recover();
        else {phase="idle";object.set_action("idle");}
      }
    }
    if(phase!="attack")vy+=1000*dt;
    move(dt);if(!alive)return;
    if(y>world.bottom+160) {die();return;}
    object.set_pos(x,y);
    if(kind=="king")world.env.ASKCrown.set_pos(x+width/2-12,y-18);
    contact(p);
  }
}

class ASKWorld {
  env=null; actors=null; maps=null; platforms=null; bottom=832; boss=null;
  crowns=null; shots=null; running=false; time=0.0;
  constructor(e,configs,map_names,platform_names,level_bottom) {
    env=e;maps=map_names;platforms=platform_names;bottom=level_bottom;actors=[];crowns=[];shots=[];
    foreach(c in configs)actors.append(ASKActor(this,c));
    if(boss!=null)for(local i=0;i<6;i++) {
      local icon=FloatingImage("images/worldmap/angry_stone_kingdom/king-hud.png");
      icon.set_anchor_point(0);icon.set_pos(260+i*30,22);icon.set_layer(600);icon.set_visible(true);crowns.append(icon);
    }
  }
  function boss_hud(hp) {foreach(i,c in crowns)c.set_visible(i<hp);}
  function exec(source) {if(source!="")compilestring(source).bindenv(env)();}
  function blocked(x,y) {
    if(x<0)return true;if(y<0||y>=bottom)return false;
    foreach(name in maps)if(env[name].get_solid()&&env[name].get_tile_id_at(x,y)!=0)return true;
    return false;
  }
  function projectiles(dt,p) {
    if(p.get_input_pressed("action")&&p.get_bonus()=="iceflower"&&shots.len()<2) {
      local d=p.get_action().find("left")!=null?-1:1;
      shots.append({x=p.get_x()+p.get_width()/2,y=p.get_y()+p.get_height()/4,vx=d*600.0+p.get_velocity_x(),vy=0.0,life=3.0});
    }
    for(local i=shots.len()-1;i>=0;i--) {
      local b=shots[i];b.life-=dt;b.vy+=1000*dt;
      local nx=b.x+b.vx*dt,ny=b.y+b.vy*dt;
      if(blocked(nx,b.y))b.life=0;
      if(blocked(nx,ny)&&b.vy>0) {b.vy=-300;ny=b.y;}
      b.x=nx;b.y=ny;
      foreach(a in actors) {
        if(!a.alive||a.kind=="king"||a.kind=="rock"||a.kind=="wave"||b.x+8<a.x||b.x>a.x+a.width||b.y+8<a.y||b.y>a.y+a.height)continue;
        b.life=0;
        if(a.phase!="attack") {a.frozen=3.0;a.vx=0;a.vy=0;a.phase="idle";a.object.set_action("idle");}
        break;
      }
      if(b.life<=0)shots.remove(i);
    }
  }
  function run() {
    if(running)return;running=true;
    while(true) {
      local dt=0.015;time+=dt;local p=env.Tux;
      projectiles(dt,p);foreach(a in actors)a.update(dt,p);
      wait(0.001);
    }
  }
}
