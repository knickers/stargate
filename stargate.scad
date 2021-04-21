diameter = 76.2;

dimension = "in"; // [in:Inner Diameter, out:Outer Diameter]

ID = dimension == "in" ? diameter        : diameter * 0.75;
OD = dimension == "in" ? diameter * 1.38 : diameter;
H  = dimension == "in" ? diameter * 0.05 : diameter * 0.04;

$fa = 0.01;
$fs = 4;
//$fn = 50 + 0;

module ring(id, od, h) {
	difference() {
		cylinder(d=od, h=h);
		translate([0, 0, -1])
			cylinder(d=id, h=h+2);
	}
}

module chevron_arc() {
	difference() {
		cylinder(d=OD*1.008, h=H*9/8);
		translate([0, -ID*0.025, 1])
			cube([OD+2, OD, ID], true);
		rotate(-15, [0,0,1])
			cube([OD, OD, ID]);
		rotate(105, [0,0,1])
			cube([OD, OD, ID]);
	}
}

module chevron_trapezoid(angle=20) {
	x = H/3;
	difference() {
		translate([-ID/6, 0, 0])
			cube([ID/3, ID/4, H]);
		translate([-x, 0, -1])
			rotate(angle+90, [0,0,1])
				cube([ID/3, ID/3, H+2]);
		translate([x, 0, -1])
			rotate(-angle, [0,0,1])
				cube([ID/3, ID/3, H+2]);
	}
	/*
	polygon([
		[],
		[],
		[],
		[],
	]);
	*/
}

module chevron() {
	chevron_arc();

	// Upper lighted chevron
	difference() {
		chevron_trapezoid();
		translate([0, H*2, -1])
			scale([1, 1, 2])
				chevron_trapezoid();
	}

	// Lower movable chevron
	translate([0, -H*2, 0])
		difference() {
			chevron_trapezoid(29);
			translate([0, H*1.2, -1])
				scale([1, 1, 2])
					chevron_trapezoid();
			translate([-ID/4, -H/1.4, -1])
				cube([ID/2, H, H+2]);
		}
}

import("images/chevron-lower.svg", center=true);
translate([0, H*2, 0])
	import("images/chevron-upper.svg", center=true);

difference() {
	ring(ID, OD, H);               // Main ring
	translate([0, 0, H*0.70])
		ring(ID*1.03, ID*1.22, H); // Symbol trough
}

b = 360/9;
/*
for (i = [0:0]) {
	rotate(b*i, [0,0,1])
		chevron();
}
*/

a = -360/39;
for (i = [0:3:38]) {
	rotate(a*i, [0,0,1])
		translate([0, ID*0.562, 0])
			linear_extrude(H*7/8)
				scale(25.4/320)
					import(
						str("symbols-by-number/", i+1, ".svg"),
						center=true,
						$fs=$fs*2
					);
	rotate(a*i+a/2, [0,0,1])
		translate([-H/16, ID*0.51, 0])
			cube([H/8, H*2.1, H*7/8]); // Symbol separator
}
