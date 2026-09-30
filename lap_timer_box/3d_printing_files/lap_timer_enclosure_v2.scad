/*
  RoboSTEAM lap-timer enclosure - version 2 print-and-fit prototype

  Architecture:
    - shallow bottom tray holds the PCB;
    - tall removable top holds the E18-D80NK sensor;
    - two exterior lugs screw into printed bottom bosses;
    - rear openings permit power and programming with the top installed.

  Coordinate system:
    X = rear to front
    Y = left to right
    Z = table upward

  Independent design: no downloaded meshes are imported or copied.
*/

part = "assembly"; // "assembly", "enclosure_preview", "base_preview", "top_preview", "base", "top", "pcb_fit_coupon", "sensor_nut_check", "screw_coupon"
explode = 0; // Set to 24 for an exploded assembly render.

$fn = 72;

// Printer and fit defaults
wall = 2.4;
floor_t = 2.4;
roof_t = 2.0;
fit = 0.30;

// PCB geometry measured from Baseboard_Scan_2.jpg at 600 pixels/inch.
// The scan-derived outline has +/-0.3 mm uncertainty; hole centres have +/-0.2 mm.
pcb_x = 60.3;
pcb_y = 59.5;
pcb_t = 1.6;
pcb_rear_clearance = 1.0;
pcb_front_clearance = 3.0;
pcb_side_clearance = 3.0;
pcb_standoff_h = 4.0;
pcb_standoff_d = 7.0;
pcb_pin_d = 2.8; // PROVISIONAL: scan suggests about 3.4 mm opening; fit-test this peg.
pcb_pin_tip_d = 2.2;
pcb_holes = [
  [4.6, 14.6],
  [4.6, 39.6],
  [56.9, 14.6],
  [56.9, 39.6]
];

// Enclosure envelope
inside_x = pcb_rear_clearance + pcb_x + pcb_front_clearance;
inside_y = pcb_y + 2*pcb_side_clearance;
outside_x = inside_x + 2*wall;
outside_y = inside_y + 2*wall;
overall_z = 61.0; // Keeps the v1 roof clearance while raising the sensor axis to 45 mm.
seam_z = 11.0;
top_h = overall_z - seam_z;

pcb_origin_x = wall + pcb_rear_clearance;
pcb_origin_y = wall + pcb_side_clearance;

// Sensor carried by the removable top
sensor_axis_z = 45.0; // User-selected v2 maximum height for generous NodeMCU clearance.
sensor_panel_hole_d = 19.0;
sensor_wall_pad_d = 27.0;
sensor_body_length = 50.0; // PROVISIONAL: measure actual E18-D80NK
sensor_front_protrusion = 3.0;
assumed_electronics_top_z = 24.0; // PROVISIONAL researched stack envelope
sensor_nominal_clearance = sensor_axis_z-9-assumed_electronics_top_z;
echo("PROVISIONAL sensor/electronics clearance (mm):", sensor_nominal_clearance);
echo("Version 2 nominal sensor/electronics vertical clearance target is about 12 mm");

// Rear connector passages - PROVISIONAL until actual hardware is measured.
// Coordinates are global: Y from outside left and Z from the table.
dc_center_from_rear_left = 12.0;
dc_center_y = outside_y-dc_center_from_rear_left; // DC jack is left when viewed from behind.
dc_center_z = floor_t + pcb_standoff_h + 6.0;
dc_open_y = 13.0;
dc_open_z = 13.0;

usb_center_y = outside_y/2;
usb_center_z = 18.0;
usb_open_y = 14.0; // molded plug-body clearance, not receptacle width
usb_open_z = 10.0; // molded plug-body clearance, not receptacle height
usb_outer_flare = 2.0;
usb_corner_r = 2.0;

// Shell locating lip
lip_h = 4.0;
lip_t = 1.4;

// No-insert fastening concept
screw_d = 3.0;
screw_clearance_d = 3.4;
screw_pilot_d = 2.6; // validate with coupon for actual printer/material/screw
screw_head_d = 6.5;
screw_head_depth = 2.0;
lug_d = 10.0;
lug_plate_t = 3.2;
lug_x = outside_x/2;
left_lug_y = -lug_d/2 + 1.0;
right_lug_y = outside_y + lug_d/2 - 1.0;

