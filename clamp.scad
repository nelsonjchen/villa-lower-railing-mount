// --- Parametric Mount Bracket ---
// Based on user sketch specifications

// --- Dimensions (Change these if needed) ---
inch = 25.4; // Conversion factor

// Post Dimensions
post_size = 0.5 * inch; // 1/2 inch square posts
post_gap_inches = 3.6; // 3.6 inches between posts
post_gap = post_gap_inches * inch;

// Mount Dimensions
mount_thickness = 5; // Vertical thickness of main top bar
mount_depth = 20; // How wide the bracket is (Y-axis length)
lip_width = 3; // ~3mm overhang for the clamp hook
wall_thickness = 3; // 3mm outer wall thickness

// Camera Mount Dimensions
extension_height = 85; // Extended +Z 85mm for the camera holes

// Bolt Dimensions
bolt_spacing = 52; // 52mm spacing for the camera mount
bolt_diameter = 4.4; // M4 screw (4mm + 0.4mm clearance)

// Tolerance / Clearance
clearance = 1.0;

// Set resolution (keep sphere fn moderate for fast minkowski)
$fn = 60;

// --- Calculations ---
total_width = post_gap + (2 * post_size) + (2 * wall_thickness);
post_start_x = post_gap / 2;

module rails() {
  // Left Rail
  translate([-post_start_x - post_size, -mount_depth, -post_size])
    cube([post_size, mount_depth * 3, post_size]);

  // Right Rail
  translate([post_start_x, -mount_depth, -post_size])
    cube([post_size, mount_depth * 3, post_size]);
}

module mount() {
  difference() {
    // --- 1. Solid Bodies ---
    union() {
      // Top Bar / Bridge
      translate([-total_width / 2, -mount_depth / 2, 0])
        cube([total_width, mount_depth, mount_thickness]);

      // Left Leg Solid (Tapers inwards at bottom for upside-down 3D printing without supports)
      hull() {
        translate([-total_width / 2, -mount_depth / 2, 0])
          cube([wall_thickness + post_size, mount_depth, 0.1]);

        translate([-total_width / 2, -mount_depth / 2, -post_size])
          cube([wall_thickness + post_size, mount_depth, 0.1]);

        translate([-total_width / 2, -mount_depth / 2, -post_size - wall_thickness])
          cube([wall_thickness + post_size + lip_width, mount_depth, 0.1]);
      }

      // Right Leg Solid (Tapers inwards at bottom for upside-down 3D printing)
      hull() {
        translate([post_start_x, -mount_depth / 2, 0])
          cube([post_size + wall_thickness, mount_depth, 0.1]);

        translate([post_start_x, -mount_depth / 2, -post_size])
          cube([post_size + wall_thickness, mount_depth, 0.1]);

        translate([post_start_x - lip_width, -mount_depth / 2, -post_size - wall_thickness])
          cube([lip_width + post_size + wall_thickness, mount_depth, 0.1]);
      }

      // The +Z 85mm Extension Tower (A-frame arch)
      hull() {
        // Base of the tower covering the center span
        translate([-post_start_x, -mount_depth / 2, 0])
          cube([post_gap, mount_depth, mount_thickness]);

        // Top Mount plate for camera holes (+Z 85mm)
        translate([-(bolt_spacing + 24) / 2, -mount_depth / 2, extension_height])
          cube([bolt_spacing + 24, mount_depth, mount_thickness]);
      }
    }

    // --- 2. Minkowski Rail Cutout (Deletes rail shape + clearance from the solid body) ---
    minkowski() {
      rails();
      // A sphere provides beautifully rounded inner corners and exact omnidirectional clearance
      sphere(r=clearance, $fn=16);
    }

    // --- 3. Bolt Holes Subtraction ---
    // Left camera hole at the top
    translate([-bolt_spacing / 2, 0, extension_height - 5])
      cylinder(h=mount_thickness + 15, d=bolt_diameter);

    // Right camera hole at the top
    translate([bolt_spacing / 2, 0, extension_height - 5])
      cylinder(h=mount_thickness + 15, d=bolt_diameter);

    // --- 4. Arch Cutout (Saves material, allows nut access underneath) ---
    hull() {
      // Bottom of the arch
      translate([-(post_start_x - 12), -mount_depth / 2 - 1, mount_thickness + 5])
        cube([(post_start_x - 12) * 2, mount_depth + 2, 0.1]);

      // Top of the arch
      translate([-(bolt_spacing / 2 + 6), -mount_depth / 2 - 1, extension_height])
        cube([(bolt_spacing / 2 + 6) * 2, mount_depth + 2, 0.1]);
    }
  }
}

// --- Render the Part ---
color("lightgrey") mount();

// --- Visual Ghost of the Posts (For debugging/Checking fit) ---
%union() {
  color("orange") rails();

  // Distance Marker (Visual aid for checking bolt spacing)
  // Preserved and moved +85mm up as requested
  translate([-bolt_spacing / 2, 0, extension_height + mount_thickness + 2])
    color("red") cylinder(h=2, d=2);
  translate([bolt_spacing / 2, 0, extension_height + mount_thickness + 2])
    color("red") cylinder(h=2, d=2);
}
