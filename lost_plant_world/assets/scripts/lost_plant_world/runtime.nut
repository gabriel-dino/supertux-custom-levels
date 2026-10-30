// SPDX-License-Identifier: GPL-3.0-or-later
// Adapted from Plant (Copyright 2006 Matthias Braun), PlantKing, and the portable world controller.
function cw_max(a,b){return a>b?a:b;}
function cw_abs(a){return a<0?-a:a;}
class LPActor {
 world=null;cfg=null;object=null;kind="";x=0.0;y=0.0;sx=0.0;sy=0.0;vx=0.0;vy=0.0;
 width=0.0;height=0.0;dir=-1;hp=1;alive=true;activated=false;grounded=false;
 phase="sleep";phaseleft=0.0;cooldown=0.0;frozen=0.0;t=0.0;summons=0;
 constructor(w,c){
  world=w;cfg=c;kind=c.kind;object=w.env[c.name];x=object.get_x();y=object.get_y();sx=x;sy=y;
  dir=c.direction=="right"?1:-1;hp=c.lives;
  if(kind=="root")object.set_action("base-up");
  else object.set_action((kind=="dart"?"flying-":"sleeping-")+(dir<0?"left":"right"));
  width=object.get_width();height=object.get_height();
  if(kind=="summon"||kind=="dart"||kind=="root"){alive=false;object.set_visible(false);}
 }
 function action(prefix=""){object.set_action(prefix+(dir<0?"left":"right"));}
 function die(){
  if(!alive)return;alive=false;object.set_visible(false);object.set_pos(x,-10000);
  if(kind=="plant-king"){world.boss_hud(0);world.env.LPCrown.set_visible(false);}
  world.exec(cfg.death);
 }
 function stomp(p){
  if(kind!="plant-king"){if(p.get_action().find("buttjump")!=null){die();p.do_jump(-300);}else p.kill(false);return;}
  p.set_pos(p.get_x(),y-p.get_height()-2);p.do_jump(-300);
  if(cooldown>0||phase=="dead")return;
  hp--;cooldown=1.2;world.boss_hud(hp);
  if(hp<=0){phase="dead";phaseleft=1.5;vx=0;action("burning-");}
 }
 function attack(){
  local stage=hp>4?1:hp>2?2:3;
  if(stage>=2){
   foreach(a in world.actors)if(a.cfg.kind=="summon" && a.kind=="summon" && summons<6){
    a.kind="plant";a.alive=true;a.activated=true;a.x=x+(dir<0?-100:180);a.y=y;a.sx=a.x;a.sy=a.y;a.dir=dir;
    a.object.set_pos(a.x,a.y);a.object.set_visible(true);a.action("sleeping-");summons++;break;
   }
   foreach(a in world.actors)if(a.kind=="dart" && !a.alive){
    a.alive=true;a.x=x+(dir<0?-100:100);a.y=y+height-24;a.dir=dir;a.vx=dir*240.0;a.phaseleft=4.0;
    a.action("flying-");a.object.set_visible(true);break;
   }
  }
  if(stage==3)foreach(a in world.actors)if(a.kind=="root" && !a.alive){
   a.alive=true;a.x=sx-180;a.y=sy+height-6;a.sy=a.y;a.phase="warn";a.phaseleft=1.2;
   a.object.set_action("base-up");a.object.set_visible(true);break;
  }
 }
 function update(dt,p){
  if(!alive)return;
  t+=dt;cooldown=cw_max(0.0,cooldown-dt);
  object.set_visible(cooldown<=0||((t*20).tointeger()%2)==0);
  if(phase=="dead"){phaseleft-=dt;if(phaseleft<=0)die();return;}
  if(kind=="dart"){
   phaseleft-=dt;x+=vx*dt;
   if(phaseleft<=0||world.blocked(x+(dir>0?width:0),y+height/2)){die();return;}
   object.set_pos(x,y);contact(p);return;
  }
  if(kind=="root"){
   phaseleft-=dt;
   if(phase=="warn" && phaseleft<=0){phase="rise";phaseleft=1.2;object.set_action("root-up");}
   if(phase=="rise")y=sy-74.0*cw_max(0.0,sin((1.2-phaseleft)/1.2*3.14159));
   object.set_pos(x,y);
   if(phase=="rise")contact(p);
   if(phase=="rise" && phaseleft<=0)die();return;
  }
  if(!activated && cw_abs(p.get_x()-x)>900)return;activated=true;
  if(cw_abs(p.get_x()-x)>1400)return;
  if(frozen>0 && kind!="plant-king"){frozen-=dt;contact(p);return;}
  if(phase=="sleep"){
   local reach=kind=="plant-king"?384:256;
   local infront=dir<0?(p.get_x()+p.get_width()>=x-reach && p.get_x()<=x+width):(p.get_x()<=x+width+reach && p.get_x()+p.get_width()>=x);
   if(infront && (kind=="plant-king" || (p.get_y()+p.get_height()>=y && p.get_y()<=y+height))){phase="wake";phaseleft=1.0;action("waking-");}
  }else{
   phaseleft-=dt;
   if(phase=="wake" && phaseleft<=0){phase="walk";phaseleft=hp<=2?2.2:3.5;action();if(kind=="plant-king")attack();}
   else if(kind=="plant-king" && phase=="walk" && phaseleft<=0){phase="wake";phaseleft=1.0;dir=p.get_x()<x?-1:1;action("waking-");}
  }
  vx=phase=="walk"?dir*(kind=="plant-king" && hp<=2?140.0:80.0):0;
  if(kind=="plant-king" && (x<sx-240||x>sx+240)){dir=x<sx?1:-1;vx=dir*cw_abs(vx);}
  local nx=x+vx*dt;
  if(world.blocked(nx+(vx>0?width:0),y+height-5)||world.blocked(nx+(vx>0?width:0),y+5)){dir=-dir;vx=-vx;}else x=nx;
  vy+=1000*dt;local ny=y+vy*dt;grounded=false;
  if(vy>=0&&(world.blocked(x+3,ny+height)||world.blocked(x+width-3,ny+height))){y=floor((ny+height)/32)*32-height;vy=0;grounded=true;}else y=ny;
  if(phase=="walk")action();
  if(y>world.bottom+160){die();return;}
  object.set_pos(x,y);if(kind=="plant-king")world.env.LPCrown.set_pos(x+width/2-12,y-18);contact(p);
 }
 function contact(p){
  if(phase=="dead")return;
  local px=p.get_x(),py=p.get_y(),pw=p.get_width(),ph=p.get_height();
  if(px+pw<=x||px>=x+width||py+ph<y-3||py>=y+height)return;
  if(world.star>0 && kind!="plant-king"){die();return;}
  if((kind=="plant-king"||kind=="plant") && p.get_velocity_y()>=0 && py+ph<=y+cw_max(16.0,p.get_velocity_y()*0.05)){stomp(p);return;}
  p.kill(false);
 }
}
class CWWorld {
  env=null;actors=null;maps=null;time=0.0;bottom=768.0;star=0.0;crowns=null;running=false;shots=null;
  constructor(e,configs,map_names,level_bottom) {
    env=e;maps=map_names;bottom=level_bottom;actors=[];crowns=[];shots=[];
    foreach(c in configs)actors.append(LPActor(this,c));
    foreach(a in actors)if(a.kind=="plant-king") {
      for(local i=0;i<a.hp;i++){
        local crown=FloatingImage("images/creatures/plant/sleeping-left.png");
        crown.set_anchor_point(0);crown.set_pos(260+i*28,22);crown.set_layer(600);crown.set_visible(true);crowns.append(crown);
      }
    }
  }
  function boss_hud(hp){foreach(i,crown in crowns)crown.set_visible(i<hp);}
  function exec(source){if(source!="")compilestring(source).bindenv(env)();}
  function blocked(x,y) {
    if(x<0)return true;if(y<0)return false;if(y>=bottom)return false;
    foreach(name in maps){local map=env[name];if(map.get_solid() && map.get_tile_id_at(x,y)!=0)return true;}
    return false;
  }
  function projectiles(dt,p) {
    local bonus=p.get_bonus();
    if(p.get_input_pressed("action") && (bonus=="fireflower"||bonus=="iceflower") && shots.len()<2) {
      local d=p.get_action().find("left")!=null?-1:1;
      shots.append({x=p.get_x()+p.get_width()/2,y=p.get_y()+p.get_height()/4,
                    vx=d*600.0+p.get_velocity_x(),vy=0.0,life=3.0,ice=bonus=="iceflower"});
    }
    for(local i=shots.len()-1;i>=0;i--) {
      local b=shots[i];b.life-=dt;b.vy+=1000.0*dt;
      local nx=b.x+b.vx*dt,ny=b.y+b.vy*dt;
      if(blocked(nx,b.y)){b.life=0;}
      if(blocked(nx,ny) && b.vy>0){b.vy=-cw_max(300.0,cw_abs(b.vx)/3.8+300);ny=b.y;}
      b.x=nx;b.y=ny;
      foreach(enemy in actors) {
        if(!enemy.alive || b.x+8<enemy.x || b.x>enemy.x+enemy.width || b.y+8<enemy.y || b.y>enemy.y+enemy.height)continue;
        b.life=0;
        if(enemy.kind=="plant-king")break;
        if(b.ice){enemy.frozen=3.0;}
        else if(enemy.kind!="ember-beetle")enemy.die();
        break;
      }
      if(b.life<=0)shots.remove(i);
    }
  }
  function run() {
    if(running)return;running=true;
    while(true) {
      local dt=0.015;time+=dt;star=cw_max(0.0,star-dt);
      local p=env.Tux;
      projectiles(dt,p);
      foreach(a in actors)a.update(dt,p);
      // Scheduler wakes only after its deadline; use a sub-tick delay.
      wait(0.001);
    }
  }
}

class LPWorld extends CWWorld {}