module rounded_box(size, radius) {
  x = size[0]; y = size[1]; z = size[2];
  hull() {
    for (px = [radius, x-radius], py = [radius, y-radius])
      translate([px, py, 0]) cylinder(r=radius, h=z);
  }
}

module rounded_rect_prism_x(depth, size_y, size_z, radius) {
  rotate([0, 90, 0])
    linear_extrude(height=depth)
      offset(r=radius)
        square([size_z-2*radius, size_y-2*radius], center=true);
}

module rear_rect_cutout(y_center, z_center, opening_y, opening_z) {
  translate([-0.2, y_center-opening_y/2, z_center-opening_z/2])
    cube([wall+0.4, opening_y, opening_z]);
}

// Larger at the outside face so the molded plug shoulder does not hit the wall.
module rear_usb_plug_passage(z_offset=0) {
  hull() {
    translate([-0.6, usb_center_y, usb_center_z-z_offset])
      rounded_rect_prism_x(
        0.8,
        usb_open_y+2*usb_outer_flare,
        usb_open_z+2*usb_outer_flare,
        usb_corner_r
      );
    translate([wall-0.2, usb_center_y, usb_center_z-z_offset])
      rounded_rect_prism_x(
        0.8,
        usb_open_y,
        usb_open_z,
        usb_corner_r
      );
  }
}

module pcb_standoffs(origin_x=pcb_origin_x, origin_y=pcb_origin_y, support_z=floor_t) {
  for (p = pcb_holes) {
    translate([origin_x+p[0], origin_y+p[1], support_z-0.2]) {
      // Overlap the floor so the exported STL is one connected printable body.
      cylinder(d=pcb_standoff_d, h=pcb_standoff_h+0.2);
      cylinder(d=pcb_pin_d, h=pcb_standoff_h+pcb_t+0.8);
      translate([0, 0, pcb_standoff_h+pcb_t+0.6])
        cylinder(d1=pcb_pin_d, d2=pcb_pin_tip_d, h=0.8);
    }
  }
}

module base_lug_bosses() {
  for (ly = [left_lug_y, right_lug_y]) {
    difference() {
      translate([lug_x, ly, 0]) cylinder(d=lug_d, h=seam_z);
      translate([lug_x, ly, seam_z-8.0])
        cylinder(d=screw_pilot_d, h=8.2);
    }
  }
}

module top_lug_plates() {
  for (ly = [left_lug_y, right_lug_y]) {
    difference() {
      translate([lug_x, ly, 0]) cylinder(d=lug_d, h=lug_plate_t);
      translate([lug_x, ly, -0.1])
        cylinder(d=screw_clearance_d, h=lug_plate_t+0.2);
      translate([lug_x, ly, lug_plate_t-screw_head_depth])
        cylinder(d=screw_head_d, h=screw_head_depth+0.2);
    }
  }
}

module base_shell() {
  difference() {
    union() {
      difference() {
        rounded_box([outside_x, outside_y, seam_z], 3.0);
        translate([wall, wall, floor_t])
          rounded_box([inside_x, inside_y, seam_z], 1.2);
      }
      pcb_standoffs();
      base_lug_bosses();
    }
    // If a connector crosses the seam, both halves contribute to its opening.
    rear_rect_cutout(dc_center_y, dc_center_z, dc_open_y, dc_open_z);
    rear_usb_plug_passage(0);
  }
}

module locating_lip() {
  // Ring descends into the bottom tray and carries side loads.
  translate([wall+fit, wall+fit, -lip_h])
    difference() {
      // The 0.2 mm overlap joins the lip to the top-shell walls in the STL.
      rounded_box([inside_x-2*fit, inside_y-2*fit, lip_h+0.2], 1.2);
      translate([lip_t, lip_t, -0.1])
        rounded_box([
          inside_x-2*fit-2*lip_t,
          inside_y-2*fit-2*lip_t,
          lip_h+0.4
        ], 0.8);
    }
}

module sensor_reinforcement_local() {
  local_z = sensor_axis_z-seam_z;
  translate([outside_x-wall, outside_y/2, local_z])
    rotate([0, 90, 0]) cylinder(d=sensor_wall_pad_d, h=wall);
}

