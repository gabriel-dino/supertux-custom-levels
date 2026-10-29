function cw_max(a,b){return a>b?a:b;}
function cw_abs(a){return a<0?-a:a;}
// Portable custom-world controller for unmodified SuperTux 0.7.0.
// GPL-3.0-or-later. Original actor behavior ported from the custom level project.
class CWActor {
  world=null; cfg=null; object=null; kind=null; x=0.0; y=0.0; sx=0.0; sy=0.0;
  vx=0.0; vy=0.0; dir=-1; width=32.0; height=32.0; speed=80.0;
  alive=true; activated=false; grounded=false; cooldown=0.0; frozen=0.0; phase="walk";
  phaseleft=0.8; hp=1; t=0.0; collapse=0.0; shell=true; oldbottom=0.0;
  constructor(w,c) {
    world=w;cfg=c;kind=c.kind;object=w.env[c.name];x=object.get_x();y=object.get_y();sx=x;sy=y;
    width=object.get_width();height=object.get_height();dir=c.direction=="right"?1:-1;
    if(kind=="ember-beetle")speed=140.0;
    if(kind=="crystal-crab")speed=65.0;
    if(kind=="armored-snail"){speed=40.0;hp=2;}
    if(kind=="eggshell-guard"){speed=55.0;hp=2;}
    if(kind=="bone-walker")speed=70.0;
    if(kind=="spring-toad")speed=70.0;
    if(kind=="marshmallow-monarch"){hp=c.lives;phase="windup";phaseleft=1.2;}
    object.set_action((kind=="marshmallow-monarch"?"crouch-":"")+(dir<0?"left":"right"));
  }
  function action(prefix="") {
    object.set_action(prefix+(dir<0?"left":"right"));
  }
  function die() {
    if(!alive)return;
    alive=false;object.set_visible(false);object.set_pos(x,-10000);
    world.exec(cfg.death);
    if(kind=="marshmallow-monarch")world.boss_hud(0);
  }
  function stomp(p) {
    if(!alive)return;
    p.set_pos(p.get_x(),y-p.get_height()-2);p.do_jump(-300.0);
    if(cooldown>0)return;
    if(frozen>0){die();return;}
    if(kind=="marshmallow-monarch") {
      if(phase!="recover"){p.kill(false);return;}
      hp--;cooldown=0.8;world.boss_hud(hp);
      if(hp==2)world.exec(cfg.pinch);
      if(hp<=0){die();return;}
      phase="windup";phaseleft=0.9;action("crouch-");
    } else if(kind=="bone-walker") {
      if(collapse>0){die();return;}
      collapse=2.4;cooldown=0.35;action("squished-");
    } else if(hp>1) {
      hp--;shell=false;cooldown=0.4;
      speed=kind=="armored-snail"?105.0:95.0;
    } else die();
  }
  function update(dt,p) {
    if(!alive)return;
    if(!activated && cw_abs(p.get_x()-sx)>900)return;
    activated=true;
    if(cw_abs(p.get_x()-x)>1400)return;
    t+=dt;cooldown=cw_max(0.0,cooldown-dt);
    if(frozen>0){frozen-=dt;object.set_visible(((t*6).tointeger()%2)==0);contact(p);return;}
    object.set_visible(cooldown<=0 || ((t*20).tointeger()%2)==0);
    if(collapse>0){
      collapse-=dt;
      if(collapse<=0)action();
      else {contact(p);return;}
    }
    local flying=kind=="snow-wisp"||kind=="peep-glider"||kind=="vampire-bat";
    if(flying) {
      local radius=kind=="snow-wisp"?96.0:kind=="peep-glider"?112.0:128.0;
      if(x<=sx-radius)dir=1;if(x>=sx+radius)dir=-1;
      vx=dir*(kind=="snow-wisp"?70.0:kind=="peep-glider"?85.0:65.0);
      vy=(sy+sin(t*2.0)*20.0-y)*3.0;
      if(kind=="vampire-bat") {
        phaseleft-=dt;
        if(phase=="dive") {
          vy=180.0;vx=dir*120.0;
          if(phaseleft<=0){phase="recover";phaseleft=0.65;}
        } else if(phase=="recover") {
          vy=-150.0;if(phaseleft<=0){phase="walk";phaseleft=2.0;}
        } else if(phaseleft<=0 && cw_abs(p.get_x()-x)<180 && p.get_y()>y+32) {
          dir=p.get_x()<x?-1:1;phase="dive";phaseleft=0.45;
        }
      }
      local nx=x+vx*dt,ny=y+vy*dt;
      if(world.blocked(nx+(dir>0?width:0),y+height/2))dir=-dir;else x=nx;
      if(!world.blocked(x+width/2,ny+height/2))y=ny;
      action();
    } else {
      phaseleft-=dt;
      if(kind=="marshmallow-monarch") {
        if(phase=="windup" && phaseleft<=0 && grounded) {
          dir=p.get_x()<x?-1:1;
          if(x<=cfg.left+8)dir=1;if(x>=cfg.right-8)dir=-1;
          vx=dir*(hp<=2?220.0:155.0);vy=hp<=2?-450.0:-400.0;
          phase="hop";grounded=false;action("hop-");
        } else if(phase=="recover" && phaseleft<=0) {
          phase="windup";phaseleft=hp<=2?0.65:1.0;action("crouch-");
        }
        if(phase!="hop")vx=0.0;
        else if(x<=cfg.left||x>=cfg.right){dir=x<=cfg.left?1:-1;vx=dir*cw_abs(vx);}
      } else if(kind=="bonbon-bunny"||kind=="pumpkin-pouncer") {
        if(grounded) {
          vx=0.0;
          if(phaseleft<=0){
            dir=p.get_x()<x?-1:1;vx=dir*(kind=="bonbon-bunny"?110.0:130.0);
            vy=kind=="bonbon-bunny"?-390.0:-430.0;
            phaseleft=kind=="bonbon-bunny"?1.6:1.8;grounded=false;
          }
        }
      } else {
        vx=dir*speed;
        if(kind=="spring-toad" && grounded && phaseleft<=0){vy=-400.0;phaseleft=1.25;grounded=false;}
        local smart=kind=="crystal-crab"||kind=="armored-snail"||kind=="eggshell-guard"||kind=="bone-walker";
        if(smart && grounded && !world.blocked(x+(dir>0?width+5:-5),y+height+6)){dir=-dir;vx=dir*speed;}
      }
      local nx=x+vx*dt;
      if(world.blocked(nx+(vx>0?width:0),y+height-5)||world.blocked(nx+(vx>0?width:0),y+5)){
        dir=-dir;vx=-vx;
      }else x=nx;
      oldbottom=y+height;
      vy+=1000.0*dt;local ny=y+vy*dt;
      grounded=false;
      if(vy>=0 && (world.blocked(x+3,ny+height)||world.blocked(x+width-3,ny+height))) {
        y=floor((ny+height)/32.0)*32.0-height;grounded=true;vy=0.0;
        if(kind=="marshmallow-monarch" && phase=="hop"){
          phase="recover";phaseleft=hp<=2?1.45:1.9;vx=0.0;action("dizzy-");
        }
      }else if(vy<0 && (world.blocked(x+3,ny)||world.blocked(x+width-3,ny))){vy=0.0;}
      else y=ny;
      if(kind!="marshmallow-monarch")action();
    }
    if(y>world.bottom+160){die();return;}
    object.set_pos(x,y);
    contact(p);
  }
  function contact(p) {
    local px=p.get_x(),py=p.get_y(),pw=p.get_width(),ph=p.get_height();
    if(px+pw<=x||px>=x+width||py+ph<y-3||py>=y+height)return;
    if(world.star>0 && kind!="marshmallow-monarch"){die();return;}
    local stomped=p.get_velocity_y()>=0 && py+ph<=y+cw_max(16.0,p.get_velocity_y()*0.05);
    if(stomped){stomp(p);return;}
    if(collapse>0)return;
    p.kill(false);
  }
}
class CWWorld {
  env=null;actors=null;maps=null;time=0.0;bottom=768.0;star=0.0;crowns=null;running=false;shots=null;
  constructor(e,configs,map_names,level_bottom) {
    env=e;maps=map_names;bottom=level_bottom;actors=[];crowns=[];shots=[];
    foreach(c in configs)actors.append(CWActor(this,c));
    foreach(a in actors)if(a.kind=="marshmallow-monarch") {
      for(local i=0;i<a.hp;i++){
        local crown=FloatingImage(a.cfg.hud);
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
        if(enemy.kind=="marshmallow-monarch")break;
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
