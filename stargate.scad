diameter = 76.2;

dimension = "in"; // [in:Inner Diameter, out:Outer Diameter]

ID = dimension == "in" ? diameter        : diameter * 0.75;
OD = dimension == "in" ? diameter * 1.38 : diameter;
H  = dimension == "in" ? diameter * 0.05 : diameter * 0.04;
H8 = H/8;
A9 = 360/9;

$fa = 0.01 + 0;
$fs =    4 + 0;
//$fn = 50 + 0;

module ring(id, od, h) {
	difference() {
		cylinder(d=od, h=h);
		translate([0, 0, -1])
			cylinder(d=id, h=h+2);
	}
}

module chevron() {
	a = 11.5;
	t = H8*9;

	difference() {                      // Top arc
		cylinder(d=OD, h=t);
		translate([0, -ID*0.02, 1])
			cube([OD+2, OD, ID], true); // Flatten bottom
		translate([0, 0, -1]) {
			rotate(-a, [0,0,1])
				cube([ID, ID, t+2]);    // Clip right point corner
			rotate(a+90, [0,0,1])
				cube([ID, ID, t+2]);    // Clip left point corner
			translate([0, OD*0.48, 0])
				linear_extrude(t+2)
					scale(H8*0.95)
						import("images/chevron-upper.svg", center=true);
		}
	}

	translate([0, OD*0.4725, 0])        // Upper lighted chevron
		difference() {
			linear_extrude(t)
				scale(H8*2/3)
					import("images/chevron-upper.svg", center=true);
			translate([0, H8*1.5, t-H8*0.6])
				linear_extrude(H)
					scale(H8*2/3)
						import("images/chevron-light.svg", center=true);
		}

	translate([0, ID*0.618, 0])          // Lower moveable chevron
		difference() {
			linear_extrude(t)
				scale(H8*0.8)
					import("images/chevron-lower.svg", center=true);

			for (i = [0:1:5]) {         // Light slits
				translate([-H*2, H8*i*1.7-H8*2.85, t-H8*0.6])
					cube([H*4, H8*0.7, H]);
			}
		}
}

module chevron_cutout() {
	translate([0, ID*0.62, H8*7]) {
		linear_extrude(H) {
			scale(H8*1.2)
				import("images/chevron-lower.svg", center=true);
			polygon([
				[+H8*8, +H8*9], // Q1
				[-H8*8, +H8*9], // Q2
				[-H8*4, -H8*4], // Q3
				[+H8*4, -H8*4]  // Q4
			]);
		}
		translate([-H*3, H*0.91, 0])
			cube([H*6, H, H]);
	}
	translate([0, OD*0.48, -1])
		difference() {
			linear_extrude(H+2)
				scale(H8*0.95)
					import("images/chevron-upper.svg", center=true);
			translate([-ID/2, -H*1.65, -2])
				cube([ID, H*2, H+4]);
		}
}

difference() {
	ring(ID, OD, H);                 // Main ring

	translate([0, 0, H8*6]) {
		ring(ID*1.03, ID*1.2305, H); // Symbol trough
		ring(OD*0.985, OD+1, H);     // Outer trough
	}

	for (i = [0:8]) {
		rotate(A9*i, [0,0,1]) {
			chevron_cutout();
		}
	}
}

for (i = [0:8]) {
	rotate(A9*i, [0,0,1])
		chevron();
}

a = -360/39;
for (i = [0:1:38]) {
	symbol = str("symbols/", i+1, ".svg");
	rotate(a*i, [0,0,1])
		translate([0, ID*0.565, 0])
			linear_extrude(H8*7)
				scale(H8*0.17)
					import(symbol, center=true, $fs=$fs*2);

	rotate(a*i+a/2, [0,0,1])
		translate([-H8/2, ID*0.51, 0])
			cube([H8, H*2.2, H8*6.5]); // Symbol separator
}
