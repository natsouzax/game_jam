// Skeleton mage that guards a mid-tower checkpoint platform. y is the feet line.
hp=1;
state=0;          // 0 materialising, 1 idle, 2 casting
anim_t=0;
cast_t=0;
face=1;
shoot_timer=irandom_range(50,90);
projectile_speed=4.6;
depth=-4;
phase=0;
home_x=x;home_y=y;