module sensor_hole_local() {
  local_z = sensor_axis_z-seam_z;
  translate([outside_x-wall-0.1, outside_y/2, local_z])
    rotate([0, 90, 0]) cylinder(d=sensor_panel_hole_d, h=wall+0.2);
}

module top_shell() {
  difference() {
    union() {
      difference() {
        rounded_box([outside_x, outside_y, top_h], 3.0);
        translate([wall, wall, -0.1])
          rounded_box([inside_x, inside_y, top_h-roof_t+0.1], 1.2);
      }
      locating_lip();
      sensor_reinforcement_local();
      top_lug_plates();
    }
    rear_rect_cutout(
      dc_center_y,
      dc_center_z-seam_z,
      dc_open_y,
      dc_open_z
    );
    rear_usb_plug_passage(seam_z);
    sensor_hole_local();

    // Roof ventilation, kept away from the sensor mounting area.
    for (y = [outside_y*0.28 : 5 : outside_y*0.72])
      translate([outside_x*0.18, y-0.75, top_h-roof_t-0.1])
        cube([outside_x*0.42, 1.5, roof_t+0.2]);
  }
}

module sensor_nut_check() {
  difference() {
    cube([32, 32, 3]);
    translate([16, 16, -0.1])
      cylinder(d=sensor_panel_hole_d, h=3.2);
  }
}

module pcb_fit_coupon() {
  coupon_h = 3.2;
  difference() {
    rounded_box([outside_x, outside_y, coupon_h], 3.0);
    translate([wall, wall, 1.2])
      rounded_box([inside_x, inside_y, coupon_h+0.2], 1.2);
    // Wide rear service opening prevents the provisional connector geometry from
    // invalidating the board-outline and pin-pattern test.
    translate([-0.2, wall+4, 1.2])
      cube([wall+0.4, inside_y-8, coupon_h+0.2]);
  }
  pcb_standoffs(pcb_origin_x, pcb_origin_y, 1.2);
}

module screw_coupon() {
  difference() {
    union() {
      cube([30, 14, 10]);
      translate([15, 7, 9.8])
        linear_extrude(height=1.2)
          text(str(screw_pilot_d, " mm"), size=3, halign="center");
    }
    for (x = [7, 15, 23])
      translate([x, 7, 2]) cylinder(d=screw_pilot_d+(x-15)*0.025, h=8.2);
  }
}

module reference_pcb() {
  color([0.05, 0.35, 0.10, 0.65])
    translate([pcb_origin_x, pcb_origin_y, floor_t+pcb_standoff_h])
      cube([pcb_x, pcb_y, pcb_t]);
}

if (part == "base") {
  base_shell();
} else if (part == "base_preview") {
  // Documentation view: printed bottom only, without the reference PCB.
  color([0.92, 0.66, 0.08, 1.0]) base_shell();
} else if (part == "top") {
  // Printable orientation: roof on the build plate, locating lip upward.
    translate([outside_x, 0, top_h]) rotate([0, 180, 0]) top_shell();
} else if (part == "top_preview") {
  color([0.24, 0.52, 0.78, 1.0]) top_shell();
} else if (part == "pcb_fit_coupon") {
  pcb_fit_coupon();
} else if (part == "sensor_nut_check") {
  sensor_nut_check();
} else if (part == "screw_coupon") {
  screw_coupon();
} else if (part == "enclosure_preview") {
  // Documentation view: empty enclosure with the sensor hole visible.
  color([0.92, 0.66, 0.08, 1.0]) base_shell();
  color([0.24, 0.52, 0.78, 1.0])
    translate([0, 0, seam_z]) top_shell();
} else {
  color([0.72, 0.72, 0.76, 1.0]) base_shell();
  reference_pcb();
  color([0.25, 0.55, 0.85, 0.42])
    translate([0, 0, seam_z+explode]) top_shell();
  color([0.9, 0.65, 0.1, 0.65])
    translate([
      outside_x+sensor_front_protrusion-sensor_body_length,
      outside_y/2,
      sensor_axis_z+explode
    ])
      rotate([0, 90, 0]) cylinder(d=18, h=sensor_body_length);
}
